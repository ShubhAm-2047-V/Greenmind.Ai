package com.agroai.app.model

data class PredictionResponse(
    val disease: String,
    val confidence: Double
)

data class RecommendationRequest(
    val disease: String,
    val confidence: Double
)

data class RecommendationResponse(
    val disease: String,
    val cause: String,
    val treatment: String,
    val prevention: String
)
