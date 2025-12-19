// lib/services/body_composition_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class BodyCompositionService {
  static String get baseUrl => ApiService.baseUrl;

  /// Get body composition measurements for a user
  static Future<Map<String, dynamic>> getBodyCompositionMeasurements({
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    try {
      final headers = await ApiService.getHeaders();
      String url = '$baseUrl/body-composition/measurements';

      List<String> params = [];
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');
      if (limit != null) params.add('limit=$limit');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return await ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Add a new body composition measurement
  static Future<Map<String, dynamic>> addBodyCompositionMeasurement({
    required double weight,
    required double bmi,
    required double bodyFatPercentage,
    required double musclePercentage,
    required double waterPercentage,
    required double boneMass,
    required double bmr,
    double? subcutaneousFat,
    double? visceralFat,
    double? proteinPercentage,
    double? skeletalMusclePercentage,
    String? measurementSource = 'bluetooth_scale',
    Map<String, dynamic>? rawData,
    DateTime? measurementDate,
  }) async {
    try {
      final headers = await ApiService.getHeaders();
      final body = jsonEncode({
        'weight': weight,
        'bmi': bmi,
        'body_fat_percentage': bodyFatPercentage,
        'muscle_percentage': musclePercentage,
        'water_percentage': waterPercentage,
        'bone_mass': boneMass,
        'bmr': bmr,
        'subcutaneous_fat': subcutaneousFat,
        'visceral_fat': visceralFat,
        'protein_percentage': proteinPercentage,
        'skeletal_muscle_percentage': skeletalMusclePercentage,
        'measurement_source': measurementSource,
        'raw_data': rawData,
        'measurement_date': measurementDate?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      });

      final response = await http.post(
        Uri.parse('$baseUrl/body-composition/measurements'),
        headers: headers,
        body: body,
      );

      return await ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Update an existing body composition measurement
  static Future<Map<String, dynamic>> updateBodyCompositionMeasurement({
    required String measurementId,
    double? weight,
    double? bmi,
    double? bodyFatPercentage,
    double? musclePercentage,
    double? waterPercentage,
    double? boneMass,
    double? bmr,
    double? subcutaneousFat,
    double? visceralFat,
    double? proteinPercentage,
    double? skeletalMusclePercentage,
    String? notes,
  }) async {
    try {
      final headers = await ApiService.getHeaders();
      final body = <String, dynamic>{};

      if (weight != null) body['weight'] = weight;
      if (bmi != null) body['bmi'] = bmi;
      if (bodyFatPercentage != null)
        body['body_fat_percentage'] = bodyFatPercentage;
      if (musclePercentage != null)
        body['muscle_percentage'] = musclePercentage;
      if (waterPercentage != null) body['water_percentage'] = waterPercentage;
      if (boneMass != null) body['bone_mass'] = boneMass;
      if (bmr != null) body['bmr'] = bmr;
      if (subcutaneousFat != null) body['subcutaneous_fat'] = subcutaneousFat;
      if (visceralFat != null) body['visceral_fat'] = visceralFat;
      if (proteinPercentage != null)
        body['protein_percentage'] = proteinPercentage;
      if (skeletalMusclePercentage != null)
        body['skeletal_muscle_percentage'] = skeletalMusclePercentage;
      if (notes != null) body['notes'] = notes;

      final response = await http.put(
        Uri.parse('$baseUrl/body-composition/measurements/$measurementId'),
        headers: headers,
        body: jsonEncode(body),
      );

      return await ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Delete a body composition measurement
  static Future<Map<String, dynamic>> deleteBodyCompositionMeasurement(
      String measurementId) async {
    try {
      final headers = await ApiService.getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/body-composition/measurements/$measurementId'),
        headers: headers,
      );

      return await ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Get latest body composition measurement
  static Future<Map<String, dynamic>> getLatestBodyComposition() async {
    try {
      final headers = await ApiService.getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/body-composition/latest'),
        headers: headers,
      );

      return await ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Get body composition statistics (trends, averages, etc.)
  static Future<Map<String, dynamic>> getBodyCompositionStats({
    String? period = '30d', // 7d, 30d, 90d, 1y
  }) async {
    try {
      final headers = await ApiService.getHeaders();
      String url = '$baseUrl/body-composition/stats';

      if (period != null) {
        url += '?period=$period';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return await ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Get body composition goals
  static Future<Map<String, dynamic>> getBodyCompositionGoals() async {
    try {
      final headers = await ApiService.getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/body-composition/goals'),
        headers: headers,
      );

      return await ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Update body composition goals
  static Future<Map<String, dynamic>> updateBodyCompositionGoals({
    double? targetWeight,
    double? targetBodyFatPercentage,
    double? targetMusclePercentage,
    String? targetDate,
  }) async {
    try {
      final headers = await ApiService.getHeaders();
      final body = <String, dynamic>{};

      if (targetWeight != null) body['target_weight'] = targetWeight;
      if (targetBodyFatPercentage != null)
        body['target_body_fat_percentage'] = targetBodyFatPercentage;
      if (targetMusclePercentage != null)
        body['target_muscle_percentage'] = targetMusclePercentage;
      if (targetDate != null) body['target_date'] = targetDate;

      final response = await http.put(
        Uri.parse('$baseUrl/body-composition/goals'),
        headers: headers,
        body: jsonEncode(body),
      );

      return await ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Sync device measurements (batch upload)
  static Future<Map<String, dynamic>> syncDeviceMeasurements({
    required List<Map<String, dynamic>> measurements,
    required String deviceId,
    required String deviceType,
  }) async {
    try {
      final headers = await ApiService.getHeaders();
      final body = jsonEncode({
        'measurements': measurements,
        'device_id': deviceId,
        'device_type': deviceType,
        'sync_timestamp': DateTime.now().toIso8601String(),
      });

      final response = await http.post(
        Uri.parse('$baseUrl/body-composition/sync'),
        headers: headers,
        body: body,
      );

      return await ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Get body composition health insights based on measurements
  static Future<Map<String, dynamic>> getHealthInsights() async {
    try {
      final headers = await ApiService.getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/body-composition/insights'),
        headers: headers,
      );

      return await ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Export body composition data
  static Future<Map<String, dynamic>> exportBodyCompositionData({
    String? startDate,
    String? endDate,
    String format = 'json', // json, csv, pdf
  }) async {
    try {
      final headers = await ApiService.getHeaders();
      String url = '$baseUrl/body-composition/export';

      List<String> params = ['format=$format'];
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');

      url += '?${params.join('&')}';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return await ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Helper method to format measurement data for API
  static Map<String, dynamic> formatMeasurementForAPI(
      Map<String, dynamic> rawMeasurement) {
    return {
      'weight': rawMeasurement['weight_kg'] ?? rawMeasurement['weight'],
      'bmi': rawMeasurement['bmi'],
      'body_fat_percentage': rawMeasurement['bodyFatPercent'] ??
          rawMeasurement['body_fat_percentage'],
      'muscle_percentage': rawMeasurement['musclePercent'] ??
          rawMeasurement['muscle_percentage'],
      'water_percentage': rawMeasurement['moisturePercent'] ??
          rawMeasurement['water_percentage'],
      'bone_mass': rawMeasurement['boneMass'] ?? rawMeasurement['bone_mass'],
      'bmr': rawMeasurement['bmr'],
      'subcutaneous_fat': rawMeasurement['subcutaneousFatPercent'] ??
          rawMeasurement['subcutaneous_fat'],
      'visceral_fat':
          rawMeasurement['visceralFat'] ?? rawMeasurement['visceral_fat'],
      'protein_percentage': rawMeasurement['proteinPercent'] ??
          rawMeasurement['protein_percentage'],
      'skeletal_muscle_percentage': rawMeasurement['smPercent'] ??
          rawMeasurement['skeletal_muscle_percentage'],
      'measurement_date': rawMeasurement['measurement_date'] ??
          DateTime.now().toIso8601String(),
      'is_stabilized':
          rawMeasurement['isStabilized'] ?? rawMeasurement['is_stabilized'],
      'data_calc_type': rawMeasurement['data_calc_type'],
      'bfa_type': rawMeasurement['bfa_type']?.toString(),
    };
  }

  /// Helper method to format API response for local use
  static Map<String, dynamic> formatAPIResponseForLocal(
      Map<String, dynamic> apiData) {
    return {
      'id': apiData['_id'] ?? apiData['id'],
      'weight': apiData['weight'],
      'bmi': apiData['bmi'],
      'bodyFatPercentage': apiData['body_fat_percentage'],
      'musclePercentage': apiData['muscle_percentage'],
      'waterPercentage': apiData['water_percentage'],
      'boneMass': apiData['bone_mass'],
      'bmr': apiData['bmr'],
      'subcutaneousFat': apiData['subcutaneous_fat'],
      'visceralFat': apiData['visceral_fat'],
      'proteinPercentage': apiData['protein_percentage'],
      'skeletalMusclePercentage': apiData['skeletal_muscle_percentage'],
      'measurementDate': apiData['measurement_date'] ?? apiData['created_at'],
      'isStabilized': apiData['is_stabilized'],
      'measurementSource': apiData['measurement_source'] ?? 'unknown',
      'notes': apiData['notes'],
      'createdAt': apiData['created_at'],
      'updatedAt': apiData['updated_at'],
    };
  }

  /// Validate measurement data before sending to API
  static bool validateMeasurementData(Map<String, dynamic> measurement) {
    final weight = measurement['weight'];
    final bmi = measurement['bmi'];
    final bodyFat =
        measurement['body_fat_percentage'] ?? measurement['bodyFatPercentage'];

    // Basic validation
    if (weight == null || weight <= 0 || weight > 500) return false;
    if (bmi == null || bmi <= 0 || bmi > 100) return false;
    if (bodyFat == null || bodyFat < 0 || bodyFat > 100) return false;

    return true;
  }

  /// Calculate BMI from weight and height
  static double calculateBMI(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0.0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Get body fat category based on age and gender
  static String getBodyFatCategory(
      double bodyFatPercentage, int age, String gender) {
    if (gender.toLowerCase() == 'male') {
      if (age < 30) {
        if (bodyFatPercentage < 8) return 'Essential Fat';
        if (bodyFatPercentage < 14) return 'Athletes';
        if (bodyFatPercentage < 18) return 'Fitness';
        if (bodyFatPercentage < 25) return 'Average';
        return 'Obese';
      } else if (age < 50) {
        if (bodyFatPercentage < 8) return 'Essential Fat';
        if (bodyFatPercentage < 17) return 'Athletes';
        if (bodyFatPercentage < 21) return 'Fitness';
        if (bodyFatPercentage < 28) return 'Average';
        return 'Obese';
      } else {
        if (bodyFatPercentage < 8) return 'Essential Fat';
        if (bodyFatPercentage < 19) return 'Athletes';
        if (bodyFatPercentage < 23) return 'Fitness';
        if (bodyFatPercentage < 30) return 'Average';
        return 'Obese';
      }
    } else {
      // Female
      if (age < 30) {
        if (bodyFatPercentage < 16) return 'Essential Fat';
        if (bodyFatPercentage < 20) return 'Athletes';
        if (bodyFatPercentage < 24) return 'Fitness';
        if (bodyFatPercentage < 31) return 'Average';
        return 'Obese';
      } else if (age < 50) {
        if (bodyFatPercentage < 16) return 'Essential Fat';
        if (bodyFatPercentage < 23) return 'Athletes';
        if (bodyFatPercentage < 27) return 'Fitness';
        if (bodyFatPercentage < 34) return 'Average';
        return 'Obese';
      } else {
        if (bodyFatPercentage < 16) return 'Essential Fat';
        if (bodyFatPercentage < 25) return 'Athletes';
        if (bodyFatPercentage < 29) return 'Fitness';
        if (bodyFatPercentage < 36) return 'Average';
        return 'Obese';
      }
    }
  }
}
