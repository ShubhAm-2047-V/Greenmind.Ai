# AgroAI Deployment Guide

## Backend Deployment (AWS EC2 / Render)

### Option 1: Docker (Recommended)
1. Ensure `Dockerfile` is present in the `backend/` directory (you can create a simple Python 3.10 slim Dockerfile).
2. Build the image: `docker build -t agroai-backend .`
3. Run the container: `docker run -p 8000:8000 -e OPENAI_API_KEY="your-key" agroai-backend`

### Option 2: Render.com
1. Push your code to a GitHub repository.
2. Create a new "Web Service" on Render.
3. Select your repository.
4. Set the Build Command: `pip install -r requirements.txt`
5. Set the Start Command: `uvicorn main:app --host 0.0.0.0 --port $PORT`
6. Add Environment Variable: `OPENAI_API_KEY` = your API key.

## Model Serving
The TensorFlow `.h5` model must be placed in the `ml_training` directory (or wherever configured in `ml_service.py`). For cloud deployment, it is often better to load the model from an S3 bucket on startup to keep the repository size small.

## Android App Deployment
1. Open `AgroAI/android_app` in Android Studio.
2. In `RetrofitInstance.kt`, update `BASE_URL` to your production backend URL (e.g., `https://agroai-backend.onrender.com`).
3. Generate Signed APK: `Build > Generate Signed Bundle / APK`.
4. Deploy the APK to devices for testing.
