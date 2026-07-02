# GreenMind AI Backend - SMTP & Stability Update
import os
import uuid
import requests
from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from gemini_service import analyze_image_with_gemini, chat_with_gemini
from plantid_service import analyze_image_with_plantid
from PIL import Image
import io
from supabase import create_client, Client
from auth_utils import get_password_hash, verify_password, create_access_token
from email_service import send_analysis_report
from dotenv import load_dotenv

def sanitize_for_pdf(text):
    """Remove or replace characters that the default PDF font doesn't support."""
    if not text: return ""
    # Convert to string and handle basic unicode to latin-1
    try:
        # Try to encode as latin-1 to see if it's supported
        text.encode('latin-1')
        return text
    except UnicodeEncodeError:
        # Fallback: remove non-latin characters for the PDF report
        import re
        return re.sub(r'[^\x00-\xFF]+', '?', str(text))

load_dotenv()

app = FastAPI(title="Plant Disease Detection AI")

# Safer Supabase Initialization
def get_supabase() -> Client:
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    if not url or not key:
        return None
    try:
        return create_client(url, key)
    except Exception:
        return None

supabase = get_supabase()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/register")
async def register(request: dict):
    if not supabase:
        return JSONResponse(status_code=500, content={"error": "Database not connected"}, media_type="application/json; charset=utf-8")
    
    email = request.get("email")
    password = request.get("password")
    
    if not email or not password:
        return JSONResponse(status_code=400, content={"error": "Email and password are required"}, media_type="application/json; charset=utf-8")
    
    try:
        response = supabase.table("users").select("*").eq("email", email).execute()
        if response.data:
            return JSONResponse(status_code=400, content={"error": "User already exists"}, media_type="application/json; charset=utf-8")
        
        hashed_password = get_password_hash(password)
        new_user = {"email": email, "password": hashed_password}
        supabase.table("users").insert(new_user).execute()
        return {"message": "User registered successfully"}
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

@app.post("/login")
async def login_route(request: dict):
    if not supabase:
        return JSONResponse(status_code=500, content={"error": "Database not connected"})
    
    email = request.get("email")
    password = request.get("password")
    
    if not email or not password:
        return JSONResponse(status_code=400, content={"error": "Email and password are required"})
    
    try:
        response = supabase.table("users").select("*").eq("email", email).execute()
        if not response.data:
            return JSONResponse(status_code=401, content={"error": "Invalid credentials"})
        
        user = response.data[0]
        if not verify_password(password, user["password"]):
            return JSONResponse(status_code=401, content={"error": "Invalid credentials"})
        
        access_token = create_access_token(data={"sub": email})
        return {"access_token": access_token, "token_type": "bearer", "email": email}
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

@app.get("/weather")
async def get_weather(city: str = "solapur"):
    api_key = os.getenv("WEATHER_API_KEY")
    url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric"
    try:
        response = requests.get(url)
        return JSONResponse(content=response.json())
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)}, media_type="application/json; charset=utf-8")

@app.post("/analyze")
async def analyze_plant(
    image: UploadFile = File(...),
    language: str = Form("english"),
    email: str = Form(None)
):
    import tempfile
    temp_dir = tempfile.gettempdir()
    temp_path = os.path.join(temp_dir, f"temp_{uuid.uuid4()}.jpg")
    
    try:
        contents = await image.read()
        with open(temp_path, "wb") as f:
            f.write(contents)
        
        result = analyze_image_with_gemini(temp_path, language=language)
        
        if os.path.exists(temp_path):
            os.remove(temp_path)
            
        if not result:
            return JSONResponse(status_code=500, content={"error": "AI analysis failed (Empty result)"})
            
        if isinstance(result, dict) and "error" in result:
            if result.get("error") == "QUOTA_EXCEEDED":
                return JSONResponse(status_code=429, content={"error": "You  have hit the limit retry after and hr"})
            return JSONResponse(status_code=500, content=result)
        
        # Save to history and send email (in separate try blocks to prevent cross-failure)
        email_status = "Not requested"
        history_status = "Not requested"
        
        if email:
            # 1. Try to save to Supabase History
            try:
                if supabase:
                    # Sanitize confidence (Gemini often returns "95%")
                    conf_val = result.get("confidence", 0.95)
                    if isinstance(conf_val, str):
                        try:
                            if "%" in conf_val:
                                conf_val = float(conf_val.replace("%", "").strip()) / 100.0
                            else:
                                conf_val = float(conf_val.strip())
                        except:
                            conf_val = 0.95
                    
                    scan_data = {
                        "user_email": email,
                        "plant_name": result.get("plant", "Unknown"),
                        "disease_name": result.get("disease", "Healthy"),
                        "confidence": conf_val,
                        "description": result.get("description", ""),
                        "cause": result.get("cause", ""),
                        "solution": result.get("solution", "")
                    }
                    save_res = supabase.table("scans").insert(scan_data).execute()
                    if save_res.data:
                        history_status = "Saved successfully"
                        print(f"DEBUG: Saved to history for {email}")
                    else:
                        history_status = "Failed to save (No data returned)"
                else:
                    history_status = "Database not connected"
            except Exception as db_e:
                print(f"WARNING: Supabase history save failed: {db_e}")
                history_status = f"Database Error: {str(db_e)}"
            
            # 2. Try to send Email Report
            try:
                success = send_analysis_report(email, result)
                email_status = "Sent successfully" if success else "Failed to send (Check SMTP)"
            except Exception as mail_e:
                print(f"WARNING: Email report failed: {mail_e}")
                email_status = f"Email Error: {str(mail_e)}"
        
        result["email_status"] = email_status
        result["history_status"] = history_status
        return JSONResponse(content=result, media_type="application/json; charset=utf-8")
    except Exception as e:
        if os.path.exists(temp_path):
            os.remove(temp_path)
        return JSONResponse(status_code=500, content={"error": str(e)})

@app.get("/history")
async def get_history(email: str):
    if not supabase:
        return JSONResponse(status_code=500, content={"error": "Database not connected"})
    
    try:
        # Use ilike for case-insensitive email matching
        response = supabase.table("scans").select("*").ilike("user_email", email).order("created_at", desc=True).execute()
        return JSONResponse(content=response.data, media_type="application/json; charset=utf-8")
    except Exception as e:
        import traceback
        error_details = traceback.format_exc()
        print(f"ERROR in get_history: {error_details}")
        return JSONResponse(status_code=500, content={"error": str(e), "details": "Check server logs for traceback"}, media_type="application/json; charset=utf-8")

@app.get("/debug_scans")
async def debug_scans():
    if not supabase: return {"error": "No DB"}
    try:
        res = supabase.table("scans").select("*").limit(5).execute()
        return {"count": len(res.data), "first_rows": res.data}
    except Exception as e:
        return {"error": str(e)}

@app.post("/chat")
async def chat_bot(request: dict):
    message = request.get("message")
    context = request.get("context", "")
    language = request.get("language", "english")
    response_text = chat_with_gemini(message, context=context, language=language)
    return JSONResponse(content={"response": response_text}, media_type="application/json; charset=utf-8")

@app.get("/health")
def health_check():
    return {"status": "ok", "db_connected": supabase is not None, "version": "1.0.5"}

@app.get("/")
def read_root():
    return {"message": "GreenMind AI API is running", "version": "1.0.5"}
