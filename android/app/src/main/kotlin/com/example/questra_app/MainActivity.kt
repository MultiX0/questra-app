package com.example.questra_app

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import androidx.core.content.ContextCompat

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Request notification permission
        if (android.os.Build.VERSION.SDK_INT >= 33) {
            requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 0)
        }
    }
}