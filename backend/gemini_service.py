import os
import json
import google.generativeai as genai
from PIL import Image
from dotenv import load_dotenv

# Load environment variables
load_dotenv(override=True)

# Initialize Gemini API
api_key = os.getenv("GEMINI_API_KEY")
if api_key:
    genai.configure(api_key=api_key)

def analyze_image_with_gemini(image_path, language="english"):
    """
    Sends an image to Gemini 3 Flash API and returns structured plant disease analysis.
    """
    if not api_key:
        print("Gemini API key not found.")
        return None

    try:
        # Load the image
        img = Image.open(image_path)

        # Initialize the model (using latest available version)
        model = genai.GenerativeModel('gemini-flash-latest')

        prompt = (
            "Analyze this plant image and provide a detailed diagnosis in JSON format. "
            "The JSON should have the following keys: "
            "plant, disease, confidence, description, cause, solution. "
            "If the plant is healthy, set 'disease' to 'Healthy'. "
            "Confidence should be a percentage string (e.g., '95%'). "
            f"RESPONSE LANGUAGE: {language.upper()}. "
            f"Crucial: All text fields (plant, disease, description, cause, solution) MUST be in {language.upper()}. "
            "Explain the description, cause, and solution in simple, everyday language that a beginner gardener can easily understand. "
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
        
        # Add the decision field as requested
        result_json["decision"] = "gemini_result"
        
        return result_json

    except Exception as e:
        print(f"Error in Gemini analysis: {e}")
        return None
def chat_with_gemini(message, context=None, language="english"):
    """
    Sends a text message to Gemini and returns the response.
    Can take optional context (e.g. disease info) to make it context-aware.
    """
    # Use CHATBOT_API_KEY if available, else fallback to GEMINI_API_KEY
    current_api_key = os.getenv("CHATBOT_API_KEY")
    if not current_api_key or current_api_key == "YOUR_CHATBOT_API_KEY_HERE":
        current_api_key = os.getenv("GEMINI_API_KEY")

    if not current_api_key:
        return "Chatbot API key not configured."

    try:
        genai.configure(api_key=current_api_key)
        model = genai.GenerativeModel('gemini-flash-latest')
        
        system_prompt = (
            f"You are GreenMind AI, a friendly and helpful neighborhood gardener. "
            f"Your goal is to help people take care of their plants using simple, easy-to-follow advice. "
            f"RESPONSE LANGUAGE: {language.upper()}. "
            f"Everything you say MUST be in {language.upper()}. "
            "Talk like a real person, avoid using too much bold text or complex symbols. "
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
            # Clean up encoding issues (e.g., smart quotes causing â)
            text = response.text
            text = text.replace("â", "'").replace("â", "'").replace("â", "\"").replace("â", "\"")
            # Also handle common Unicode smart quotes directly
            text = text.replace("\u2019", "'").replace("\u2018", "'").replace("\u201d", "\"").replace("\u201c", "\"")
            return text
        return "I processed your request but didn't generate a text response. Please try rephrasing."

    except Exception as e:
        print(f"Error in Gemini chat: {e}")
        return "Sorry, I am having trouble connecting to my brain right now."
