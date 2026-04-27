import os
import shutil
import uuid
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from gpt_service import analyze_image_with_gpt
from gemini_service import analyze_image_with_gemini
from plantid_service import analyze_image_with_plantid
from PIL import Image
import io

app = FastAPI(title="Plant Disease Detection AI")

# Ensure temp directory exists
TEMP_DIR = "temp"
if not os.path.exists(TEMP_DIR):
    os.makedirs(TEMP_DIR)

@app.post("/predict")
async def predict(file: UploadFile = File(...), provider: str = "gemini"):
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
            result = analyze_image_with_gemini(temp_path)
            
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
                content={"error": f"{provider} analysis failed and no fallback available"}
            )
            
        # Log which API was used for success
        used_api = result.get("decision", "unknown").replace("_result", "").upper()
        print(f"SUCCESS: Analysis completed using {used_api} API")
            
        return result

    finally:
        # 4. Cleanup: Delete temp file
        if os.path.exists(temp_path):
            os.remove(temp_path)

@app.get("/")
def read_root():
    return {"message": "Plant Disease Detection API is running. Use POST /predict to analyze images."}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
