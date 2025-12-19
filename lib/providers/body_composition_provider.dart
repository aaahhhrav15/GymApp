import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:icdevicemanager_flutter/icdevicemanager_flutter.dart';
import 'package:icdevicemanager_flutter/ic_bluetooth_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_app_2/models/body_composition_model.dart';
import 'package:gym_app_2/providers/profile_provider.dart';
import 'package:gym_app_2/services/body_composition_service.dart';

/// Body Composition Provider - Local Storage Mode
///
/// This provider is currently configured to work with LOCAL STORAGE ONLY.
/// All measurements from the Bluetooth scale are saved directly to local storage
/// and DO NOT affect backend data. This ensures the backend remains unchanged
/// while still providing real-time measurement updates from the scale.
///
/// Key behaviors:
/// - Scale measurements are saved to local storage only
/// - Backend data remains untouched
/// - Local measurements update every time user steps on scale
/// - CRUD operations work with local storage only

class BodyCompositionProvider
    with ChangeNotifier
    implements ICDeviceManagerDelegate, ICScanDeviceDelegate {
  // Device and connection state
  ICWeightData? _lastData;
  List<ICDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnected = false;
  bool _scanningSessionActive = false; // Track if we're in an active scanning session
  bool _isInitialized = false;
  String? _error;

  // Profile provider reference for user data
  final ProfileProvider? _profileProvider;

  // User profile data - will be populated from ProfileProvider
  String _userName = "";
  DateTime? _userDOB;
  int _userAge = 25;
  double _userHeight = 175.0; // cm
  double _userWeight = 70.0; // kg
  ICSexType _userSex = ICSexType.ICSexTypeMale;
  bool _hasUserProfile = false;
  bool _useMetricUnits = true; // true for metric, false for imperial

  // Legacy model support
  BodyCompositionModel? _currentComposition;
  List<BodyCompositionModel> _compositionHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Measurement history
  List<Map<String, dynamic>> _measurementHistory = [];
  int _totalMeasurements = 0;
  
  // Track last saved stabilized measurement to prevent duplicate saves
  double? _lastSavedStabilizedWeight;
  DateTime? _lastSavedStabilizedTime;

  // Getters for SDK data
  ICWeightData? get lastData => _lastData;
  List<ICDevice> get devices => _devices;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  // User profile getters
  String get userName => _userName;
  DateTime? get userDOB => _userDOB;
  int get userAge => _userAge;
  double get userHeight => _userHeight;
  double get userWeight => _userWeight;
  ICSexType get userSex => _userSex;
  bool get hasUserProfile => _hasUserProfile;
  bool get useMetricUnits => _useMetricUnits;

  // History getters
  List<Map<String, dynamic>> get measurementHistory => _measurementHistory;
  int get totalMeasurements => _totalMeasurements;

  // Legacy model getters
  BodyCompositionModel? get currentComposition => _currentComposition;
  List<BodyCompositionModel> get compositionHistory => _compositionHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Backwards compatibility getters for existing UI components
  double get weight => _lastData?.weight_kg ?? 0.0;
  double get bodyFatPercentage => _lastData?.bodyFatPercent ?? 0.0;
  double get musclePercentage => _lastData?.musclePercent ?? 0.0;
  double get waterPercentage => _lastData?.moisturePercent ?? 0.0;
  double get boneMass => _lastData?.boneMass ?? 0.0;
  double get visceralFat => _lastData?.visceralFat ?? 0.0;
  double get bmr => _lastData?.bmr.toDouble() ?? 0.0;
  double get bmi => _lastData?.bmi ?? 0.0;
  String get measurementStatus => _lastData != null
      ? getDataStatus(_lastData!.bodyFatPercent, "body fat")
      : "Not measured";
  DateTime? get lastMeasurementDate =>
      _lastData != null ? DateTime.now() : null;
  bool get hasData => _lastData != null;

  /// Initialize the provider
  BodyCompositionProvider({ProfileProvider? profileProvider})
      : _profileProvider = profileProvider {
    initialize();
  }

  /// Initialize the provider with SDK and load data from backend
  Future<void> initialize() async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      // Load user profile data
      await _loadUserProfile();

      // Initialize Bluetooth SDK
      await _initializeSDK();

      // Load measurement history from backend
      await _loadMeasurementHistory();

      // Load latest measurement from backend
      await _loadLatestMeasurement();

      _isInitialized = true;
      debugPrint("BodyCompositionProvider initialized successfully");
    } catch (e) {
      _error = "Failed to initialize: $e";
      debugPrint("BodyCompositionProvider initialization error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user profile from ProfileProvider
  Future<void> _loadUserProfile() async {
    try {
      // Try to get data from ProfileProvider first
      if (_profileProvider?.userProfile != null) {
        final profile = _profileProvider!.userProfile!;
        _userName = profile.name;
        _userHeight = profile.height ?? 175.0; // Default to 175cm if not set
        _userWeight = profile.weight ?? 70.0; // Default to 70kg if not set
        
        // Load birthday and calculate age for SDK
        if (profile.birthday != null) {
          _userDOB = profile.birthday;
          // Calculate age from birthday
          final now = DateTime.now();
          _userAge = now.year - profile.birthday!.year;
          if (now.month < profile.birthday!.month ||
              (now.month == profile.birthday!.month && now.day < profile.birthday!.day)) {
            _userAge--;
          }
        }
        
        // Load gender/sex for SDK
        if (profile.gender != null) {
          final genderLower = profile.gender!.toLowerCase();
          if (genderLower.contains('male') || genderLower == 'm') {
            _userSex = ICSexType.ICSexTypeMale;
          } else if (genderLower.contains('female') || genderLower == 'f') {
            _userSex = ICSexType.ICSexTypeFemale;
          }
          // Otherwise keep default (Male)
        }
        
        _hasUserProfile = true;

        debugPrint(
            "Loaded user profile from ProfileProvider: Name=$_userName, Age=$_userAge, Height=${_userHeight}cm, Weight=${_userWeight}kg, Sex=$_userSex, DOB=${_userDOB?.toString() ?? 'not set'}");
      } else {
        // Fallback to SharedPreferences if ProfileProvider is not available
        final prefs = await SharedPreferences.getInstance();

        _userName = prefs.getString('user_name') ?? "";
        _userAge = prefs.getInt('user_age') ?? 25;
        _userHeight = prefs.getDouble('user_height') ?? 175.0;
        _userWeight = prefs.getDouble('user_weight') ?? 70.0;
        _userSex = ICSexType.values[prefs.getInt('user_sex') ?? 0];
        _useMetricUnits = prefs.getBool('use_metric_units') ?? true;
        _hasUserProfile = prefs.getBool('has_user_profile') ?? false;

        debugPrint(
            "Loaded user profile from SharedPreferences: Name=$_userName, Age=$_userAge");
      }
    } catch (e) {
      debugPrint("Error loading user profile: $e");
    }
  }

  /// Initialize the Bluetooth SDK
  Future<void> _initializeSDK() async {
    try {
      IcBluetoothSdk.instance.setDeviceManagerDelegate(this);
      final config = ICDeviceManagerConfig();
      IcBluetoothSdk.instance.initSDK(config);
      _updateUserInfo();
      debugPrint("SDK initialized successfully");
    } catch (e) {
      debugPrint("Error initializing SDK: $e");
      throw e;
    }
  }

  /// Update user info in the SDK
  void _updateUserInfo() {
    try {
      // Always use metric units (cm and kg) as ProfileProvider already stores in metric
      double heightCm = _userHeight;
      double weightKg = _userWeight;

      ICUserInfo userInfo = ICUserInfo();
      userInfo.sex = _userSex;
      userInfo.age = _userAge;
      userInfo.height = heightCm.round();
      userInfo.weight = weightKg;
      // Not setting targetWeight as requested (keeping it null/default)
      userInfo.bfaType = ICBFAType.ICBFATypeWLA01;
      userInfo.enableMeasureImpendence = true;
      userInfo.enableMeasureHr = true;

      debugPrint(
          "Updating SDK with user info: Age=$_userAge, Height=${heightCm}cm, Weight=${weightKg}kg, Sex=$_userSex, TargetWeight=not_set");
      IcBluetoothSdk.instance.updateUserInfo(userInfo);
    } catch (e) {
      debugPrint("Error updating user info: $e");
    }
  }

  /// Load measurement history from backend API
  Future<void> _loadMeasurementHistory() async {
    debugPrint("Loading measurement history from local storage only...");
    // Load directly from local storage, no backend calls
    await _loadMeasurementHistoryFromLocal();
  }

  /// Load measurement history from local storage
  Future<void> _loadMeasurementHistoryFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJsonList = prefs.getStringList('measurement_history') ?? [];

      _measurementHistory = historyJsonList
          .map((jsonString) => jsonDecode(jsonString) as Map<String, dynamic>)
          .toList();

      _totalMeasurements = _measurementHistory.length;

      // Update legacy composition history for backward compatibility
      _compositionHistory = _measurementHistory
          .map((m) => _convertToBodyCompositionModel(m))
          .toList();

      // Update latest measurement if available
      if (_measurementHistory.isNotEmpty) {
        _currentComposition =
            _convertToBodyCompositionModel(_measurementHistory.first);
      }

      debugPrint(
          "Loaded ${_measurementHistory.length} measurements from local storage");
    } catch (e) {
      debugPrint("Error loading measurement history from local storage: $e");
      _measurementHistory = [];
      _totalMeasurements = 0;
      _compositionHistory = [];
    }
  }

  /// Load latest measurement from local storage
  Future<void> _loadLatestMeasurement() async {
    try {
      debugPrint("Loading latest measurement from local storage...");

      if (_measurementHistory.isNotEmpty) {
        final latestData = _measurementHistory.first;

        // Convert to ICWeightData format for SDK compatibility
        _lastData = _convertToICWeightData(latestData);

        // Update legacy current composition for backward compatibility
        _currentComposition = _convertToBodyCompositionModel(latestData);

        debugPrint(
            "Loaded latest measurement from local storage: Weight=${_lastData?.weight_kg}kg");
      } else {
        debugPrint("No measurements found in local storage");
      }
    } catch (e) {
      debugPrint("Error loading latest measurement from local storage: $e");
    }
  }

  /// Request permissions and start scanning for devices
  Future<bool> startScan() async {
    try {
      _error = null;

      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      final granted = statuses.values.every((s) => s.isGranted);
      if (!granted) {
        _error = "Bluetooth/Location permissions are required to scan";
        notifyListeners();
        return false;
      }

      _isScanning = true;
      _scanningSessionActive = true; // Mark scanning session as active
      _devices.clear();
      notifyListeners();

      IcBluetoothSdk.instance.scanDevice(this);

      return true;
    } catch (e) {
      _error = "Failed to start scan: $e";
      _isScanning = false;
      debugPrint("Error starting scan: $e");
      notifyListeners();
      return false;
    }
  }

  /// Stop scanning for devices
  void stopScan() {
    try {
      _isScanning = false;
      // Only end scanning session if we're not connected
      // If connected, keep session active so weight data continues to be accepted
      if (!_isConnected) {
        _scanningSessionActive = false;
      }
      IcBluetoothSdk.instance.stopScan();
      notifyListeners();
    } catch (e) {
      debugPrint("Error stopping scan: $e");
    }
  }

  /// Get data status classification
  String getDataStatus(double value, String metric) {
    if (value <= 0) return "Not measured";

    switch (metric.toLowerCase()) {
      case 'body fat':
        if (value < 10) return "Below Standard";
        if (value <= 20) return "Good";
        if (value <= 25) return "Standard";
        return "Above Standard";
      case 'muscle':
        if (value < 30) return "Below Standard";
        if (value <= 40) return "Good";
        if (value <= 50) return "Standard";
        return "Above Standard";
      default:
        return "Measured";
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Convert backend API data to ICWeightData format for SDK compatibility
  ICWeightData _convertToICWeightData(Map<String, dynamic> data) {
    // Create a mock ICWeightData with real backend data
    // Note: This is a simplified conversion - adjust based on actual ICWeightData structure
    return ICWeightData()
      ..weight_kg = data['weight']?.toDouble() ?? 0.0
      ..bmi = data['bmi']?.toDouble() ?? 0.0
      ..bodyFatPercent = data['bodyFatPercentage']?.toDouble() ?? 0.0
      ..musclePercent = data['musclePercentage']?.toDouble() ?? 0.0
      ..moisturePercent = data['waterPercentage']?.toDouble() ?? 0.0
      ..boneMass = data['boneMass']?.toDouble() ?? 0.0
      ..bmr = data['bmr']?.toInt() ?? 0
      ..subcutaneousFatPercent = data['subcutaneousFat']?.toDouble() ?? 0.0
      ..visceralFat = data['visceralFat']?.toDouble() ?? 0.0
      ..proteinPercent = data['proteinPercentage']?.toDouble() ?? 0.0
      ..smPercent = data['skeletalMusclePercentage']?.toDouble() ?? 0.0
      ..isStabilized = data['isStabilized'] ?? true;
  }

  /// Convert backend API data to BodyCompositionModel for legacy compatibility
  BodyCompositionModel _convertToBodyCompositionModel(
      Map<String, dynamic> data) {
    return BodyCompositionModel(
      id: data['id'] ?? '',
      weight: data['weight']?.toDouble() ?? 0.0,
      bmi: data['bmi']?.toDouble() ?? 0.0,
      muscleRate: data['musclePercentage']?.toDouble() ?? 0.0,
      fatFreeBodyWeight: _calculateFatFreeBodyWeight(
          data['weight']?.toDouble() ?? 0.0,
          data['bodyFatPercentage']?.toDouble() ?? 0.0),
      bodyFat: data['bodyFatPercentage']?.toDouble() ?? 0.0,
      subcutaneousFat: data['subcutaneousFat']?.toDouble() ?? 0.0,
      visceralFat: data['visceralFat']?.toDouble() ?? 0.0,
      bodyWater: data['waterPercentage']?.toDouble() ?? 0.0,
      skeletalMuscle: data['skeletalMusclePercentage']?.toDouble() ?? 0.0,
      muscleMass: data['musclePercentage']?.toDouble() ??
          0.0, // Using muscle percentage as muscle mass
      boneMass: data['boneMass']?.toDouble() ?? 0.0,
      protein: data['proteinPercentage']?.toDouble() ?? 0.0,
      measurementDate:
          DateTime.tryParse(data['measurementDate'] ?? '') ?? DateTime.now(),
      weightStatus: _getWeightStatus(data['bmi']?.toDouble() ?? 0.0),
      bmiStatus: _getBMIStatus(data['bmi']?.toDouble() ?? 0.0),
      muscleRateStatus:
          _getMuscleStatus(data['musclePercentage']?.toDouble() ?? 0.0),
      fatFreeBodyWeightStatus: 'Standard', // Default status
      bodyFatStatus:
          _getBodyFatStatus(data['bodyFatPercentage']?.toDouble() ?? 0.0),
      subcutaneousFatStatus:
          _getSubcutaneousFatStatus(data['subcutaneousFat']?.toDouble() ?? 0.0),
      visceralFatStatus:
          _getVisceralFatStatus(data['visceralFat']?.toDouble() ?? 0.0),
      bodyWaterStatus:
          _getWaterStatus(data['waterPercentage']?.toDouble() ?? 0.0),
      skeletalMuscleStatus:
          _getMuscleStatus(data['skeletalMusclePercentage']?.toDouble() ?? 0.0),
      muscleMassStatus:
          _getMuscleStatus(data['musclePercentage']?.toDouble() ?? 0.0),
      boneMassStatus: _getBoneMassStatus(data['boneMass']?.toDouble() ?? 0.0),
      proteinStatus:
          _getProteinStatus(data['proteinPercentage']?.toDouble() ?? 0.0),
    );
  }

  /// Calculate fat-free body weight
  double _calculateFatFreeBodyWeight(double weight, double bodyFatPercentage) {
    if (weight <= 0 || bodyFatPercentage <= 0) return 0.0;
    return weight * (1 - bodyFatPercentage / 100);
  }

  /// Get weight status based on BMI
  String _getWeightStatus(double bmi) {
    if (bmi < 18.5) return 'Low';
    if (bmi < 25.0) return 'Standard';
    if (bmi < 30.0) return 'High';
    return 'Excellent'; // This might need adjustment based on your business logic
  }

  /// Get BMI status
  String _getBMIStatus(double bmi) {
    return BodyCompositionService.getBMICategory(bmi);
  }

  /// Get body fat status
  String _getBodyFatStatus(double bodyFatPercentage) {
    return getDataStatus(bodyFatPercentage, "body fat");
  }

  /// Get muscle status
  String _getMuscleStatus(double musclePercentage) {
    return getDataStatus(musclePercentage, "muscle");
  }

  /// Get subcutaneous fat status
  String _getSubcutaneousFatStatus(double subcutaneousFat) {
    if (subcutaneousFat < 10) return 'Low';
    if (subcutaneousFat < 20) return 'Standard';
    return 'High';
  }

  /// Get visceral fat status
  String _getVisceralFatStatus(double visceralFat) {
    if (visceralFat < 10) return 'Standard';
    if (visceralFat < 15) return 'High';
    return 'Excellent'; // This might need adjustment
  }

  /// Get water status
  String _getWaterStatus(double waterPercentage) {
    return getDataStatus(waterPercentage, "water");
  }

  /// Get bone mass status
  String _getBoneMassStatus(double boneMass) {
    return getDataStatus(boneMass, "bone mass");
  }

  /// Get protein status
  String _getProteinStatus(double proteinPercentage) {
    if (proteinPercentage < 15) return 'Low';
    if (proteinPercentage < 20) return 'Standard';
    if (proteinPercentage < 25) return 'Good';
    return 'Excellent';
  }

  /// Update user data from ProfileProvider - call this when profile data changes
  void updateFromProfileProvider() {
    if (_profileProvider?.userProfile != null) {
      final profile = _profileProvider!.userProfile!;
      final oldName = _userName;
      final oldHeight = _userHeight;
      final oldWeight = _userWeight;
      final oldAge = _userAge;
      final oldSex = _userSex;
      final oldDOB = _userDOB;

      _userName = profile.name;
      _userHeight = profile.height ?? 175.0;
      _userWeight = profile.weight ?? 70.0;
      
      // Update birthday and calculate age for SDK
      if (profile.birthday != null) {
        _userDOB = profile.birthday;
        // Calculate age from birthday
        final now = DateTime.now();
        _userAge = now.year - profile.birthday!.year;
        if (now.month < profile.birthday!.month ||
            (now.month == profile.birthday!.month && now.day < profile.birthday!.day)) {
          _userAge--;
        }
      }
      
      // Update gender/sex for SDK
      if (profile.gender != null) {
        final genderLower = profile.gender!.toLowerCase();
        if (genderLower.contains('male') || genderLower == 'm') {
          _userSex = ICSexType.ICSexTypeMale;
        } else if (genderLower.contains('female') || genderLower == 'f') {
          _userSex = ICSexType.ICSexTypeFemale;
        }
      }
      
      _hasUserProfile = true;

      // Update SDK if user info has changed (including age, sex, or DOB)
      if (oldName != _userName ||
          oldHeight != _userHeight ||
          oldWeight != _userWeight ||
          oldAge != _userAge ||
          oldSex != _userSex ||
          oldDOB != _userDOB) {
        debugPrint("User profile data changed - updating SDK with Age=$_userAge, Sex=$_userSex");
        _updateUserInfo();
      }

      notifyListeners();
    }
  }

  // Legacy methods for backward compatibility - now use backend
  Future<void> fetchBodyComposition() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _loadLatestMeasurement();

      debugPrint("Body composition data fetched from backend");
    } catch (e) {
      _error = "Failed to fetch body composition: $e";
      debugPrint("Error fetching body composition: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCompositionHistory() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _loadMeasurementHistory();

      debugPrint("Body composition history fetched from backend");
    } catch (e) {
      _error = "Failed to fetch composition history: $e";
      debugPrint("Error fetching composition history: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBodyCompositionMeasurement(
      BodyCompositionModel newMeasurement) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create measurement data for local storage only
      final measurementData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'weight': newMeasurement.weight,
        'bmi': newMeasurement.bmi,
        'bodyFatPercentage': newMeasurement.bodyFat,
        'musclePercentage': newMeasurement.muscleRate,
        'waterPercentage': newMeasurement.bodyWater,
        'boneMass': newMeasurement.boneMass,
        'bmr': 1500.0, // Default BMR as it's not in the legacy model
        'subcutaneousFat': newMeasurement.subcutaneousFat,
        'visceralFat': newMeasurement.visceralFat,
        'proteinPercentage': newMeasurement.protein,
        'skeletalMusclePercentage': newMeasurement.skeletalMuscle,
        'measurementDate': newMeasurement.measurementDate.toIso8601String(),
        'measurementSource': 'manual_entry',
        'isStabilized': true,
      };

      // Update local data only (no backend call)
      _measurementHistory.insert(0, measurementData);
      _compositionHistory.insert(
          0, _convertToBodyCompositionModel(measurementData));
      _currentComposition = _convertToBodyCompositionModel(measurementData);

      // Save to local storage
      await _saveMeasurementHistoryToLocal();

      debugPrint(
          "Body composition measurement added to local storage successfully");
    } catch (e) {
      _error = "Failed to add measurement: $e";
      debugPrint("Error adding body composition measurement: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBodyCompositionMeasurement(
      BodyCompositionModel updatedMeasurement) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create updated measurement data for local storage only
      final updatedData = {
        'id': updatedMeasurement.id,
        'weight': updatedMeasurement.weight,
        'bmi': updatedMeasurement.bmi,
        'bodyFatPercentage': updatedMeasurement.bodyFat,
        'musclePercentage': updatedMeasurement.muscleRate,
        'waterPercentage': updatedMeasurement.bodyWater,
        'boneMass': updatedMeasurement.boneMass,
        'bmr': 1500.0, // Default BMR
        'subcutaneousFat': updatedMeasurement.subcutaneousFat,
        'visceralFat': updatedMeasurement.visceralFat,
        'proteinPercentage': updatedMeasurement.protein,
        'skeletalMusclePercentage': updatedMeasurement.skeletalMuscle,
        'measurementDate': updatedMeasurement.measurementDate.toIso8601String(),
        'measurementSource': 'manual_entry',
        'isStabilized': true,
      };

      // Update local data only (no backend call)
      if (_currentComposition?.id == updatedMeasurement.id) {
        _currentComposition = _convertToBodyCompositionModel(updatedData);
      }

      final index = _compositionHistory
          .indexWhere((comp) => comp.id == updatedMeasurement.id);
      if (index != -1) {
        _compositionHistory[index] =
            _convertToBodyCompositionModel(updatedData);
      }

      final historyIndex = _measurementHistory
          .indexWhere((m) => m['id'] == updatedMeasurement.id);
      if (historyIndex != -1) {
        _measurementHistory[historyIndex] = updatedData;
      }

      // Save to local storage
      await _saveMeasurementHistoryToLocal();

      debugPrint(
          "Body composition measurement updated in local storage successfully");
    } catch (e) {
      _error = "Failed to update measurement: $e";
      debugPrint("Error updating body composition measurement: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBodyCompositionMeasurement(String measurementId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Remove from local data only (no backend call)
      _compositionHistory.removeWhere((comp) => comp.id == measurementId);
      _measurementHistory.removeWhere((m) => m['id'] == measurementId);

      if (_currentComposition?.id == measurementId) {
        _currentComposition =
            _compositionHistory.isNotEmpty ? _compositionHistory.first : null;
      }

      // Update total measurements count
      _totalMeasurements = _measurementHistory.length;

      // Save to local storage
      await _saveMeasurementHistoryToLocal();

      debugPrint(
          "Body composition measurement deleted from local storage successfully");
    } catch (e) {
      _error = "Failed to delete measurement: $e";
      debugPrint("Error deleting body composition measurement: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBodyComposition() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Refresh both latest measurement and history from backend
      await _loadLatestMeasurement();
      await _loadMeasurementHistory();

      debugPrint("Body composition data refreshed from backend");
    } catch (e) {
      _error = "Failed to refresh data: $e";
      debugPrint("Error refreshing body composition data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return 'green';
      case 'standard':
      case 'normal':
        return 'green';
      case 'high':
        return 'orange';
      case 'low':
        return 'blue';
      case 'poor':
      case 'critical':
        return 'red';
      default:
        return 'gray';
    }
  }

  static String getFormattedValue(double value, String unit) {
    if (unit == 'kg') {
      return '${value.toStringAsFixed(1)} $unit';
    } else if (unit == '%') {
      return '${value.toStringAsFixed(1)}$unit';
    } else {
      return '${value.toStringAsFixed(1)} $unit';
    }
  }

  // Backwards compatibility methods
  Future<void> startScanning() async {
    await startScan();
  }

  Future<void> connectToDevice() async {
    if (_devices.isNotEmpty) {
      debugPrint("Connecting to first available device");
    }
  }

  Future<void> disconnectFromDevice() async {
    _isConnected = false;
    notifyListeners();
  }

  Future<void> clearData() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear local data
      _lastData = null;
      _measurementHistory.clear();
      _compositionHistory.clear();
      _currentComposition = null;
      _totalMeasurements = 0;

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = [
        'last_weight_kg',
        'last_bmi',
        'last_body_fat_percent',
        'last_muscle_percent',
        'last_water_percent',
        'last_bone_mass_kg',
        'last_measure_time',
        'last_bmr',
        'last_subcutaneous_fat_percent',
        'last_visceral_fat',
        'last_protein_percent',
        'last_sm_percent',
        'last_is_stabilized',
        'measurement_history',
        'total_measurements'
      ];

      for (final key in keysToRemove) {
        await prefs.remove(key);
      }

      debugPrint("Local body composition data cleared");

      // Note: We don't clear backend data as that would permanently delete user's measurement history
      // If you need to clear backend data, you would need to call a specific API endpoint
    } catch (e) {
      debugPrint("Error clearing body composition data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getFormattedWeight() {
    if (_lastData == null) return 'No data';
    return '${_lastData!.weight_kg.toStringAsFixed(1)} kg';
  }

  String getFormattedBodyFat() {
    if (_lastData == null) return 'No data';
    return '${_lastData!.bodyFatPercent.toStringAsFixed(1)}%';
  }

  String getFormattedMuscle() {
    if (_lastData == null) return 'No data';
    return '${_lastData!.musclePercent.toStringAsFixed(1)}%';
  }

  String getFormattedWater() {
    if (_lastData == null) return 'No data';
    return '${_lastData!.moisturePercent.toStringAsFixed(1)}%';
  }

  Color getHealthStatusColor() {
    if (_lastData == null) return Colors.grey;
    final status = getDataStatus(_lastData!.bodyFatPercent, "body fat");
    return status == "Good"
        ? Colors.green
        : status == "Standard"
            ? Colors.orange
            : Colors.red;
  }

  Future<void> refreshData() async {
    await _loadMeasurementHistory();
  }

  // ICDeviceManagerDelegate implementation - required methods
  @override
  void onBleState(ICBleState state) {
    debugPrint("BLE State: $state");
  }

  @override
  void onInitFinish(bool bSuccess) {
    debugPrint("Init finished: $bSuccess");
  }

  @override
  void onNodeConnectionChanged(
      ICDevice device, int nodeId, ICDeviceConnectState state) {
    _isConnected = state == ICDeviceConnectState.ICDeviceConnectStateConnected;
    notifyListeners();
  }

  @override
  void onDeviceConnectionChanged(ICDevice device, ICDeviceConnectState state) {
    _isConnected = state == ICDeviceConnectState.ICDeviceConnectStateConnected;
    // End scanning session when device disconnects
    if (state != ICDeviceConnectState.ICDeviceConnectStateConnected) {
      _scanningSessionActive = false;
    }
    notifyListeners();
  }

  @override
  void onReceiveBattery(ICDevice device, int battery, Object ext) {}

  @override
  void onReceiveConfigWifiResult(ICDevice device, ICConfigWifiState state) {}

  @override
  void onReceiveCoordData(ICDevice device, ICCoordData data) {}

  @override
  void onReceiveDebugData(ICDevice device, int type, Object obj) {}

  @override
  void onReceiveDeviceInfo(ICDevice device, ICDeviceInfo deviceInfo) {}

  @override
  void onReceiveHR(ICDevice device, int hr) {}

  @override
  void onReceiveHistorySkipData(ICDevice device, ICSkipData data) {}

  @override
  void onReceiveKitchenScaleData(ICDevice device, ICKitchenScaleData data) {}

  @override
  void onReceiveKitchenScaleUnitChanged(
      ICDevice device, ICKitchenScaleUnit unit) {}

  @override
  void onReceiveMeasureStepData(
      ICDevice device, ICMeasureStep step, Object data) {}

  @override
  void onReceiveRulerData(ICDevice device, ICRulerData data) {}

  @override
  void onReceiveRulerHistoryData(ICDevice device, ICRulerData data) {}

  @override
  void onReceiveRulerMeasureModeChanged(
      ICDevice device, ICRulerMeasureMode mode) {}

  @override
  void onReceiveRulerUnitChanged(ICDevice device, ICRulerUnit unit) {}

  @override
  void onReceiveSkipData(ICDevice device, ICSkipData data) {}

  @override
  void onReceiveUpgradePercent(
      ICDevice device, ICUpgradeStatus status, int percent) {}

  @override
  void onReceiveWeightCenterData(ICDevice device, ICWeightCenterData data) {}

  @override
  void onReceiveWeightHistoryData(ICDevice device, ICWeightHistoryData data) {}

  @override
  void onReceiveWeightUnitChanged(ICDevice device, ICWeightUnit unit) {}

  @override
  void onReceiveWeightData(ICDevice device, ICWeightData data) {
    // Only process weight data when scanning session is active
    // This ensures weight is only updated when user has explicitly started scanning
    // Weight data is accepted during active scanning OR when connected (as result of scanning)
    if (!_scanningSessionActive) {
      debugPrint("⚠️ Weight data received but scanning session is not active - ignoring weight update");
      return;
    }

    debugPrint("=== WEIGHT DATA RECEIVED ===");
    debugPrint("Weight(kg): ${data.weight_kg}");
    debugPrint("Body Fat %: ${data.bodyFatPercent}");
    debugPrint("Muscle %: ${data.musclePercent}");
    debugPrint("Water %: ${data.moisturePercent}");
    debugPrint("Bone Mass kg: ${data.boneMass}");
    debugPrint("BMR: ${data.bmr} kcal");
    debugPrint("Subcutaneous Fat %: ${data.subcutaneousFatPercent}");
    debugPrint("Visceral Fat: ${data.visceralFat}");
    debugPrint("Protein %: ${data.proteinPercent}");
    debugPrint("Skeletal Muscle %: ${data.smPercent}");
    debugPrint("Is Stabilized: ${data.isStabilized}");

    _lastData = data;

    // Update legacy model for backward compatibility (always update UI)
    _currentComposition =
        _convertToBodyCompositionModel(_convertWeightDataToMap(data));

    notifyListeners();

    // Only save measurement when stabilized to prevent multiple saves during fluctuations
    if (data.isStabilized) {
      // Check if we've already saved this stabilized measurement
      // Allow save if weight changed significantly (>0.1kg) or it's been more than 5 seconds since last save
      final now = DateTime.now();
      final shouldSave = _lastSavedStabilizedWeight == null ||
          (_lastSavedStabilizedTime != null &&
              (now.difference(_lastSavedStabilizedTime!).inSeconds > 5 ||
                  (data.weight_kg - _lastSavedStabilizedWeight!).abs() > 0.1));

      if (shouldSave) {
        // Update tracking variables
        _lastSavedStabilizedWeight = data.weight_kg;
        _lastSavedStabilizedTime = now;

        // Save measurement to backend API
        // Save measurement to local storage only (non-blocking)
        _saveMeasurementToLocalStorage(device, data);
      }
    }
  }

  /// Convert ICWeightData to Map for processing
  Map<String, dynamic> _convertWeightDataToMap(ICWeightData data) {
    return {
      'weight': data.weight_kg,
      'bmi': data.bmi,
      'bodyFatPercentage': data.bodyFatPercent,
      'musclePercentage': data.musclePercent,
      'waterPercentage': data.moisturePercent,
      'boneMass': data.boneMass,
      'bmr': data.bmr,
      'subcutaneousFat': data.subcutaneousFatPercent,
      'visceralFat': data.visceralFat,
      'proteinPercentage': data.proteinPercent,
      'skeletalMusclePercentage': data.smPercent,
      'isStabilized': data.isStabilized,
      'measurementDate': DateTime.now().toIso8601String(),
    };
  }

  /// Save measurement to local storage only (backend unchanged)
  Future<void> _saveMeasurementToLocalStorage(
      ICDevice device, ICWeightData data) async {
    try {
      debugPrint("Saving measurement to local storage only...");

      // Save to local storage
      await _saveToLocalStorage(data);

      // Create measurement data for local history
      final measurementData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'weight': data.weight_kg,
        'bmi': data.bmi,
        'bodyFatPercentage': data.bodyFatPercent,
        'musclePercentage': data.musclePercent,
        'waterPercentage': data.moisturePercent,
        'boneMass': data.boneMass,
        'bmr': data.bmr.toDouble(),
        'subcutaneousFat': data.subcutaneousFatPercent,
        'visceralFat': data.visceralFat,
        'proteinPercentage': data.proteinPercent,
        'skeletalMusclePercentage': data.smPercent,
        'measurementDate': DateTime.now().toIso8601String(),
        'isStabilized': data.isStabilized,
        'measurementSource': 'bluetooth_scale',
        'deviceMac': device.macAddr ?? 'unknown',
        'dataCalcType': data.data_calc_type,
        'bfaType': data.bfa_type?.index,
      };

      // Add to local history
      _measurementHistory.insert(0, measurementData);
      _compositionHistory.insert(
          0, _convertToBodyCompositionModel(measurementData));

      // Keep only last 50 measurements locally
      if (_measurementHistory.length > 50) {
        _measurementHistory = _measurementHistory.take(50).toList();
        _compositionHistory = _compositionHistory.take(50).toList();
      }

      _totalMeasurements = _measurementHistory.length;

      // Save updated history to local storage
      await _saveMeasurementHistoryToLocal();

      debugPrint("✅ Measurement saved to local storage successfully");
    } catch (e) {
      debugPrint("❌ Error saving measurement to local storage: $e");
    }
  }

  /// Save measurement history to local storage
  Future<void> _saveMeasurementHistoryToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _measurementHistory
          .map((measurement) => jsonEncode(measurement))
          .toList();
      await prefs.setStringList('measurement_history', historyJson);
      debugPrint("✅ Measurement history saved to local storage");
    } catch (e) {
      debugPrint("❌ Error saving measurement history to local storage: $e");
    }
  }

  /// Fallback method to save measurement to local storage
  Future<void> _saveToLocalStorage(ICWeightData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Save latest measurement data
      await prefs.setDouble('last_weight_kg', data.weight_kg);
      await prefs.setDouble('last_bmi', data.bmi);
      await prefs.setDouble('last_body_fat_percent', data.bodyFatPercent);
      await prefs.setDouble('last_muscle_percent', data.musclePercent);
      await prefs.setDouble('last_water_percent', data.moisturePercent);
      await prefs.setDouble('last_bone_mass_kg', data.boneMass);
      await prefs.setInt('last_measure_time', timestamp);
      await prefs.setDouble('last_bmr', data.bmr.toDouble());
      await prefs.setDouble(
          'last_subcutaneous_fat_percent', data.subcutaneousFatPercent);
      await prefs.setDouble('last_visceral_fat', data.visceralFat);
      await prefs.setDouble('last_protein_percent', data.proteinPercent);
      await prefs.setDouble('last_sm_percent', data.smPercent);
      await prefs.setBool('last_is_stabilized', data.isStabilized);

      debugPrint("✅ Measurement saved to local storage as backup");
    } catch (e) {
      debugPrint("❌ Error saving measurement to local storage: $e");
    }
  }

  // ICScanDeviceDelegate implementation
  @override
  void onScanResult(ICScanDeviceInfo deviceInfo) {
    final mac = deviceInfo.macAddr;
    if (mac != null) {
      if (!_devices.any((d) => d.macAddr == mac)) {
        _devices.add(ICDevice(mac));
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    if (_isScanning) {
      stopScan();
    }
    super.dispose();
  }
}
