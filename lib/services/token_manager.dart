import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'navigation_service.dart';

/// TokenManager - A utility class for managing JWT tokens and user authentication state
/// This class provides static methods that can be accessed from anywhere in the codebase
class TokenManager {
  // SharedPreferences keys
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _loginTimeKey = 'login_time';

  /// Save JWT token and user data to SharedPreferences
  /// This method is called after successful login/registration
  static Future<bool> saveToken({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTime = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, json.encode(userData));
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setInt(_loginTimeKey, loginTime);

      return true;
    } catch (e) {
      print('Error saving token: $e');
      return false;
    }
  }

  /// Get JWT token from SharedPreferences
  /// Returns null if no token is found or if there's an error
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  /// Get user data from SharedPreferences
  /// Returns null if no user data is found or if there's an error
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      if (userData != null && userData.isNotEmpty) {
        return json.decode(userData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Check if user is currently logged in
  /// Returns true if valid token exists, user is marked as logged in, and token is not expired
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasToken = prefs.getString(_tokenKey)?.isNotEmpty ?? false;
      final isLoggedInFlag = prefs.getBool(_isLoggedInKey) ?? false;
      
      // If no token or not marked as logged in, return false
      if (!hasToken || !isLoggedInFlag) {
        return false;
      }
      
      // Check if token is expired
      final isExpired = await isTokenExpired();
      if (isExpired) {
        // Token expired, clear authentication data
        await clearToken();
        return false;
      }
      
      return true;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  /// Get login timestamp
  /// Returns the timestamp when user last logged in
  static Future<DateTime?> getLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_loginTimeKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      print('Error getting login time: $e');
      return null;
    }
  }

  /// Clear all authentication data (logout)
  /// This removes token, user data, and login status
  static Future<bool> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_loginTimeKey);
      await prefs.setBool(_isLoggedInKey, false);
      return true;
    } catch (e) {
      print('Error clearing token: $e');
      return false;
    }
  }

  /// Get Authorization headers for API requests
  /// Returns headers with Bearer token if logged in and not expired, otherwise basic headers
  /// Automatically clears token and navigates to login if expired (production-ready)
  static Future<Map<String, String>> getAuthHeaders() async {
    // Check if token is expired before using it
    final isExpired = await isTokenExpired();
    if (isExpired) {
      await clearToken();
      _navigateToLogin();
      return {
        'Content-Type': 'application/json',
      };
    }
    
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    
    // No token found - navigate to login
    _navigateToLogin();
    return {
      'Content-Type': 'application/json',
    };
  }

  /// Navigate to login page when authentication fails
  /// Uses global navigator key to navigate from anywhere
  static void _navigateToLogin() {
    try {
      // Reset login state before navigating to ensure phone input screen is shown
      // We'll do this in the LoginScreen's initState, but also try to reset here if possible
      NavigationService.navigateToLogin();
    } catch (e) {
      print('Error navigating to login: $e');
    }
  }

  /// Handle authentication error - clear token and navigate to login
  /// Call this method when API returns 401 or token is invalid
  static Future<void> handleAuthError() async {
    await clearToken();
    _navigateToLogin();
  }

  /// Get specific user field from stored user data
  /// Example: getUserField('name') or getUserField('phone')
  static Future<dynamic> getUserField(String field) async {
    try {
      final userData = await getUserData();
      return userData?[field];
    } catch (e) {
      print('Error getting user field $field: $e');
      return null;
    }
  }

  /// Update user data in SharedPreferences
  /// This can be used to update user profile information
  static Future<bool> updateUserData(Map<String, dynamic> newUserData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(newUserData));
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  /// Check if token is expired (optional - requires JWT decode)
  /// Token is valid for 365 days from login time
  static Future<bool> isTokenExpired() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return true;

      // Check if it's been more than 1000 days since login
      final loginTime = await getLoginTime();
      if (loginTime != null) {
        final daysSinceLogin = DateTime.now().difference(loginTime).inDays;
        return daysSinceLogin > 1000; // 1000-day token expiry
      }

      return false;
    } catch (e) {
      print('Error checking token expiration: $e');
      return true;
    }
  }

  /// Refresh token if needed (placeholder for future implementation)
  /// This method can be implemented when you have refresh token functionality
  static Future<bool> refreshTokenIfNeeded() async {
    try {
      final isExpired = await isTokenExpired();
      if (isExpired) {
        // TODO: Implement refresh token logic
        print('Token expired - refresh needed');
        return false;
      }
      return true;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  /// Get user's basic info as a formatted string
  /// Useful for displaying user info in UI
  static Future<String> getUserDisplayName() async {
    try {
      final userData = await getUserData();
      if (userData != null) {
        final name = userData['name'] as String?;
        final phone = userData['phone'] as String?;

        if (name != null && name.isNotEmpty) {
          return name;
        } else if (phone != null && phone.isNotEmpty) {
          return phone;
        }
      }
      return 'User';
    } catch (e) {
      print('Error getting user display name: $e');
      return 'User';
    }
  }

  /// Debug method to print stored user data in JSON format
  /// Use this for debugging purposes only
  static Future<void> debugPrintUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString(_userKey);
      
      print('=== TOKEN MANAGER DEBUG ===');
      print('Raw JSON stored in user_data:');
      print(userDataJson ?? 'No user data found');
      print('========================');
      
      if (userDataJson != null) {
        final userData = json.decode(userDataJson);
        print('Parsed user data:');
        userData.forEach((key, value) {
          print('  $key: $value');
        });
        print('========================');
      }
    } catch (e) {
      print('Error debugging user data: $e');
    }
  }
}
