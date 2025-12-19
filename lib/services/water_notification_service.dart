// lib/services/water_notification_service.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../database/water_database.dart';

class WaterNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int _reminderNotificationBaseId =
      1000; // Base ID for scheduled reminders
  static const int _goalAchievedNotificationId = 1001;

  // Reminder messages
  static const List<String> _reminderMessages = [
    'Time to hydrate! 💧',
    'Don\'t forget to drink water!',
    'Stay hydrated, stay healthy! 🌊',
    'Your body needs water! 💦',
    'Drink up! Your health depends on it!',
    'Hydration time! 🥤',
    'Water break! Keep those energy levels up! ⚡',
    'Remember: 8 glasses a day keeps dehydration away!',
    'Sip by sip, stay fit! 💪',
    'Your cells are calling for water! 📞',
  ];

  // Goal achieved messages
  static const List<String> _goalMessages = [
    'Congratulations! You\'ve reached your daily water goal! 🎉',
    'Amazing! You\'ve stayed hydrated today! ✨',
    'Great job! Daily hydration goal completed! 🏆',
    'Well done! You\'ve drunk enough water today! 👏',
    'Fantastic! Your body thanks you for staying hydrated! 🙌',
  ];

  // States
  static bool _isInitialized = false;
  static int _reminderInterval = 120; // minutes
  static List<int> _scheduledNotificationIds = [];

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Initialize the plugin
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_notification');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      if (Platform.isAndroid) {
        // Create notification channel for Android
        await _createNotificationChannel();
      }

      // Load stored reminder settings
      await _loadReminderSettings();

      _isInitialized = true;
      debugPrint('WaterNotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing WaterNotificationService: $e');
      rethrow;
    }
  }

  /// Create notification channel for Android
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'water_reminders',
      'Water Reminders',
      description: 'Notifications to remind you to drink water',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
    // Note: iOS permissions are handled during initialization
  }

  /// Load reminder settings from SharedPreferences
  static Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _reminderInterval = prefs.getInt('reminder_interval_minutes') ?? 60;
    _scheduledNotificationIds = prefs
            .getStringList('scheduled_notification_ids')
            ?.map((id) => int.parse(id))
            .toList() ??
        [];
  }

  /// Save scheduled notification IDs
  static Future<void> _saveScheduledNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('scheduled_notification_ids',
        _scheduledNotificationIds.map((id) => id.toString()).toList());
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap if needed
    // Could navigate to water tracking screen
  }

  /// Start water reminders with proper background scheduling
  static Future<void> startReminders({Duration? interval}) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Cancel existing reminders
    await stopReminders();

    final reminderInterval = interval ?? Duration(minutes: _reminderInterval);

    try {
      // Check if goal is already achieved
      final isGoalAchieved = await _isGoalAchievedToday();
      if (isGoalAchieved) {
        debugPrint('Daily goal already achieved. Not starting reminders.');
        return;
      }

      // Schedule notifications for the next 24 hours
      await _scheduleBackgroundReminders(reminderInterval);

      debugPrint('Water reminders started with interval: $reminderInterval');
    } catch (e) {
      debugPrint('Error starting water reminders: $e');
    }
  }

  /// Schedule background reminders for the next 24 hours
  static Future<void> _scheduleBackgroundReminders(Duration interval) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final endOfDay =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, 23, 59);

      // Clear previous scheduled IDs
      _scheduledNotificationIds.clear();

      // Calculate how many reminders to schedule until end of day
      int notificationCount = 0;
      var nextReminderTime = now.add(interval);

      while (nextReminderTime.isBefore(endOfDay) && notificationCount < 24) {
        final notificationId = _reminderNotificationBaseId + notificationCount;
        _scheduledNotificationIds.add(notificationId);

        await _scheduleReminderNotification(nextReminderTime, notificationId);

        nextReminderTime = nextReminderTime.add(interval);
        notificationCount++;
      }

      // Save scheduled IDs for tracking
      await _saveScheduledNotificationIds();

      debugPrint('Scheduled $notificationCount background water reminders');
    } catch (e) {
      debugPrint('Error scheduling background reminders: $e');
    }
  }

  /// Schedule a single reminder notification
  static Future<void> _scheduleReminderNotification(
      tz.TZDateTime scheduledTime, int notificationId) async {
    try {
      final randomMessage =
          _reminderMessages[Random().nextInt(_reminderMessages.length)];

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'water_reminders',
        'Water Reminders',
        channelDescription: 'Notifications to remind you to drink water',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Water Reminder',
        playSound: true,
        enableVibration: true,
        autoCancel: true,
        showWhen: true,
        icon: '@drawable/ic_notification',
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'mark_done',
            'Mark as Done',
            showsUserInterface: false,
          ),
        ],
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        'Hydration Reminder',
        randomMessage,
        scheduledTime,
        notificationDetails,
        payload: 'water_reminder',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint(
          'Scheduled water reminder for ${scheduledTime.toString()} with ID: $notificationId');
    } catch (e) {
      debugPrint('Error scheduling reminder notification: $e');
    }
  }

  /// Stop water reminders and cancel all scheduled notifications
  static Future<void> stopReminders() async {
    try {
      // Cancel all scheduled reminder notifications
      for (final notificationId in _scheduledNotificationIds) {
        await _notificationsPlugin.cancel(notificationId);
      }

      _scheduledNotificationIds.clear();
      await _saveScheduledNotificationIds();

      debugPrint('All water reminders stopped and cancelled');
    } catch (e) {
      debugPrint('Error stopping water reminders: $e');
    }
  }

  /// Show goal achieved notification
  static Future<void> showGoalAchievedNotification() async {
    try {
      final randomMessage =
          _goalMessages[Random().nextInt(_goalMessages.length)];

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'water_reminders',
        'Water Reminders',
        channelDescription: 'Notifications for water tracking achievements',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Goal Achieved',
        playSound: true,
        enableVibration: true,
        autoCancel: true,
        showWhen: true,
        icon: '@drawable/ic_notification',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _goalAchievedNotificationId,
        'Daily Goal Achieved! 🎉',
        randomMessage,
        notificationDetails,
        payload: 'goal_achieved',
      );

      debugPrint('Goal achieved notification sent: $randomMessage');
    } catch (e) {
      debugPrint('Error sending goal achieved notification: $e');
    }
  }

  /// Check if daily goal is achieved
  static Future<bool> _isGoalAchievedToday() async {
    try {
      final todayIntake = await WaterDatabase.getTodaysTotalIntake();
      final dailyGoal = await WaterDatabase.getDailyGoal();
      return todayIntake >= dailyGoal;
    } catch (e) {
      debugPrint('Error checking goal achievement: $e');
      return false;
    }
  }

  /// Save reminder settings
  static Future<void> saveReminderSettings({
    required bool enabled,
    required int intervalMinutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders_enabled', enabled);
    await prefs.setInt('reminder_interval_minutes', intervalMinutes);
    _reminderInterval = intervalMinutes;
  }

  /// Check if reminders are scheduled
  static bool get areRemindersActive => _scheduledNotificationIds.isNotEmpty;

  /// Get reminder interval
  static int get reminderInterval => _reminderInterval;

  /// Get number of scheduled reminders
  static int get scheduledRemindersCount => _scheduledNotificationIds.length;

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      _scheduledNotificationIds.clear();
      await _saveScheduledNotificationIds();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }

  /// Reschedule reminders if goal is no longer achieved (used when removing water intake)
  static Future<void> rescheduleRemindersIfNeeded() async {
    try {
      final isGoalAchieved = await _isGoalAchievedToday();
      final remindersEnabled = await _getReminderEnabled();

      if (!isGoalAchieved && remindersEnabled && !areRemindersActive) {
        await startReminders();
        debugPrint('Reminders rescheduled as goal is no longer achieved');
      }
    } catch (e) {
      debugPrint('Error rescheduling reminders: $e');
    }
  }

  /// Get reminder enabled status
  static Future<bool> _getReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('reminders_enabled') ?? true;
  }

  /// Check and handle daily reset
  static Future<void> handleDailyReset() async {
    try {
      // Cancel all existing reminders
      await stopReminders();

      // Check if reminders should be restarted for new day
      final remindersEnabled = await _getReminderEnabled();
      if (remindersEnabled) {
        await startReminders();
        debugPrint('Reminders restarted for new day');
      }
    } catch (e) {
      debugPrint('Error handling daily reset: $e');
    }
  }

  /// Test notification (for debugging)
  static Future<void> testNotification() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'water_reminders',
        'Water Reminders',
        channelDescription: 'Test notification',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@drawable/ic_notification',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        999,
        'Test Notification',
        'This is a test water reminder notification - works in background!',
        notificationDetails,
        payload: 'test',
      );

      debugPrint('Test notification sent');
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

  /// Schedule reminders for a specific time range
  static Future<void> scheduleReminderForTimeRange({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required Duration interval,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final today = tz.TZDateTime(tz.local, now.year, now.month, now.day);

      final startDateTime = today.add(Duration(
        hours: startTime.hour,
        minutes: startTime.minute,
      ));

      final endDateTime = today.add(Duration(
        hours: endTime.hour,
        minutes: endTime.minute,
      ));

      // Clear previous scheduled IDs
      await stopReminders();

      var currentTime = startDateTime;
      int notificationCount = 0;

      while (currentTime.isBefore(endDateTime) && notificationCount < 24) {
        final notificationId = _reminderNotificationBaseId + notificationCount;
        _scheduledNotificationIds.add(notificationId);

        await _scheduleReminderNotification(currentTime, notificationId);

        currentTime = currentTime.add(interval);
        notificationCount++;
      }

      await _saveScheduledNotificationIds();
      debugPrint(
          'Scheduled $notificationCount reminders for time range ${startTime.hour}:${startTime.minute} - ${endTime.hour}:${endTime.minute}');
    } catch (e) {
      debugPrint('Error scheduling time range reminders: $e');
    }
  }

  /// Get notification history (placeholder for future implementation)
  static Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    // TODO: Implement notification history tracking
    return [];
  }
}
