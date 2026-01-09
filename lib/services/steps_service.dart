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
  Timer? _periodicSyncTimer;
  Timer? _healthCheckTimer;

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
  DateTime _lastBackgroundServiceCheck = DateTime.now();
  int _consecutiveHealthCheckFailures = 0;
  
  // Synchronization lock to prevent race conditions
  bool _isUpdating = false;
  
  // Timezone tracking for travelers
  String? _lastKnownTimezone;

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
      
      // Start health check monitoring
      _startHealthCheckMonitoring();

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
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!_isUpdating) {
        await _syncWithBackgroundService();
      }
    });
  }
  
  // Health check monitoring for background service
  void _startHealthCheckMonitoring() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _performHealthCheck();
    });
  }
  
  // Perform health check on background service
  Future<void> _performHealthCheck() async {
    try {
      // Check if background service is still active
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateTime = prefs.getString('${_dateKey}_last_update');
      
      if (lastUpdateTime != null) {
        final lastUpdate = DateTime.parse(lastUpdateTime);
        final timeSinceUpdate = DateTime.now().difference(lastUpdate);
        
        // If no update in last 10 minutes and service should be active, restart it
        if (timeSinceUpdate.inMinutes > 10 && _isBackgroundServiceActive) {
          print('Health check: Background service appears inactive (last update: ${timeSinceUpdate.inMinutes} min ago)');
          _consecutiveHealthCheckFailures++;
          
          if (_consecutiveHealthCheckFailures >= 2) {
            print('Health check: Restarting background service after ${_consecutiveHealthCheckFailures} failures');
            await _restartBackgroundService();
            _consecutiveHealthCheckFailures = 0;
          }
        } else {
          _consecutiveHealthCheckFailures = 0; // Reset on success
        }
      }
      
      // Check if pedometer stream is still active
      if (_isUsingRealPedometer && _stepCountStream == null) {
        print('Health check: Pedometer stream lost, attempting to restart...');
        await _startListening();
      }
      
      _lastBackgroundServiceCheck = DateTime.now();
    } catch (e) {
      print('Error during health check: $e');
    }
  }
  
  // Restart background service
  Future<void> _restartBackgroundService() async {
    try {
      print('Restarting background service...');
      await _stopBackgroundService();
      await Future.delayed(const Duration(seconds: 1));
      await _startBackgroundService();
      print('Background service restarted successfully');
    } catch (e) {
      print('Error restarting background service: $e');
    }
  }

  // Sync with background service data
  Future<void> _syncWithBackgroundService() async {
    if (_isUpdating) return; // Prevent concurrent updates
    
    _isUpdating = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final backgroundSteps = prefs.getInt(_dailyStepsKey) ?? _dailySteps;
      final backgroundDate = prefs.getString(_dateKey) ?? _currentDate;

      // Update last sync time for health check
      await prefs.setString('${_dateKey}_last_update', DateTime.now().toIso8601String());

      // Check for day change (with timezone awareness)
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

        // Save to database periodically
        if (_dailySteps % 50 == 0 && _dailySteps > oldSteps) {
          await _saveToDatabase();
        }

        _stepsController.add(_dailySteps);

        if (_dailySteps != oldSteps) {
          print('Background sync: $_dailySteps steps (was: $oldSteps)');
        }
      }
    } catch (e) {
      print('Error syncing with background service: $e');
    } finally {
      _isUpdating = false;
    }
  }

  // Force sync - Single Source of Truth pattern
  // Priority: Database > SharedPreferences > In-memory
  Future<void> forceSyncFromSharedPreferences() async {
    if (_isUpdating) return;
    
    _isUpdating = true;
    try {
      final today = _getTodayString();
      
      // First, try to get from database (single source of truth)
      int syncedSteps = 0;
      try {
        final dbData = await StepsDatabase.getDailySteps(today);
        if (dbData != null && dbData['total_steps'] != null) {
          syncedSteps = dbData['total_steps'] as int;
          print('Force sync: Loaded from database: $syncedSteps');
        }
      } catch (e) {
        print('Force sync: Could not load from database: $e');
      }
      
      // Fallback to SharedPreferences if database doesn't have data
      if (syncedSteps == 0) {
        final prefs = await SharedPreferences.getInstance();
        syncedSteps = prefs.getInt(_dailyStepsKey) ?? _dailySteps;
        final backgroundDate = prefs.getString(_dateKey) ?? today;
        final backgroundGoal = prefs.getInt(_goalKey) ?? _dailyGoal;

        // Check for day change
        if (backgroundDate != _currentDate) {
          await _checkForNewDay();
        }

        _dailySteps = syncedSteps;
        _currentDate = backgroundDate;
        _dailyGoal = backgroundGoal;
      } else {
        // If we got data from database, use it and update SharedPreferences cache
        final oldSteps = _dailySteps;
        _dailySteps = syncedSteps;
        
        // Update SharedPreferences cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_dailyStepsKey, _dailySteps);
        await prefs.setString(_dateKey, today);
        
        print('Force sync: Updated from database: $_dailySteps (was: $oldSteps)');
      }

      // Always emit the latest value to update UI
      _stepsController.add(_dailySteps);

      print('Force sync completed: $_dailySteps steps on $_currentDate');
    } catch (e) {
      print('Error force syncing: $e');
    } finally {
      _isUpdating = false;
    }
  }

  // Simple helper methods with timezone awareness
  String _getTodayString() {
    final now = DateTime.now();
    final timezone = now.timeZoneName;
    
    // Detect timezone changes (for travelers)
    if (_lastKnownTimezone != null && _lastKnownTimezone != timezone) {
      print('Timezone change detected: $_lastKnownTimezone -> $timezone');
      // Recheck day change when timezone changes
      _checkForNewDay();
    }
    
    _lastKnownTimezone = timezone;
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
  
  // Get today's date in UTC for consistency
  String _getTodayStringUTC() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _checkForNewDay() async {
    final today = _getTodayString();
    final todayUTC = _getTodayStringUTC();

    // Check both local and UTC dates to handle timezone edge cases
    if (_currentDate != today && _currentDate != todayUTC) {
      print('New day detected: $today (was: $_currentDate, UTC: $todayUTC)');

      try {
        // Save yesterday's data to database if we had any steps
        if (_dailySteps > 0 && _currentDate.isNotEmpty) {
          try {
            // Parse the old date (could be local or UTC)
            DateTime? yesterday;
            try {
              yesterday = DateTime.parse(_currentDate);
            } catch (e) {
              // If parsing fails, use current date minus 1 day
              yesterday = DateTime.now().subtract(const Duration(days: 1));
            }
            
            final dayName = _getDayAbbreviation(yesterday.weekday);
            await StepsDatabase.insertOrUpdateSteps(dayName, _dailySteps);

            // Save to daily history table using the stored date
            await StepsDatabase.insertOrUpdateDailySteps(
              _currentDate,
              _dailySteps,
            );

            print('Saved yesterday\'s steps: $dayName = $_dailySteps for date: $_currentDate');
          } catch (e) {
            print('Error saving yesterday\'s steps: $e');
            // Continue with day change even if save fails
          }
        }

        // Maintain 30-day history (remove oldest entries)
        await StepsDatabase.maintain30DayHistory();

        // Reset for new day
        _dailySteps = 0;
        _currentDate = today; // Use local date for consistency
        _deviceStepsAtMidnight = 0; // Will be set when we get first reading

        // Initialize today's entry in database
        try {
          await StepsDatabase.insertOrUpdateDailySteps(
            today,
            0,
          );
        } catch (e) {
          print('Error initializing today\'s entry: $e');
          // Continue even if database init fails
        }

        await _saveStoredData();
        _stepsController.add(_dailySteps);
      } catch (e) {
        print('Critical error during day change: $e');
        // Ensure we still update the date to prevent infinite loops
        _currentDate = today;
        await _saveStoredData();
      }
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
    if (_isUpdating) return; // Prevent concurrent updates
    
    _isUpdating = true;
    try {
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
    var newDailySteps = currentDeviceSteps - _deviceStepsAtMidnight;

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

    // Apply reasonable limits (max ~60k steps per day for very active users)
    if (newDailySteps > 60000) {
      print('Unreasonable step count detected: $newDailySteps, capping at 60000');
      newDailySteps = 60000;
      // Recalculate baseline to prevent future issues
      _deviceStepsAtMidnight = currentDeviceSteps - newDailySteps;
      await _saveStoredData();
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

      await _saveStoredData();

      // Save to database every 50 steps or every 2 minutes
      final timeSinceLastSave = now.difference(_lastUpdateTime).inMinutes;
      if (stepIncrement >= 50 || timeSinceLastSave >= 2) {
        await _saveToDatabase();
      }

      _stepsController.add(_dailySteps);
      print('Daily steps updated: $_dailySteps (+$stepIncrement)');
    }
    } catch (e) {
      print('Error handling step count: $e');
    } finally {
      _isUpdating = false;
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

      // Allow up to 300 steps per minute (for runners/sprinters)
      // Minimum 2000 steps buffer for app being closed
      final maxReasonableSteps = math.max(2000, timeDiff * 300);

      if (difference > maxReasonableSteps) {
        print(
            'Step reading validation failed: difference=$difference in ${timeDiff}min (max allowed: $maxReasonableSteps)');
        // If difference is huge, might be device reset - allow it but log warning
        if (difference > 100000) {
          print('WARNING: Very large step difference detected. Device may have reset.');
          // Reset baseline tracking
          _lastValidDeviceSteps = 0;
          return true; // Allow it, will be handled in baseline recalculation
        }
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
  // With retry logic for production reliability
  // This is the single source of truth - all writes go through here
  Future<void> _saveToDatabase() async {
    if (_dailySteps == 0) return;

    final today = _getDayAbbreviation(DateTime.now().weekday);
    final todayDateStr = _getTodayString();
    int retries = 3;
    int delayMs = 100;

    while (retries > 0) {
      try {
        // Save to daily history (primary storage - single source of truth)
        await StepsDatabase.insertOrUpdateDailySteps(
          todayDateStr,
          _dailySteps,
        );
        
        // Also save to weekly table (for backward compatibility)
        await StepsDatabase.insertOrUpdateSteps(today, _dailySteps);
        
        // Update SharedPreferences cache (for background service)
        await _saveStoredData();
        
        print('Saved steps to database (SSoT): $today = $_dailySteps');
        return; // Success, exit retry loop
      } catch (e) {
        retries--;
        if (retries > 0) {
          print('Error saving steps to database (retrying in ${delayMs}ms): $e');
          await Future.delayed(Duration(milliseconds: delayMs));
          delayMs *= 2; // Exponential backoff
        } else {
          print('CRITICAL: Failed to save steps to database after 3 retries: $e');
          // Save to SharedPreferences as backup (degraded mode)
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt(_dailyStepsKey, _dailySteps);
            await prefs.setString(_dateKey, todayDateStr);
            print('Saved to SharedPreferences as backup');
          } catch (backupError) {
            print('CRITICAL: Failed to save to SharedPreferences backup: $backupError');
          }
        }
      }
    }
  }


  // Load stored data - Single Source of Truth pattern
  // Priority: Database > SharedPreferences > Defaults
  Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();
      
      // Try to load from database first (single source of truth)
      try {
        final dbData = await StepsDatabase.getDailySteps(today);
        if (dbData != null && dbData['total_steps'] != null) {
          _dailySteps = dbData['total_steps'] as int;
          print('Loaded steps from database: $_dailySteps');
        }
      } catch (e) {
        print('Could not load from database, using SharedPreferences: $e');
      }
      
      // Fallback to SharedPreferences if database doesn't have today's data
      if (_dailySteps == 0) {
        _dailySteps = prefs.getInt(_dailyStepsKey) ?? 0;
      }
      
      // Load other data from SharedPreferences (these are not in database)
      _dailyGoal = prefs.getInt(_goalKey) ?? 10000;
      _deviceStepsAtMidnight = prefs.getInt(_deviceStepsKey) ?? 0;
      _currentDate = prefs.getString(_dateKey) ?? today;
      
      // If date doesn't match today, check for day change
      if (_currentDate != today) {
        await _checkForNewDay();
      }

      print('Loaded stored data (Single Source of Truth):');
      print('  Daily steps: $_dailySteps (from ${_dailySteps > 0 ? "database" : "prefs"})');
      print('  Daily goal: $_dailyGoal');
      print('  Date: $_currentDate');
      print('  Device baseline: $_deviceStepsAtMidnight');

      // Immediately notify listeners with loaded data
      _stepsController.add(_dailySteps);
    } catch (e) {
      print('Error loading stored data: $e');
      // Set defaults
      _dailySteps = 0;
      _dailyGoal = 10000;
      _currentDate = _getTodayString();
      _deviceStepsAtMidnight = 0;
    }
  }

  // Save stored data - Single Source of Truth pattern
  // Database is primary, SharedPreferences is cache for background service
  Future<void> _saveStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();

      // Save to database first (single source of truth)
      try {
        await StepsDatabase.insertOrUpdateDailySteps(
          today,
          _dailySteps,
        );
      } catch (e) {
        print('Warning: Could not save to database, using SharedPreferences only: $e');
      }

      // Also save to SharedPreferences as cache (for background service)
      await prefs.setInt(_dailyStepsKey, _dailySteps);
      await prefs.setInt(_goalKey, _dailyGoal);
      await prefs.setInt(_deviceStepsKey, _deviceStepsAtMidnight);
      await prefs.setString(_dateKey, _currentDate);
      
      // Update last sync time for health check
      await prefs.setString('${_dateKey}_last_update', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving stored data: $e');
    }
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

  // Get steps for a 7-day period (offset: 0 = today-6, 1 = today-13, etc.)
  // Returns a map with date strings (YYYY-MM-DD) as keys and step counts as values
  Future<Map<String, int>> getStepsFor7DayPeriod(int offset, {int? todaySteps}) async {
    try {
      final stepsMap = await StepsDatabase.getStepsFor7DayPeriod(offset);
      
      // If this is offset 0 (current week), update today's steps with live data
      if (offset == 0) {
        final today = _getTodayString();
        stepsMap[today] = todaySteps ?? _dailySteps;
      }
      
      print('7-day period steps (offset $offset): $stepsMap');
      return stepsMap;
    } catch (e) {
      print('Error getting 7-day period steps: $e');
      return {};
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
    _periodicSyncTimer?.cancel();
    _healthCheckTimer?.cancel();
    _stepCountStream?.cancel();
    _pedestrianStatusStream?.cancel();
    _stepsController.close();
    _statusController.close();

    // Optionally stop background service (uncomment if needed)
    // _stopBackgroundService();
  }
}
