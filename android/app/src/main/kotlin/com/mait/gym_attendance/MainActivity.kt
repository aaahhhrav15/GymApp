package com.mait.gym_attendance

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "flutter.native/helper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        android.util.Log.d("MainActivity", "Configuring Flutter engine with method channel")
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            android.util.Log.d("MainActivity", "Method channel called: ${call.method}")
            when (call.method) {
                "expandNotificationPanel" -> {
                    try {
                        expandNotificationPanel()
                        result.success("Notification panel expanded")
                    } catch (e: Exception) {
                        android.util.Log.e("MainActivity", "Error expanding notification panel", e)
                        result.error("UNAVAILABLE", "Failed to expand notification panel", null)
                    }
                }
                "isBluetoothEnabled" -> {
                    try {
                        val isEnabled = isBluetoothEnabled()
                        android.util.Log.d("MainActivity", "Bluetooth enabled: $isEnabled")
                        result.success(isEnabled)
                    } catch (e: Exception) {
                        android.util.Log.e("MainActivity", "Error checking Bluetooth status", e)
                        result.error("UNAVAILABLE", "Failed to check Bluetooth status", null)
                    }
                }
                "isLocationEnabled" -> {
                    try {
                        val isEnabled = isLocationEnabled()
                        android.util.Log.d("MainActivity", "Location enabled: $isEnabled")
                        result.success(isEnabled)
                    } catch (e: Exception) {
                        android.util.Log.e("MainActivity", "Error checking Location status", e)
                        result.error("UNAVAILABLE", "Failed to check Location status", null)
                    }
                }
                "startStepCounterService" -> {
                    try {
                        startStepCounterService()
                        result.success("Step counter service started")
                    } catch (e: Exception) {
                        android.util.Log.e("MainActivity", "Error starting step counter service", e)
                        result.error("UNAVAILABLE", "Failed to start step counter service", null)
                    }
                }
                "stopStepCounterService" -> {
                    try {
                        stopStepCounterService()
                        result.success("Step counter service stopped")
                    } catch (e: Exception) {
                        android.util.Log.e("MainActivity", "Error stopping step counter service", e)
                        result.error("UNAVAILABLE", "Failed to stop step counter service", null)
                    }
                }
                else -> {
                    android.util.Log.w("MainActivity", "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }

    private fun startStepCounterService() {
        android.util.Log.d("MainActivity", "Starting step counter service")
        
        // Check required permissions for dataSync foreground service
        val hasActivityRecognition = checkSelfPermission(android.Manifest.permission.ACTIVITY_RECOGNITION) == PackageManager.PERMISSION_GRANTED
        val hasForegroundServiceDataSync = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            checkSelfPermission(android.Manifest.permission.FOREGROUND_SERVICE_DATA_SYNC) == PackageManager.PERMISSION_GRANTED
        } else {
            true // Not required on older versions
        }
        
        android.util.Log.d("MainActivity", "Permissions - ActivityRecognition: $hasActivityRecognition, ForegroundServiceDataSync: $hasForegroundServiceDataSync")
        
        if (!hasActivityRecognition) {
            android.util.Log.e("MainActivity", "Missing ACTIVITY_RECOGNITION permission")
            return
        }
        
        val serviceIntent = Intent(this, StepCounterService::class.java).apply {
            action = StepCounterService.ACTION_START_SERVICE
        }
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }
        } catch (e: SecurityException) {
            android.util.Log.e("MainActivity", "SecurityException starting service: ${e.message}")
        }
    }

    private fun stopStepCounterService() {
        android.util.Log.d("MainActivity", "Stopping step counter service")
        val serviceIntent = Intent(this, StepCounterService::class.java).apply {
            action = StepCounterService.ACTION_STOP_SERVICE
        }
        startService(serviceIntent)
    }

    private fun isBluetoothEnabled(): Boolean {
        return try {
            val bluetoothAdapter = android.bluetooth.BluetoothAdapter.getDefaultAdapter()
            bluetoothAdapter?.isEnabled ?: false
        } catch (e: Exception) {
            false
        }
    }

    private fun isLocationEnabled(): Boolean {
        return try {
            val locationManager = getSystemService(Context.LOCATION_SERVICE) as android.location.LocationManager
            val isGpsEnabled = locationManager.isProviderEnabled(android.location.LocationManager.GPS_PROVIDER)
            val isNetworkEnabled = locationManager.isProviderEnabled(android.location.LocationManager.NETWORK_PROVIDER)
            isGpsEnabled || isNetworkEnabled
        } catch (e: Exception) {
            false
        }
    }

    private fun expandNotificationPanel() {
        try {
            val service = getSystemService(Context.STATUS_BAR_SERVICE)
            val statusbarManager = Class.forName("android.app.StatusBarManager")
            val expand = statusbarManager.getMethod("expandNotificationsPanel")
            expand.invoke(service)
        } catch (e: Exception) {
            // Fallback for newer Android versions
            try {
                val intent = android.content.Intent("android.intent.action.CLOSE_SYSTEM_DIALOGS")
                sendBroadcast(intent)
                
                val expandIntent = android.content.Intent()
                expandIntent.action = "android.intent.action.QUICK_SETTINGS_PANEL"
                startActivity(expandIntent)
            } catch (fallbackException: Exception) {
                e.printStackTrace()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge for Android 15+ compatibility
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Configure system UI for edge-to-edge
        val windowInsetsController = WindowCompat.getInsetsController(window, window.decorView)
        windowInsetsController.isAppearanceLightStatusBars = true
        windowInsetsController.isAppearanceLightNavigationBars = true
        
        // Use new APIs instead of deprecated ones
        window.statusBarColor = android.graphics.Color.TRANSPARENT
        window.navigationBarColor = android.graphics.Color.TRANSPARENT
        
        // Auto-start step counter service when app launches
        startStepCounterService()
    }

    override fun onDestroy() {
        super.onDestroy()
        // Don't stop the service when activity is destroyed
        // The service should continue running in background
    }
}