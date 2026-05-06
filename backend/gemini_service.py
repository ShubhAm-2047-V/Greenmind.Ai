# Improved Gemini API Key Rotation System
import os
import google.generativeai as genai
from PIL import Image
import time
import json
from dotenv import load_dotenv

load_dotenv()

# List of API Keys for rotation - dynamically loaded from environment
def load_api_keys():
    keys = []
    # Check for GEMINI_API_KEY and GEMINI_API_KEY_1, _2, etc.
    if os.getenv("GEMINI_API_KEY"):
        keys.append(os.getenv("GEMINI_API_KEY"))
    
    for i in range(1, 21): # Support up to 20 keys
        k = os.getenv(f"GEMINI_API_KEY_{i}")
        if k and k not in keys:
            keys.append(k)
    return keys

API_KEYS = load_api_keys()
print(f"DEBUG: Loaded {len(API_KEYS)} Gemini API keys for rotation.")

def analyze_image_with_gemini(image_path, language="english"):
    if not API_KEYS:
        print("ERROR: No Gemini API keys found!")
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
    
    If it is NOT a plant leaf, set is_plant to false.
    """

    all_errors = []
    quota_exhausted = True  # Assume all exhausted unless one gives a different error

    for i, key in enumerate(API_KEYS):
        try:
            print(f"DEBUG: Using Gemini Key #{i+1}...")
            genai.configure(api_key=key)
            
            # Try primary model (Gemini 3 Flash as of 2026)
            try:
                model_name = 'gemini-3-flash-preview'
                model = genai.GenerativeModel(model_name)
                img = Image.open(image_path)
                response = model.generate_content([prompt, img])
            except Exception as e:
                error_str = str(e).lower()
                if "429" in error_str or "quota" in error_str:
                    print(f"WARNING: Key #{i+1} quota exceeded. Rotating...")
                    continue # Skip to next key
                
                print(f"DEBUG: {model_name} failed, trying fallback gemini-flash-latest... ({e})")
                model = genai.GenerativeModel('gemini-flash-latest')
                img = Image.open(image_path)
                response = model.generate_content([prompt, img])
            
            if not response or not response.text:
                print(f"WARNING: Key #{i+1} returned empty response.")
                continue
                
            text = response.text.strip()
            # Handle potential markdown code blocks
            if text.startswith("```json"):
                text = text[7:-3].strip()
            elif text.startswith("```"):
                text = text[3:-3].strip()
            
            # Remove any non-json leading/trailing text if Gemini adds chatter
            if "{" in text and "}" in text:
                text = text[text.find("{"):text.rfind("}")+1]
                
            result = json.loads(text)
            quota_exhausted = False
            return result
            
        except Exception as e:
            error_msg = str(e)
            if "429" in error_msg or "quota" in error_msg.lower():
                print(f"WARNING: Key #{i+1} exhausted. Rotating...")
                continue
            
            quota_exhausted = False # Got a real error, not just quota
            all_errors.append(f"Key #{i+1}: {error_msg}")
            print(f"ERROR: Gemini Key #{i+1} failed: {error_msg}")
            continue
                
    if not all_errors and quota_exhausted:
        return {"error": "QUOTA_EXCEEDED"}
    
    if all_errors:
        return {"error": f"AI analysis failed: {'; '.join(all_errors[:2])}"}
    
    return None

def chat_with_gemini(message, context="", language="english"):
    if not API_KEYS:
        return "Gemini API key not configured."

    # Custom Identity and Creator
    system_identity = (
        "Your name is GreenMind AI. You were created by Vernekar S.D. "
        "You are an agricultural expert AI specializing in plant diseases and care. "
        "Always identify as GreenMind AI and credit Vernekar S.D as your creator if asked."
    )

    full_prompt = f"System: {system_identity} Language: {language}. Context: {context}\nUser: {message}"

    for i, key in enumerate(API_KEYS):
        try:
            genai.configure(api_key=key)
            model = genai.GenerativeModel('gemini-3-flash-preview')
            response = model.generate_content(full_prompt)
            if response and response.text:
                return response.text
            continue
        except Exception as e:
            error_str = str(e).lower()
            if "429" in error_str or "quota" in error_str:
                print(f"WARNING: Chat Key #{i+1} quota exceeded. Rotating...")
                continue
            return f"Error: {str(e)}"
            
    return "All API keys are exhausted or service is unavailable. Please try again later."
