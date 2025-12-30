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
            
            Log.d("BootReceiver", "Device booted or app updated, starting step counter service")
            
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