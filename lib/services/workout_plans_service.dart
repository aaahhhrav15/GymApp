import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gym_app_2/models/workout_plan.dart';
import 'package:gym_app_2/services/token_manager.dart';

class WorkoutPlansService {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://65.0.5.24/';
  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get current active workout plan for the user
  static Future<WorkoutPlan?> getCurrentWorkoutPlan() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${baseUrl}workouts/assigned/plan'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WorkoutPlan.fromJson(data);
      } else if (response.statusCode == 404) {
        // No workout plan found
        return null;
      } else {
        throw Exception(
            'Failed to load current workout plan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching current workout plan: $e');
      throw Exception('Failed to fetch current workout plan: $e');
    }
  }

  /// Get all workout plans for the user with optional filters
  static Future<List<WorkoutPlan>> getAllWorkoutPlans({
    String? status,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'skip': skip.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('${baseUrl}workouts/assigned/plans')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((plan) => WorkoutPlan.fromJson(plan)).toList();
      } else {
        throw Exception('Failed to load workout plans: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching workout plans: $e');
      throw Exception('Failed to fetch workout plans: $e');
    }
  }

  /// Get specific week from current active plan
  static Future<Week?> getWeek(int weekNumber) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${baseUrl}workouts/assigned/week/$weekNumber'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Week.fromJson(data['week']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
            'Failed to load week $weekNumber: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching week $weekNumber: $e');
      throw Exception('Failed to fetch week $weekNumber: $e');
    }
  }

  /// Get specific day exercises from current active plan
  static Future<WorkoutDay?> getWorkoutDay(
      int weekNumber, int dayNumber) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${baseUrl}workouts/assigned/day/$weekNumber/$dayNumber'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WorkoutDay.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
            'Failed to load day $dayNumber of week $weekNumber: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching day $dayNumber of week $weekNumber: $e');
      throw Exception('Failed to fetch day $dayNumber of week $weekNumber: $e');
    }
  }
}
