import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gym_app_2/models/user_model.dart';
import 'package:gym_app_2/services/token_manager.dart';

class ProfileService {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://65.0.5.24/';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get user profile information with retry mechanism
  static Future<UserProfile> getUserProfile({int maxRetries = 2}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts <= maxRetries) {
      try {
        final headers = await _getHeaders();
        final response = await http
            .get(
              Uri.parse('${baseUrl}users/me'),
              headers: headers,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('ProfileService: Successfully fetched user profile');
          return UserProfile.fromJson(data);
        } else if (response.statusCode == 401) {
          throw Exception('401 Unauthorized - Please login again');
        } else if (response.statusCode == 404) {
          throw Exception('User profile not found');
        } else {
          throw Exception(
              'Server error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        print('ProfileService: Attempt $attempts failed: $e');

        // Don't retry auth errors or client errors
        if (e.toString().contains('401') ||
            e.toString().contains('404') ||
            e.toString().contains('Unauthorized')) {
          break;
        }

        // Wait before retrying (exponential backoff)
        if (attempts <= maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          print('ProfileService: Retrying in ${500 * attempts}ms...');
        }
      }
    }

    print('ProfileService: All attempts failed. Last error: $lastException');
    throw lastException ??
        Exception('Failed to fetch user profile after $maxRetries attempts');
  }

  /// Update user profile with retry mechanism
  static Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> updateData,
      {int maxRetries = 2}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts <= maxRetries) {
      try {
        final headers = await _getHeaders();
        final response = await http
            .patch(
              Uri.parse('${baseUrl}users/update'),
              headers: headers,
              body: json.encode(updateData),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('ProfileService: Successfully updated user profile');
          return {
            'success': true,
            'data': data,
            'message': 'Profile updated successfully',
          };
        } else if (response.statusCode == 401) {
          return {
            'success': false,
            'error': '401 Unauthorized - Please login again',
            'authError': true,
          };
        } else {
          throw Exception(
              'Server error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        print('ProfileService: Update attempt $attempts failed: $e');

        // Don't retry auth errors
        if (e.toString().contains('401') ||
            e.toString().contains('Unauthorized')) {
          return {
            'success': false,
            'error': '401 Unauthorized - Please login again',
            'authError': true,
          };
        }

        // Wait before retrying
        if (attempts <= maxRetries) {
          await Future.delayed(Duration(milliseconds: 1000 * attempts));
          print('ProfileService: Retrying update in ${1000 * attempts}ms...');
        }
      }
    }

    print(
        'ProfileService: All update attempts failed. Last error: $lastException');
    return {
      'success': false,
      'error':
          'Failed to update profile after $maxRetries attempts: ${lastException?.toString() ?? 'Unknown error'}',
    };
  }

  /// Sign out user - Clear all stored data and tokens
  static Future<void> signOut() async {
    try {
      // Clear JWT token and all user data from SharedPreferences
      await TokenManager.clearToken();

      print('User signed out successfully - all data cleared');
    } catch (e) {
      print('Error during sign out: $e');
      throw Exception('Failed to sign out: $e');
    }
  }
}
