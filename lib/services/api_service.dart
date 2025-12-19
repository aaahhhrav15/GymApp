// lib/services/api_service.dart - Updated with Nutrition endpoints
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'token_manager.dart';

class ApiService {

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://65.0.5.24/';

  // For Android Emulator, use: http://10.0.2.2:4000
  // For iOS Simulator, use: http://127.0.0.1:4000
  // For physical device, use your computer's IP: http://YOUR_IP:4000

  static const String _tokenKey = 'auth_token';

  // Get stored token
  static Future<String?> getToken() async {
    return await TokenManager.getToken();
  }

  // Store token
  static Future<void> saveToken(String token) async {
    // This method is deprecated - use TokenManager.saveToken instead
    // Keeping for backward compatibility
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Remove token
  static Future<void> removeToken() async {
    await TokenManager.clearToken();
  }

  // Store user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await TokenManager.updateUserData(userData);
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    return await TokenManager.getUserData();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return await TokenManager.isLoggedIn();
  }

  // Get headers with authorization
  static Future<Map<String, String>> getHeaders({
    bool includeAuth = true,
  }) async {
    if (includeAuth) {
      return await TokenManager.getAuthHeaders();
    } else {
      return {'Content-Type': 'application/json'};
    }
  }

  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
  }) async {
    return getHeaders(includeAuth: includeAuth);
  }

  // Handle API response
  static Future<Map<String, dynamic>> handleResponse(http.Response response) async {
    final responseData = jsonDecode(response.body);

    // Handle 401 Unauthorized - token expired or invalid
    if (response.statusCode == 401) {
      await TokenManager.handleAuthError();
      return {
        'success': false,
        'error': 'Session expired. Please login again.',
        'statusCode': 401,
      };
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        'data': responseData,
        'statusCode': response.statusCode,
      };
    } else {
      return {
        'success': false,
        'error': responseData['error'] ?? 'An error occurred',
        'statusCode': response.statusCode,
      };
    }
  }

  static Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    return await handleResponse(response);
  }

  // Test connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Register user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String countryCode,
    required String dateOfBirth,
    required String gender,
    required String weight,
    required String height,
    String? gymCode,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: false);

      final body = jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'countryCode': countryCode,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'weight': weight,
        'height': height,
        'gymCode': gymCode,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: body,
      );

      final result = await _handleResponse(response);

      if (result['success']) {
        // Save token and user data
        final responseData = result['data'];
        await saveToken(responseData['token']);
        await saveUserData(responseData['user']);
      }

      return result;
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: false);

      final body = jsonEncode({'phone': phone, 'password': password});

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: body,
      );

      final result = await _handleResponse(response);

      if (result['success']) {
        // Save token and user data
        final responseData = result['data'];
        await saveToken(responseData['token']);
        await saveUserData(responseData['user']);
      }

      return result;
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: headers,
      );

      final result = await _handleResponse(response);

      if (result['success']) {
        // Update stored user data
        final responseData = result['data'];
        await saveUserData(responseData['user']);
      }

      return result;
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? weight,
    String? height,
    String? gymCode,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (weight != null) body['weight'] = weight;
      if (height != null) body['height'] = height;
      if (gymCode != null) body['gymCode'] = gymCode;

      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: headers,
        body: jsonEncode(body),
      );

      final result = await _handleResponse(response);

      if (result['success']) {
        // Update stored user data
        final responseData = result['data'];
        await saveUserData(responseData['user']);
      }

      return result;
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: headers,
        body: body,
      );

      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: headers,
      );

      final result = await _handleResponse(response);

      // Always remove local data regardless of API response
      await removeToken();

      return result;
    } catch (e) {
      // Even if API call fails, remove local data
      await removeToken();
      return {'success': true, 'message': 'Logged out locally'};
    }
  }

  // Google authentication
  static Future<Map<String, dynamic>> googleAuth({
    required String email,
    required String name,
    required String id,
    String? photoUrl,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: false);

      final body = jsonEncode({
        'email': email,
        'name': name,
        'id': id,
        'photoUrl': photoUrl,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-auth'),
        headers: headers,
        body: body,
      );

      final result = await _handleResponse(response);

      if (result['success'] && result['data']['action'] == 'login') {
        // Save token and user data for successful login
        final responseData = result['data'];
        await saveToken(responseData['token']);
        await saveUserData(responseData['user']);
      }

      return result;
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Google register
  static Future<Map<String, dynamic>> googleRegister({
    required Map<String, dynamic> googleUserData,
    required String dateOfBirth,
    required String gender,
    required String weight,
    required String height,
    required String phone,
    required String countryCode,
    String? gymCode,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: false);

      final body = jsonEncode({
        'googleUserData': googleUserData,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'weight': weight,
        'height': height,
        'phone': phone,
        'countryCode': countryCode,
        'gymCode': gymCode,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-register'),
        headers: headers,
        body: body,
      );

      final result = await _handleResponse(response);

      if (result['success']) {
        // Save token and user data
        final responseData = result['data'];
        await saveToken(responseData['token']);
        await saveUserData(responseData['user']);
      }

      return result;
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // ========== NUTRITION API METHODS ==========

  // Get nutrition goals
  static Future<Map<String, dynamic>> getNutritionGoals() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/nutrition/goals'),
        headers: headers,
      );

      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Update nutrition goals
  static Future<Map<String, dynamic>> updateNutritionGoals({
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/nutrition/goals'),
        headers: headers,
        body: body,
      );

      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get meals for a specific date
  static Future<Map<String, dynamic>> getMeals({String? date}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/nutrition/meals';

      if (date != null) {
        url += '?date=$date';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Add a new meal
  static Future<Map<String, dynamic>> addMeal({
    required String name,
    required int calories,
    required double protein,
    required double fat,
    required double carbs,
    String mealType = 'custom',
    String source = 'manual',
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'name': name,
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'meal_type': mealType,
        'source': source,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/nutrition/meals'),
        headers: headers,
        body: body,
      );

      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Update a meal
  static Future<Map<String, dynamic>> updateMeal({
    required String mealId,
    String? name,
    int? calories,
    double? protein,
    double? fat,
    double? carbs,
    String? mealType,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (calories != null) body['calories'] = calories;
      if (protein != null) body['protein'] = protein;
      if (fat != null) body['fat'] = fat;
      if (carbs != null) body['carbs'] = carbs;
      if (mealType != null) body['meal_type'] = mealType;

      final response = await http.put(
        Uri.parse('$baseUrl/nutrition/meals/$mealId'),
        headers: headers,
        body: jsonEncode(body),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Delete a meal
  static Future<Map<String, dynamic>> deleteMeal(String mealId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/nutrition/meals/$mealId'),
        headers: headers,
      );

      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Analyze food using AI (text-based)
  static Future<Map<String, dynamic>> analyzeFoodByName({
    required String foodName,
    int weightGrams = 100,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'food_name': foodName,
        'weight_grams': weightGrams,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/nutrition/analyze-food'),
        headers: headers,
        body: body,
      );

      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Analyze food image using AI
  static Future<Map<String, dynamic>> analyzeFoodImage(
      String base64Image) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'image': base64Image,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/nutrition/analyze-image'),
        headers: headers,
        body: body,
      );

      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get nutrition summary
  static Future<Map<String, dynamic>> getNutritionSummary({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/nutrition/summary';

      List<String> params = [];
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Search for food in database
  static Future<Map<String, dynamic>> searchFood(String query) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
            '$baseUrl/nutrition/search-food?q=${Uri.encodeComponent(query)}'),
        headers: headers,
      );

      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // ========== NUTRITION HELPER METHODS ==========

  // Helper method to format nutrition data for UI
  static Map<String, dynamic> formatNutritionData(Map<String, dynamic> data) {
    return {
      'name': data['name'] ?? '',
      'calories': (data['calories'] ?? 0).round(),
      'protein': double.tryParse(data['protein'].toString()) ?? 0.0,
      'fat': double.tryParse(data['fat'].toString()) ?? 0.0,
      'carbs': double.tryParse(data['carbs'].toString()) ?? 0.0,
      'time': data['time'] ?? DateTime.now().toString(),
      'type': data['meal_type'] ?? 'custom',
    };
  }

  // Helper method to calculate nutrition totals
  static Map<String, dynamic> calculateTotals(
      List<Map<String, dynamic>> meals) {
    int totalCalories = 0;
    double totalProtein = 0.0;
    double totalFat = 0.0;
    double totalCarbs = 0.0;

    for (var meal in meals) {
      totalCalories += (meal['calories'] ?? 0) as int;
      totalProtein += double.tryParse(meal['protein'].toString()) ?? 0.0;
      totalFat += double.tryParse(meal['fat'].toString()) ?? 0.0;
      totalCarbs += double.tryParse(meal['carbs'].toString()) ?? 0.0;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein.round(),
      'fat': totalFat.round(),
      'carbs': totalCarbs.round(),
    };
  }

  // Helper to determine meal type based on time
  static String getMealTypeByTime() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 11) {
      return 'breakfast';
    } else if (hour >= 11 && hour < 16) {
      return 'lunch';
    } else if (hour >= 16 && hour < 20) {
      return 'dinner';
    } else {
      return 'snack';
    }
  }

  // Validate nutrition values
  static bool validateNutritionValues({
    required int calories,
    required double protein,
    required double fat,
    required double carbs,
  }) {
    return calories >= 0 &&
        protein >= 0 &&
        fat >= 0 &&
        carbs >= 0 &&
        calories <= 5000 && // Reasonable upper limit
        protein <= 200 &&
        fat <= 200 &&
        carbs <= 500;
  }
}
