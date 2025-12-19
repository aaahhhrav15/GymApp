import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class BMIData {
  final double bmi;
  final String status;
  final String gender;
  final double height;
  final int weight;
  final int age;
  final DateTime calculatedDate;

  BMIData({
    required this.bmi,
    required this.status,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
    required this.calculatedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'bmi': bmi,
      'status': status,
      'gender': gender,
      'height': height,
      'weight': weight,
      'age': age,
      'calculatedDate': calculatedDate.toIso8601String(),
    };
  }

  factory BMIData.fromJson(Map<String, dynamic> json) {
    return BMIData(
      bmi: (json['bmi'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'Normal',
      gender: json['gender'] ?? 'Female',
      height: (json['height'] ?? 172.0).toDouble(),
      weight: json['weight'] ?? 58,
      age: json['age'] ?? 22,
      calculatedDate: json['calculatedDate'] != null
          ? DateTime.parse(json['calculatedDate'])
          : DateTime.now(),
    );
  }
}

class BMIProvider with ChangeNotifier {
  // SharedPreferences keys
  static const String _bmiDataKey = 'bmi_data';
  static const String _bmiHistoryKey = 'bmi_history';
  static const String _userUpdatedValuesKey = 'bmi_user_updated_values';

  // Current BMI data
  BMIData? _currentBMI;
  List<BMIData> _bmiHistory = [];

  // UI state
  bool _isLoading = false;
  String? _error;

  // Input values for calculation
  String _selectedGender = 'Female';
  double _height = 172.0;
  int _weight = 58;
  int _age = 22;

  // Track if user has manually updated values
  bool _userHasUpdatedValues = false;

  // Getters
  BMIData? get currentBMI => _currentBMI;
  List<BMIData> get bmiHistory => List.unmodifiable(_bmiHistory);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedGender => _selectedGender;
  double get height => _height;
  int get weight => _weight;
  int get age => _age;
  bool get userHasUpdatedValues => _userHasUpdatedValues;

  // Computed getters
  bool get hasBMIData => _currentBMI != null;

  double get currentBMIValue => _currentBMI?.bmi ?? 0.0;

  String get currentBMIStatus => _currentBMI?.status ?? 'Unknown';

  /// Initialize the provider and load saved data
  Future<void> initialize({UserProfile? userProfile}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadUserUpdatedFlag();
      await _loadSavedBMIData();
      await _loadBMIHistory();

      // If user hasn't updated values and we have backend data, use it
      if (!_userHasUpdatedValues && userProfile != null) {
        await _initializeFromBackend(userProfile);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load BMI data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialize or update BMI data from backend user profile
  Future<void> initializeFromBackendData(UserProfile userProfile) async {
    try {
      // If user hasn't manually updated values, use backend data
      if (!_userHasUpdatedValues &&
          userProfile.height != null &&
          userProfile.weight != null) {
        _height = userProfile.height!;
        _weight = userProfile.weight!.round();

        // Calculate BMI automatically from backend data
        await _calculateBMIFromBackend(userProfile);
        notifyListeners();
      }
    } catch (e) {
      print('Error initializing from backend data: $e');
    }
  }

  /// Calculate BMI from backend data without marking as user updated
  Future<void> _calculateBMIFromBackend(UserProfile userProfile) async {
    if (userProfile.bmi != null) {
      // Create BMI data from backend calculation
      final backendBMIData = BMIData(
        bmi: userProfile.bmi!,
        status: userProfile.bmiCategory ?? _getBMIStatus(userProfile.bmi!),
        gender: _selectedGender, // Keep current gender selection
        height: userProfile.height!,
        weight: userProfile.weight!.round(),
        age: _age, // Keep current age
        calculatedDate: DateTime.now(),
      );

      // Only update if we don't have current BMI data or if user hasn't updated locally
      if (_currentBMI == null || !_userHasUpdatedValues) {
        _currentBMI = backendBMIData;

        // Update input values but don't mark as user updated
        _height = userProfile.height!;
        _weight = userProfile.weight!.round();

        // Save to local storage
        await _saveBMIData();
      }
    }
  }

  /// Initialize height and weight from backend user profile (only if user hasn't updated locally)
  Future<void> _initializeFromBackend(UserProfile userProfile) async {
    try {
      if (userProfile.weight != null && userProfile.height != null) {
        _height = userProfile.height!;
        _weight = userProfile.weight!.round();

        // Don't mark as user updated since this is from backend
        notifyListeners();
      }
    } catch (e) {
      print('Error initializing from backend: $e');
      // Continue with default values if backend data is invalid
    }
  }

  /// Load flag indicating if user has manually updated values
  Future<void> _loadUserUpdatedFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userHasUpdatedValues = prefs.getBool(_userUpdatedValuesKey) ?? false;
    } catch (e) {
      print('Error loading user updated flag: $e');
      _userHasUpdatedValues = false;
    }
  }

  /// Save flag indicating user has manually updated values
  Future<void> _saveUserUpdatedFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_userUpdatedValuesKey, _userHasUpdatedValues);
    } catch (e) {
      print('Error saving user updated flag: $e');
    }
  }

  /// Mark that user has manually updated height/weight values
  void _markUserUpdated() {
    if (!_userHasUpdatedValues) {
      _userHasUpdatedValues = true;
      _saveUserUpdatedFlag(); // Save to persistent storage
    }
  }

  /// Load current BMI data from SharedPreferences
  Future<void> _loadSavedBMIData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bmiDataString = prefs.getString(_bmiDataKey);

      if (bmiDataString != null) {
        final bmiDataJson = json.decode(bmiDataString);
        _currentBMI = BMIData.fromJson(bmiDataJson);

        // Update input values with saved data
        _selectedGender = _currentBMI!.gender;
        _height = _currentBMI!.height;
        _weight = _currentBMI!.weight;
        _age = _currentBMI!.age;
      }
    } catch (e) {
      print('Error loading BMI data: $e');
      // Don't throw error, just continue with default values
    }
  }

  /// Load BMI history from SharedPreferences
  Future<void> _loadBMIHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString(_bmiHistoryKey);

      if (historyString != null) {
        final historyJson = json.decode(historyString) as List;
        _bmiHistory =
            historyJson.map((item) => BMIData.fromJson(item)).toList();

        // Sort by date descending (newest first)
        _bmiHistory
            .sort((a, b) => b.calculatedDate.compareTo(a.calculatedDate));
      }
    } catch (e) {
      print('Error loading BMI history: $e');
      _bmiHistory = [];
    }
  }

  /// Save current BMI data to SharedPreferences
  Future<void> _saveBMIData() async {
    if (_currentBMI == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final bmiDataString = json.encode(_currentBMI!.toJson());
      await prefs.setString(_bmiDataKey, bmiDataString);
    } catch (e) {
      print('Error saving BMI data: $e');
      throw Exception('Failed to save BMI data');
    }
  }

  /// Save BMI history to SharedPreferences
  Future<void> _saveBMIHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _bmiHistory.map((bmi) => bmi.toJson()).toList();
      final historyString = json.encode(historyJson);
      await prefs.setString(_bmiHistoryKey, historyString);
    } catch (e) {
      print('Error saving BMI history: $e');
      throw Exception('Failed to save BMI history');
    }
  }

  /// Update gender
  void updateGender(String gender) {
    if (_selectedGender != gender) {
      _selectedGender = gender;
      notifyListeners();
    }
  }

  /// Update height
  void updateHeight(double height) {
    if (_height != height) {
      _height = height;
      _markUserUpdated();
      notifyListeners();
    }
  }

  /// Update weight
  void updateWeight(int weight) {
    if (_weight != weight && weight >= 30 && weight <= 300) {
      _weight = weight;
      _markUserUpdated();
      notifyListeners();
    }
  }

  /// Update age
  void updateAge(int age) {
    if (_age != age && age >= 10 && age <= 100) {
      _age = age;
      notifyListeners();
    }
  }

  /// Increment weight
  void incrementWeight() {
    if (_weight < 300) {
      _weight++;
      _markUserUpdated();
      notifyListeners();
    }
  }

  /// Decrement weight
  void decrementWeight() {
    if (_weight > 30) {
      _weight--;
      _markUserUpdated();
      notifyListeners();
    }
  }

  /// Increment age
  void incrementAge() {
    if (_age < 100) {
      _age++;
      notifyListeners();
    }
  }

  /// Decrement age
  void decrementAge() {
    if (_age > 10) {
      _age--;
      notifyListeners();
    }
  }

  /// Calculate BMI and save the result
  Future<BMIData> calculateBMI() async {
    _error = null;

    try {
      // Calculate BMI
      final heightInMeters = _height / 100;
      final bmi = _weight / (heightInMeters * heightInMeters);
      final status = _getBMIStatus(bmi);

      // Create new BMI data
      final newBMIData = BMIData(
        bmi: bmi,
        status: status,
        gender: _selectedGender,
        height: _height,
        weight: _weight,
        age: _age,
        calculatedDate: DateTime.now(),
      );

      // Update current BMI
      _currentBMI = newBMIData;

      // Add to history
      _bmiHistory.insert(0, newBMIData);

      // Keep only last 50 records in history
      if (_bmiHistory.length > 50) {
        _bmiHistory = _bmiHistory.take(50).toList();
      }

      // Save to persistent storage
      await _saveBMIData();
      await _saveBMIHistory();

      notifyListeners();
      return newBMIData;
    } catch (e) {
      _error = 'Failed to calculate BMI: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  /// Get BMI status based on BMI value
  String _getBMIStatus(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// Get BMI description
  String getBMIDescription(double bmi) {
    if (bmi < 18.5) {
      return 'A BMI below 18.5 indicates that you may be underweight. Consider consulting with a healthcare provider.';
    } else if (bmi < 25) {
      return 'A BMI of 18.5 - 24.9 indicates that you are at a healthy weight for your height. By maintaining a healthy weight, you lower your risk of developing serious health problems.';
    } else if (bmi < 30) {
      return 'A BMI of 25 - 29.9 indicates that you may be overweight. Consider a balanced diet and regular exercise.';
    } else {
      return 'A BMI of 30 or above indicates obesity. It\'s recommended to consult with a healthcare provider for guidance.';
    }
  }

  /// Get BMI status color
  Color getBMIStatusColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF2196F3); // Blue
    if (bmi < 25) return const Color(0xFF4CAF50); // Green
    if (bmi < 30) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  /// Clear current BMI data
  Future<void> clearBMIData() async {
    _currentBMI = null;
    _error = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bmiDataKey);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear BMI data: $e';
      notifyListeners();
    }
  }

  /// Clear BMI history
  Future<void> clearBMIHistory() async {
    _bmiHistory.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bmiHistoryKey);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear BMI history: $e';
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Get BMI trend (comparing with previous calculation)
  String? getBMITrend() {
    if (_bmiHistory.length < 2) return null;

    final current = _bmiHistory[0].bmi;
    final previous = _bmiHistory[1].bmi;

    final difference = current - previous;

    if (difference > 0.1) return 'increasing';
    if (difference < -0.1) return 'decreasing';
    return 'stable';
  }

  /// Get formatted BMI trend text
  String? getBMITrendText() {
    final trend = getBMITrend();
    if (trend == null || _bmiHistory.length < 2) return null;

    final difference = (_bmiHistory[0].bmi - _bmiHistory[1].bmi).abs();

    switch (trend) {
      case 'increasing':
        return '↑ +${difference.toStringAsFixed(1)} from last time';
      case 'decreasing':
        return '↓ -${difference.toStringAsFixed(1)} from last time';
      case 'stable':
        return '→ No significant change';
      default:
        return null;
    }
  }
}
