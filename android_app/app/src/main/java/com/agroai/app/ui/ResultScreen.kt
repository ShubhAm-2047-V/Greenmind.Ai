package com.agroai.app.ui

import android.net.Uri
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.rememberAsyncImagePainter
import com.agroai.app.viewmodel.UIState

@Composable
fun ResultScreen(state: UIState.Success, imageUri: Uri?, onBack: () -> Unit) {
    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
            .verticalScroll(scrollState),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Analysis Result",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.primary
        )
        
        Spacer(modifier = Modifier.height(16.dp))

        if (imageUri != null) {
            Image(
                painter = rememberAsyncImagePainter(imageUri),
                contentDescription = "Analyzed Image",
                modifier = Modifier
                    .size(200.dp)
                    .clip(RoundedCornerShape(16.dp))
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(text = "Disease: ${state.disease}", fontSize = 18.sp, fontWeight = FontWeight.Bold)
                
                val confidenceColor = when {
                    state.confidence >= 85 -> Color(0xFF4CAF50) // Green
                    state.confidence >= 70 -> Color(0xFFFF9800) // Orange
                    else -> Color.Red
                }
                
                Text(
                    text = "Confidence: ${state.confidence}%", 
                    fontSize = 16.sp,
                    color = confidenceColor,
                    fontWeight = FontWeight.Medium
                )
                
                if (state.confidence < 70) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = "Warning: Uncertain prediction. Consider retaking the image or consulting an expert.",
                        color = Color.Red,
                        fontSize = 14.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        if (state.recommendation != null) {
            RecommendationCard(title = "Cause", content = state.recommendation.cause)
            Spacer(modifier = Modifier.height(8.dp))
            RecommendationCard(title = "Treatment", content = state.recommendation.treatment)
            Spacer(modifier = Modifier.height(8.dp))
            RecommendationCard(title = "Prevention", content = state.recommendation.prevention)
        } else {
            Card(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Recommendation data unavailable.",
                    modifier = Modifier.padding(16.dp),
                    color = Color.Gray
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        Button(
            onClick = onBack,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Scan Another Leaf")
        }
    }
}

@Composable
fun RecommendationCard(title: String, content: String) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(text = title, fontSize = 16.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
            Spacer(modifier = Modifier.height(4.dp))
            Text(text = content, fontSize = 14.sp)
        }
    }
}
