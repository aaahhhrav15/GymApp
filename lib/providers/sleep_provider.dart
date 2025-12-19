import 'package:flutter/material.dart';
import '../models/sleep_model.dart';
import '../database/sleep_database_helper.dart';

class SleepProvider with ChangeNotifier {
  final SleepDatabaseHelper _databaseHelper = SleepDatabaseHelper();

  SleepSchedule? _currentSchedule;
  SleepData? _todaysSleepData;
  List<SleepData> _last7DaysSleepData = [];
  Map<String, Map<String, dynamic>> _weeklySleepDataMap = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  SleepSchedule? get currentSchedule => _currentSchedule;
  SleepData? get todaysSleepData => _todaysSleepData;
  List<SleepData> get last7DaysSleepData => _last7DaysSleepData;
  Map<String, Map<String, dynamic>> get weeklySleepDataMap =>
      _weeklySleepDataMap;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed getters
  String get bedtime => _currentSchedule?.bedtime ?? '22:30';
  String get wakeTime => _currentSchedule?.wakeTime ?? '06:30';
  int get sleepTargetHours => _currentSchedule?.targetHours ?? 8;
  int get sleepTargetMinutes => _currentSchedule?.targetMinutes ?? 0;

  double get todaysSleepHours => _todaysSleepData?.hours ?? 0.0;
  int get todaysSleepQuality => _todaysSleepData?.quality ?? 0;
  double get todaysDeepSleep => _todaysSleepData?.deepSleep ?? 0.0;

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _databaseHelper.initializeWithDefaults();
      await loadAllData();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize sleep data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all data from database
  Future<void> loadAllData() async {
    try {
      await Future.wait([
        _loadCurrentSchedule(),
        _loadTodaysSleepData(),
        _loadLast7DaysSleepData(),
        _loadWeeklySleepDataMap(),
      ]);
      _clearError();
    } catch (e) {
      _setError('Failed to load sleep data: $e');
    }
  }

  Future<void> _loadCurrentSchedule() async {
    _currentSchedule = await _databaseHelper.getCurrentSleepSchedule();
  }

  Future<void> _loadTodaysSleepData() async {
    _todaysSleepData = await _databaseHelper.getTodaysSleepData();
  }

  Future<void> _loadLast7DaysSleepData() async {
    _last7DaysSleepData = await _databaseHelper.getSleepDataForLast7Days();
  }

  Future<void> _loadWeeklySleepDataMap() async {
    _weeklySleepDataMap = await _databaseHelper.getWeeklySleepDataMap();
  }

  // Update sleep schedule
  Future<bool> updateSleepSchedule({
    required String bedtime,
    required String wakeTime,
    required int targetHours,
    required int targetMinutes,
  }) async {
    _setLoading(true);
    try {
      final newSchedule = SleepSchedule(
        bedtime: bedtime,
        wakeTime: wakeTime,
        targetHours: targetHours,
        targetMinutes: targetMinutes,
      );

      await _databaseHelper.insertOrUpdateSleepSchedule(newSchedule);
      await _loadCurrentSchedule();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update sleep schedule: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add or update sleep data for a specific date
  Future<bool> addOrUpdateSleepData({
    required DateTime date,
    required double hours,
    required int quality,
    required double deepSleep,
    String? bedtime,
    String? wakeTime,
  }) async {
    _setLoading(true);
    try {
      final sleepData = SleepData(
        date: _formatDate(date),
        hours: hours,
        quality: quality,
        deepSleep: deepSleep,
        bedtime: bedtime ?? this.bedtime,
        wakeTime: wakeTime ?? this.wakeTime,
      );

      await _databaseHelper.insertSleepData(sleepData);
      await loadAllData();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to save sleep data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get sleep data for a specific date
  Future<SleepData?> getSleepDataForDate(DateTime date) async {
    try {
      return await _databaseHelper.getSleepDataForDate(date);
    } catch (e) {
      _setError('Failed to get sleep data for date: $e');
      return null;
    }
  }

  // Get sleep data for today
  SleepData? getTodaysSleepData() {
    return _todaysSleepData;
  }

  // Get sleep data for a specific day name (Mon, Tue, etc.)
  Map<String, dynamic>? getSleepDataForDay(String dayName) {
    return _weeklySleepDataMap[dayName];
  }

  // Calculate sleep duration from bedtime and wake time
  Duration calculateSleepDuration(String bedtime, String wakeTime) {
    try {
      final bedtimeParts = bedtime.split(':');
      final waketimeParts = wakeTime.split(':');

      final bedHour = int.parse(bedtimeParts[0]);
      final bedMinute = int.parse(bedtimeParts[1]);
      final wakeHour = int.parse(waketimeParts[0]);
      final wakeMinute = int.parse(waketimeParts[1]);

      final bedDateTime = DateTime(2024, 1, 1, bedHour, bedMinute);
      var wakeDateTime = DateTime(2024, 1, 1, wakeHour, wakeMinute);

      // If wake time is before bed time, it means next day
      if (wakeDateTime.isBefore(bedDateTime)) {
        wakeDateTime = wakeDateTime.add(const Duration(days: 1));
      }

      return wakeDateTime.difference(bedDateTime);
    } catch (e) {
      return const Duration(hours: 8); // Default 8 hours
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadAllData();
    notifyListeners();
  }

  // Helper methods
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Generate hourly sleep stages data (for sleep stages chart)
  List<double> generateHourlySleepStages() {
    // Generate 24 hours of sleep stage data based on sleep schedule
    final List<double> stages = List.filled(24, 0.0);

    if (_currentSchedule == null) return stages;

    try {
      final bedtimeParts = _currentSchedule!.bedtime.split(':');
      final waketimeParts = _currentSchedule!.wakeTime.split(':');

      final bedHour = int.parse(bedtimeParts[0]);
      final wakeHour = int.parse(waketimeParts[0]);

      // Simulate sleep stages during sleep hours
      for (int hour = 0; hour < 24; hour++) {
        if ((bedHour > wakeHour && (hour >= bedHour || hour < wakeHour)) ||
            (bedHour < wakeHour && hour >= bedHour && hour < wakeHour)) {
          // During sleep hours - generate realistic sleep stages
          if (hour == bedHour || hour == bedHour + 1) {
            stages[hour] = 2.0 + (hour % 3) * 0.5; // Light sleep at start
          } else if (hour == wakeHour - 1 || hour == wakeHour - 2) {
            stages[hour] = 1.5 + (hour % 2) * 0.3; // Light sleep before waking
          } else {
            // Deep and REM sleep in middle hours
            stages[hour] = 3.0 + (hour % 4) * 0.8;
          }
        } else {
          stages[hour] = 0.0; // Awake
        }
      }
    } catch (e) {
      // Return default pattern if parsing fails
      return [
        4,
        5,
        6,
        6,
        5,
        4,
        3,
        2,
        2,
        3,
        4,
        5,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        3,
        4
      ];
    }

    return stages;
  }

  @override
  void dispose() {
    _databaseHelper.close();
    super.dispose();
  }
}
