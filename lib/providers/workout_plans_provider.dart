import 'package:flutter/material.dart';
import 'package:gym_app_2/models/workout_plan.dart';
import 'package:gym_app_2/services/workout_plans_service.dart';

class WorkoutPlansProvider with ChangeNotifier {
  WorkoutPlan? _currentWorkoutPlan;
  List<WorkoutPlan> _workoutPlans = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  WorkoutPlan? get currentWorkoutPlan => _currentWorkoutPlan;
  List<WorkoutPlan> get workoutPlans => _workoutPlans;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Initialize provider - fetch current workout plan
  Future<void> initialize() async {
    await fetchCurrentWorkoutPlan();
  }

  /// Fetch current active workout plan
  Future<void> fetchCurrentWorkoutPlan() async {
    try {
      _setLoading(true);
      _setError(null);

      final plan = await WorkoutPlansService.getCurrentWorkoutPlan();
      _currentWorkoutPlan = plan;

      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch current workout plan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch all workout plans with optional filters
  Future<void> fetchAllWorkoutPlans({
    String? status,
    int limit = 20,
    int skip = 0,
    bool append = false,
  }) async {
    try {
      if (!append) {
        _setLoading(true);
      }
      _setError(null);

      final plans = await WorkoutPlansService.getAllWorkoutPlans(
        status: status,
        limit: limit,
        skip: skip,
      );

      if (append) {
        _workoutPlans.addAll(plans);
      } else {
        _workoutPlans = plans;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch workout plans: ${e.toString()}');
    } finally {
      if (!append) {
        _setLoading(false);
      }
    }
  }

  /// Filter workout plans by status
  List<WorkoutPlan> getWorkoutPlansByStatus(String status) {
    return _workoutPlans.where((plan) => plan.status == status).toList();
  }

  /// Get active workout plans
  List<WorkoutPlan> get activeWorkoutPlans {
    return getWorkoutPlansByStatus('active');
  }

  /// Get completed workout plans
  List<WorkoutPlan> get completedWorkoutPlans {
    return getWorkoutPlansByStatus('completed');
  }

  /// Get paused workout plans
  List<WorkoutPlan> get pausedWorkoutPlans {
    return getWorkoutPlansByStatus('paused');
  }

  /// Get cancelled workout plans
  List<WorkoutPlan> get cancelledWorkoutPlans {
    return getWorkoutPlansByStatus('cancelled');
  }

  /// Refresh data
  Future<void> refresh() async {
    await Future.wait([
      fetchCurrentWorkoutPlan(),
      fetchAllWorkoutPlans(),
    ]);
  }

  /// Clear all data
  void clear() {
    _currentWorkoutPlan = null;
    _workoutPlans.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
    }
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}

class WorkoutDayProvider with ChangeNotifier {
  WorkoutDay? _currentWorkoutDay;
  bool _isLoading = false;
  String? _error;

  // Getters
  WorkoutDay? get currentWorkoutDay => _currentWorkoutDay;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Fetch workout day data
  Future<void> fetchWorkoutDay(int weekNumber, int dayNumber) async {
    try {
      _setLoading(true);
      _setError(null);

      final workoutDay =
          await WorkoutPlansService.getWorkoutDay(weekNumber, dayNumber);
      _currentWorkoutDay = workoutDay;

      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch workout day: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear current workout day
  void clear() {
    _currentWorkoutDay = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
    }
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}
