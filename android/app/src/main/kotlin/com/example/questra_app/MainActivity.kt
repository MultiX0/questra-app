package com.example.questra_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Create notification channel
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel()
        }
        
        // Request battery optimization exemption on Android 6.0+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestBatteryOptimizationExemption()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "appVersionChannel")
            .setMethodCallHandler { call, result ->
                if (call.method == "getAppInfo") {
                    try {
                        val packageInfo = packageManager.getPackageInfo(packageName, 0)
                        val version = packageInfo.versionName
                        val buildNumber = packageInfo.longVersionCode.toString()
                        val appInfo = mapOf("version" to version, "buildNumber" to buildNumber)
                        result.success(appInfo)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Package info not available", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channels = listOf(
                NotificationChannel(
                    "quest_channel",
                    "Quest Notifications",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Channel for Quest notifications"
                    enableVibration(true)
                    setShowBadge(true)
                },
                NotificationChannel(
                    "system_channel",
                    "System Notifications",
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "Channel for system-level notifications"
                }
            )
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            channels.forEach { channel ->
                notificationManager.createNotificationChannel(channel)
            }
        }
    }

    private fun requestBatteryOptimizationExemption() {
        val packageName = packageName
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        
        // Check if app is already exempted
        if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
            try {
                // Request battery optimization exemption
                startActivity(
                    Intent(
                        Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, 
                        Uri.parse("package:$packageName")
                    )
                )
            } catch (e: Exception) {
                // Fallback intent if direct exemption fails
                val fallbackIntent = Intent(
                    Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS
                )
                startActivity(fallbackIntent)
            }
        }
    }
}