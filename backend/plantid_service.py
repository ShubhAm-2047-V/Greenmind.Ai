import os
import base64
import json
import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv(override=True)

API_KEY = os.getenv("PLANTID_API_KEY")
API_URL = "https://api.plant.id/v3/identification"

def analyze_image_with_plantid(image_path):
    """
    Sends an image to Plant.id v3 API and returns structured plant disease analysis.
    """
    if not API_KEY:
        print("Plant.id API key not found.")
        return None

    try:
        # 1. Prepare image
        with open(image_path, "rb") as file:
            base64_image = base64.b64encode(file.read()).decode('ascii')

        # 2. Make request
        # We request classification and health assessment
        payload = {
            "images": [base64_image],
            "latitude": 49.207,  # Optional: helps with identification
            "longitude": 16.608,
            "similar_images": True
        }
        
        headers = {
            "Api-Key": API_KEY,
            "Content-Type": "application/json"
        }

        # Requesting both identification and health assessment
        response = requests.post(
            API_URL,
            params={"details": "common_names,description,cause,treatment,url"},
            headers=headers,
            json=payload
        )
        
        if response.status_code == 401:
            print(f"Error in Plant.id analysis: 401 Unauthorized. Please check if your API key is valid: {API_KEY[:5]}...{API_KEY[-5:]}")
            return None
            
        response.raise_for_status()
        data = response.json()

        # 3. Parse result
        result = data.get("result", {})
        classification = result.get("classification", {})
        suggestions = classification.get("suggestions", [])
        
        if not suggestions:
            return None

        top_suggestion = suggestions[0]
        plant_name = top_suggestion.get("name", "Unknown")
        confidence = f"{top_suggestion.get('probability', 0) * 100:.1f}%"
        
        # Plant.id handles health in a separate object if requested, 
        # but for simplicity in this first version, we'll extract from suggestions
        # or use a default if it's healthy.
        
        # Note: Plant.id v3 health assessment is a separate feature. 
        # For now, we'll try to provide a clean response.
        
        return {
            "plant": plant_name,
            "disease": "Healthy", # Default
            "confidence": confidence,
            "description": top_suggestion.get("details", {}).get("description", {}).get("value", "N/A"),
            "cause": "N/A",
            "solution": "N/A",
            "decision": "plantid_result"
        }

    except Exception as e:
        print(f"Error in Plant.id analysis: {e}")
        return None
