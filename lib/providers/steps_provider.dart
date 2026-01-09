// lib/providers/steps_provider.dart
import 'package:flutter/foundation.dart';
import '../services/steps_service.dart';

class StepsProvider extends ChangeNotifier {
  final StepsService _stepsService = StepsService.instance;

  int _currentSteps = 0;
  int _dailyGoal = 10000;
  String _pedestrianStatus = 'unknown';
  bool _isInitialized = false;
  bool _isLoading = false;

  // Getters
  int get currentSteps => _currentSteps;
  int get dailyGoal => _dailyGoal;
  String get pedestrianStatus => _pedestrianStatus;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isUsingRealPedometer => _stepsService.isUsingRealPedometer;

  Future<bool> get isStepCountingAvailable =>
      _stepsService.isStepCountingAvailable;

  double get progressPercentage => (_currentSteps / _dailyGoal).clamp(0.0, 1.0);
  bool get isGoalAchieved => _currentSteps >= _dailyGoal;
  int get remainingSteps => _dailyGoal - _currentSteps;

  StepsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Initialize the steps service
      await _stepsService.initialize();

      // Load initial data
      _currentSteps = _stepsService.currentSteps;
      _dailyGoal = _stepsService.dailyGoal;
      _pedestrianStatus = _stepsService.pedestrianStatus;

      // Listen to real-time updates
      _stepsService.stepsStream.listen((steps) {
        _currentSteps = steps;
        _dailyGoal = _stepsService.dailyGoal;
        notifyListeners();
      });

      _stepsService.statusStream.listen((status) {
        _pedestrianStatus = status;
        notifyListeners();
      });

      _isInitialized = true;
      print('StepsProvider initialized successfully - Steps: $_currentSteps');
    } catch (e) {
      print('Error initializing StepsProvider: $e');
      // Set default values in case of error
      _currentSteps = 0;
      _dailyGoal = 10000;
      _pedestrianStatus = 'unknown';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manual refresh with app resume sync
  Future<void> refresh() async {
    // Force sync with background service to get latest step count
    await _stepsService.forceSyncFromSharedPreferences();
    // Then sync with device pedometer when app resumes
    await _stepsService.syncOnAppResume();

    // Update local data from service
    _currentSteps = _stepsService.currentSteps;
    _dailyGoal = _stepsService.dailyGoal;
    _pedestrianStatus = _stepsService.pedestrianStatus;

    notifyListeners();
    print('StepsProvider refreshed - Current steps: $_currentSteps');
  }

  // Retry pedometer setup (useful after permission grant)
  Future<void> retryPedometerSetup() async {
    try {
      await _stepsService.retryPedometerSetup();
      // Refresh our local data
      _currentSteps = _stepsService.currentSteps;
      _dailyGoal = _stepsService.dailyGoal;
      _pedestrianStatus = _stepsService.pedestrianStatus;
      notifyListeners();
    } catch (e) {
      print('Error retrying pedometer setup: $e');
      rethrow;
    }
  }

  // Set daily goal
  Future<void> setDailyGoal(int goal) async {
    try {
      await _stepsService.setDailyGoal(goal);
      _dailyGoal = goal;
      notifyListeners();
    } catch (e) {
      print('Error setting daily goal: $e');
      rethrow;
    }
  }

  // Add steps manually (for testing)
  Future<void> addSteps(int steps) async {
    try {
      await _stepsService.addSteps(steps);
      // The service will notify through stream, so we don't need to update here
    } catch (e) {
      print('Error adding steps: $e');
      rethrow;
    }
  }

  // Get weekly steps data
  Future<Map<String, int>> getWeeklySteps() async {
    try {
      return await _stepsService.getWeeklySteps();
    } catch (e) {
      print('Error getting weekly steps: $e');
      return {};
    }
  }

  // Get steps for a 7-day period (offset: 0 = today-6, 1 = today-13, etc.)
  // Returns a map with date strings as keys and step counts as values
  Future<Map<String, int>> getStepsFor7DayPeriod(int offset, {int? todaySteps}) async {
    try {
      return await _stepsService.getStepsFor7DayPeriod(offset, todaySteps: todaySteps ?? _currentSteps);
    } catch (e) {
      print('Error getting 7-day period steps: $e');
      return {};
    }
  }


  // Get tracking status for debugging
  Map<String, dynamic> getTrackingStatus() {
    return _stepsService.getTrackingStatus();
  }

  @override
  void dispose() {
    _stepsService.dispose();
    super.dispose();
  }
}
