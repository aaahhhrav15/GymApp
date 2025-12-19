// lib/services/water_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WaterService {
  // SharedPreferences keys
  static const String _waterDataKey = 'water_data';
  static const String _lastResetDateKey = 'last_reset_date';
  static const String _dailyGoalKey = 'water_daily_goal';
  static const String _weeklyDataKey = 'weekly_water_data';

  // Default values
  static const int defaultDailyGoal = 2000; // ml
  static const int defaultCupSize = 250; // ml

  // Get today's date string (YYYY-MM-DD)
  static String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Check if it's a new day and reset if needed
  static Future<bool> checkAndResetIfNewDay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();
      final lastResetDate = prefs.getString(_lastResetDateKey);

      if (lastResetDate != today) {
        // It's a new day, save yesterday's data to weekly and reset
        await _saveToWeeklyData();
        await _resetDailyData();
        await prefs.setString(_lastResetDateKey, today);
        return true; // Data was reset
      }
      return false; // No reset needed
    } catch (e) {
      print('Error checking reset: $e');
      return false;
    }
  }

  // Save current day's data to weekly history before reset
  static Future<void> _saveToWeeklyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayString =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      // Get yesterday's data
      final yesterdayDataString =
          prefs.getString('${_waterDataKey}_$yesterdayString');
      if (yesterdayDataString != null) {
        final yesterdayData = jsonDecode(yesterdayDataString);

        // Load existing weekly data
        final weeklyDataString = prefs.getString(_weeklyDataKey);
        Map<String, dynamic> weeklyData = {};
        if (weeklyDataString != null) {
          weeklyData = Map<String, dynamic>.from(jsonDecode(weeklyDataString));
        }

        // Safely get intake history count
        int totalDrinks = 0;
        if (yesterdayData['intakeHistory'] != null &&
            yesterdayData['intakeHistory'] is List) {
          totalDrinks = (yesterdayData['intakeHistory'] as List).length;
        }

        // Add yesterday's summary to weekly data
        weeklyData[yesterdayString] = {
          'totalIntake': yesterdayData['currentIntake'] ?? 0,
          'goalAchieved':
              (yesterdayData['currentIntake'] ?? 0) >= await getDailyGoal(),
          'totalDrinks': totalDrinks,
          'date': yesterdayString,
        };

        // Keep only last 30 days
        final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
        weeklyData.removeWhere((key, value) {
          try {
            final date = DateTime.parse(key);
            return date.isBefore(cutoffDate);
          } catch (e) {
            return true; // Remove invalid entries
          }
        });

        // Save updated weekly data
        await prefs.setString(_weeklyDataKey, jsonEncode(weeklyData));
      }
    } catch (e) {
      print('Error saving to weekly data: $e');
    }
  }

  // Reset daily data
  static Future<void> _resetDailyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();

      final initialData = {
        'currentIntake': 0,
        'intakeHistory': [],
        'lastUpdated': DateTime.now().toIso8601String(),
        'date': today,
      };

      await prefs.setString('${_waterDataKey}_$today', jsonEncode(initialData));
    } catch (e) {
      print('Error resetting daily data: $e');
    }
  }

  // Get current water data
  static Future<Map<String, dynamic>> getCurrentWaterData() async {
    try {
      await checkAndResetIfNewDay(); // Always check for reset first

      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();
      final waterDataString = prefs.getString('${_waterDataKey}_$today');

      if (waterDataString != null) {
        final data = jsonDecode(waterDataString);

        // Safely convert intake history
        List<Map<String, dynamic>> intakeHistory = [];
        if (data['intakeHistory'] != null) {
          final historyData = data['intakeHistory'];
          if (historyData is List) {
            for (var item in historyData) {
              if (item is Map) {
                intakeHistory.add(Map<String, dynamic>.from(item));
              }
            }
          }
        }

        return {
          'currentIntake': data['currentIntake'] ?? 0,
          'intakeHistory': intakeHistory,
          'currentCups':
              ((data['currentIntake'] ?? 0) / defaultCupSize).round(),
          'lastUpdated': data['lastUpdated'],
        };
      } else {
        // No data for today, create initial data
        final initialData = {
          'currentIntake': 0,
          'intakeHistory': <Map<String, dynamic>>[],
          'currentCups': 0,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        await _saveTodaysData(initialData);
        return initialData;
      }
    } catch (e) {
      print('Error getting current water data: $e');
      return {
        'currentIntake': 0,
        'intakeHistory': <Map<String, dynamic>>[],
        'currentCups': 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  // Add water intake
  static Future<Map<String, dynamic>> addWaterIntake(int amount,
      {String? customType}) async {
    try {
      final currentData = await getCurrentWaterData();
      final now = DateTime.now();

      // Create intake record
      final intakeRecord = {
        'time':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        'amount': amount,
        'type': customType ?? _getIntakeType(amount),
        'timestamp': now.toIso8601String(),
        'id': now.millisecondsSinceEpoch.toString(), // Unique ID for deletion
      };

      // Safely get and update intake history
      List<Map<String, dynamic>> intakeHistory = [];
      if (currentData['intakeHistory'] is List) {
        for (var item in currentData['intakeHistory']) {
          if (item is Map) {
            intakeHistory.add(Map<String, dynamic>.from(item));
          }
        }
      }
      intakeHistory.add(intakeRecord);

      // Update data
      final updatedData = {
        'currentIntake': (currentData['currentIntake'] as int) + amount,
        'intakeHistory': intakeHistory,
        'currentCups':
            (((currentData['currentIntake'] as int) + amount) / defaultCupSize)
                .round(),
        'lastUpdated': now.toIso8601String(),
      };

      await _saveTodaysData(updatedData);
      return {
        'success': true,
        'message': 'Added ${amount}ml water successfully!',
        'data': updatedData,
      };
    } catch (e) {
      print('Error adding water intake: $e');
      return {
        'success': false,
        'message': 'Failed to add water intake: $e',
      };
    }
  }

  // Remove water intake by ID
  static Future<Map<String, dynamic>> removeWaterIntake(String intakeId) async {
    try {
      final currentData = await getCurrentWaterData();

      // Safely get intake history
      List<Map<String, dynamic>> intakeHistory = [];
      if (currentData['intakeHistory'] is List) {
        for (var item in currentData['intakeHistory']) {
          if (item is Map) {
            intakeHistory.add(Map<String, dynamic>.from(item));
          }
        }
      }

      // Find and remove the intake record
      final intakeIndex =
          intakeHistory.indexWhere((intake) => intake['id'] == intakeId);
      if (intakeIndex == -1) {
        return {
          'success': false,
          'message': 'Intake record not found',
        };
      }

      final removedIntake = intakeHistory.removeAt(intakeIndex);
      final removedAmount = removedIntake['amount'] as int;

      // Update data
      final updatedData = {
        'currentIntake': ((currentData['currentIntake'] as int) - removedAmount)
            .clamp(0, double.infinity)
            .toInt(),
        'intakeHistory': intakeHistory,
        'currentCups': ((((currentData['currentIntake'] as int) - removedAmount)
                    .clamp(0, double.infinity)) /
                defaultCupSize)
            .round(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await _saveTodaysData(updatedData);
      return {
        'success': true,
        'message': 'Removed ${removedAmount}ml from intake',
        'data': updatedData,
      };
    } catch (e) {
      print('Error removing water intake: $e');
      return {
        'success': false,
        'message': 'Failed to remove water intake: $e',
      };
    }
  }

  // Get daily goal
  static Future<int> getDailyGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_dailyGoalKey) ?? defaultDailyGoal;
    } catch (e) {
      return defaultDailyGoal;
    }
  }

  // Set daily goal
  static Future<bool> setDailyGoal(int goal) async {
    try {
      if (goal < 500 || goal > 5000) {
        return false; // Invalid goal
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dailyGoalKey, goal);
      return true;
    } catch (e) {
      print('Error setting daily goal: $e');
      return false;
    }
  }

  // Get target cups based on daily goal
  static Future<int> getTargetCups() async {
    final goal = await getDailyGoal();
    return (goal / defaultCupSize).round();
  }

  // Reset today's intake
  static Future<Map<String, dynamic>> resetTodaysIntake() async {
    try {
      final resetData = {
        'currentIntake': 0,
        'intakeHistory': <Map<String, dynamic>>[],
        'currentCups': 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await _saveTodaysData(resetData);
      return {
        'success': true,
        'message': 'Today\'s intake has been reset',
        'data': resetData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to reset intake: $e',
      };
    }
  }

  // Get weekly/historical data
  static Future<Map<String, dynamic>> getWeeklyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weeklyDataString = prefs.getString(_weeklyDataKey);

      if (weeklyDataString != null) {
        final weeklyData = jsonDecode(weeklyDataString);

        // Convert to list and sort by date
        final dataList = weeklyData.entries.map((entry) {
          return {
            'date': entry.key,
            ...entry.value,
          };
        }).toList();

        dataList.sort(
            (a, b) => b['date'].compareTo(a['date'])); // Most recent first

        return {
          'success': true,
          'data': dataList,
        };
      } else {
        return {
          'success': true,
          'data': [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get weekly data: $e',
        'data': [],
      };
    }
  }

  // Get water intake statistics
  static Future<Map<String, dynamic>> getWaterStats() async {
    try {
      final currentData = await getCurrentWaterData();
      final weeklyResult = await getWeeklyData();
      final weeklyData = weeklyResult['data'] as List;
      final dailyGoal = await getDailyGoal();

      // Calculate statistics
      int streakDays = 0;
      int totalDaysTracked = weeklyData.length;
      int goalAchievedDays = 0;
      int totalIntakeThisWeek = currentData['currentIntake'];

      // Count streak and goal achievements
      for (var dayData in weeklyData) {
        if (dayData['goalAchieved'] == true) {
          goalAchievedDays++;
          streakDays++;
        } else {
          if (streakDays > 0) break; // Streak broken
        }

        // Add to weekly total (last 7 days)
        if (weeklyData.indexOf(dayData) < 7) {
          totalIntakeThisWeek += (dayData['totalIntake'] as int? ?? 0);
        }
      }

      // Check if today's goal is achieved
      bool todayGoalAchieved = currentData['currentIntake'] >= dailyGoal;
      if (todayGoalAchieved) {
        streakDays++; // Include today in streak
      }

      double averageDailyIntake = totalDaysTracked > 0
          ? (weeklyData
                      .map((d) => d['totalIntake'] as int? ?? 0)
                      .fold(0, (a, b) => a + b) +
                  currentData['currentIntake']) /
              (totalDaysTracked + 1)
          : currentData['currentIntake'].toDouble();

      return {
        'currentIntake': currentData['currentIntake'],
        'dailyGoal': dailyGoal,
        'todayGoalAchieved': todayGoalAchieved,
        'streakDays': streakDays,
        'goalAchievedDays': goalAchievedDays,
        'totalDaysTracked': totalDaysTracked + 1, // Include today
        'averageDailyIntake': averageDailyIntake.round(),
        'totalIntakeThisWeek': totalIntakeThisWeek,
        'completionPercentage':
            ((currentData['currentIntake'] / dailyGoal) * 100)
                .clamp(0, 100)
                .round(),
      };
    } catch (e) {
      print('Error getting water stats: $e');
      return {
        'currentIntake': 0,
        'dailyGoal': defaultDailyGoal,
        'todayGoalAchieved': false,
        'streakDays': 0,
        'goalAchievedDays': 0,
        'totalDaysTracked': 1,
        'averageDailyIntake': 0,
        'totalIntakeThisWeek': 0,
        'completionPercentage': 0,
      };
    }
  }

  // Save today's data to SharedPreferences
  static Future<void> _saveTodaysData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();

      final dataToSave = {
        ...data,
        'date': today,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await prefs.setString('${_waterDataKey}_$today', jsonEncode(dataToSave));
    } catch (e) {
      print('Error saving today\'s data: $e');
    }
  }

  // Determine intake type based on amount
  static String _getIntakeType(int amount) {
    if (amount <= 150) return 'Small sip';
    if (amount <= 250) return 'Regular drink';
    if (amount <= 400) return 'Big gulp';
    if (amount <= 600) return 'Large drink';
    return 'Extra large';
  }

  // Clear all water data (for testing/reset purposes)
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((key) =>
              key.startsWith(_waterDataKey) ||
              key == _lastResetDateKey ||
              key == _dailyGoalKey ||
              key == _weeklyDataKey)
          .toList();

      for (String key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  // Initialize water service (call this on app start)
  static Future<void> initialize() async {
    try {
      await checkAndResetIfNewDay();

      // Ensure we have today's data structure
      final currentData = await getCurrentWaterData();
      if (currentData['currentIntake'] == null) {
        await _resetDailyData();
      }
    } catch (e) {
      print('Error initializing water service: $e');
    }
  }

  // Get today's intake history with more details
  static Future<List<Map<String, dynamic>>> getTodaysIntakeHistory() async {
    try {
      final currentData = await getCurrentWaterData();

      // Safely convert intake history
      List<Map<String, dynamic>> intakeHistory = [];
      if (currentData['intakeHistory'] is List) {
        for (var item in currentData['intakeHistory']) {
          if (item is Map) {
            intakeHistory.add(Map<String, dynamic>.from(item));
          }
        }
      }

      return intakeHistory;
    } catch (e) {
      print('Error getting today\'s intake history: $e');
      return [];
    }
  }

  // Get hydration reminders (you can expand this for notifications)
  static Map<String, String> getHydrationReminders() {
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

  // Export data for sharing
  static Future<String> exportWaterData() async {
    try {
      final currentData = await getCurrentWaterData();
      final weeklyResult = await getWeeklyData();
      final stats = await getWaterStats();

      final exportData = {
        'todaysData': currentData,
        'weeklyData': weeklyResult['data'],
        'statistics': stats,
        'exportDate': DateTime.now().toIso8601String(),
      };

      return jsonEncode(exportData);
    } catch (e) {
      return jsonEncode({'error': 'Failed to export data: $e'});
    }
  }
}
