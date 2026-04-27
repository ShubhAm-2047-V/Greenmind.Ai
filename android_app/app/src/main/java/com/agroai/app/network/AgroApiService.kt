package com.agroai.app.network

import com.agroai.app.model.PredictionResponse
import com.agroai.app.model.RecommendationRequest
import com.agroai.app.model.RecommendationResponse
import okhttp3.MultipartBody
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.Multipart
import retrofit2.http.POST
import retrofit2.http.Part

interface AgroApiService {
    @Multipart
    @POST("/predict")
    suspend fun predictDisease(
        @Part file: MultipartBody.Part
    ): Response<PredictionResponse>

    @POST("/recommend")
    suspend fun getRecommendation(
        @Body request: RecommendationRequest
    ): Response<RecommendationResponse>
}
