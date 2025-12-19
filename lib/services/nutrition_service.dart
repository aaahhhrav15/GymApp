// // lib/services/nutrition_service.dart - Updated with timezone fixes
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class NutritionService {
//   static const String baseUrl =
//       'http://192.168.1.114:5000/api'; // Match your server IP
//   static const String _nutritionEndpoint = '/nutrition';

//   // TIMEZONE FIX: Get IST time (UTC + 5:30)
//   static DateTime getISTTime() {
//     final utcNow = DateTime.now().toUtc();
//     // Add IST offset (5 hours 30 minutes)
//     return utcNow.add(const Duration(hours: 5, minutes: 30));
//   }

//   // Format time for display in 12-hour format (IST)
//   static String getCurrentTimeForMealDisplay() {
//     final istTime = getISTTime();
//     final hour = istTime.hour;
//     final minute = istTime.minute;

//     if (hour == 0) {
//       return '12:${minute.toString().padLeft(2, '0')} AM';
//     } else if (hour < 12) {
//       return '$hour:${minute.toString().padLeft(2, '0')} AM';
//     } else if (hour == 12) {
//       return '12:${minute.toString().padLeft(2, '0')} PM';
//     } else {
//       return '${hour - 12}:${minute.toString().padLeft(2, '0')} PM';
//     }
//   }

//   // Get current date in IST
//   static String getCurrentDateIST() {
//     final istTime = getISTTime();
//     return istTime.toIso8601String().split('T')[0];
//   }

//   // Convert UTC timestamp from API to IST display time
//   static String convertUTCToISTDisplay(String utcTimestamp) {
//     try {
//       final utcTime = DateTime.parse(utcTimestamp);
//       final istTime = utcTime.add(const Duration(hours: 5, minutes: 30));

//       final hour = istTime.hour;
//       final minute = istTime.minute;

//       if (hour == 0) {
//         return '12:${minute.toString().padLeft(2, '0')} AM';
//       } else if (hour < 12) {
//         return '$hour:${minute.toString().padLeft(2, '0')} AM';
//       } else if (hour == 12) {
//         return '12:${minute.toString().padLeft(2, '0')} PM';
//       } else {
//         return '${hour - 12}:${minute.toString().padLeft(2, '0')} PM';
//       }
//     } catch (e) {
//       return getCurrentTimeForMealDisplay(); // Fallback to current IST time
//     }
//   }

//   // Get headers with authorization
//   static Future<Map<String, String>> _getHeaders({
//     bool includeAuth = true,
//   }) async {
//     final headers = {'Content-Type': 'application/json'};

//     if (includeAuth) {
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final token = prefs.getString('auth_token');
//         if (token != null && token.isNotEmpty) {
//           headers['Authorization'] = 'Bearer $token';
//         }
//       } catch (e) {
//         print('Error getting auth token: $e');
//       }
//     }

//     return headers;
//   }

//   // Handle API response with robust error checking
//   static Map<String, dynamic> _handleResponse(http.Response response) {
//     try {
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.body.isEmpty) {
//         return {
//           'success': false,
//           'error': 'Empty response from server',
//           'statusCode': response.statusCode,
//         };
//       }

//       final responseData = jsonDecode(response.body);

//       // Handle null response
//       if (responseData == null) {
//         return {
//           'success': false,
//           'error': 'Null response from server',
//           'statusCode': response.statusCode,
//         };
//       }

//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         return {
//           'success': true,
//           'data': responseData,
//           'statusCode': response.statusCode,
//           // Handle direct success responses
//           ...responseData,
//         };
//       } else {
//         return {
//           'success': false,
//           'error': responseData is Map
//               ? (responseData['error'] ??
//                   responseData['message'] ??
//                   'Unknown error')
//               : 'Server error',
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       print('Error parsing response: $e');
//       return {
//         'success': false,
//         'error': 'Failed to parse server response: ${e.toString()}',
//         'statusCode': response.statusCode,
//       };
//     }
//   }

//   // Get nutrition goals with null safety
//   static Future<Map<String, dynamic>> getNutritionGoals() async {
//     try {
//       final headers = await _getHeaders();
//       print('Getting nutrition goals...');

//       final response = await http.get(
//         Uri.parse('$baseUrl$_nutritionEndpoint/goals'),
//         headers: headers,
//       );

//       final result = _handleResponse(response);

//       // Ensure goals data exists
//       if (result['success'] == true) {
//         final goals = result['goals'];
//         if (goals == null) {
//           return {
//             'success': true,
//             'goals': {
//               'calories': 2200,
//               'protein': 110,
//               'fat': 67,
//               'carbs': 185,
//             }
//           };
//         }

//         // Validate goals structure
//         return {
//           'success': true,
//           'goals': {
//             'calories': _safeInt(goals['calories'], 2200),
//             'protein': _safeInt(goals['protein'], 110),
//             'fat': _safeInt(goals['fat'], 67),
//             'carbs': _safeInt(goals['carbs'], 185),
//           }
//         };
//       }

//       return result;
//     } catch (e) {
//       print('Network error getting goals: $e');
//       return {'success': false, 'error': 'Network error: ${e.toString()}'};
//     }
//   }

//   // Update nutrition goals
//   static Future<Map<String, dynamic>> updateNutritionGoals({
//     required int calories,
//     required int protein,
//     required int fat,
//     required int carbs,
//   }) async {
//     try {
//       final headers = await _getHeaders();
//       final body = jsonEncode({
//         'calories': calories,
//         'protein': protein,
//         'fat': fat,
//         'carbs': carbs,
//       });

//       print('Updating nutrition goals: $body');

//       final response = await http.put(
//         Uri.parse('$baseUrl$_nutritionEndpoint/goals'),
//         headers: headers,
//         body: body,
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       print('Network error updating goals: $e');
//       return {'success': false, 'error': 'Network error: ${e.toString()}'};
//     }
//   }

//   // Get meals for a specific date with null safety and timezone fix
//   static Future<Map<String, dynamic>> getMeals({String? date}) async {
//     try {
//       final headers = await _getHeaders();
//       // Use IST date if no date provided
//       final targetDate = date ?? getCurrentDateIST();
//       String url = '$baseUrl$_nutritionEndpoint/meals?date=$targetDate';

//       print('Getting meals from: $url');

//       final response = await http.get(
//         Uri.parse(url),
//         headers: headers,
//       );

//       final result = _handleResponse(response);

//       // Ensure meals and totals data exists with defaults
//       if (result['success'] == true) {
//         final meals = result['meals'];
//         final totals = result['totals'];

//         // Convert all meal times from UTC to IST
//         final processedMeals = _safeMealsList(meals);

//         return {
//           'success': true,
//           'meals': processedMeals,
//           'totals': _safeTotals(totals),
//           'date': result['date'] ?? targetDate,
//         };
//       }

//       return result;
//     } catch (e) {
//       print('Network error getting meals: $e');
//       return {'success': false, 'error': 'Network error: ${e.toString()}'};
//     }
//   }

//   // Add a new meal with IST timestamp
//   static Future<Map<String, dynamic>> addMeal({
//     required String name,
//     required int calories,
//     required double protein,
//     required double fat,
//     required double carbs,
//     String mealType = 'custom',
//     String source = 'manual',
//   }) async {
//     try {
//       final headers = await _getHeaders();
//       final istTime = getISTTime();

//       final body = jsonEncode({
//         'name': name,
//         'calories': calories,
//         'protein': protein,
//         'fat': fat,
//         'carbs': carbs,
//         'meal_type': mealType,
//         'source': source,
//         'timestamp': istTime.toIso8601String(), // Send IST timestamp
//         'date': getCurrentDateIST(),
//       });

//       print('Adding meal: $body');

//       final response = await http.post(
//         Uri.parse('$baseUrl$_nutritionEndpoint/meals'),
//         headers: headers,
//         body: body,
//       );

//       final result = _handleResponse(response);

//       // Ensure meal data exists and convert time to IST
//       if (result['success'] == true && result['meal'] != null) {
//         final processedMeal = _safeMeal(result['meal']);

//         return {
//           'success': true,
//           'meal': processedMeal,
//           'message': result['message'] ?? 'Meal added successfully',
//         };
//       }

//       return result;
//     } catch (e) {
//       print('Network error adding meal: $e');
//       return {'success': false, 'error': 'Network error: ${e.toString()}'};
//     }
//   }

//   // Update a meal
//   static Future<Map<String, dynamic>> updateMeal({
//     required String mealId,
//     String? name,
//     int? calories,
//     double? protein,
//     double? fat,
//     double? carbs,
//     String? mealType,
//   }) async {
//     try {
//       final headers = await _getHeaders();
//       final body = <String, dynamic>{};

//       if (name != null) body['name'] = name;
//       if (calories != null) body['calories'] = calories;
//       if (protein != null) body['protein'] = protein;
//       if (fat != null) body['fat'] = fat;
//       if (carbs != null) body['carbs'] = carbs;
//       if (mealType != null) body['meal_type'] = mealType;

//       // Add IST timestamp for update
//       body['updated_at'] = getISTTime().toIso8601String();

//       final response = await http.put(
//         Uri.parse('$baseUrl$_nutritionEndpoint/meals/$mealId'),
//         headers: headers,
//         body: jsonEncode(body),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       print('Network error updating meal: $e');
//       return {'success': false, 'error': 'Network error: ${e.toString()}'};
//     }
//   }

//   // Delete a meal
//   static Future<Map<String, dynamic>> deleteMeal(String mealId) async {
//     try {
//       final headers = await _getHeaders();

//       final response = await http.delete(
//         Uri.parse('$baseUrl$_nutritionEndpoint/meals/$mealId'),
//         headers: headers,
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       print('Network error deleting meal: $e');
//       return {'success': false, 'error': 'Network error: ${e.toString()}'};
//     }
//   }

//   // Analyze food using AI (text-based) with IST timestamp
//   static Future<Map<String, dynamic>> analyzeFoodByName({
//     required String foodName,
//     int weightGrams = 100,
//   }) async {
//     try {
//       final headers = await _getHeaders();
//       final body = jsonEncode({
//         'food_name': foodName,
//         'weight_grams': weightGrams,
//         'timestamp': getISTTime().toIso8601String(),
//       });

//       final response = await http.post(
//         Uri.parse('$baseUrl$_nutritionEndpoint/analyze-food'),
//         headers: headers,
//         body: body,
//       );

//       final result = _handleResponse(response);

//       // Ensure nutrition data exists
//       if (result['success'] == true && result['nutrition'] != null) {
//         return {
//           'success': true,
//           'nutrition':
//               _safeNutrition(result['nutrition'], foodName, weightGrams),
//         };
//       }

//       return result;
//     } catch (e) {
//       print('Network error analyzing food: $e');
//       return {'success': false, 'error': 'Network error: ${e.toString()}'};
//     }
//   }

//   // Analyze food image using AI with IST timestamp
//   static Future<Map<String, dynamic>> analyzeFoodImage(
//       String base64Image) async {
//     try {
//       final headers = await _getHeaders();
//       final body = jsonEncode({
//         'image': base64Image,
//         'timestamp': getISTTime().toIso8601String(),
//       });

//       final response = await http.post(
//         Uri.parse('$baseUrl$_nutritionEndpoint/analyze-image'),
//         headers: headers,
//         body: body,
//       );

//       final result = _handleResponse(response);

//       // Ensure food_items data exists
//       if (result['success'] == true) {
//         final foodItems = result['food_items'];
//         return {
//           'success': true,
//           'food_items': _safeFoodItemsList(foodItems),
//         };
//       }

//       return result;
//     } catch (e) {
//       print('Network error analyzing image: $e');
//       return {'success': false, 'error': 'Network error: ${e.toString()}'};
//     }
//   }

//   // UPDATED: Get meal type based on IST time
//   static String getMealTypeByTime() {
//     final istTime = getISTTime();
//     final hour = istTime.hour;
//     final minute = istTime.minute;
//     final timeInMinutes = hour * 60 + minute;

//     // Convert times to minutes for more precise control (IST based)
//     const breakfastStart = 6 * 60; // 6:00 AM IST
//     const breakfastEnd = 11 * 60; // 11:00 AM IST
//     const lunchStart = 11 * 60; // 11:00 AM IST
//     const lunchEnd = 16 * 60; // 4:00 PM IST
//     const dinnerStart = 16 * 60; // 4:00 PM IST
//     const dinnerEnd = 22 * 60; // 10:00 PM IST

//     if (timeInMinutes >= breakfastStart && timeInMinutes < breakfastEnd) {
//       return 'breakfast';
//     } else if (timeInMinutes >= lunchStart && timeInMinutes < lunchEnd) {
//       return 'lunch';
//     } else if (timeInMinutes >= dinnerStart && timeInMinutes < dinnerEnd) {
//       return 'dinner';
//     } else {
//       return 'snack';
//     }
//   }

//   // Helper methods for null safety (unchanged but improved meal time handling)
//   static int _safeInt(dynamic value, int defaultValue) {
//     if (value == null) return defaultValue;
//     if (value is int) return value;
//     if (value is double) return value.round();
//     if (value is String) return int.tryParse(value) ?? defaultValue;
//     return defaultValue;
//   }

//   static double _safeDouble(dynamic value, double defaultValue) {
//     if (value == null) return defaultValue;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value) ?? defaultValue;
//     return defaultValue;
//   }

//   static String _safeString(dynamic value, String defaultValue) {
//     if (value == null) return defaultValue;
//     return value.toString();
//   }

//   static Map<String, dynamic> _safeTotals(dynamic totals) {
//     if (totals == null || totals is! Map) {
//       return {
//         'calories': 0,
//         'protein': 0.0,
//         'fat': 0.0,
//         'carbs': 0.0,
//       };
//     }

//     final totalsMap = totals as Map<String, dynamic>;
//     return {
//       'calories': _safeInt(totalsMap['calories'], 0),
//       'protein': _safeDouble(totalsMap['protein'], 0.0),
//       'fat': _safeDouble(totalsMap['fat'], 0.0),
//       'carbs': _safeDouble(totalsMap['carbs'], 0.0),
//     };
//   }

//   static List<Map<String, dynamic>> _safeMealsList(dynamic meals) {
//     if (meals == null || meals is! List) {
//       return [];
//     }

//     return (meals).map((meal) => _safeMeal(meal)).toList();
//   }

//   // UPDATED: Handle meal time conversion from UTC to IST
//   static Map<String, dynamic> _safeMeal(dynamic meal) {
//     if (meal == null || meal is! Map) {
//       return {
//         'id': '',
//         'name': 'Unknown Food',
//         'calories': 0,
//         'protein': 0.0,
//         'fat': 0.0,
//         'carbs': 0.0,
//         'meal_type': 'custom',
//         'time': getCurrentTimeForMealDisplay(),
//         'created_at': getISTTime().toIso8601String(),
//         'source': 'manual',
//       };
//     }

//     final mealMap = meal as Map<String, dynamic>;

//     // Handle time conversion from UTC to IST
//     String displayTime = getCurrentTimeForMealDisplay();
//     if (mealMap['time'] != null) {
//       final timeStr = mealMap['time'].toString();
//       if (timeStr.contains('T') || timeStr.contains('Z')) {
//         // This is a UTC timestamp, convert to IST
//         displayTime = convertUTCToISTDisplay(timeStr);
//       } else if (timeStr.contains(':')) {
//         // This might already be formatted time, use as is
//         displayTime = timeStr;
//       }
//     } else if (mealMap['created_at'] != null) {
//       // Fallback to created_at timestamp
//       displayTime = convertUTCToISTDisplay(mealMap['created_at'].toString());
//     }

//     return {
//       'id': _safeString(mealMap['id'], ''),
//       'name': _safeString(mealMap['name'], 'Unknown Food'),
//       'calories': _safeInt(mealMap['calories'], 0),
//       'protein': _safeDouble(mealMap['protein'], 0.0),
//       'fat': _safeDouble(mealMap['fat'], 0.0),
//       'carbs': _safeDouble(mealMap['carbs'], 0.0),
//       'meal_type': _safeString(mealMap['meal_type'], 'custom'),
//       'time': displayTime, // Now properly converted to IST
//       'created_at':
//           _safeString(mealMap['created_at'], getISTTime().toIso8601String()),
//       'source': _safeString(mealMap['source'], 'manual'),
//     };
//   }

//   static Map<String, dynamic> _safeNutrition(
//       dynamic nutrition, String foodName, int weightGrams) {
//     if (nutrition == null || nutrition is! Map) {
//       return {
//         'name': foodName,
//         'weight_grams': weightGrams,
//         'calories': 100,
//         'protein': 5.0,
//         'fat': 3.0,
//         'carbs': 15.0,
//         'fiber': 2.0,
//         'sugar': 5.0,
//         'sodium': 50.0,
//       };
//     }

//     final nutritionMap = nutrition as Map<String, dynamic>;
//     return {
//       'name': _safeString(nutritionMap['name'], foodName),
//       'weight_grams': _safeInt(nutritionMap['weight_grams'], weightGrams),
//       'calories': _safeInt(nutritionMap['calories'], 100),
//       'protein': _safeDouble(nutritionMap['protein'], 5.0),
//       'fat': _safeDouble(nutritionMap['fat'], 3.0),
//       'carbs': _safeDouble(nutritionMap['carbs'], 15.0),
//       'fiber': _safeDouble(nutritionMap['fiber'], 2.0),
//       'sugar': _safeDouble(nutritionMap['sugar'], 5.0),
//       'sodium': _safeDouble(nutritionMap['sodium'], 50.0),
//     };
//   }

//   static List<Map<String, dynamic>> _safeFoodItemsList(dynamic foodItems) {
//     if (foodItems == null || foodItems is! List) {
//       return [];
//     }

//     return (foodItems).map((item) {
//       if (item == null || item is! Map) {
//         return {
//           'name': 'Unknown Food',
//           'estimated_weight': 100,
//           'calories': 100,
//           'protein': 5.0,
//           'fat': 3.0,
//           'carbs': 15.0,
//           'confidence': 50,
//         };
//       }

//       final itemMap = item as Map<String, dynamic>;
//       return {
//         'name': _safeString(itemMap['name'], 'Unknown Food'),
//         'estimated_weight': _safeInt(itemMap['estimated_weight'], 100),
//         'calories': _safeInt(itemMap['calories'], 100),
//         'protein': _safeDouble(itemMap['protein'], 5.0),
//         'fat': _safeDouble(itemMap['fat'], 3.0),
//         'carbs': _safeDouble(itemMap['carbs'], 15.0),
//         'confidence': _safeInt(itemMap['confidence'], 50),
//       };
//     }).toList();
//   }

//   // Validate nutrition values
//   static bool validateNutritionValues({
//     required int calories,
//     required double protein,
//     required double fat,
//     required double carbs,
//   }) {
//     return calories >= 0 &&
//         protein >= 0 &&
//         fat >= 0 &&
//         carbs >= 0 &&
//         calories <= 5000 &&
//         protein <= 200 &&
//         fat <= 200 &&
//         carbs <= 500;
//   }
// }
