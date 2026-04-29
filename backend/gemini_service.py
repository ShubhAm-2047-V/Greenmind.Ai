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

def analyze_image_with_gemini(image_path):
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
            "Explain the description, cause, and solution in simple, everyday language that a beginner gardener can easily understand. Avoid overly complex scientific jargon or Latin names unless necessary. "
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
def chat_with_gemini(message, context=None):
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
        
        system_prompt = "You are GreenMind AI, a helpful plant care and disease expert. Keep your answers concise and friendly."
        if context:
            system_prompt += f" Context: The user is asking about a plant with the following details: {context}."
        
        response = model.generate_content(f"{system_prompt}\n\nUser: {message}")
        return response.text

    except Exception as e:
        print(f"Error in Gemini chat: {e}")
        return "Sorry, I am having trouble connecting to my brain right now."
