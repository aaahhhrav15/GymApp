// lib/services/steps_service.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import '../database/steps_database.dart';

class StepsService {
  // Simplified storage keys (matching native service)
  static const String _dailyStepsKey = 'daily_steps';
  static const String _dateKey = 'steps_date';
  static const String _goalKey = 'steps_daily_goal';
  static const String _deviceStepsKey = 'device_steps_at_midnight';

  // Native method channel for background service
  static const MethodChannel _nativeChannel =
      MethodChannel('flutter.native/helper');

  static StepsService? _instance;
  static StepsService get instance => _instance ??= StepsService._();
  StepsService._();

  StreamSubscription<StepCount>? _stepCountStream;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusStream;

  // Core data - simplified
  int _dailySteps = 0;
  int _dailyGoal = 10000;
  int _deviceStepsAtMidnight = 0;
  String _currentDate = '';
  String _pedestrianStatus = 'unknown';
  bool _isUsingRealPedometer = false;
  bool _isBackgroundServiceActive = false;

  // For validation and safety
  int _lastValidDeviceSteps = 0;
  DateTime _lastUpdateTime = DateTime.now();

  // Hourly tracking
  List<int> _todayHourlySteps = List.filled(24, 0);
  int _lastHour = -1;

  // Controllers for real-time updates
  final StreamController<int> _stepsController =
      StreamController<int>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  // Public getters
  Stream<int> get stepsStream => _stepsController.stream;
  Stream<String> get statusStream => _statusController.stream;
  int get currentSteps => _dailySteps;
  int get dailyGoal => _dailyGoal;
  String get pedestrianStatus => _pedestrianStatus;
  bool get isUsingRealPedometer =>
      _isUsingRealPedometer || _isBackgroundServiceActive;

  // Check if step counting is available and permissions are granted
  Future<bool> get isStepCountingAvailable async {
    try {
      // On iOS, Core Motion doesn't require explicit permission requests
      // It's automatically available if NSMotionUsageDescription is in Info.plist
      if (Platform.isIOS) {
        return true; // Core Motion is available by default on iOS
      }
      
      // On Android, check activity recognition permission
      final activityPermission = await Permission.activityRecognition.status;
      return activityPermission.isGranted;
    } catch (e) {
      print('Error checking step counting availability: $e');
      // On iOS, assume it's available even if there's an error
      return Platform.isIOS;
    }
  }

  // Initialize with background service support
  Future<void> initialize() async {
    try {
      print('Initializing Steps Service with background support...');

      // Initialize database
      await StepsDatabase.checkAndResetWeek();

      // Maintain 30-day history (remove entries older than 30 days)
      await StepsDatabase.maintain30DayHistory();

      // Load stored data first - this is critical for persistence
      await _loadStoredData();
      print('Loaded stored steps: $_dailySteps for date: $_currentDate');

      // Load today's hourly steps from database
      await _loadTodayHourlySteps();

      // Check if we need to reset for new day
      await _checkForNewDay();

      // Request permissions
      await _requestPermissions();

      // Start background service
      await _startBackgroundService();

      // Start listening to pedometer (for when app is active)
      await _startListening();

      // Periodic sync with background service
      _startPeriodicSync();

      print(
          'Steps Service initialized - Daily steps: $_dailySteps (Background: $_isBackgroundServiceActive)');
    } catch (e) {
      print('Error initializing Steps Service: $e');
      // Ensure we have default values
      _dailySteps = 0;
      _dailyGoal = 10000;
      _currentDate = _getTodayString();
    }
  }

  // Start background service
  Future<void> _startBackgroundService() async {
    try {
      if (Platform.isIOS) {
        print('iOS detected: Starting background step tracking with Core Motion');
        try {
          // Start iOS background step tracking
          await _nativeChannel.invokeMethod('startStepCounterService');
          _isBackgroundServiceActive = true;
          print('iOS background step tracking started');
        } catch (e) {
          print('Failed to start iOS background service: $e');
          _isBackgroundServiceActive = false;
        }
        return;
      }

      print('Starting Android background step counter service...');
      final result =
          await _nativeChannel.invokeMethod('startStepCounterService');
      _isBackgroundServiceActive = true;
      print('Android background service started: $result');
    } catch (e) {
      print('Failed to start background service: $e');
      _isBackgroundServiceActive = false;
    }
  }

  // Stop background service
  Future<void> _stopBackgroundService() async {
    try {
      print('Stopping background step counter service...');
      final result =
          await _nativeChannel.invokeMethod('stopStepCounterService');
      _isBackgroundServiceActive = false;
      print('Background service stopped: $result');
    } catch (e) {
      print('Failed to stop background service: $e');
    }
  }

  // Periodic sync with SharedPreferences (updated by background service)
  void _startPeriodicSync() {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _syncWithBackgroundService();
    });
  }

  // Sync with background service data
  Future<void> _syncWithBackgroundService() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backgroundSteps = prefs.getInt(_dailyStepsKey) ?? _dailySteps;
      final backgroundDate = prefs.getString(_dateKey) ?? _currentDate;

      // Check for day change
      if (backgroundDate != _currentDate) {
        await _checkForNewDay();
      }

      // Only update if we have new data
      if (backgroundSteps != _dailySteps || backgroundDate != _currentDate) {
        final oldSteps = _dailySteps;
        final stepIncrement = backgroundSteps > _dailySteps 
            ? backgroundSteps - _dailySteps 
            : 0;

        _dailySteps = backgroundSteps;
        _currentDate = backgroundDate;

        // Update hourly steps if we got new steps
        if (stepIncrement > 0) {
          final currentHour = DateTime.now().hour;
          _todayHourlySteps[currentHour] += stepIncrement;
        }

        // Save to database periodically
        if (_dailySteps % 50 == 0 && _dailySteps > oldSteps) {
          await _saveToDatabase();
          await _saveHourlyStepsToDatabase();
        }

        _stepsController.add(_dailySteps);

        if (_dailySteps != oldSteps) {
          print('Background sync: $_dailySteps steps (was: $oldSteps)');
        }
      }
    } catch (e) {
      print('Error syncing with background service: $e');
    }
  }

  // Force sync with SharedPreferences - always gets the latest value from background service
  Future<void> forceSyncFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backgroundSteps = prefs.getInt(_dailyStepsKey) ?? 0;
      final backgroundDate = prefs.getString(_dateKey) ?? _getTodayString();
      final backgroundGoal = prefs.getInt(_goalKey) ?? 10000;

      final oldSteps = _dailySteps;
      final stepIncrement = backgroundSteps > _dailySteps 
          ? backgroundSteps - _dailySteps 
          : 0;

      // Check for day change
      if (backgroundDate != _currentDate) {
        await _checkForNewDay();
      }

      _dailySteps = backgroundSteps;
      _currentDate = backgroundDate;
      _dailyGoal = backgroundGoal;

      // Update hourly steps if we got new steps
      if (stepIncrement > 0) {
        final currentHour = DateTime.now().hour;
        _todayHourlySteps[currentHour] += stepIncrement;
        await _saveHourlyStepsToDatabase();
      }

      // Always emit the latest value to update UI
      _stepsController.add(_dailySteps);

      print(
          'Force sync from SharedPreferences: $_dailySteps steps (was: $oldSteps) on $_currentDate');
    } catch (e) {
      print('Error force syncing from SharedPreferences: $e');
    }
  }

  // Simple helper methods
  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _checkForNewDay() async {
    final today = _getTodayString();

    if (_currentDate != today) {
      print('New day detected: $today (was: $_currentDate)');

      // Save yesterday's data to database if we had any steps
      if (_dailySteps > 0 && _currentDate.isNotEmpty) {
        // Save to weekly table (for backward compatibility)
        final yesterday = DateTime.parse(_currentDate);
        final dayName = _getDayAbbreviation(yesterday.weekday);
        await StepsDatabase.insertOrUpdateSteps(dayName, _dailySteps);

        // Save to daily history table with hourly breakdown
        await StepsDatabase.insertOrUpdateDailySteps(
          _currentDate,
          _dailySteps,
          _todayHourlySteps,
        );

        print('Saved yesterday\'s steps: $dayName = $_dailySteps');
      }

      // Maintain 30-day history (remove oldest entries)
      await StepsDatabase.maintain30DayHistory();

      // Reset for new day
      _dailySteps = 0;
      _currentDate = today;
      _deviceStepsAtMidnight = 0; // Will be set when we get first reading
      _todayHourlySteps = List.filled(24, 0);
      _lastHour = -1;

      // Initialize today's entry in database
      await StepsDatabase.insertOrUpdateDailySteps(
        today,
        0,
        List.filled(24, 0),
      );

      await _saveStoredData();
      _stepsController.add(_dailySteps);
    }
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    print('Requesting permissions for step tracking...');

    // On iOS, Core Motion doesn't require explicit permission requests
    // The system will show NSMotionUsageDescription automatically when needed
    if (Platform.isIOS) {
      print('iOS detected: Core Motion permissions are handled automatically');
      return;
    }

    // Android-specific permissions
    // Check activity recognition permission
    final activityStatus = await Permission.activityRecognition.status;
    print('Activity Recognition permission status: $activityStatus');

    if (activityStatus.isDenied || activityStatus.isPermanentlyDenied) {
      final result = await Permission.activityRecognition.request();
      print('Activity Recognition permission request result: $result');

      // Do not auto-open settings; let UI handle optional prompt
    }

    // Check sensors permission (for older Android versions)
    final sensorsStatus = await Permission.sensors.status;
    print('Sensors permission status: $sensorsStatus');

    if (sensorsStatus.isDenied || sensorsStatus.isPermanentlyDenied) {
      final result = await Permission.sensors.request();
      print('Sensors permission request result: $result');
    }

    // Verify permissions are granted
    final finalActivityStatus = await Permission.activityRecognition.status;
    if (!finalActivityStatus.isGranted) {
      print(
          'Warning: Activity Recognition permission not granted. Step tracking may not work properly.');
    } else {
      print('Activity Recognition permission granted successfully!');
    }
  }

  // Start listening to step count and pedestrian status
  Future<void> _startListening() async {
    try {
      print('Attempting to start pedometer streams...');

      // On iOS, Core Motion doesn't require explicit permission checks
      // On Android, check if permissions are granted before starting
      if (!Platform.isIOS) {
        final activityPermission = await Permission.activityRecognition.status;
        if (!activityPermission.isGranted) {
          throw Exception('Activity Recognition permission not granted');
        }
      }

      _stepCountStream = Pedometer.stepCountStream.listen(
        (StepCount event) async {
          print('Real step count received: ${event.steps}');
          await _handleStepCount(event);
        },
        onError: (error) {
          print('Step Count Error: $error');
          _handleStepCountError(error);
        },
      );

      _pedestrianStatusStream = Pedometer.pedestrianStatusStream.listen(
        (PedestrianStatus event) {
          print('Pedestrian status update: ${event.status}');
          _handlePedestrianStatus(event);
        },
        onError: (error) {
          print('Pedestrian Status Error: $error');
        },
      );

      print('Started listening to pedometer streams successfully');
      _isUsingRealPedometer = true;
    } catch (e) {
      print('Error starting pedometer: $e');
      _isUsingRealPedometer = false;
      //print('Falling back to simulated steps due to error');
      //_simulateSteps();
    }
  }

  // Simple and accurate step count handling
  Future<void> _handleStepCount(StepCount event) async {
    final currentDeviceSteps = event.steps;
    final now = DateTime.now();
    _isUsingRealPedometer = true;

    print('Device total steps: $currentDeviceSteps');

    // Validate the reading
    if (!_isValidStepReading(currentDeviceSteps)) {
      print('Invalid step reading, ignoring: $currentDeviceSteps');
      return;
    }

    // Initialize baseline for new day or first run
    if (_deviceStepsAtMidnight == 0) {
      // If we have existing daily steps, calculate baseline from that
      // Otherwise, assume we're starting fresh today
      if (_dailySteps > 0) {
        _deviceStepsAtMidnight = currentDeviceSteps - _dailySteps;
        print(
            'Set device baseline from existing steps: $_deviceStepsAtMidnight (current daily: $_dailySteps, device total: $currentDeviceSteps)');
      } else {
        // Starting fresh - use current device steps as baseline
        _deviceStepsAtMidnight = currentDeviceSteps;
        print(
            'Set device baseline for new day: $_deviceStepsAtMidnight (device total: $currentDeviceSteps)');
      }
      await _saveStoredData();
    }

    // Calculate today's steps - this is the accurate count from device
    final newDailySteps = currentDeviceSteps - _deviceStepsAtMidnight;

    // Validate the calculated daily steps
    if (newDailySteps < 0) {
      print('Device may have reset or baseline incorrect. Recalculating baseline.');
      // Recalculate baseline - assume current device steps represent today's start
      _deviceStepsAtMidnight = currentDeviceSteps - _dailySteps;
      if (_deviceStepsAtMidnight < 0) {
        // If still negative, device likely reset - start fresh
        _deviceStepsAtMidnight = currentDeviceSteps;
        _dailySteps = 0;
      }
      await _saveStoredData();
      return;
    }

    // Apply reasonable limits (max ~40k steps per day)
    if (newDailySteps > 40000) {
      print('Unreasonable step count detected: $newDailySteps, ignoring');
      return;
    }

    // Only update if we have new steps and they're reasonable
    if (newDailySteps > _dailySteps) {
      final stepIncrement = newDailySteps - _dailySteps;

      // Validate increment is reasonable (max ~2000 steps between readings)
      if (stepIncrement > 2000) {
        print(
            'Large step increment detected: $stepIncrement, may be catch-up from app being closed');
        // Allow it but log it
      }

      _dailySteps = newDailySteps;
      _lastValidDeviceSteps = currentDeviceSteps;
      _lastUpdateTime = now;

      // Update hourly steps for current hour
      final currentHour = now.hour;
      if (_lastHour != currentHour) {
        // New hour - ensure we have the correct baseline
        _lastHour = currentHour;
      }

      // Add increment to current hour
      _todayHourlySteps[currentHour] += stepIncrement;

      await _saveStoredData();

      // Save to database every 50 steps or every 2 minutes
      final timeSinceLastSave = now.difference(_lastUpdateTime).inMinutes;
      if (stepIncrement >= 50 || timeSinceLastSave >= 2) {
        await _saveToDatabase();
        // Also save hourly data
        await _saveHourlyStepsToDatabase();
      }

      _stepsController.add(_dailySteps);
      print('Daily steps updated: $_dailySteps (+$stepIncrement) at hour $currentHour');
    }
  }

  // Validate step readings to prevent bad data
  bool _isValidStepReading(int deviceSteps) {
    // Basic validation
    if (deviceSteps < 0) return false;

    // Check for unreasonable jumps
    if (_lastValidDeviceSteps > 0) {
      final difference = (deviceSteps - _lastValidDeviceSteps).abs();
      final timeDiff = DateTime.now().difference(_lastUpdateTime).inMinutes;

      // Allow up to 200 steps per minute (very fast walking/running)
      final maxReasonableSteps = math.max(2000, timeDiff * 200);

      if (difference > maxReasonableSteps) {
        print(
            'Step reading validation failed: difference=$difference in ${timeDiff}min');
        return false;
      }
    }

    return true;
  }

  // Handle step count errors
  void _handleStepCountError(dynamic error) {
    print('Pedometer not available or permission denied: $error');
    //_simulateSteps();
  }

  // Handle pedestrian status updates
  void _handlePedestrianStatus(PedestrianStatus event) {
    _pedestrianStatus = event.status;
    _statusController.add(_pedestrianStatus);
    print('Pedestrian status: $_pedestrianStatus');
  }

  // Simulate steps for testing
  // void _simulateSteps() {
  //   print('WARNING: Using simulated step data. Real pedometer not available.');
  //   _isUsingRealPedometer = false;

  //   _simulationTimer =
  //       Timer.periodic(const Duration(seconds: 5), (timer) async {
  //     if (_pedestrianStatus == 'walking' || math.Random().nextDouble() > 0.7) {
  //       final additionalSteps = math.Random().nextInt(15) + 5;
  //       _currentSteps += additionalSteps;

  //       // Update hourly data
  //       final currentHour = DateTime.now().hour;
  //       _todayHourlySteps[currentHour] += additionalSteps;

  //       await _saveStepsData();
  //       await _saveHourlyData();
  //       // Save to database every 50 steps for testing
  //       if (_currentSteps % 50 == 0) {
  //         await _saveToDatabase();
  //       }
  //       _stepsController.add(_currentSteps);
  //       print('Simulated steps: $_currentSteps (+$additionalSteps)');
  //     }
  //   });

  //   _statusTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
  //     final statuses = ['walking', 'stopped', 'unknown'];
  //     _pedestrianStatus = statuses[math.Random().nextInt(statuses.length)];
  //     _statusController.add(_pedestrianStatus);
  //   });
  // }

  // Retry pedometer setup (useful after permission grant)
  Future<void> retryPedometerSetup() async {
    print('Retrying pedometer setup...');

    // Cancel existing streams
    await _stepCountStream?.cancel();
    await _pedestrianStatusStream?.cancel();

    // Retry initialization
    await _requestPermissions();
    await _startListening();
  }

  // Save current day's steps to database (weekly table for backward compatibility)
  Future<void> _saveToDatabase() async {
    if (_dailySteps == 0) return;

    final today = _getDayAbbreviation(DateTime.now().weekday);

    try {
      await StepsDatabase.insertOrUpdateSteps(today, _dailySteps);
      print('Saved steps to database: $today = $_dailySteps');
    } catch (e) {
      print('Error saving steps to database: $e');
    }
  }

  // Save hourly steps to daily history database
  Future<void> _saveHourlyStepsToDatabase() async {
    final today = _getTodayString();

    try {
      await StepsDatabase.insertOrUpdateDailySteps(
        today,
        _dailySteps,
        _todayHourlySteps,
      );
      print('Saved hourly steps to database for $today');
    } catch (e) {
      print('Error saving hourly steps to database: $e');
    }
  }

  // Load today's hourly steps from database
  Future<void> _loadTodayHourlySteps() async {
    final today = _getTodayString();

    try {
      final dailyData = await StepsDatabase.getDailySteps(today);
      if (dailyData != null) {
        final hourlyList = dailyData['hourly_steps'] as List<dynamic>;
        _todayHourlySteps = hourlyList.map((e) => e as int).toList();
        _dailySteps = dailyData['total_steps'] as int;
        print('Loaded hourly steps from database for $today: $_dailySteps total');
      } else {
        // Initialize with zeros if no data
        _todayHourlySteps = List.filled(24, 0);
        print('No hourly data found for $today, initialized with zeros');
      }
    } catch (e) {
      print('Error loading hourly steps from database: $e');
      _todayHourlySteps = List.filled(24, 0);
    }
  }

  // Load stored data - simplified
  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();

    _dailySteps = prefs.getInt(_dailyStepsKey) ?? 0;
    _dailyGoal = prefs.getInt(_goalKey) ?? 10000;
    _deviceStepsAtMidnight = prefs.getInt(_deviceStepsKey) ?? 0;
    _currentDate = prefs.getString(_dateKey) ?? _getTodayString();

    print('Loaded stored data:');
    print('  Daily steps: $_dailySteps');
    print('  Daily goal: $_dailyGoal');
    print('  Date: $_currentDate');
    print('  Device baseline: $_deviceStepsAtMidnight');

    // Immediately notify listeners with loaded data
    _stepsController.add(_dailySteps);
  }

  // Save stored data - simplified
  Future<void> _saveStoredData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_dailyStepsKey, _dailySteps);
    await prefs.setInt(_goalKey, _dailyGoal);
    await prefs.setInt(_deviceStepsKey, _deviceStepsAtMidnight);
    await prefs.setString(_dateKey, _currentDate);
  }

  // Get hourly steps data - returns actual tracked hourly data
  Future<List<int>> getHourlySteps([String? day]) async {
    final today = _getTodayString();
    final todayDayName = _getDayAbbreviation(DateTime.now().weekday);

    // If requesting today or no day specified, return today's hourly data
    if (day == null || day == 'Today' || day == todayDayName) {
      // Return current hourly steps (live data)
      return List.from(_todayHourlySteps);
    }

    // For historical days, try to get from database
    // Convert day name to date (this is approximate - we'll need to calculate based on current week)
    try {
      // For weekly view, we need to calculate the date
      // This is a simplified approach - in a full implementation, you'd track dates properly
      final now = DateTime.now();
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final dayIndex = days.indexOf(day);
      if (dayIndex == -1) {
        return List.filled(24, 0);
      }

      // Calculate the date for this day in current week
      final currentDayIndex = now.weekday - 1; // Monday = 0
      final daysDiff = dayIndex - currentDayIndex;
      final targetDate = now.add(Duration(days: daysDiff));
      final targetDateString = _getDateString(targetDate);

      // Get from daily history
      final hourlySteps = await StepsDatabase.getHourlyStepsForDate(targetDateString);
      return hourlySteps;
    } catch (e) {
      print('Error getting hourly steps for day $day: $e');
      return List.filled(24, 0);
    }
  }

  // Helper to get date string
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Get weekly steps data from database
  Future<Map<String, int>> getWeeklySteps() async {
    try {
      // Get data from database
      Map<String, int> weeklySteps = await StepsDatabase.getWeeklySteps();

      // Add today's current steps
      final today = _getDayAbbreviation(DateTime.now().weekday);
      weeklySteps[today] = _dailySteps;

      print('Weekly steps: $weeklySteps');
      return weeklySteps;
    } catch (e) {
      print('Error getting weekly steps from database: $e');
      return {
        'Mon': 0,
        'Tue': 0,
        'Wed': 0,
        'Thu': 0,
        'Fri': 0,
        'Sat': 0,
        'Sun': 0,
      };
    }
  }

  // Set daily goal
  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;
    await _saveStoredData();
    print('Daily goal set to: $goal');
  }

  // Add steps manually (for testing)
  Future<void> addSteps(int steps) async {
    _dailySteps += steps;
    await _saveStoredData();
    await _saveToDatabase();

    _stepsController.add(_dailySteps);
    print('Manually added $steps steps. Total: $_dailySteps');
  }

  // Add some test data (for debugging)
  Future<void> addTestDataForToday() async {
    _dailySteps += 500;
    await _saveStoredData();
    _stepsController.add(_dailySteps);
    print('Added 500 test steps. Total: $_dailySteps');
  }

  // Helper method to get day abbreviation
  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return 'Mon';
    }
  }

  // Simple sync method for app resume
  Future<void> syncOnAppResume() async {
    try {
      print('Syncing steps on app resume...');
      await _checkForNewDay();
      await forceSyncFromSharedPreferences(); // Force sync latest data from background service
      print('App resume sync completed - Current steps: $_dailySteps');
    } catch (e) {
      print('Error syncing on app resume: $e');
    }
  }

  // Debug method to check tracking status
  Map<String, dynamic> getTrackingStatus() {
    return {
      'dailySteps': _dailySteps,
      'dailyGoal': _dailyGoal,
      'deviceStepsAtMidnight': _deviceStepsAtMidnight,
      'currentDate': _currentDate,
      'isUsingRealPedometer': _isUsingRealPedometer,
      'pedestrianStatus': _pedestrianStatus,
      'lastValidDeviceSteps': _lastValidDeviceSteps,
    };
  }

  // Helper methods
  bool isGoalAchieved() => _dailySteps >= _dailyGoal;
  double getProgressPercentage() => (_dailySteps / _dailyGoal).clamp(0.0, 1.0);
  int getRemainingSteps() => math.max(0, _dailyGoal - _dailySteps);

  void dispose() {
    _stepCountStream?.cancel();
    _pedestrianStatusStream?.cancel();
    _stepsController.close();
    _statusController.close();

    // Optionally stop background service (uncomment if needed)
    // _stopBackgroundService();
  }
}
