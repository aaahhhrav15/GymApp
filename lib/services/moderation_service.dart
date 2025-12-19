import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_app_2/services/token_manager.dart';

class ModerationService {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://65.0.5.24/';
  static const String _reportEndpoint = 'moderation/report';
  static const String _blockEndpoint = 'moderation/block';
  static const String _filterEndpoint = 'moderation/filter';
  
  // Local storage keys
  static const String _blockedUsersKey = 'blocked_users';
  static const String _reportedContentKey = 'reported_content';

  /// Report inappropriate content
  static Future<Map<String, dynamic>> reportContent({
    required String contentType, // 'reel', 'accountability', 'result'
    required String contentId,
    required String reason,
    String? additionalDetails,
  }) async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      final body = {
        'contentType': contentType,
        'contentId': contentId,
        'reason': reason,
        'additionalDetails': additionalDetails,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl$_reportEndpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store report locally
        await _storeReportedContent(contentType, contentId);
        
        return {
          'success': true,
          'message': 'Content reported successfully. We will review within 24 hours.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to report content: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Block a user
  static Future<Map<String, dynamic>> blockUser({
    required String userId,
    required String reason,
  }) async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      final body = {
        'blockedUserId': userId,
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl$_blockEndpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store blocked user locally
        await _storeBlockedUser(userId);
        
        return {
          'success': true,
          'message': 'User blocked successfully.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to block user: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Filter content for inappropriate text
  static Future<Map<String, dynamic>> filterContent({
    required String text,
    required String contentType,
  }) async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      final body = {
        'text': text,
        'contentType': contentType,
      };

      final response = await http.post(
        Uri.parse('$baseUrl$_filterEndpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'isAppropriate': data['isAppropriate'] ?? true,
          'filteredText': data['filteredText'] ?? text,
          'confidence': data['confidence'] ?? 0.0,
        };
      } else {
        // If filtering fails, allow content but log the issue
        return {
          'success': false,
          'isAppropriate': true,
          'filteredText': text,
          'confidence': 0.0,
        };
      }
    } catch (e) {
      // If filtering fails, allow content but log the issue
      return {
        'success': false,
        'isAppropriate': true,
        'filteredText': text,
        'confidence': 0.0,
      };
    }
  }

  /// Check if content should be hidden based on local filters
  static Future<bool> shouldHideContent({
    required String contentType,
    required String contentId,
    String? userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if content was reported
      final reportedContent = prefs.getStringList(_reportedContentKey) ?? [];
      final contentKey = '${contentType}_$contentId';
      if (reportedContent.contains(contentKey)) {
        return true;
      }

      // Check if user is blocked
      if (userId != null) {
        final blockedUsers = prefs.getStringList(_blockedUsersKey) ?? [];
        if (blockedUsers.contains(userId)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get list of blocked users
  static Future<List<String>> getBlockedUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_blockedUsersKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Get list of reported content
  static Future<List<String>> getReportedContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_reportedContentKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Store reported content locally
  static Future<void> _storeReportedContent(String contentType, String contentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportedContent = prefs.getStringList(_reportedContentKey) ?? [];
      final contentKey = '${contentType}_$contentId';
      
      if (!reportedContent.contains(contentKey)) {
        reportedContent.add(contentKey);
        await prefs.setStringList(_reportedContentKey, reportedContent);
      }
    } catch (e) {
      // Ignore storage errors
    }
  }

  /// Store blocked user locally
  static Future<void> _storeBlockedUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedUsers = prefs.getStringList(_blockedUsersKey) ?? [];
      
      if (!blockedUsers.contains(userId)) {
        blockedUsers.add(userId);
        await prefs.setStringList(_blockedUsersKey, blockedUsers);
      }
    } catch (e) {
      // Ignore storage errors
    }
  }

  /// Unblock a user
  static Future<void> unblockUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedUsers = prefs.getStringList(_blockedUsersKey) ?? [];
      blockedUsers.remove(userId);
      await prefs.setStringList(_blockedUsersKey, blockedUsers);
    } catch (e) {
      // Ignore storage errors
    }
  }

  /// Clear all moderation data (for testing)
  static Future<void> clearAllModerationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_blockedUsersKey);
      await prefs.remove(_reportedContentKey);
    } catch (e) {
      // Ignore storage errors
    }
  }
}
