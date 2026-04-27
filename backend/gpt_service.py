import base64
import os
import json
from openai import OpenAI
from dotenv import load_dotenv

# Load environment variables
load_dotenv(override=True)

# Initialize OpenAI client
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def encode_image(image_path):
    """Encodes an image to a base64 string."""
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def analyze_image_with_gpt(image_path):
    """
    Sends an image to GPT Vision API and returns structured plant disease analysis.
    """
    base64_image = encode_image(image_path)

    prompt = (
        "Analyze this plant image and provide a detailed diagnosis in JSON format. "
        "The JSON should have the following keys: "
        "plant, disease, confidence, description, cause, solution. "
        "If the plant is healthy, set 'disease' to 'Healthy'. "
        "Confidence should be a percentage string (e.g., '95%'). "
        "Ensure the output is ONLY the JSON object, nothing else."
    )

    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}",
                            },
                        },
                    ],
                }
            ],
            max_tokens=500,
            response_format={"type": "json_object"}
        )

        # Parse the JSON response
        result_text = response.choices[0].message.content
        result_json = json.loads(result_text)
        
        # Add the decision field as requested
        result_json["decision"] = "gpt_result"
        
        return result_json

    except Exception as e:
        print(f"Error in GPT analysis: {e}")
        return None
