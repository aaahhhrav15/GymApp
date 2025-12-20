package com.mait.gym_attendance

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || 
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            
            Log.d("BootReceiver", "Device booted or app updated")
            
            // Android 15+ (API 35+) restricts starting foreground services with restricted types
            // from BOOT_COMPLETED receivers. The service should be started when the app is opened instead.
            if (Build.VERSION.SDK_INT >= 35) { // Android 15 (API 35)
                Log.d("BootReceiver", "Android 15+ detected: Skipping service start from BOOT_COMPLETED to comply with restrictions")
                // Service will be started when user opens the app
                return
            }
            
            val serviceIntent = Intent(context, StepCounterService::class.java).apply {
                action = StepCounterService.ACTION_START_SERVICE
            }
            
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
                Log.d("BootReceiver", "Step counter service started successfully")
            } catch (e: Exception) {
                Log.e("BootReceiver", "Failed to start step counter service", e)
            }
        }
    }
}