import os
import shutil
import uuid
import requests
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from gpt_service import analyze_image_with_gpt
from gemini_service import analyze_image_with_gemini, chat_with_gemini
from plantid_service import analyze_image_with_plantid
from PIL import Image
import io

app = FastAPI(title="Plant Disease Detection AI")

# Add CORS middleware to allow testing from Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

import tempfile

# Ensure temp directory exists
TEMP_DIR = tempfile.gettempdir()

@app.post("/predict")
async def predict(file: UploadFile = File(...), provider: str = "gemini", language: str = "english"):
    """
    Endpoint to receive an image and return plant disease analysis.
    Supports provider='gpt' or provider='gemini' (default).
    """
    # 1. Validate image
    try:
        content = await file.read()
        image = Image.open(io.BytesIO(content))
        image.verify()  # Check if it's a valid image
    except Exception:
        return JSONResponse(
            status_code=400,
            content={"decision": "invalid_image"}
        )

    # 2. Save temporarily
    file_extension = os.path.splitext(file.filename)[1]
    if not file_extension:
        file_extension = ".jpg"
    
    temp_filename = f"{uuid.uuid4()}{file_extension}"
    temp_path = os.path.join(TEMP_DIR, temp_filename)
    
    with open(temp_path, "wb") as buffer:
        buffer.write(content)

    try:
        # 3. Process with selected provider
        if provider.lower() == "gpt":
            result = analyze_image_with_gpt(temp_path)
        elif provider.lower() == "plantid":
            result = analyze_image_with_plantid(temp_path)
        else:
            # Default to Gemini
            result = analyze_image_with_gemini(temp_path, language=language)
            
            # Fallback chain: Gemini -> Plant.id -> GPT
            if not result and os.getenv("PLANTID_API_KEY"):
                print("Gemini failed, falling back to Plant.id...")
                result = analyze_image_with_plantid(temp_path)
            
            if not result and os.getenv("OPENAI_API_KEY"):
                print("Falling back to GPT...")
                result = analyze_image_with_gpt(temp_path)
        
        if not result:
            return JSONResponse(
                status_code=500,
                content={"error": f"{provider} analysis failed and no fallback available"},
                media_type="application/json; charset=utf-8"
            )
            
        # Log which API was used for success
        used_api = result.get("decision", "unknown").replace("_result", "").upper()
        print(f"SUCCESS: Analysis completed using {used_api} API")
            
        return JSONResponse(content=result, media_type="application/json; charset=utf-8")

    finally:
        # 4. Cleanup: Delete temp file
        if os.path.exists(temp_path):
            os.remove(temp_path)

@app.get("/weather")
async def get_weather(city: str = "New Delhi"):
    """
    Fetch weather data for a given city using OpenWeatherMap.
    """
    api_key = os.getenv("WEATHER_API_KEY")
    if not api_key:
        return JSONResponse(
            status_code=500,
            content={"error": "Weather API key not configured on server"},
            media_type="application/json; charset=utf-8"
        )

    url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric"
    
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            return JSONResponse(content=response.json(), media_type="application/json; charset=utf-8")
        else:
            return JSONResponse(
                status_code=response.status_code,
                content={"error": f"Weather API returned {response.status_code}"},
                media_type="application/json; charset=utf-8"
            )
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": str(e)},
            media_type="application/json; charset=utf-8"
        )

@app.post("/chat")
async def chat(request: dict):
    """
    Endpoint for the chatbot.
    Expects {"message": "...", "context": "...", "language": "..."}
    """
    message = request.get("message")
    context = request.get("context")
    language = request.get("language", "english")
    
    if not message:
        return JSONResponse(
            status_code=400, 
            content={"error": "Message is required"},
            media_type="application/json; charset=utf-8"
        )
    
    response_text = chat_with_gemini(message, context, language=language)
    return JSONResponse(
        content={"response": response_text},
        media_type="application/json; charset=utf-8"
    )

@app.get("/")
def read_root():
    return JSONResponse(
        content={"message": "Plant Disease Detection API is running. Use POST /predict to analyze images."},
        media_type="application/json; charset=utf-8"
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
