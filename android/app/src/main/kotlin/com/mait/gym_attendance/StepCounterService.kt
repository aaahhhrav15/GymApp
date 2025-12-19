package com.mait.gym_attendance

import android.app.*
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import android.content.SharedPreferences
import android.util.Log
import java.text.SimpleDateFormat
import java.util.*
import android.app.AlarmManager
import android.app.PendingIntent
import android.os.Handler
import android.os.Looper

class StepCounterService : Service(), SensorEventListener {
    companion object {
        const val CHANNEL_ID = "STEP_COUNTER_CHANNEL"
        const val NOTIFICATION_ID = 1
        const val ACTION_START_SERVICE = "START_STEP_COUNTER"
        const val ACTION_STOP_SERVICE = "STOP_STEP_COUNTER"
        
        // SharedPreferences keys
        const val PREFS_NAME = "FlutterSharedPreferences"
        const val KEY_DAILY_STEPS = "flutter.daily_steps"
        const val KEY_STEPS_DATE = "flutter.steps_date"
        const val KEY_DEVICE_STEPS = "flutter.device_steps_at_midnight"
        const val KEY_DAILY_GOAL = "flutter.steps_daily_goal"
        const val KEY_SERVICE_STEPS = "flutter.service_total_steps"
        const val KEY_SERVICE_DATE = "flutter.service_date"
    }

    private lateinit var sensorManager: SensorManager
    private var stepSensor: Sensor? = null
    private lateinit var sharedPreferences: SharedPreferences
    
    private var serviceTotalSteps = 0
    private var serviceStartDate = ""
    private var lastSavedSteps = 0
    private val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
    private val handler = Handler(Looper.getMainLooper())
    private var dayCheckRunnable: Runnable? = null

    override fun onCreate() {
        super.onCreate()
        Log.d("StepService", "Service created")
        
        sharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        
        createNotificationChannel()
        cleanCorruptedData()
        loadServiceData()
        checkForNewDay()
        scheduleMidnightAlarm()
        startPeriodicDayCheck()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("StepService", "Service started with action: ${intent?.action}")
        
        when (intent?.action) {
            ACTION_START_SERVICE -> {
                // Check for day change first
                checkForNewDay()
                
                val notification = createNotification()
                startForeground(NOTIFICATION_ID, notification)
                startStepCounting()
                
                // Ensure notification is persistent
                val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.notify(NOTIFICATION_ID, notification)
                
                // Schedule midnight alarm if not already scheduled
                scheduleMidnightAlarm()
                
                // Start periodic day check if not already running
                startPeriodicDayCheck()
            }
            ACTION_STOP_SERVICE -> {
                stopStepCounting()
                stopPeriodicDayCheck()
                cancelMidnightAlarm()
                stopSelf()
            }
            "REFRESH_AFTER_DAY_CHANGE" -> {
                // Handle day change refresh
                Log.d("StepService", "Refreshing service after day change")
                checkForNewDay()
                val notification = createNotification()
                startForeground(NOTIFICATION_ID, notification)
                // Ensure step counting is still active
                startStepCounting()
                scheduleMidnightAlarm() // Reschedule for next midnight
                startPeriodicDayCheck() // Restart periodic check
            }
            else -> {
                // If service is already running but no action specified, ensure it stays active
                val notification = createNotification()
                startForeground(NOTIFICATION_ID, notification)
                if (stepSensor != null) {
                    startStepCounting()
                }
                scheduleMidnightAlarm()
                startPeriodicDayCheck()
            }
        }
        
        return START_STICKY // Restart if killed by system
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Step Counter",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Background step counting - cannot be dismissed"
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                enableLights(false)
                enableVibration(false)
                setSound(null, null)
                // Make the channel non-bypassable
                setBypassDnd(false)
                canBypassDnd()
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val currentSteps = try {
            sharedPreferences.getLong(KEY_DAILY_STEPS, 0L).toInt()
        } catch (e: ClassCastException) {
            // Clear corrupted data and use default
            sharedPreferences.edit().remove(KEY_DAILY_STEPS).apply()
            0
        }
        val dailyGoal = try {
            sharedPreferences.getInt(KEY_DAILY_GOAL, 10000)
        } catch (e: ClassCastException) {
            // Clear corrupted data and use default
            sharedPreferences.edit().remove(KEY_DAILY_GOAL).apply()
            10000
        }
        
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Step Counter Active")
            .setContentText("Steps today: $currentSteps / $dailyGoal")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setContentIntent(pendingIntent)
            .setOngoing(true)  // This makes the notification non-removable
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)  // Changed from LOW to DEFAULT
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setShowWhen(false)
            .setAutoCancel(false)  // Prevents auto-cancellation
            .setLocalOnly(true)    // Keeps it on this device only
            .setDeleteIntent(null) // Prevent deletion
            .setCategory(NotificationCompat.CATEGORY_SERVICE) // Mark as service notification
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE) // For Android 12+
            .build()
    }

    private fun startStepCounting() {
        stepSensor?.let { sensor ->
            sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)
            Log.d("StepService", "Started listening to step sensor")
        } ?: run {
            Log.e("StepService", "Step sensor not available")
        }
    }

    private fun stopStepCounting() {
        sensorManager.unregisterListener(this)
        saveServiceData()
        Log.d("StepService", "Stopped listening to step sensor")
    }

    override fun onSensorChanged(event: SensorEvent?) {
        event?.let {
            if (it.sensor.type == Sensor.TYPE_STEP_COUNTER) {
                val totalSteps = it.values[0].toInt()
                handleStepCount(totalSteps)
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Not needed for step counter
    }

    private fun handleStepCount(totalSteps: Int) {
        val today = dateFormat.format(Date())
        
        // Initialize service data for first run
        if (serviceTotalSteps == 0) {
            serviceTotalSteps = totalSteps
            serviceStartDate = today
        }

        // Check for new day
        if (serviceStartDate != today) {
            handleNewDay(totalSteps)
            return
        }

        // Calculate daily steps for service
        val serviceSteps = totalSteps - serviceTotalSteps
        
        // Get current daily steps from SharedPreferences
        val currentDailySteps = try {
            sharedPreferences.getLong(KEY_DAILY_STEPS, 0L).toInt()
        } catch (e: ClassCastException) {
            sharedPreferences.edit().remove(KEY_DAILY_STEPS).apply()
            0
        }
        val deviceStepsAtMidnight = try {
            sharedPreferences.getLong(KEY_DEVICE_STEPS, 0L).toInt()
        } catch (e: ClassCastException) {
            sharedPreferences.edit().remove(KEY_DEVICE_STEPS).apply()
            0
        }
        
        // If app has been used today, sync with app data
        val storedDate = sharedPreferences.getString(KEY_STEPS_DATE, "")
        if (storedDate == today && deviceStepsAtMidnight > 0) {
            // App has been active today, calculate steps from device baseline
            val appCalculatedSteps = totalSteps - deviceStepsAtMidnight
            
            // Use the higher value (service or app calculated)
            val finalSteps = maxOf(appCalculatedSteps, serviceSteps, currentDailySteps)
            updateDailySteps(finalSteps)
        } else {
            // App hasn't been active today, use service calculation
            updateDailySteps(serviceSteps)
            
            // Update device baseline for when app becomes active
            sharedPreferences.edit()
                .putLong(KEY_DEVICE_STEPS, (totalSteps - serviceSteps).toLong())
                .putString(KEY_STEPS_DATE, today)
                .apply()
        }
        
        // Save service data periodically
        if (serviceSteps - lastSavedSteps >= 10) {
            saveServiceData()
            lastSavedSteps = serviceSteps
            updateNotification()
            
            // Double-check we're still running as foreground service
            try {
                val notification = createNotification()
                startForeground(NOTIFICATION_ID, notification)
            } catch (e: Exception) {
                Log.w("StepService", "Failed to maintain foreground status: $e")
            }
        }
        
        Log.d("StepService", "Total: $totalSteps, Service: $serviceSteps, Daily: ${try { sharedPreferences.getLong(KEY_DAILY_STEPS, 0L) } catch (e: ClassCastException) { 0L }}")
    }

    private fun handleNewDay(totalSteps: Int) {
        val today = dateFormat.format(Date())
        
        Log.d("StepService", "New day detected: $today")
        
        // Reset for new day
        serviceTotalSteps = totalSteps
        serviceStartDate = today
        lastSavedSteps = 0
        
        // Reset daily steps
        updateDailySteps(0)
        
        // Clear device baseline (will be set when app becomes active)
        sharedPreferences.edit()
            .putLong(KEY_DEVICE_STEPS, 0L)
            .putString(KEY_STEPS_DATE, today)
            .apply()
        
        saveServiceData()
        
        // CRITICAL: Ensure service maintains foreground status after day change
        val notification = createNotification()
        try {
            startForeground(NOTIFICATION_ID, notification)
            Log.d("StepService", "Maintained foreground status after day change")
        } catch (e: Exception) {
            Log.e("StepService", "Failed to maintain foreground status: $e")
            // Try to restart the service
            val refreshIntent = Intent(this, StepCounterService::class.java).apply {
                action = "REFRESH_AFTER_DAY_CHANGE"
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(refreshIntent)
            } else {
                startService(refreshIntent)
            }
        }
        
        updateNotification()
    }

    private fun updateDailySteps(steps: Int) {
        sharedPreferences.edit()
            .putLong(KEY_DAILY_STEPS, steps.toLong())
            .apply()
    }

    private fun loadServiceData() {
        serviceTotalSteps = try {
            sharedPreferences.getLong(KEY_SERVICE_STEPS, 0L).toInt()
        } catch (e: ClassCastException) {
            sharedPreferences.edit().remove(KEY_SERVICE_STEPS).apply()
            0
        }
        serviceStartDate = sharedPreferences.getString(KEY_SERVICE_DATE, dateFormat.format(Date())) ?: dateFormat.format(Date())
        Log.d("StepService", "Loaded service data: steps=$serviceTotalSteps, date=$serviceStartDate")
    }

    private fun saveServiceData() {
        sharedPreferences.edit()
            .putLong(KEY_SERVICE_STEPS, serviceTotalSteps.toLong())
            .putString(KEY_SERVICE_DATE, serviceStartDate)
            .apply()
        Log.d("StepService", "Saved service data: steps=$serviceTotalSteps, date=$serviceStartDate")
    }

    private fun checkForNewDay() {
        val today = dateFormat.format(Date())
        val storedDate = sharedPreferences.getString(KEY_STEPS_DATE, "")
        
        if (storedDate != today) {
            Log.d("StepService", "Service detected new day: $today (was: $storedDate)")
            // Reset daily steps for new day
            updateDailySteps(0)
            sharedPreferences.edit()
                .putString(KEY_STEPS_DATE, today)
                .putLong(KEY_DEVICE_STEPS, 0L)
                .apply()
        }
    }

    private fun updateNotification() {
        val notification = createNotification()
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Update foreground notification
        notificationManager.notify(NOTIFICATION_ID, notification)
        
        // Ensure we're still in foreground mode
        try {
            startForeground(NOTIFICATION_ID, notification)
        } catch (e: Exception) {
            Log.w("StepService", "Failed to update foreground notification: $e")
        }
    }

    private fun cleanCorruptedData() {
        try {
            // Test each key to see if it causes ClassCastException
            sharedPreferences.getLong(KEY_DAILY_STEPS, 0L)
        } catch (e: ClassCastException) {
            Log.w("StepService", "Cleaning corrupted KEY_DAILY_STEPS")
            sharedPreferences.edit().remove(KEY_DAILY_STEPS).apply()
        }
        
        try {
            sharedPreferences.getLong(KEY_DEVICE_STEPS, 0L)
        } catch (e: ClassCastException) {
            Log.w("StepService", "Cleaning corrupted KEY_DEVICE_STEPS")
            sharedPreferences.edit().remove(KEY_DEVICE_STEPS).apply()
        }
        
        try {
            sharedPreferences.getLong(KEY_SERVICE_STEPS, 0L)
        } catch (e: ClassCastException) {
            Log.w("StepService", "Cleaning corrupted KEY_SERVICE_STEPS")
            sharedPreferences.edit().remove(KEY_SERVICE_STEPS).apply()
        }
        
        try {
            sharedPreferences.getInt(KEY_DAILY_GOAL, 10000)
        } catch (e: ClassCastException) {
            Log.w("StepService", "Cleaning corrupted KEY_DAILY_GOAL")
            sharedPreferences.edit().remove(KEY_DAILY_GOAL).apply()
        }
    }

    // Schedule alarm to refresh service at midnight
    private fun scheduleMidnightAlarm() {
        try {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(this, StepCounterService::class.java).apply {
                action = "REFRESH_AFTER_DAY_CHANGE"
            }
            val pendingIntent = PendingIntent.getService(
                this,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Calculate next midnight
            val calendar = Calendar.getInstance().apply {
                timeInMillis = System.currentTimeMillis()
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                add(Calendar.DAY_OF_YEAR, 1) // Next midnight
            }
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
            }
            
            Log.d("StepService", "Scheduled midnight alarm for: ${calendar.time}")
        } catch (e: Exception) {
            Log.e("StepService", "Failed to schedule midnight alarm: $e")
        }
    }
    
    // Cancel midnight alarm
    private fun cancelMidnightAlarm() {
        try {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(this, StepCounterService::class.java).apply {
                action = "REFRESH_AFTER_DAY_CHANGE"
            }
            val pendingIntent = PendingIntent.getService(
                this,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
            Log.d("StepService", "Cancelled midnight alarm")
        } catch (e: Exception) {
            Log.e("StepService", "Failed to cancel midnight alarm: $e")
        }
    }
    
    // Start periodic check for day changes (every 5 minutes)
    private fun startPeriodicDayCheck() {
        stopPeriodicDayCheck() // Stop any existing check
        
        dayCheckRunnable = object : Runnable {
            override fun run() {
                val today = dateFormat.format(Date())
                if (serviceStartDate != today) {
                    Log.d("StepService", "Day change detected in periodic check: $today")
                    // Get the last known total steps from sensor (if we had a reading)
                    // Since we can't directly query the sensor, we'll use a reasonable approach:
                    // Reset the service state for the new day
                    val currentTotalSteps = serviceTotalSteps
                    
                    // If we have a sensor, the next reading will update this
                    // For now, reset the date tracking
                    serviceStartDate = today
                    serviceTotalSteps = 0 // Will be set on next sensor reading
                    lastSavedSteps = 0
                    updateDailySteps(0)
                    
                    // Clear device baseline
                    sharedPreferences.edit()
                        .putLong(KEY_DEVICE_STEPS, 0L)
                        .putString(KEY_STEPS_DATE, today)
                        .apply()
                    
                    saveServiceData()
                    
                    // Ensure foreground status is maintained
                    val notification = createNotification()
                    try {
                        startForeground(NOTIFICATION_ID, notification)
                        Log.d("StepService", "Maintained foreground status in periodic check")
                    } catch (e: Exception) {
                        Log.e("StepService", "Failed to maintain foreground in periodic check: $e")
                    }
                    
                    updateNotification()
                } else {
                    // No day change, but ensure we're still in foreground
                    try {
                        val notification = createNotification()
                        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        notificationManager.notify(NOTIFICATION_ID, notification)
                    } catch (e: Exception) {
                        Log.w("StepService", "Failed to update notification in periodic check: $e")
                    }
                }
                
                // Schedule next check in 5 minutes
                handler.postDelayed(this, 5 * 60 * 1000)
            }
        }
        
        // Start first check after 1 minute
        handler.postDelayed(dayCheckRunnable!!, 60 * 1000)
        Log.d("StepService", "Started periodic day check")
    }
    
    // Stop periodic day check
    private fun stopPeriodicDayCheck() {
        dayCheckRunnable?.let {
            handler.removeCallbacks(it)
            dayCheckRunnable = null
            Log.d("StepService", "Stopped periodic day check")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopStepCounting()
        stopPeriodicDayCheck()
        cancelMidnightAlarm()
        Log.d("StepService", "Service destroyed")
    }
}