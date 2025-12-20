import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/token_manager.dart';
import '../models/user_model.dart';

class OnboardingProvider with ChangeNotifier {
  // Onboarding data
  double? _height;
  double? _weight;
  DateTime? _birthday;
  String? _dietPreference; // 'veg' or 'non-veg'
  String? _lifestyle;
  String? _goal;

  // UI state
  int _currentStep = 0;
  bool _isSaving = false;
  String? _error;

  // Getters
  double? get height => _height;
  double? get weight => _weight;
  DateTime? get birthday => _birthday;
  String? get dietPreference => _dietPreference;
  String? get lifestyle => _lifestyle;
  String? get goal => _goal;
  int get currentStep => _currentStep;
  bool get isSaving => _isSaving;
  String? get error => _error;

  // Initialize with existing user data if available
  Future<void> initialize() async {
    try {
      final userData = await TokenManager.getUserData();
      if (userData != null) {
        final userProfile = UserProfile.fromJson(userData);
        _height = userProfile.height;
        _weight = userProfile.weight;
        _birthday = userProfile.birthday;
        _dietPreference = userProfile.dietPreference;
        _lifestyle = userProfile.lifestyle;
        _goal = userProfile.goal;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing onboarding: $e');
    }
  }

  // Update methods
  void updateHeight(double? value) {
    _height = value;
    notifyListeners();
  }

  void updateWeight(double? value) {
    _weight = value;
    notifyListeners();
  }

  void updateBirthday(DateTime? value) {
    _birthday = value;
    notifyListeners();
  }

  void updateDietPreference(String? value) {
    _dietPreference = value;
    notifyListeners();
  }

  void updateLifestyle(String? value) {
    _lifestyle = value;
    notifyListeners();
  }

  void updateGoal(String? value) {
    _goal = value;
    notifyListeners();
  }

  // Navigation methods
  void nextStep() {
    if (_currentStep < 4) {
      _currentStep++;
      _error = null;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _error = null;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      _currentStep = step;
      _error = null;
      notifyListeners();
    }
  }

  // Save onboarding data
  Future<bool> saveOnboardingData() async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      Map<String, dynamic> updateData = {};

      // Only include fields that have values
      if (_height != null) {
        updateData['height'] = _height;
      }
      if (_weight != null) {
        updateData['weight'] = _weight;
      }
      if (_birthday != null) {
        // Normalize birthday to UTC at midnight
        final normalized = DateTime(_birthday!.year, _birthday!.month, _birthday!.day);
        final utcDate = DateTime.utc(normalized.year, normalized.month, normalized.day);
        updateData['birthday'] = utcDate.toIso8601String();
      }
      if (_dietPreference != null && _dietPreference!.isNotEmpty) {
        updateData['dietPreference'] = _dietPreference;
      }
      if (_lifestyle != null && _lifestyle!.isNotEmpty) {
        updateData['lifestyle'] = _lifestyle;
      }
      if (_goal != null && _goal!.isNotEmpty) {
        updateData['goal'] = _goal;
      }

      // Always set hasRegistered to true after onboarding (even if skipped)
      updateData['hasRegistered'] = true;
      updateData['registerTime'] = DateTime.now().toIso8601String();

      if (updateData.isEmpty) {
        _isSaving = false;
        notifyListeners();
        return true; // Nothing to save, but that's okay
      }

      final result = await ProfileService.updateUserProfile(updateData);

      if (result['success']) {
        // Update local user data
        final updatedUserData = result['data'];
        await TokenManager.updateUserData(updatedUserData);
        _isSaving = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Failed to save onboarding data';
        _isSaving = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error saving data: ${e.toString()}';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // Check if current step is valid
  bool isStepValid(int step) {
    switch (step) {
      case 0: // Height and Weight
        return true; // Optional, can skip
      case 1: // Date of Birth
        return true; // Optional, can skip
      case 2: // Diet Preference
        return true; // Optional, can skip
      case 3: // Lifestyle
        return true; // Optional, can skip
      case 4: // Goal
        return true; // Optional, can skip
      default:
        return false;
    }
  }

  // Reset onboarding state
  void reset() {
    _currentStep = 0;
    _height = null;
    _weight = null;
    _birthday = null;
    _dietPreference = null;
    _lifestyle = null;
    _goal = null;
    _isSaving = false;
    _error = null;
    notifyListeners();
  }
}

