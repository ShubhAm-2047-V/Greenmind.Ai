package com.agroai.app.ui

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import com.agroai.app.viewmodel.AgroViewModel
import com.agroai.app.viewmodel.UIState

class MainActivity : ComponentActivity() {
    private val viewModel: AgroViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            AgroAIAppTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    AgroApp(viewModel)
                }
            }
        }
    }
}

@Composable
fun AgroAIAppTheme(content: @Composable () -> Unit) {
    MaterialTheme(content = content)
}

@Composable
fun AgroApp(viewModel: AgroViewModel) {
    val uiState by viewModel.uiState.collectAsState()
    val selectedImageUri by viewModel.selectedImageUri.collectAsState()

    when (uiState) {
        is UIState.Idle -> HomeScreen(viewModel = viewModel)
        is UIState.Loading -> LoadingScreen()
        is UIState.Success -> ResultScreen(
            state = uiState as UIState.Success, 
            imageUri = selectedImageUri,
            onBack = { viewModel.resetState() }
        )
        is UIState.Error -> ErrorScreen(
            error = (uiState as UIState.Error).message,
            onRetry = { viewModel.resetState() }
        )
    }
}
