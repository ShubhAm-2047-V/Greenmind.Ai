import os
import google.generativeai as genai
from PIL import Image
import time
import json
from dotenv import load_dotenv

load_dotenv()

# List of API Keys for rotation
API_KEYS = [
    os.getenv("GEMINI_API_KEY"),
    os.getenv("GEMINI_API_KEY_1"),
    os.getenv("GEMINI_API_KEY_2"),
    os.getenv("GEMINI_API_KEY_3"),
    os.getenv("GEMINI_API_KEY_4"),
    os.getenv("GEMINI_API_KEY_5"),
    os.getenv("GEMINI_API_KEY_6"),
    os.getenv("GEMINI_API_KEY_7"),
    os.getenv("GEMINI_API_KEY_8"),
    os.getenv("GEMINI_API_KEY_9"),
    os.getenv("GEMINI_API_KEY_10"),
]

# Filter out empty keys
API_KEYS = [k for k in API_KEYS if k]
print(f"DEBUG: Found {len(API_KEYS)} Gemini API keys.")

def analyze_image_with_gemini(image_path, language="english"):
    if not API_KEYS:
        print("ERROR: No Gemini API keys found in .env!")
        return None

    prompt = f"""
    Analyze this plant leaf image and provide a detailed report in JSON format.
    The response must be in {language}.
    
    JSON structure:
    {{
        "is_plant": boolean,
        "plant": "name of the plant",
        "disease": "name of the disease or 'Healthy'",
        "confidence": "95%", 
        "description": "brief description",
        "cause": "what caused this",
        "solution": "how to fix it"
    }}
    
    Note: confidence should be a string (e.g. "95%").
    
    If it is NOT a plant leaf, set is_plant to false.
    """

    all_errors = []
    for i, key in enumerate(API_KEYS):
        try:
            print(f"DEBUG: Trying Gemini API Key #{i+1}...")
            genai.configure(api_key=key)
            
            try:
                model = genai.GenerativeModel('gemini-1.5-flash')
                img = Image.open(image_path)
                response = model.generate_content([prompt, img])
            except Exception as e:
                print(f"DEBUG: gemini-2.5-flash failed, trying 2.0-flash... ({e})")
                model = genai.GenerativeModel('gemini-2.0-flash')
                img = Image.open(image_path)
                response = model.generate_content([prompt, img])
            
            if not response or not response.text:
                print(f"WARNING: Key #{i+1} returned empty response.")
                continue
                
            # Clean up the response
            text = response.text.strip()
            if text.startswith("```json"):
                text = text[7:-3].strip()
            elif text.startswith("```"):
                text = text[3:-3].strip()
                
            return json.loads(text)
            
        except Exception as e:
            error_msg = str(e)
            all_errors.append(error_msg)
            print(f"ERROR: Gemini Key #{i+1} failed: {error_msg}")
            continue
                
    if any("429" in err or "quota" in err.lower() for err in all_errors):
        return {"error": "QUOTA_EXCEEDED"}
    
    print("CRITICAL: All Gemini API keys failed!")
    return None

def chat_with_gemini(message, context="", language="english"):
    if not API_KEYS:
        return "Gemini API key not configured."

    full_prompt = f"System: You are an agricultural expert AI. Help the user with their plants. Language: {language}. Context: {context}\nUser: {message}"

    for i, key in enumerate(API_KEYS):
        try:
            genai.configure(api_key=key)
            model = genai.GenerativeModel('gemini-2.5-flash')
            response = model.generate_content(full_prompt)
            return response.text
        except Exception as e:
            if "429" in str(e) or "quota" in str(e).lower():
                continue
            return f"Error: {str(e)}"
            
    return "All API keys are exhausted. Please try again later."
