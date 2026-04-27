# AgroAI Testing Strategy

## 1. Machine Learning Model Testing
- **Validation Split**: Model trained on 80% data, validated on 20%.
- **Metrics**: Track Accuracy and Categorical Crossentropy Loss.
- **Confusion Matrix**: Use `scikit-learn` to generate a confusion matrix on a separate test set to identify which diseases are often misclassified (e.g., Early Blight vs Late Blight).

## 2. Backend API Testing
- **Unit Tests**: Use `pytest` and `httpx` to test endpoints.
- **Mock LLM**: Ensure the backend falls back gracefully if the OpenAI API key is missing or quota is exceeded.
- **Image Upload Handling**: Test `/predict` with invalid files (e.g., PDFs, text files) to ensure correct error handling.

## 3. Android App Testing
- **UI Tests (Compose)**: Use Compose testing libraries to ensure UI updates correctly based on ViewModel state (Loading -> Success/Error).
- **Network Resilience**: Test app behavior with no internet connection. Verify that Retrofit errors are properly mapped to the UI.
- **Low Confidence Flow**: Ensure that if confidence is <70%, the warning text appears in red as required by the specification.
