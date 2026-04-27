package com.agroai.app.viewmodel

import android.content.Context
import android.net.Uri
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.agroai.app.model.RecommendationRequest
import com.agroai.app.model.RecommendationResponse
import com.agroai.app.network.RetrofitInstance
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File

sealed class UIState {
    object Idle : UIState()
    object Loading : UIState()
    data class Success(
        val disease: String, 
        val confidence: Double, 
        val recommendation: RecommendationResponse?
    ) : UIState()
    data class Error(val message: String) : UIState()
}

class AgroViewModel : ViewModel() {
    private val _uiState = MutableStateFlow<UIState>(UIState.Idle)
    val uiState: StateFlow<UIState> = _uiState.asStateFlow()
    
    private val _selectedImageUri = MutableStateFlow<Uri?>(null)
    val selectedImageUri = _selectedImageUri.asStateFlow()

    fun setImageUri(uri: Uri?) {
        _selectedImageUri.value = uri
    }

    fun analyzeImage(context: Context, uri: Uri) {
        viewModelScope.launch {
            _uiState.value = UIState.Loading
            try {
                // 1. Prepare File for upload
                val file = getFileFromUri(context, uri)
                if (file == null) {
                    _uiState.value = UIState.Error("Failed to process image.")
                    return@launch
                }
                
                val requestFile = file.asRequestBody("image/*".toMediaTypeOrNull())
                val body = MultipartBody.Part.createFormData("file", file.name, requestFile)

                // 2. Call Predict API
                val predictResponse = RetrofitInstance.api.predictDisease(body)
                if (predictResponse.isSuccessful && predictResponse.body() != null) {
                    val prediction = predictResponse.body()!!
                    
                    // 3. Call Recommend API
                    val recReq = RecommendationRequest(prediction.disease, prediction.confidence)
                    val recResponse = RetrofitInstance.api.getRecommendation(recReq)
                    
                    if (recResponse.isSuccessful) {
                        _uiState.value = UIState.Success(
                            prediction.disease, 
                            prediction.confidence, 
                            recResponse.body()
                        )
                    } else {
                        // If recommend fails, show predict result anyway
                        _uiState.value = UIState.Success(
                            prediction.disease, 
                            prediction.confidence, 
                            null
                        )
                    }
                } else {
                    _uiState.value = UIState.Error("Prediction failed: ${predictResponse.message()}")
                }
            } catch (e: Exception) {
                _uiState.value = UIState.Error(e.localizedMessage ?: "Unknown error occurred")
            }
        }
    }

    private fun getFileFromUri(context: Context, uri: Uri): File? {
        val inputStream = context.contentResolver.openInputStream(uri) ?: return null
        val tempFile = File.createTempFile("upload", ".jpg", context.cacheDir)
        tempFile.outputStream().use { outputStream ->
            inputStream.copyTo(outputStream)
        }
        return tempFile
    }
    
    fun resetState() {
        _uiState.value = UIState.Idle
        _selectedImageUri.value = null
    }
}
