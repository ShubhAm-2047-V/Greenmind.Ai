import os
import json
import google.generativeai as genai
from PIL import Image
from dotenv import load_dotenv

# Load environment variables
load_dotenv(override=True)

# Load all available Gemini API keys from environment
def get_gemini_keys():
    keys = []
    # Check for the primary key first
    primary = os.getenv("GEMINI_API_KEY")
    if primary and primary != "YOUR_GEMINI_API_KEY_HERE":
        keys.append(primary)
    
    # Check for additional keys (GEMINI_API_KEY_1, GEMINI_API_KEY_2, etc.)
    for i in range(1, 11): # Support up to 10 extra keys
        k = os.getenv(f"GEMINI_API_KEY_{i}")
        if k:
            keys.append(k)
    return keys

GEMINI_KEYS = get_gemini_keys()

def analyze_image_with_gemini(image_path, language="english"):
    """
    Sends an image to Gemini 3 Flash API and returns structured plant disease analysis.
    Rotates through available keys if quota is reached.
    """
    if not GEMINI_KEYS:
        print("No Gemini API keys found.")
        return None

    try:
        img = Image.open(image_path)
    except Exception as e:
        print(f"Error opening image: {e}")
        return None
    
    for key in GEMINI_KEYS:
        try:
            genai.configure(api_key=key)
            model = genai.GenerativeModel('gemini-flash-latest')

            prompt = (
                "FIRST: Determine if this image contains a plant, leaf, flower, or tree. "
                "Then provide a detailed diagnosis in JSON format with the following keys: "
                "is_plant (boolean), plant, disease, confidence, description, cause, solution. "
                "If it is NOT a plant, set 'is_plant' to false and all other text fields to an empty string. "
                "If it IS a plant, set 'is_plant' to true and fill the other fields. "
                f"CRITICAL: The user's language is {language.upper()}. "
                f"You MUST translate EVERYTHING (plant name, disease name, description, cause, and solution) into {language.upper()}. "
                f"DO NOT use any English words. Even if the disease name is common in English, provide the {language.upper()} translation or transliteration. "
                "If the plant is healthy, set 'disease' to 'Healthy' (but in the requested language). "
                "Confidence should be a percentage string (e.g., '95%'). "
                "Explain the description, cause, and solution in simple, everyday language. "
                "Ensure the output is ONLY the JSON object, nothing else."
            )

            # Generate content with JSON constraint
            response = model.generate_content(
                [prompt, img],
                generation_config={"response_mime_type": "application/json"}
            )

            # Parse the JSON response
            result_text = response.text
            result_json = json.loads(result_text)
            result_json["decision"] = "gemini_result"
            return result_json

        except Exception as e:
            error_msg = str(e).lower()
            if "429" in error_msg or "quota" in error_msg:
                print(f"API Key Quota reached for key ending in ...{key[-4:]}. Trying next key...")
                continue
            else:
                print(f"Gemini error with key ending in ...{key[-4:]}: {e}")
                continue
    
    print("All Gemini API keys failed or exhausted.")
    return None

def chat_with_gemini(message, context=None, language="english"):
    """
    Sends a text message to Gemini and returns the response.
    Rotates through available keys if quota is reached.
    """
    if not GEMINI_KEYS:
        return "No Gemini API keys found."

    for key in GEMINI_KEYS:
        try:
            genai.configure(api_key=key)
            model = genai.GenerativeModel('gemini-flash-latest')
            
            system_prompt = (
                f"You are GreenMind AI, a friendly and helpful neighborhood gardener. "
                f"Your goal is to help people take care of their plants using simple, easy-to-follow advice. "
                f"RESPONSE LANGUAGE: {language.upper()}. "
                f"Everything you say MUST be in {language.upper()}. "
                f"CRITICAL: Do not use any English words. Even technical terms should be explained or transliterated in {language.upper()}. "
                "Talk like a person, avoid using too much bold text or complex symbols. "
                "Use simple words, like you're talking to a friend who just started gardening. "
                "If the user is worried, be very encouraging and tell them their plant can be saved! "
            )
            if context:
                system_prompt += (
                    f"\n\nIMPORTANT CONTEXT: The user has just analyzed a plant with your app. "
                    f"The analysis results are: {context}. "
                    "Refer to these details if the user asks for more information or clarification."
                )
            
            response = model.generate_content(f"{system_prompt}\n\nUser: {message}")
            if response and response.text:
                text = response.text
                text = text.replace("â€™", "'").replace("â€˜", "'").replace("â€ ", "\"").replace("â€œ", "\"")
                text = text.replace("\u2019", "'").replace("\u2018", "'").replace("\u201d", "\"").replace("\u201c", "\"")
                return text
            continue

        except Exception as e:
            error_msg = str(e).lower()
            if "429" in error_msg or "quota" in error_msg:
                print(f"Chat API Key Quota reached for key ending in ...{key[-4:]}. Trying next...")
                continue
            else:
                print(f"Gemini chat error with key ending in ...{key[-4:]}: {e}")
                continue

    return "Sorry, all my API connections are busy or exhausted right now. Please try again later."
