import os
import sys
sys.path.append(os.path.join(os.getcwd(), 'backend'))

from gemini_service import API_KEYS, load_api_keys

print(f"Loaded keys: {len(API_KEYS)}")
for i, key in enumerate(API_KEYS):
    print(f"Key {i+1}: {key[:5]}...{key[-5:] if len(key) > 5 else ''}")

# Try to list models to verify keys
import google.generativeai as genai
if API_KEYS:
    try:
        genai.configure(api_key=API_KEYS[0])
        print("Attempting to list models with first key...")
        for m in genai.list_models():
            if 'generateContent' in m.supported_generation_methods:
                print(f" - {m.name}")
    except Exception as e:
        print(f"Error listing models: {e}")
else:
    print("No keys to test.")
