// lib/providers/water_provider.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/water_database.dart';
import '../services/water_notification_service.dart';

class WaterProvider with ChangeNotifier {
  // Current day data
  int _currentIntake = 0;
  int _dailyGoal = 2000;
  List<Map<String, dynamic>> _todaysIntake = [];
  bool _isLoading = false;
  String? _error;

  // Reminder settings
  bool _reminderEnabled = true;
  int _reminderInterval = 60; // minutes

  // Getters
  int get currentIntake => _currentIntake;
  int get dailyGoal => _dailyGoal;
  List<Map<String, dynamic>> get todaysIntake => _todaysIntake;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get reminderEnabled => _reminderEnabled;
  int get reminderInterval => _reminderInterval;

  // Computed properties
  int get currentCups => (_currentIntake / 250).round();
  int get targetCups => (_dailyGoal / 250).round();
  int get remaining => (_dailyGoal - _currentIntake).clamp(0, _dailyGoal);
  double get progressPercentage =>
      _dailyGoal > 0 ? (_currentIntake / _dailyGoal).clamp(0.0, 1.0) : 0.0;
  int get progressPercent => (progressPercentage * 100).round();
  bool get isGoalAchieved => _currentIntake >= _dailyGoal;

  bool _isInitialized = false;
  bool _isInitializing = false;

  // Initialize provider
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) {
      return; // Already initialized or initializing
    }

    _isInitializing = true;
    _setLoading(true);

    try {
      await WaterNotificationService.initialize();
      await loadTodaysData();
      await loadSettings();

      // Start reminders if enabled
      if (_reminderEnabled) {
        await WaterNotificationService.startReminders();
      }

      _isInitialized = true;
      _clearError();
    } catch (e) {
      _setError('Failed to initialize water tracking: $e');
    } finally {
      _isInitializing = false;
      _setLoading(false);
    }
  }

  // Load today's data from database
  Future<void> loadTodaysData() async {
    try {
      _todaysIntake = await WaterDatabase.getTodaysIntake();
      _currentIntake = await WaterDatabase.getTodaysTotalIntake();
      _dailyGoal = await WaterDatabase.getDailyGoal();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load today\'s data: $e');
    }
  }

  // Load settings from database
  Future<void> loadSettings() async {
    try {
      _reminderEnabled = await WaterDatabase.getReminderEnabled();
      _reminderInterval = await WaterDatabase.getReminderInterval();
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Add water intake
  Future<bool> addWaterIntake(int amount, {String? customType}) async {
    if (amount <= 0 || amount > 2000) {
      _setError('Invalid water amount. Please enter 1-2000ml.');
      return false;
    }

    try {
      final wasGoalAchieved = isGoalAchieved;

      // Determine intake type
      final type = customType ?? _getIntakeType(amount);

      // Add to database
      await WaterDatabase.addWaterIntake(
        amount: amount,
        type: type,
        timestamp: DateTime.now(),
      );

      // Update daily summary
      await WaterDatabase.updateDailySummary(DateTime.now(), _dailyGoal);

      // Reload data
      await loadTodaysData();

      // Check if goal was just achieved
      if (!wasGoalAchieved && isGoalAchieved) {
        await WaterNotificationService.showGoalAchievedNotification();
        // Stop reminders when goal is achieved
        await WaterNotificationService.stopReminders();
      }

      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to add water intake: $e');
      return false;
    }
  }

  // Update water intake
  Future<bool> updateWaterIntake(int intakeId, int amount, {String? customType}) async {
    if (amount <= 0 || amount > 2000) {
      _setError('Invalid water amount. Please enter 1-2000ml.');
      return false;
    }

    try {
      final type = customType ?? _getIntakeType(amount);
      
      final success = await WaterDatabase.updateWaterIntake(
        intakeId: intakeId,
        amount: amount,
        type: type,
      );

      if (success) {
        // Update daily summary
        await WaterDatabase.updateDailySummary(DateTime.now(), _dailyGoal);

        // Reload data
        await loadTodaysData();

        // Check if goal status changed
        await WaterNotificationService.rescheduleRemindersIfNeeded();

        _clearError();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update water intake: $e');
      return false;
    }
  }

  // Remove water intake
  Future<bool> removeWaterIntake(int intakeId) async {
    try {
      final success = await WaterDatabase.removeWaterIntake(intakeId);

      if (success) {
        // Update daily summary
        await WaterDatabase.updateDailySummary(DateTime.now(), _dailyGoal);

        // Reload data
        await loadTodaysData();

        // Restart reminders if goal is no longer achieved and reminders are enabled
        await WaterNotificationService.rescheduleRemindersIfNeeded();

        _clearError();
        return true;
      } else {
        _setError('Intake record not found');
        return false;
      }
    } catch (e) {
      _setError('Failed to remove water intake: $e');
      return false;
    }
  }

  // Update daily goal
  Future<bool> updateDailyGoal(int newGoal) async {
    if (newGoal < 500 || newGoal > 5000) {
      _setError('Invalid goal. Please enter a value between 500-5000ml');
      return false;
    }

    try {
      // Update in database
      await WaterDatabase.setDailyGoal(newGoal);

      // Update daily summary with new goal
      await WaterDatabase.updateDailySummary(DateTime.now(), newGoal);

      _dailyGoal = newGoal;

      // Send goal changed notification
      // Note: Goal change notification can be implemented later if needed

      // Restart reminders if not achieved and enabled
      if (!isGoalAchieved && _reminderEnabled) {
        await WaterNotificationService.startReminders();
      } else if (isGoalAchieved) {
        await WaterNotificationService.stopReminders();
      }
      notifyListeners();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update daily goal: $e');
      return false;
    }
  }

  // Reset today's intake
  Future<bool> resetTodaysIntake() async {
    try {
      await WaterDatabase.resetTodaysData();
      await loadTodaysData();

      // Restart reminders if enabled
      if (_reminderEnabled) {
        await WaterNotificationService.startReminders();
      }

      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to reset today\'s intake: $e');
      return false;
    }
  }

  // Update reminder settings
  Future<bool> updateReminderSettings(
      {bool? enabled, int? intervalMinutes}) async {
    try {
      // Update settings in database
      final database = await WaterDatabase.database;
      if (enabled != null) {
        await database.insert(
            'settings',
            {
              'setting_key': 'reminders_enabled',
              'setting_value': enabled.toString(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      if (intervalMinutes != null) {
        await database.insert(
            'settings',
            {
              'setting_key': 'reminder_interval_minutes',
              'setting_value': intervalMinutes.toString(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Save settings for persistence
      if (enabled != null) {
        _reminderEnabled = enabled;
      }
      if (intervalMinutes != null) {
        _reminderInterval = intervalMinutes;
      }

      // Save to SharedPreferences for app restart continuity
      await WaterNotificationService.saveReminderSettings(
        enabled: _reminderEnabled,
        intervalMinutes: _reminderInterval,
      );

      // Restart reminders with new settings
      if (_reminderEnabled) {
        final interval = Duration(minutes: _reminderInterval);
        await WaterNotificationService.startReminders(interval: interval);
      } else {
        await WaterNotificationService.stopReminders();
      }

      await loadSettings();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update reminder settings: $e');
      return false;
    }
  }

  // Get water statistics
  Future<Map<String, dynamic>> getWaterStats() async {
    try {
      final stats = await WaterDatabase.getWaterStats();
      return stats;
    } catch (e) {
      print('Error getting water stats: $e');
      return {
        'streakDays': 0,
        'goalAchievedDays': 0,
        'averageDailyIntake': _currentIntake,
        'totalIntakeThisWeek': _currentIntake,
        'todayIntake': _currentIntake,
        'dailyGoal': _dailyGoal,
        'completionPercentage': progressPercent,
      };
    }
  }

  // Get weekly data for history
  Future<List<Map<String, dynamic>>> getWeeklyData() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      return await WaterDatabase.getDailySummaries(startDate, endDate);
    } catch (e) {
      print('Error getting weekly data: $e');
      return [];
    }
  }

  // Get intake records for a specific date
  Future<List<Map<String, dynamic>>> getIntakeForDate(DateTime date) async {
    try {
      return await WaterDatabase.getIntakeForDate(date);
    } catch (e) {
      print('Error getting intake for date: $e');
      return [];
    }
  }

  // Update water intake for a specific date (for editing previous days)
  Future<bool> updateWaterIntakeForDate({
    required int intakeId,
    required int amount,
    required DateTime date,
    String? customType,
  }) async {
    if (amount <= 0 || amount > 2000) {
      _setError('Invalid water amount. Please enter 1-2000ml.');
      return false;
    }

    try {
      final type = customType ?? _getIntakeType(amount);
      
      final success = await WaterDatabase.updateWaterIntake(
        intakeId: intakeId,
        amount: amount,
        type: type,
      );

      if (success) {
        // Update daily summary for that date
        final goal = await WaterDatabase.getDailyGoal();
        await WaterDatabase.updateDailySummary(date, goal);

        // Reload today's data if editing today
        if (date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day) {
          await loadTodaysData();
        }

        _clearError();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update water intake: $e');
      return false;
    }
  }

  // Remove water intake for a specific date (for editing previous days)
  Future<bool> removeWaterIntakeForDate(int intakeId, DateTime date) async {
    try {
      final success = await WaterDatabase.removeWaterIntake(intakeId);

      if (success) {
        // Update daily summary for that date
        final goal = await WaterDatabase.getDailyGoal();
        await WaterDatabase.updateDailySummary(date, goal);

        // Reload today's data if editing today
        if (date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day) {
          await loadTodaysData();
        }

        _clearError();
        return true;
      } else {
        _setError('Intake record not found');
        return false;
      }
    } catch (e) {
      _setError('Failed to remove water intake: $e');
      return false;
    }
  }

  // Get hydration reminders
  Map<String, String> getHydrationReminders() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 9) {
      return {
        'title': 'Morning Hydration 🌅',
        'message': 'Start your day with a glass of water!',
        'suggestion': 'Try adding lemon for extra benefits'
      };
    } else if (hour >= 9 && hour < 12) {
      return {
        'title': 'Mid-Morning Boost 💪',
        'message': 'Keep the momentum going!',
        'suggestion': 'Perfect time for your second glass'
      };
    } else if (hour >= 12 && hour < 15) {
      return {
        'title': 'Afternoon Refresh 🍽️',
        'message': 'Stay hydrated during lunch time',
        'suggestion': 'Have water before and after meals'
      };
    } else if (hour >= 15 && hour < 18) {
      return {
        'title': 'Energy Dip Fighter ⚡',
        'message': 'Beat the afternoon slump with water',
        'suggestion': 'Dehydration can cause fatigue'
      };
    } else if (hour >= 18 && hour < 21) {
      return {
        'title': 'Evening Wind Down 🌆',
        'message': 'Almost there! Keep it up',
        'suggestion': 'Great time to reach your daily goal'
      };
    } else {
      return {
        'title': 'Rest & Recharge 🌙',
        'message': 'Prepare for tomorrow',
        'suggestion': 'Light hydration before bed'
      };
    }
  }

  // Get intake type based on amount
  String _getIntakeType(int amount) {
    if (amount <= 150) return 'Small Sip';
    if (amount <= 250) return 'Regular Drink';
    if (amount <= 400) return 'Big Gulp';
    if (amount <= 600) return 'Large Drink';
    return 'Extra large';
  }

  // Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }

  // Dispose resources
  @override
  void dispose() {
    // New notification service manages its own lifecycle
    super.dispose();
  }

  // Force refresh data
  Future<void> refresh() async {
    await loadTodaysData();
    await loadSettings();
  }

  // Format time for display
  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Get formatted intake for list display
  List<Map<String, dynamic>> getFormattedTodaysIntake() {
    return _todaysIntake.map((intake) {
      return {
        'id': intake['id'],
        'amount': intake['amount'],
        'type': intake['type'],
        'time': intake['time'],
        'timestamp': intake['timestamp'],
      };
    }).toList();
  }
}
