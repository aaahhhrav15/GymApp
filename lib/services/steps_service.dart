// lib/services/steps_service.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import '../database/steps_database.dart';
import 'permission_service.dart';

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
  Timer? _periodicDatabaseSaveTimer;
  Timer? _preMidnightSaveTimer;

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

      // Start background service (runs independently, continues when app is closed)
      await _startBackgroundService();

      // Start listening to pedometer (for when app is active)
      // This calculates steps when app is open
      await _startListening();

      // Sync with background service immediately to get latest data
      // This ensures we have the latest steps if background service was running
      await _syncWithBackgroundService();

      // Periodic sync with background service (every 2 seconds)
      // This keeps app in sync with background service data
      _startPeriodicSync();
      
      // Start health check monitoring
      _startHealthCheckMonitoring();
      
      // RECOMMENDATION 4: Monitor battery optimization status
      _monitorBatteryOptimizationStatus();

      print(
          'Steps Service initialized - Daily steps: $_dailySteps (Background: $_isBackgroundServiceActive)');
      print('Background service will continue tracking steps when app is closed.');
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
  // CRITICAL FIX: Reduced to 5 seconds for better responsiveness and to prevent notification/app mismatch
  // This ensures notifications and app show the same data more quickly
  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isUpdating) {
        await _syncWithBackgroundService();
      }
    });
    
    // Also add a periodic database save to ensure data persistence
    // CRITICAL: Save more frequently to prevent data loss when app is killed
    // Save every 10 seconds to minimize data loss window
    _periodicDatabaseSaveTimer?.cancel();
    _periodicDatabaseSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_isUpdating) {
        try {
          // Always save, even if 0 steps, to ensure the date entry exists
          await _saveToDatabase();
          
          // CRITICAL: Mark successful save timestamp for recovery detection
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('last_periodic_save', DateTime.now().toIso8601String());
          
          print('Periodic database save: $_dailySteps steps');
        } catch (e) {
          print('Error in periodic database save: $e');
        }
      }
    });
    
    // CRITICAL FIX: Pre-midnight save mechanism
    // Save steps at 11:58 PM to capture final count before day change
    // This prevents losing steps when background service resets at midnight
    _preMidnightSaveTimer?.cancel();
    _startPreMidnightSave();
  }
  
  // CRITICAL FIX: Pre-midnight save to capture yesterday's steps before day change
  // This runs at 11:58 PM every day to save final step count before background service resets
  void _startPreMidnightSave() {
    _preMidnightSaveTimer?.cancel();
    
    // Calculate time until 11:58 PM today
    final now = DateTime.now();
    final targetTime = DateTime(now.year, now.month, now.day, 23, 58, 0);
    
    Duration delay;
    if (now.isBefore(targetTime)) {
      // Today's 11:58 PM hasn't passed yet
      delay = targetTime.difference(now);
    } else {
      // Today's 11:58 PM has passed, schedule for tomorrow
      delay = targetTime.add(const Duration(days: 1)).difference(now);
    }
    
    _preMidnightSaveTimer = Timer(delay, () {
      _performPreMidnightSave();
      // Schedule for next day
      _preMidnightSaveTimer = Timer.periodic(const Duration(days: 1), (timer) {
        _performPreMidnightSave();
      });
    });
    
    print('Scheduled pre-midnight save in ${delay.inMinutes} minutes');
  }
  
  // CRITICAL FIX: Save final steps before midnight to prevent data loss
  Future<void> _performPreMidnightSave() async {
    try {
      print('CRITICAL: Pre-midnight save - capturing final steps before day change');
      
      // Get the latest steps from SharedPreferences (background service may have updated)
      final prefs = await SharedPreferences.getInstance();
      final latestSteps = prefs.getInt(_dailyStepsKey) ?? _dailySteps;
      final currentDate = prefs.getString(_dateKey) ?? _currentDate;
      
      // Use the higher value to ensure we don't lose steps
      final finalSteps = math.max(_dailySteps, latestSteps);
      
      print('Pre-midnight save: Saving $finalSteps steps for $currentDate');
      
      // CRITICAL: Save to database with retry logic
      int retries = 5;
      bool saved = false;
      while (retries > 0 && !saved) {
        try {
          await StepsDatabase.insertOrUpdateDailySteps(currentDate, finalSteps);
          final dayName = _getDayAbbreviation(DateTime.parse(currentDate).weekday);
          await StepsDatabase.insertOrUpdateSteps(dayName, finalSteps);
          
          // Also update SharedPreferences to ensure background service sees this value
          await prefs.setInt(_dailyStepsKey, finalSteps);
          await prefs.setString(_dateKey, currentDate);
          
          // Mark that we saved before midnight
          await prefs.setString('pre_midnight_save_time', DateTime.now().toIso8601String());
          await prefs.setInt('pre_midnight_saved_steps', finalSteps);
          await prefs.setString('pre_midnight_saved_date', currentDate);
          
          _dailySteps = finalSteps;
          _currentDate = currentDate;
          
          saved = true;
          print('CRITICAL: Pre-midnight save successful: $finalSteps steps for $currentDate');
        } catch (e) {
          retries--;
          if (retries > 0) {
            print('Pre-midnight save failed, retrying... ($retries left): $e');
            await Future.delayed(Duration(milliseconds: 500));
          } else {
            print('CRITICAL ERROR: Pre-midnight save failed after retries: $e');
            // Save to SharedPreferences as backup
            try {
              await prefs.setInt('${_dailyStepsKey}_pre_midnight_backup', finalSteps);
              await prefs.setString('${_dateKey}_pre_midnight_backup', currentDate);
            } catch (backupError) {
              print('CRITICAL: Failed to save pre-midnight backup: $backupError');
            }
          }
        }
      }
    } catch (e) {
      print('Error in pre-midnight save: $e');
    }
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
  // CRITICAL FIX: Improved sync to prevent data loss and notification/app mismatch
  Future<void> _syncWithBackgroundService() async {
    if (_isUpdating) return; // Prevent concurrent updates
    
    _isUpdating = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      var backgroundSteps = prefs.getInt(_dailyStepsKey) ?? _dailySteps;
      var backgroundDate = prefs.getString(_dateKey) ?? _currentDate;

      // CRITICAL FIX: Check for pre-midnight saved steps (backup from yesterday)
      // This recovers steps that were saved before midnight but lost during day change
      try {
        final preMidnightDate = prefs.getString('pre_midnight_saved_date');
        final preMidnightSteps = prefs.getInt('pre_midnight_saved_steps');
        if (preMidnightDate != null && preMidnightSteps != null && 
            preMidnightDate != backgroundDate && preMidnightDate == _currentDate) {
          // We have pre-midnight saved steps for yesterday that need to be recovered
          print('RECOVERY: Found pre-midnight saved steps: $preMidnightSteps for $preMidnightDate');
          try {
            final dbData = await StepsDatabase.getDailySteps(preMidnightDate);
            final dbSteps = dbData?['total_steps'] as int? ?? 0;
            if (preMidnightSteps > dbSteps) {
              await StepsDatabase.insertOrUpdateDailySteps(preMidnightDate, preMidnightSteps);
              final dayName = _getDayAbbreviation(DateTime.parse(preMidnightDate).weekday);
              await StepsDatabase.insertOrUpdateSteps(dayName, preMidnightSteps);
              print('RECOVERY: Restored pre-midnight steps to database: $preMidnightSteps');
            }
            // Clear the backup after recovery
            await prefs.remove('pre_midnight_saved_steps');
            await prefs.remove('pre_midnight_saved_date');
          } catch (e) {
            print('Error recovering pre-midnight steps: $e');
          }
        }
      } catch (e) {
        print('Error checking pre-midnight backup: $e');
      }

      // Validate background data before using it
      if (backgroundSteps < 0) {
        print('WARNING: Negative background steps value: $backgroundSteps, using 0');
        backgroundSteps = 0;
      }
      if (backgroundSteps > 100000) {
        print('WARNING: Unreasonably high background steps value: $backgroundSteps, capping at 100000');
        backgroundSteps = 100000;
      }
      
      // Validate date format
      if (backgroundDate.isNotEmpty && !_isValidDateString(backgroundDate)) {
        print('WARNING: Invalid date format: $backgroundDate, using today');
        backgroundDate = _getTodayString();
      }

      // Update last sync time for health check
      await prefs.setString('${_dateKey}_last_update', DateTime.now().toIso8601String());

      // Check for day change (with timezone awareness)
      // CRITICAL FIX: Handle day change BEFORE updating steps to prevent losing yesterday's data
      if (backgroundDate != _currentDate && backgroundDate.isNotEmpty) {
        print('Day change detected in sync: $_currentDate -> $backgroundDate');
        
        // CRITICAL FIX: Get the best value for yesterday's steps from multiple sources
        int yesterdaySteps = _dailySteps;
        String yesterdayDate = _currentDate;
        
        // EDGE CASE: Validate yesterday's date before processing
        if (!_isValidDateString(yesterdayDate)) {
          print('ERROR: Invalid yesterday date format: $yesterdayDate');
          // Use current date minus 1 day as fallback
          final fallbackDate = DateTime.now().subtract(const Duration(days: 1));
          yesterdayDate = '${fallbackDate.year}-${fallbackDate.month.toString().padLeft(2, '0')}-${fallbackDate.day.toString().padLeft(2, '0')}';
        }
        
        // CRITICAL FIX: Check multiple sources for yesterday's steps
        // 1. Pre-midnight backup (most reliable)
        try {
          final preMidnightDate = prefs.getString('pre_midnight_saved_date');
          final preMidnightSteps = prefs.getInt('pre_midnight_saved_steps');
          if (preMidnightDate == yesterdayDate && preMidnightSteps != null) {
            yesterdaySteps = math.max(yesterdaySteps, preMidnightSteps);
            print('Using pre-midnight saved steps: $preMidnightSteps');
          }
        } catch (e) {
          print('Error reading pre-midnight backup: $e');
        }
        
        // 2. Database (might have been saved earlier)
        try {
          final dbData = await StepsDatabase.getDailySteps(yesterdayDate);
          if (dbData != null && dbData['total_steps'] != null) {
            final dbSteps = dbData['total_steps'] as int;
            // Use the higher value (database or current memory)
            yesterdaySteps = math.max(yesterdaySteps, dbSteps);
            print('Found yesterday\'s steps in database: $dbSteps, using: $yesterdaySteps');
          }
        } catch (e) {
          print('Could not load yesterday from database: $e');
        }
        
        // 3. SharedPreferences backup
        try {
          final backupSteps = prefs.getInt('${_dailyStepsKey}_yesterday');
          final backupDate = prefs.getString('${_dateKey}_yesterday');
          if (backupDate == yesterdayDate && backupSteps != null) {
            yesterdaySteps = math.max(yesterdaySteps, backupSteps);
            print('Using SharedPreferences backup: $backupSteps');
          }
        } catch (e) {
          print('Error reading SharedPreferences backup: $e');
        }
        
        // EDGE CASE: Validate yesterday's steps before saving
        if (yesterdaySteps < 0) {
          print('WARNING: Negative yesterday steps: $yesterdaySteps, setting to 0');
          yesterdaySteps = 0;
        }
        if (yesterdaySteps > 100000) {
          print('WARNING: Unreasonably high yesterday steps: $yesterdaySteps, capping at 100000');
          yesterdaySteps = 100000;
        }
        
        print('CRITICAL: Saving yesterday\'s steps: $yesterdaySteps for date: $yesterdayDate');
        
        // Force save yesterday's steps to database immediately with retry logic
        int saveRetries = 5;
        bool saveSuccess = false;
        while (saveRetries > 0 && !saveSuccess) {
          try {
            await StepsDatabase.insertOrUpdateDailySteps(
              yesterdayDate,
              yesterdaySteps,
            );
            final yesterdayDayName = _getDayAbbreviation(
              DateTime.parse(yesterdayDate).weekday
            );
            await StepsDatabase.insertOrUpdateSteps(yesterdayDayName, yesterdaySteps);
            print('CRITICAL: Saved yesterday\'s steps to database: $yesterdayDate = $yesterdaySteps');
            saveSuccess = true;
          } catch (e) {
            saveRetries--;
            if (saveRetries > 0) {
              print('CRITICAL ERROR: Failed to save yesterday\'s steps (retrying): $e');
              await Future.delayed(Duration(milliseconds: 500));
            } else {
              print('CRITICAL ERROR: Failed to save yesterday\'s steps after retries: $e');
              // Save to SharedPreferences as last resort
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('${_dailyStepsKey}_yesterday', yesterdaySteps);
                await prefs.setString('${_dateKey}_yesterday', yesterdayDate);
                print('Saved yesterday\'s steps to SharedPreferences as backup');
              } catch (backupError) {
                print('CRITICAL: Failed to save yesterday to SharedPreferences: $backupError');
              }
            }
          }
        }
        
        // Now handle the day change (this will reset _dailySteps to 0)
        await _checkForNewDay();
        
        // After day change, update to today's values from background service
        _dailySteps = backgroundSteps;
        _currentDate = backgroundDate;
        
        // CRITICAL FIX: Immediately sync to database to prevent notification/app mismatch
        await _saveToDatabase();
        
        _stepsController.add(_dailySteps);
        return; // Exit early after day change to prevent double processing
      }

      // CRITICAL FIX: Always sync to ensure database and SharedPreferences match
      // This prevents notification/app mismatch
      final oldSteps = _dailySteps;
      
      // Use the higher value to prevent data loss
      final finalSteps = math.max(_dailySteps, backgroundSteps);
      
      // EDGE CASE: Handle steps going backwards (should never happen, but handle gracefully)
      if (backgroundSteps < _dailySteps && _dailySteps > 0) {
        print('WARNING: Steps decreased from $_dailySteps to $backgroundSteps');
        print('This may indicate device reset or data corruption. Keeping higher value.');
        // Keep the higher value to prevent data loss
      }
      
      final stepIncrement = finalSteps > _dailySteps 
          ? finalSteps - _dailySteps 
          : 0;

      // Validate step increment is reasonable (max 5000 steps in 5 seconds)
      if (stepIncrement > 5000) {
        print('WARNING: Unusually large step increment in sync: $stepIncrement');
        print('This may indicate data corruption. Capping increment to 5000.');
        // Cap the increment to prevent corruption
        finalSteps = _dailySteps + 5000;
      }

      // CRITICAL FIX: Always update and save to keep database and SharedPreferences in sync
      // This ensures notifications and app show the same data
      if (finalSteps != _dailySteps || backgroundDate != _currentDate) {
        _dailySteps = finalSteps;
        _currentDate = backgroundDate;

        // Always save to database when steps change to prevent data loss
        // This ensures no steps are lost even if app closes unexpectedly
        await _saveToDatabase();

        _stepsController.add(_dailySteps);

        if (_dailySteps != oldSteps) {
          print('Background sync: $_dailySteps steps (was: $oldSteps)');
        }
      }
    } catch (e, stackTrace) {
      print('Error syncing with background service: $e');
      print('Stack trace: $stackTrace');
      // Don't throw - allow retry on next sync cycle
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

  // CRITICAL FIX: Improved day change detection with pre-midnight backup recovery
  Future<void> _checkForNewDay() async {
    final today = _getTodayString();
    final todayUTC = _getTodayStringUTC();

    // EDGE CASE: Validate current date before checking
    if (!_isValidDateString(_currentDate) && _currentDate.isNotEmpty) {
      print('WARNING: Invalid current date format: $_currentDate, resetting to today');
      _currentDate = today;
    }

    // Check both local and UTC dates to handle timezone edge cases
    // EDGE CASE: Also handle empty date strings
    if (_currentDate.isNotEmpty && _currentDate != today && _currentDate != todayUTC) {
      print('New day detected: $today (was: $_currentDate, UTC: $todayUTC)');

      try {
        // CRITICAL FIX: Always save yesterday's data to database, even if 0 steps
        // This ensures all days have entries in the database
        if (_currentDate.isNotEmpty) {
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
            
            // CRITICAL FIX: Check for pre-midnight saved steps first (most reliable)
            final prefs = await SharedPreferences.getInstance();
            int finalYesterdaySteps = _dailySteps;
            
            try {
              final preMidnightDate = prefs.getString('pre_midnight_saved_date');
              final preMidnightSteps = prefs.getInt('pre_midnight_saved_steps');
              if (preMidnightDate == _currentDate && preMidnightSteps != null) {
                finalYesterdaySteps = math.max(finalYesterdaySteps, preMidnightSteps);
                print('Using pre-midnight saved steps for yesterday: $preMidnightSteps');
              }
            } catch (e) {
              print('Error reading pre-midnight backup: $e');
            }
            
            // Also check database for any existing value
            try {
              final dbData = await StepsDatabase.getDailySteps(_currentDate);
              if (dbData != null && dbData['total_steps'] != null) {
                final dbSteps = dbData['total_steps'] as int;
                finalYesterdaySteps = math.max(finalYesterdaySteps, dbSteps);
                print('Found existing steps in database: $dbSteps');
              }
            } catch (e) {
              print('Error reading from database: $e');
            }
            
            // Save to daily history table using the stored date
            // Always save, even with 0 steps, to ensure the date entry exists
            await StepsDatabase.insertOrUpdateDailySteps(
              _currentDate,
              finalYesterdaySteps,
            );
            
            // Also save to weekly table for backward compatibility
            await StepsDatabase.insertOrUpdateSteps(dayName, finalYesterdaySteps);

            print('CRITICAL: Saved yesterday\'s steps: $dayName = $finalYesterdaySteps for date: $_currentDate');
            
            // Clear pre-midnight backup after successful save
            try {
              await prefs.remove('pre_midnight_saved_steps');
              await prefs.remove('pre_midnight_saved_date');
            } catch (e) {
              print('Error clearing pre-midnight backup: $e');
            }
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

        // Initialize today's entry in database (always, even with 0 steps)
        try {
          await StepsDatabase.insertOrUpdateDailySteps(
            today,
            0,
          );
          // Also initialize weekly table entry
          final todayDayName = _getDayAbbreviation(DateTime.now().weekday);
          await StepsDatabase.insertOrUpdateSteps(todayDayName, 0);
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
    
    // RECOMMENDATION 2: Request battery optimization exemption
    // This is critical to prevent the system from killing the background service
    await _requestBatteryOptimizationExemption();
  }
  
  // RECOMMENDATION 2: Request battery optimization exemption
  // This prevents the system from killing the background service when memory is low
  Future<void> _requestBatteryOptimizationExemption() async {
    if (Platform.isIOS) {
      // iOS doesn't have battery optimization like Android
      return;
    }
    
    try {
      // Check if battery optimization is already ignored
      final isIgnored = await _nativeChannel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      
      if (isIgnored == true) {
        print('Battery optimization is already ignored - background service will continue running');
        return;
      }
      
      // Request to ignore battery optimizations
      print('Requesting battery optimization exemption...');
      final result = await _nativeChannel.invokeMethod<bool>('requestIgnoreBatteryOptimizations');
      
      if (result == true) {
        print('Battery optimization exemption granted - background service protected');
      } else {
        print('WARNING: Battery optimization exemption not granted');
        print('The background service may be killed by the system when memory is low');
        print('User should manually disable battery optimization in system settings');
      }
    } catch (e) {
      print('Error requesting battery optimization exemption: $e');
      // Don't fail initialization if this fails
    }
  }
  
  // RECOMMENDATION 4: Check battery optimization status and warn if needed
  Future<bool> isBatteryOptimizationIgnored() async {
    if (Platform.isIOS) {
      return true; // iOS doesn't have this issue
    }
    
    try {
      final isIgnored = await _nativeChannel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return isIgnored ?? false;
    } catch (e) {
      print('Error checking battery optimization status: $e');
      return false;
    }
  }
  
  // Check all step counter permissions and settings
  Future<Map<String, dynamic>> checkStepCounterPermissions() async {
    Map<String, dynamic> status = {
      'stepCountingAvailable': await isStepCountingAvailable,
      'backgroundServiceActive': _isBackgroundServiceActive,
    };
    
    if (Platform.isAndroid) {
      final activityStatus = await Permission.activityRecognition.status;
      final batteryOptimized = await isBatteryOptimizationIgnored();
      
      status['activityRecognition'] = activityStatus.isGranted;
      status['activityRecognitionStatus'] = activityStatus.toString();
      status['batteryOptimizationIgnored'] = batteryOptimized;
      status['needsActivityRecognition'] = !activityStatus.isGranted;
      status['needsBatteryOptimization'] = !batteryOptimized;
    } else {
      // iOS: Check notification permission via native
      try {
        final isAuthorized = await _nativeChannel.invokeMethod<bool>('checkNotificationPermission') ?? false;
        status['notificationPermission'] = isAuthorized;
        status['needsNotificationPermission'] = !isAuthorized;
      } catch (e) {
        status['notificationPermission'] = false;
        status['needsNotificationPermission'] = true;
      }
    }
    
    return status;
  }
  
  // Request all step counter permissions (for re-enabling)
  Future<Map<String, bool>> requestStepCounterPermissions() async {
    Map<String, bool> results = {};
    
    if (Platform.isAndroid) {
      // Request activity recognition
      final activityStatus = await Permission.activityRecognition.status;
      if (!activityStatus.isGranted) {
        final result = await Permission.activityRecognition.request();
        results['activityRecognition'] = result.isGranted;
      } else {
        results['activityRecognition'] = true;
      }
      
      // Request battery optimization exemption
      if (!await isBatteryOptimizationIgnored()) {
        try {
          await _nativeChannel.invokeMethod<bool>('requestIgnoreBatteryOptimizations');
          // Check again after request
          results['batteryOptimization'] = await isBatteryOptimizationIgnored();
        } catch (e) {
          results['batteryOptimization'] = false;
        }
      } else {
        results['batteryOptimization'] = true;
      }
    } else {
      // iOS: Request notification permission via native
      try {
        await _nativeChannel.invokeMethod('requestNotificationPermission');
        // Check again after request
        final isAuthorized = await _nativeChannel.invokeMethod<bool>('checkNotificationPermission') ?? false;
        results['notification'] = isAuthorized;
      } catch (e) {
        results['notification'] = false;
      }
    }
    
    // Restart background service after permissions are granted
    if (results.values.every((v) => v)) {
      await _restartBackgroundService();
    }
    
    return results;
  }
  
  // Open app settings for manual permission enabling
  Future<void> openStepCounterSettings() async {
    await PermissionService.openSettings();
  }
  
  // RECOMMENDATION 4: Monitor battery optimization status periodically
  // Warn if it's not ignored (service may be killed)
  Timer? _batteryOptimizationCheckTimer;
  void _monitorBatteryOptimizationStatus() {
    _batteryOptimizationCheckTimer?.cancel();
    // Check every 5 minutes
    _batteryOptimizationCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (Platform.isAndroid) {
        final isIgnored = await isBatteryOptimizationIgnored();
        if (!isIgnored) {
          print('WARNING: Battery optimization is NOT ignored');
          print('The background service may be killed by the system when memory is low');
          print('User should disable battery optimization in system settings');
          // Store warning for UI to display
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('battery_optimization_warning', true);
        } else {
          // Clear warning if it's now ignored
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('battery_optimization_warning', false);
        }
      }
    });
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
      // Check if this is first install or first time enabling real steps
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('steps_service_initialized') != true;
      
      if (isFirstTime || _dailySteps == 0) {
        // First install or first time enabling real steps - start from 0
        // Set baseline to current device steps so we count from NOW
        _deviceStepsAtMidnight = currentDeviceSteps;
        _dailySteps = 0;
        print(
            'First time setup: Setting baseline to current device steps ($currentDeviceSteps)');
        print('Steps will be counted from this point forward (starting at 0).');
        print('This baseline is shared with background service for consistent tracking.');
        
        // Mark that service has been initialized
        await prefs.setBool('steps_service_initialized', true);
        
        // Save baseline to SharedPreferences so background service can use it
        await _saveStoredData();
        
        // Sync with background service to ensure it has the same baseline
        await _syncWithBackgroundService();
        
        return; // Don't process this reading, wait for next update
      } else if (_dailySteps > 0) {
        // We have existing daily steps, calculate baseline from that
        // This happens when app reopens and we have stored steps
        _deviceStepsAtMidnight = currentDeviceSteps - _dailySteps;
        print(
            'App reopened: Set device baseline from existing steps: $_deviceStepsAtMidnight (current daily: $_dailySteps, device total: $currentDeviceSteps)');
        print('Background service was tracking steps while app was closed.');
        await _saveStoredData();
      } else {
        // New day - use current device steps as baseline
        _deviceStepsAtMidnight = currentDeviceSteps;
        _dailySteps = 0;
        print(
            'Set device baseline for new day: $_deviceStepsAtMidnight (device total: $currentDeviceSteps)');
        await _saveStoredData();
        return; // Don't process this reading, wait for next update
      }
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

    // CRITICAL: Detect and fix incorrect baseline (when real steps are first enabled)
    // If calculated steps are unreasonably high (>15k) and we just enabled real steps,
    // it means the baseline was set incorrectly (using lifetime steps instead of today's steps)
    if (newDailySteps > 15000 && _dailySteps == 0) {
      print('WARNING: Detected unreasonably high step count ($newDailySteps) on first reading.');
      print('This likely means baseline was set incorrectly. Resetting to start fresh.');
      // Reset baseline to current device steps and start counting from now
      _deviceStepsAtMidnight = currentDeviceSteps;
      _dailySteps = 0;
      await _saveStoredData();
      return; // Don't process this reading, wait for next update
    }

    // Also check if steps jump dramatically (more than 20k in one update)
    // This indicates the baseline was wrong
    if (newDailySteps > _dailySteps + 20000 && _dailySteps > 0) {
      print('WARNING: Detected dramatic step jump (${newDailySteps - _dailySteps} steps).');
      print('Baseline may be incorrect. Recalculating...');
      // Recalculate baseline based on current daily steps
      _deviceStepsAtMidnight = currentDeviceSteps - _dailySteps;
      if (_deviceStepsAtMidnight < 0) {
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
    // EDGE CASE: Handle steps going backwards (should never happen)
    if (newDailySteps < _dailySteps) {
      print('WARNING: Steps decreased from $_dailySteps to $newDailySteps');
      print('This may indicate device reset or data corruption. Keeping higher value.');
      // Keep the higher value to prevent data loss
      newDailySteps = _dailySteps;
    }
    
    if (newDailySteps > _dailySteps) {
      final stepIncrement = newDailySteps - _dailySteps;

      // Validate increment is reasonable (max ~2000 steps between readings)
      if (stepIncrement > 2000) {
        print(
            'Large step increment detected: $stepIncrement, may be catch-up from app being closed');
        // EDGE CASE: Cap unreasonable increments to prevent corruption
        if (stepIncrement > 10000) {
          print('WARNING: Extremely large increment ($stepIncrement), capping to 10000');
          newDailySteps = _dailySteps + 10000;
        }
      }

      _dailySteps = newDailySteps;
      _lastValidDeviceSteps = currentDeviceSteps;
      _lastUpdateTime = now;

      await _saveStoredData();

      // Always save to database when steps change to prevent data loss
      // This ensures no steps are lost even if app closes unexpectedly
      if (stepIncrement > 0) {
        await _saveToDatabase();
      }

      _stepsController.add(_dailySteps);
      print('Daily steps updated: $_dailySteps (+$stepIncrement)');
    }
    } catch (e, stackTrace) {
      print('Error handling step count: $e');
      print('Stack trace: $stackTrace');
      // Ensure we don't get stuck in updating state
      _isUpdating = false;
      // Try to recover by syncing with background service
      try {
        await _syncWithBackgroundService();
      } catch (syncError) {
        print('Error during recovery sync: $syncError');
      }
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
    print('Pedometer error: $error');
    _isUsingRealPedometer = false;
    
    // EDGE CASE: Try to recover from stream errors
    // Cancel existing stream and attempt to restart after delay
    _stepCountStream?.cancel();
    _stepCountStream = null;
    
    // Attempt to restart after a delay
    Future.delayed(const Duration(seconds: 5), () async {
      try {
        print('Attempting to recover pedometer stream...');
        await _startListening();
      } catch (e) {
        print('Failed to recover pedometer stream: $e');
      }
    });
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
    // EDGE CASE: Prevent concurrent saves
    if (_isUpdating) {
      print('Save already in progress, skipping duplicate save');
      return;
    }
    
    // Always save, even if steps are 0, to ensure the date entry exists
    final today = _getDayAbbreviation(DateTime.now().weekday);
    final todayDateStr = _getTodayString();
    
    // EDGE CASE: Validate data before saving
    if (_dailySteps < 0) {
      print('WARNING: Negative steps detected: $_dailySteps, setting to 0');
      _dailySteps = 0;
    }
    if (_dailySteps > 100000) {
      print('WARNING: Unreasonably high steps: $_dailySteps, capping at 100000');
      _dailySteps = 100000;
    }
    if (!_isValidDateString(todayDateStr)) {
      print('ERROR: Invalid date string: $todayDateStr, cannot save');
      return;
    }
    
    int retries = 3;
    int delayMs = 100;

    while (retries > 0) {
      try {
        // Save to daily history (primary storage - single source of truth)
        // Always save to ensure the date entry exists, even with 0 steps
        await StepsDatabase.insertOrUpdateDailySteps(
          todayDateStr,
          _dailySteps,
        );
        
        // Also save to weekly table (for backward compatibility)
        await StepsDatabase.insertOrUpdateSteps(today, _dailySteps);
        
        // Update SharedPreferences cache (for background service)
        // This ensures notifications read the same value
        await _saveStoredData();
        
        print('Saved steps to database (SSoT): $today = $_dailySteps for date: $todayDateStr');
        return; // Success, exit retry loop
      } catch (e) {
        // EDGE CASE: Handle database locked errors specifically
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('locked') || errorStr.contains('database is locked')) {
          print('Database locked, waiting longer before retry...');
          delayMs = 500; // Wait longer for locked database
        }
        
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
  
  // Validate date string format (YYYY-MM-DD)
  bool _isValidDateString(String dateStr) {
    if (dateStr.isEmpty) return false;
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return false;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      if (year < 2020 || year > 2100) return false;
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;
      // Try to parse as DateTime to validate
      DateTime.parse(dateStr);
      return true;
    } catch (e) {
      return false;
    }
  }


  // Load stored data - Single Source of Truth pattern
  // Priority: Database > SharedPreferences > Defaults
  Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();
      
      // CRITICAL: Check if app was killed and recover data
      // The background service saves to SharedPreferences, so we need to sync that data
      await _recoverFromAppKill(prefs, today);
      
      // Check if this is first install (no data exists)
      final hasStoredDate = prefs.containsKey(_dateKey);
      final hasStoredSteps = prefs.containsKey(_dailyStepsKey);
      
      // Try to load from database first (single source of truth)
      int dbSteps = 0;
      bool hasDbData = false;
      try {
        final dbData = await StepsDatabase.getDailySteps(today);
        if (dbData != null && dbData['total_steps'] != null) {
          dbSteps = dbData['total_steps'] as int;
          hasDbData = true;
          print('Loaded steps from database: $dbSteps');
        }
      } catch (e) {
        print('Could not load from database, using SharedPreferences: $e');
      }
      
      // Detect first install: no stored data in both database and SharedPreferences
      final isFirstInstall = !hasStoredDate && !hasStoredSteps && !hasDbData;
      
      if (isFirstInstall) {
        print('First install detected - starting from 0 steps');
        _dailySteps = 0;
        _deviceStepsAtMidnight = 0;
        _currentDate = today;
        _dailyGoal = prefs.getInt(_goalKey) ?? 10000;
        
        // Initialize today's entry in database with 0 steps
        try {
          await StepsDatabase.insertOrUpdateDailySteps(today, 0);
          final todayDayName = _getDayAbbreviation(DateTime.now().weekday);
          await StepsDatabase.insertOrUpdateSteps(todayDayName, 0);
        } catch (e) {
          print('Error initializing first install data: $e');
        }
        
        // Save to SharedPreferences to mark that app has been initialized
        await prefs.setInt(_dailyStepsKey, 0);
        await prefs.setString(_dateKey, today);
        await prefs.setInt(_deviceStepsKey, 0);
        await prefs.setBool('steps_service_initialized', true);
        
        print('First install: Initialized with 0 steps');
        _stepsController.add(_dailySteps);
        return;
      }
      
      // Get steps from SharedPreferences (may be more recent from background service)
      // EDGE CASE: Handle SharedPreferences corruption (wrong data type)
      int prefsSteps = 0;
      try {
        final prefsValue = prefs.get(_dailyStepsKey);
        if (prefsValue is int) {
          prefsSteps = prefsValue;
        } else if (prefsValue is String) {
          prefsSteps = int.tryParse(prefsValue) ?? 0;
        } else if (prefsValue != null) {
          print('WARNING: Unexpected data type in SharedPreferences for steps: ${prefsValue.runtimeType}');
          // Clear corrupted data
          await prefs.remove(_dailyStepsKey);
        }
      } catch (e) {
        print('Error reading steps from SharedPreferences: $e');
        prefsSteps = 0;
      }
      
      // Validate loaded steps - if unreasonably high (>15k), reset to 0
      // This fixes cases where baseline was set incorrectly when real steps were first enabled
      int loadedSteps = math.max(dbSteps, prefsSteps);
      if (loadedSteps > 15000) {
        print('WARNING: Detected unreasonably high step count ($loadedSteps) on load.');
        print('This may be from incorrect baseline. Resetting to 0.');
        loadedSteps = 0;
        // Clear the stored baseline so it gets recalculated
        _deviceStepsAtMidnight = 0;
        // Update database and SharedPreferences
        try {
          await StepsDatabase.insertOrUpdateDailySteps(today, 0);
          final todayDayName = _getDayAbbreviation(DateTime.now().weekday);
          await StepsDatabase.insertOrUpdateSteps(todayDayName, 0);
          await prefs.setInt(_dailyStepsKey, 0);
          await prefs.setInt(_deviceStepsKey, 0);
        } catch (e) {
          print('Error resetting steps: $e');
        }
      }
      
      _dailySteps = loadedSteps;
      
      // If SharedPreferences has a higher value (and it's reasonable), update database
      if (prefsSteps > dbSteps && prefsSteps <= 15000) {
        print('SharedPreferences has higher step count ($prefsSteps > $dbSteps), updating database');
        try {
          await StepsDatabase.insertOrUpdateDailySteps(today, prefsSteps);
          final todayDayName = _getDayAbbreviation(DateTime.now().weekday);
          await StepsDatabase.insertOrUpdateSteps(todayDayName, prefsSteps);
        } catch (e) {
          print('Error updating database with SharedPreferences value: $e');
        }
      }
      
      // Load other data from SharedPreferences (these are not in database)
      // EDGE CASE: Handle SharedPreferences corruption for all fields
      try {
        final goalValue = prefs.get(_goalKey);
        if (goalValue is int) {
          _dailyGoal = goalValue;
        } else {
          _dailyGoal = 10000;
        }
      } catch (e) {
        print('Error reading goal from SharedPreferences: $e');
        _dailyGoal = 10000;
      }
      
      try {
        final deviceStepsValue = prefs.get(_deviceStepsKey);
        if (deviceStepsValue is int) {
          _deviceStepsAtMidnight = deviceStepsValue;
        } else {
          _deviceStepsAtMidnight = 0;
        }
      } catch (e) {
        print('Error reading device steps from SharedPreferences: $e');
        _deviceStepsAtMidnight = 0;
      }
      
      try {
        final dateValue = prefs.getString(_dateKey);
        if (dateValue != null && _isValidDateString(dateValue)) {
          _currentDate = dateValue;
        } else {
          _currentDate = today;
          if (dateValue != null) {
            print('WARNING: Invalid date format in SharedPreferences: $dateValue');
            await prefs.remove(_dateKey);
          }
        }
      } catch (e) {
        print('Error reading date from SharedPreferences: $e');
        _currentDate = today;
      }
      
      // If date doesn't match today, check for day change
      // CRITICAL: Save yesterday's steps before day change to prevent data loss
      if (_currentDate != today && _currentDate.isNotEmpty) {
        print('Day change detected on load: $_currentDate -> $today');
        
        // CRITICAL: Get the best value for yesterday's steps
        // Try to get from database first (might have been saved earlier)
        int yesterdaySteps = _dailySteps;
        
        try {
          final dbData = await StepsDatabase.getDailySteps(_currentDate);
          if (dbData != null && dbData['total_steps'] != null) {
            final dbSteps = dbData['total_steps'] as int;
            // Use the higher value (database or current memory)
            yesterdaySteps = math.max(yesterdaySteps, dbSteps);
            print('Found yesterday\'s steps in database on load: $dbSteps, using: $yesterdaySteps');
          }
        } catch (e) {
          print('Could not load yesterday from database on load: $e');
        }
        
        print('Saving yesterday\'s steps before day change: $yesterdaySteps for $_currentDate');
        
        // Save yesterday's steps to database BEFORE day change
        try {
          await StepsDatabase.insertOrUpdateDailySteps(
            _currentDate,
            yesterdaySteps,
          );
          final yesterdayDayName = _getDayAbbreviation(
            DateTime.parse(_currentDate).weekday
          );
          await StepsDatabase.insertOrUpdateSteps(yesterdayDayName, yesterdaySteps);
          print('Saved yesterday\'s steps on load: $_currentDate = $yesterdaySteps');
        } catch (e) {
          print('Error saving yesterday\'s steps on load: $e');
        }
        
        await _checkForNewDay();
      }

      print('Loaded stored data (Single Source of Truth):');
      print('  Daily steps: $_dailySteps (database: $dbSteps, prefs: $prefsSteps)');
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

  // CRITICAL FIX: Save stored data - Single Source of Truth pattern
  // Database is primary, SharedPreferences is cache for background service and notifications
  // This method ensures database and SharedPreferences stay in sync to prevent notification/app mismatch
  Future<void> _saveStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();

      // CRITICAL FIX: Save to database first (single source of truth) with retry logic
      int dbRetries = 3;
      bool dbSaved = false;
      while (dbRetries > 0 && !dbSaved) {
        try {
          await StepsDatabase.insertOrUpdateDailySteps(
            today,
            _dailySteps,
          );
          // Also update weekly table for backward compatibility
          final todayDayName = _getDayAbbreviation(DateTime.now().weekday);
          await StepsDatabase.insertOrUpdateSteps(todayDayName, _dailySteps);
          dbSaved = true;
        } catch (e) {
          dbRetries--;
          if (dbRetries > 0) {
            print('Warning: Could not save to database (retrying): $e');
            await Future.delayed(Duration(milliseconds: 200));
          } else {
            print('Warning: Could not save to database after retries, using SharedPreferences only: $e');
          }
        }
      }

      // CRITICAL FIX: Always save to SharedPreferences as cache (for background service and notifications)
      // This ensures notifications read the same value as the steps page
      // Use atomic operations to prevent corruption
      try {
        await prefs.setInt(_dailyStepsKey, _dailySteps);
        await prefs.setInt(_goalKey, _dailyGoal);
        await prefs.setInt(_deviceStepsKey, _deviceStepsAtMidnight);
        await prefs.setString(_dateKey, _currentDate);
        
        // Update last sync time for health check
        await prefs.setString('${_dateKey}_last_update', DateTime.now().toIso8601String());
      } catch (e) {
        print('Error saving to SharedPreferences: $e');
        // Try to clear corrupted data
        try {
          await prefs.remove(_dailyStepsKey);
          await prefs.setInt(_dailyStepsKey, _dailySteps);
        } catch (clearError) {
          print('Error clearing corrupted SharedPreferences: $clearError');
        }
      }
      
      print('Saved stored data: $_dailySteps steps for $_currentDate (goal: $_dailyGoal)');
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

  // CRITICAL FIX: Improved sync method for app resume
  // Called when app comes back to foreground after being closed
  // This ensures immediate sync to prevent notification/app mismatch
  Future<void> syncOnAppResume() async {
    try {
      print('CRITICAL: Syncing steps on app resume...');
      print('Background service was tracking steps while app was closed.');
      
      // CRITICAL: Check for day change first and recover any lost data
      await _checkForNewDay();
      
      // CRITICAL FIX: Force immediate sync to prevent notification/app mismatch
      // Sync with background service first to get latest data
      await _syncWithBackgroundService();
      
      // Then force sync from SharedPreferences to ensure database is updated
      await forceSyncFromSharedPreferences();
      
      // Final sync to ensure everything is in sync
      await _syncWithBackgroundService();
      
      // CRITICAL: Save immediately to database to ensure persistence
      await _saveToDatabase();
      
      print('App resume sync completed - Current steps: $_dailySteps');
      print('Steps tracked while app was closed have been synced.');
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

  // Save steps before app closes - critical for data persistence
  Future<void> saveBeforeAppCloses() async {
    try {
      print('Saving steps before app closes: $_dailySteps');
      // Force save current steps to database
      await _saveToDatabase();
      // Also ensure SharedPreferences is updated (this is critical - background service reads from here)
      await _saveStoredData();
      
      // CRITICAL: Mark that we saved successfully before close
      // This helps detect if app was killed vs normal close
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_save_before_close', DateTime.now().toIso8601String());
      await prefs.setInt('last_saved_steps', _dailySteps);
      await prefs.setString('last_saved_date', _currentDate);
      
      print('Steps saved successfully before app close');
    } catch (e) {
      print('Error saving steps before app close: $e');
    }
  }
  
  // CRITICAL: Recover data when app restarts after being killed by the system
  // 
  // What happens when app is killed:
  // 1. Flutter app code stops immediately - no chance to save
  // 2. Background service (native Android/iOS) may continue running IF:
  //    - It's a foreground service with notification
  //    - System hasn't killed it due to memory pressure
  // 3. Background service saves to SharedPreferences (not database)
  // 4. When app restarts, we need to:
  //    - Check SharedPreferences for steps updated by background service
  //    - Sync those steps to database
  //    - Recover any lost data
  //
  // The background service continues running and saves to SharedPreferences
  // We need to sync that data to the database
  Future<void> _recoverFromAppKill(SharedPreferences prefs, String today) async {
    try {
      // Check if there's data in SharedPreferences that's not in database
      final prefsSteps = prefs.getInt(_dailyStepsKey) ?? 0;
      final prefsDate = prefs.getString(_dateKey) ?? today;
      
      // Check if app was killed (no last_save_before_close timestamp)
      final lastSaveTime = prefs.getString('last_save_before_close');
      final lastSavedSteps = prefs.getInt('last_saved_steps') ?? 0;
      final lastSavedDate = prefs.getString('last_saved_date') ?? '';
      
      // If we have steps in SharedPreferences but no recent save timestamp,
      // it means the app was killed and background service updated SharedPreferences
      if (prefsSteps > 0 && prefsDate == today) {
        try {
          // Check if database has this data
          final dbData = await StepsDatabase.getDailySteps(today);
          final dbSteps = dbData?['total_steps'] as int? ?? 0;
          
          // If SharedPreferences has more steps than database, background service was updating
          // This means app was killed and we need to recover
          if (prefsSteps > dbSteps) {
            print('RECOVERY: App was killed, recovering steps from background service');
            print('  SharedPreferences: $prefsSteps, Database: $dbSteps');
            
            // Save the recovered steps to database
            await StepsDatabase.insertOrUpdateDailySteps(today, prefsSteps);
            final todayDayName = _getDayAbbreviation(DateTime.now().weekday);
            await StepsDatabase.insertOrUpdateSteps(todayDayName, prefsSteps);
            
            print('RECOVERY: Saved recovered steps to database: $prefsSteps');
          }
          
          // Also check if yesterday's steps need recovery
          if (lastSavedDate.isNotEmpty && lastSavedDate != today) {
            try {
              final yesterdayDbData = await StepsDatabase.getDailySteps(lastSavedDate);
              final yesterdayDbSteps = yesterdayDbData?['total_steps'] as int? ?? 0;
              
              // If we have saved steps for yesterday that aren't in database, recover them
              if (lastSavedSteps > 0 && lastSavedSteps > yesterdayDbSteps) {
                print('RECOVERY: Recovering yesterday\'s steps: $lastSavedSteps for $lastSavedDate');
                await StepsDatabase.insertOrUpdateDailySteps(lastSavedDate, lastSavedSteps);
                final yesterdayDayName = _getDayAbbreviation(
                  DateTime.parse(lastSavedDate).weekday
                );
                await StepsDatabase.insertOrUpdateSteps(yesterdayDayName, lastSavedSteps);
              }
            } catch (e) {
              print('Error recovering yesterday\'s steps: $e');
            }
          }
        } catch (e) {
          print('Error during recovery: $e');
        }
      }
    } catch (e) {
      print('Error in _recoverFromAppKill: $e');
    }
  }

  void dispose() {
    // Save before disposing
    saveBeforeAppCloses();
    
    _periodicSyncTimer?.cancel();
    _healthCheckTimer?.cancel();
    _periodicDatabaseSaveTimer?.cancel();
    _preMidnightSaveTimer?.cancel();
    _stepCountStream?.cancel();
    _pedestrianStatusStream?.cancel();
    _stepsController.close();
    _statusController.close();

    // Optionally stop background service (uncomment if needed)
    // _stopBackgroundService();
  }
}
