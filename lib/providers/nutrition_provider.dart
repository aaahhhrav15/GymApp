import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/token_manager.dart';
import '../services/connectivity_service.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import '../models/nutrition_models.dart';

class NutritionProvider extends ChangeNotifier {
  static Database? _database;

  // Current state
  bool _isLoading = false;
  NutritionGoals _nutritionGoals = NutritionGoals(
    calories: 2200,
    protein: 110,
    fat: 67,
    carbs: 185,
  );
  NutritionTotals _currentTotals = NutritionTotals(
    calories: 0,
    protein: 0.0,
    fat: 0.0,
    carbs: 0.0,
  );
  List<Meal> _meals = [];
  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];

  // 7-day history
  Map<String, List<Meal>> _weeklyMeals = {};
  Map<String, NutritionTotals> _weeklyTotals = {};
  Map<String, NutritionGoals> _weeklyGoals = {};

  // Getters
  bool get isLoading => _isLoading;
  NutritionGoals get nutritionGoals => _nutritionGoals;
  NutritionTotals get currentTotals => _currentTotals;
  List<Meal> get meals => _meals;
  String get selectedDate => _selectedDate;
  Map<String, List<Meal>> get weeklyMeals => _weeklyMeals;
  Map<String, NutritionTotals> get weeklyTotals => _weeklyTotals;
  Map<String, NutritionGoals> get weeklyGoals => _weeklyGoals;

  // Database initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'nutrition_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Nutrition goals table
    await db.execute('''
      CREATE TABLE nutrition_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE,
        calories INTEGER NOT NULL,
        protein INTEGER NOT NULL,
        fat INTEGER NOT NULL,
        carbs INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Meals table
    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories INTEGER NOT NULL,
        protein REAL NOT NULL,
        fat REAL NOT NULL,
        carbs REAL NOT NULL,
        meal_type TEXT NOT NULL,
        time TEXT NOT NULL,
        date TEXT NOT NULL,
        source TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Custom food items table for future use
    await db.execute('''
      CREATE TABLE custom_foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories_per_100g INTEGER NOT NULL,
        protein_per_100g REAL NOT NULL,
        fat_per_100g REAL NOT NULL,
        carbs_per_100g REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Initialize provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadNutritionGoals();
      await _loadMealsForDate(_selectedDate);
      await _loadWeeklyData();
      _calculateTotals();
    } catch (e) {
      debugPrint('Error initializing nutrition provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load 7 days of data for history
  Future<void> _loadWeeklyData() async {
    final today = DateTime.now();
    _weeklyMeals.clear();
    _weeklyTotals.clear();
    _weeklyGoals.clear();

    for (int i = 0; i < 7; i++) {
      final date =
          today.subtract(Duration(days: i)).toIso8601String().split('T')[0];

      // Load meals for this date
      final meals = await _loadMealsForSpecificDate(date);
      _weeklyMeals[date] = meals;

      // Calculate totals
      _weeklyTotals[date] = NutritionTotals.fromMeals(meals);

      // Load goals for this date
      _weeklyGoals[date] = await _loadGoalsForDate(date);
    }
  }

  // Load meals for a specific date (without affecting current state)
  Future<List<Meal>> _loadMealsForSpecificDate(String date) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'meals',
        where: 'date = ?',
        whereArgs: [date],
        orderBy: 'created_at DESC',
      );

      return maps
          .map((map) => Meal(
                id: map['id'].toString(),
                name: map['name'],
                calories: map['calories'],
                protein: map['protein'],
                fat: map['fat'],
                carbs: map['carbs'],
                mealType: map['meal_type'],
                time: map['time'],
                createdAt: DateTime.parse(map['created_at']),
                source: map['source'],
              ))
          .toList();
    } catch (e) {
      debugPrint('Error loading meals for date $date: $e');
      return [];
    }
  }

  // Load goals for a specific date
  Future<NutritionGoals> _loadGoalsForDate(String date) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'nutrition_goals',
        where: 'date = ?',
        whereArgs: [date],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return NutritionGoals(
          calories: maps.first['calories'],
          protein: maps.first['protein'],
          fat: maps.first['fat'],
          carbs: maps.first['carbs'],
        );
      } else {
        // Return default goals
        return NutritionGoals(
          calories: 2200,
          protein: 110,
          fat: 67,
          carbs: 185,
        );
      }
    } catch (e) {
      debugPrint('Error loading goals for date $date: $e');
      return NutritionGoals(
        calories: 2200,
        protein: 110,
        fat: 67,
        carbs: 185,
      );
    }
  }

  // Change selected date for viewing history
  Future<void> changeSelectedDate(String date) async {
    if (_selectedDate == date) return;

    _isLoading = true;
    _selectedDate = date;
    notifyListeners();

    try {
      await _loadNutritionGoals();
      await _loadMealsForDate(_selectedDate);
      _calculateTotals();
    } catch (e) {
      debugPrint('Error changing selected date: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if data is from today, if not reset for new day
  void _checkAndResetForNewDay() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (_selectedDate != today) {
      _selectedDate = today;
      _meals.clear();
      _currentTotals = NutritionTotals(
        calories: 0,
        protein: 0.0,
        fat: 0.0,
        carbs: 0.0,
      );
    }
  }

  // Load nutrition goals for current date
  Future<void> _loadNutritionGoals() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'nutrition_goals',
        where: 'date = ?',
        whereArgs: [_selectedDate],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _nutritionGoals = NutritionGoals(
          calories: maps.first['calories'],
          protein: maps.first['protein'],
          fat: maps.first['fat'],
          carbs: maps.first['carbs'],
        );
      } else {
        // Save default goals for today
        await _saveNutritionGoals(_nutritionGoals);
      }
    } catch (e) {
      debugPrint('Error loading nutrition goals: $e');
    }
  }

  // Save nutrition goals
  Future<void> _saveNutritionGoals(NutritionGoals goals) async {
    try {
      final db = await database;
      await db.insert(
        'nutrition_goals',
        {
          'date': _selectedDate,
          'calories': goals.calories,
          'protein': goals.protein,
          'fat': goals.fat,
          'carbs': goals.carbs,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error saving nutrition goals: $e');
    }
  }

  // Load meals for specific date
  Future<void> _loadMealsForDate(String date) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'meals',
        where: 'date = ?',
        whereArgs: [date],
        orderBy: 'created_at DESC',
      );

      _meals = maps
          .map((map) => Meal(
                id: map['id'].toString(),
                name: map['name'],
                calories: map['calories'],
                protein: map['protein'],
                fat: map['fat'],
                carbs: map['carbs'],
                mealType: map['meal_type'],
                time: map['time'],
                createdAt: DateTime.parse(map['created_at']),
                source: map['source'],
              ))
          .toList();
    } catch (e) {
      debugPrint('Error loading meals: $e');
      _meals = [];
    }
  }

  // Calculate current totals
  void _calculateTotals() {
    _currentTotals = NutritionTotals.fromMeals(_meals);
  }

  // Update nutrition goals
  Future<void> updateNutritionGoals(NutritionGoals goals) async {
    _isLoading = true;
    notifyListeners();

    try {
      _nutritionGoals = goals;
      await _saveNutritionGoals(goals);
    } catch (e) {
      debugPrint('Error updating nutrition goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add meal
  Future<void> addMeal(Meal meal) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await database;
      final mealWithTime = meal.copyWith(
        time: _getCurrentTimeString(),
        createdAt: DateTime.now(),
      );

      final id = await db.insert('meals', {
        'name': mealWithTime.name,
        'calories': mealWithTime.calories,
        'protein': mealWithTime.protein,
        'fat': mealWithTime.fat,
        'carbs': mealWithTime.carbs,
        'meal_type': mealWithTime.mealType,
        'time': mealWithTime.time,
        'date': _selectedDate,
        'source': mealWithTime.source,
        'created_at': mealWithTime.createdAt.toIso8601String(),
      });

      // Add to local list with database ID
      _meals.insert(0, mealWithTime.copyWith(id: id.toString()));
      _calculateTotals();
    } catch (e) {
      debugPrint('Error adding meal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete meal
  Future<void> deleteMeal(String mealId) async {
    try {
      final db = await database;
      await db.delete(
        'meals',
        where: 'id = ?',
        whereArgs: [int.parse(mealId)],
      );

      _meals.removeWhere((meal) => meal.id == mealId);
      _calculateTotals();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting meal: $e');
    }
  }

  // Update meal
  Future<void> updateMeal(String mealId, Meal updatedMeal) async {
    try {
      final db = await database;
      await db.update(
        'meals',
        {
          'name': updatedMeal.name,
          'calories': updatedMeal.calories,
          'protein': updatedMeal.protein,
          'fat': updatedMeal.fat,
          'carbs': updatedMeal.carbs,
          'meal_type': updatedMeal.mealType,
        },
        where: 'id = ?',
        whereArgs: [int.parse(mealId)],
      );

      final index = _meals.indexWhere((meal) => meal.id == mealId);
      if (index != -1) {
        _meals[index] = _meals[index].copyWith(
          name: updatedMeal.name,
          calories: updatedMeal.calories,
          protein: updatedMeal.protein,
          fat: updatedMeal.fat,
          carbs: updatedMeal.carbs,
          mealType: updatedMeal.mealType,
        );
      }

      _calculateTotals();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating meal: $e');
    }
  }

  // Add custom food item
  Future<void> addCustomFood(FoodItem foodItem) async {
    try {
      final db = await database;
      await db.insert('custom_foods', {
        'name': foodItem.name,
        'calories_per_100g': foodItem.caloriesPer100g,
        'protein_per_100g': foodItem.proteinPer100g,
        'fat_per_100g': foodItem.fatPer100g,
        'carbs_per_100g': foodItem.carbsPer100g,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error adding custom food: $e');
    }
  }

  // Get custom food items
  Future<List<FoodItem>> getCustomFoods() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'custom_foods',
        orderBy: 'created_at DESC',
      );

      return maps
          .map((map) => FoodItem(
                id: map['id'].toString(),
                name: map['name'],
                caloriesPer100g: map['calories_per_100g'],
                proteinPer100g: map['protein_per_100g'],
                fatPer100g: map['fat_per_100g'],
                carbsPer100g: map['carbs_per_100g'],
              ))
          .toList();
    } catch (e) {
      debugPrint('Error getting custom foods: $e');
      return [];
    }
  }

  // Refresh data for new day
  Future<void> refreshForNewDay() async {
    _checkAndResetForNewDay();
    await initialize();
  }

  // Get current time string for display
  String _getCurrentTimeString() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    if (hour == 0) {
      return '12:${minute.toString().padLeft(2, '0')} AM';
    } else if (hour < 12) {
      return '$hour:${minute.toString().padLeft(2, '0')} AM';
    } else if (hour == 12) {
      return '12:${minute.toString().padLeft(2, '0')} PM';
    } else {
      return '${hour - 12}:${minute.toString().padLeft(2, '0')} PM';
    }
  }

  // Test network connectivity to Google APIs
  Future<bool> _testNetworkConnectivity() async {
    try {
      debugPrint('Testing network connectivity to Google APIs...');
      final client = HttpClient();

      // Test basic connectivity to google.com first
      final request = await client.getUrl(Uri.parse('https://www.google.com'));
      final response = await request.close();
      client.close();

      debugPrint('Network test result: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Network connectivity test failed: $e');
      return false;
    }
  }

  // AI Image Analysis for Nutrition Detection via backend
  Future<DetectedFoodItem?> analyzeImageForNutrition(String imagePath) async {
    try {
      _isLoading = true;
      notifyListeners();

      // PROACTIVE: Check internet connectivity before making API call
      final connectivityService = ConnectivityService();
      if (!connectivityService.isConnected) {
        debugPrint('No internet connection detected before image analysis');
        throw Exception('NO_INTERNET_CONNECTION');
      }

      // Read image file and send to backend AI endpoint
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint('Image file not found: $imagePath');
        throw Exception('IMAGE_FILE_NOT_FOUND: The selected image file could not be found. Please try selecting the image again.');
      }
      
      Uint8List imageBytes;
      try {
        imageBytes = await imageFile.readAsBytes();
      } catch (e) {
        debugPrint('Error reading image file: $e');
        throw Exception('IMAGE_READ_ERROR: Unable to read the image file. Please try selecting a different image.');
      }
      
      if (imageBytes.isEmpty) {
        debugPrint('Image file is empty: $imagePath');
        throw Exception('IMAGE_EMPTY: The selected image file is empty. Please try selecting a different image.');
      }
      
      final imageB64 = base64Encode(imageBytes);

      final headers = await TokenManager.getAuthHeaders();
      final url = '${ApiService.baseUrl}ai/nutrition-image';
      
      final resp = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          'imageBase64': imageB64,
          'mimeType': 'image/jpeg',
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('REQUEST_TIMEOUT');
        },
      );

      if (resp.statusCode == 400) {
        // Handle different types of 400 errors from backend
        Map<String, dynamic> errorData;
        try {
          errorData = json.decode(resp.body) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('Failed to parse 400 error response: $e');
          throw Exception('NON_EDIBLE_ITEM: Unable to analyze the image. Please ensure the image contains food and try again.');
        }
        
        final errorType = errorData['error'] ?? '';
        final errorMessage = errorData['message'] ?? 'Analysis failed';
        
        debugPrint('Backend error (400): $errorType - $errorMessage');
        
        // Check if it's an image quality issue (too close, blurry, etc.)
        if (errorType == 'Image too close' || errorMessage.toLowerCase().contains('too close') || 
            errorMessage.toLowerCase().contains('20cm') || errorMessage.toLowerCase().contains('distance')) {
          throw Exception('IMAGE_TOO_CLOSE: $errorMessage');
        }
        
        // Otherwise treat as non-edible item error
        throw Exception('NON_EDIBLE_ITEM: $errorMessage');
      }
      
      if (resp.statusCode == 401) {
        debugPrint('Backend error (401): Unauthorized - token may be expired');
        throw Exception('UNAUTHORIZED');
      }
      
      if (resp.statusCode == 502) {
        // Bad Gateway - AI service issue
        debugPrint('Backend error (502): AI service unavailable or returned invalid response');
        Map<String, dynamic>? errorData;
        try {
          errorData = json.decode(resp.body) as Map<String, dynamic>?;
        } catch (e) {
          // Ignore parsing error, use default message
        }
        final errorMessage = errorData?['error'] ?? 'AI service temporarily unavailable';
        throw Exception('AI_SERVICE_ERROR: $errorMessage. Please try again in a moment.');
      }
      
      if (resp.statusCode == 500) {
        debugPrint('Backend error (500): Server error');
        throw Exception('SERVER_ERROR');
      }
      
      if (resp.statusCode != 200) {
        debugPrint('Backend AI error: ${resp.statusCode} ${resp.body}');
        throw Exception('BACKEND_ERROR: ${resp.statusCode}');
      }

      // Parse successful response
      Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(resp.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Failed to parse AI response JSON: $e');
        throw Exception('AI_RESPONSE_PARSE_ERROR: The AI service returned an invalid response. Please try again.');
      }
      final detectedFood = DetectedFoodItem(
        name: jsonData['name'] ?? 'Unknown Food',
        estimatedWeight: jsonData['estimated_weight'] ?? 100,
        calories: jsonData['calories'] ?? 0,
        protein: double.tryParse(jsonData['protein']?.toString() ?? '0') ?? 0.0,
        fat: double.tryParse(jsonData['fat']?.toString() ?? '0') ?? 0.0,
        carbs: double.tryParse(jsonData['carbs']?.toString() ?? '0') ?? 0.0,
        confidence: jsonData['confidence'] ?? 0,
      );

      return detectedFood;
    } catch (e) {
      debugPrint('Error analyzing image with AI: $e');

      // Handle specific error types
      final errorString = e.toString();
      
      if (errorString.contains('NO_INTERNET_CONNECTION')) {
        debugPrint('No internet connection - cannot analyze image');
        throw Exception('NO_INTERNET_CONNECTION');
      }
      
      if (errorString.contains('REQUEST_TIMEOUT')) {
        debugPrint('Request timeout - server took too long to respond');
        throw Exception('REQUEST_TIMEOUT');
      }
      
      if (errorString.contains('IMAGE_TOO_CLOSE')) {
        debugPrint('Image too close or unclear - cannot analyze');
        throw Exception(errorString); // Preserve the original message
      }
      
      if (errorString.contains('NON_EDIBLE_ITEM')) {
        debugPrint('Non-edible item detected in image');
        throw Exception(errorString); // Preserve the original message
      }
      
      if (errorString.contains('UNAUTHORIZED')) {
        debugPrint('Unauthorized - authentication failed');
        throw Exception('UNAUTHORIZED');
      }
      
      if (errorString.contains('SERVER_ERROR')) {
        debugPrint('Server error - backend issue');
        throw Exception('SERVER_ERROR');
      }
      
      if (errorString.contains('BACKEND_ERROR')) {
        debugPrint('Backend error detected');
        throw Exception(errorString); // Preserve status code
      }
      
      if (errorString.contains('AI_SERVICE_ERROR')) {
        debugPrint('AI service error detected');
        throw Exception(errorString); // Preserve the original message
      }
      
      if (errorString.contains('AI_RESPONSE_PARSE_ERROR')) {
        debugPrint('AI response parsing error');
        throw Exception(errorString); // Preserve the original message
      }
      
      if (errorString.contains('IMAGE_FILE_NOT_FOUND') || 
          errorString.contains('IMAGE_READ_ERROR') ||
          errorString.contains('IMAGE_EMPTY')) {
        debugPrint('Image file error detected');
        throw Exception(errorString); // Preserve the original message
      }
      
      // Check for JSON parsing errors
      if (errorString.contains('FormatException') ||
          errorString.contains('type \'Null\' is not a subtype') ||
          errorString.contains('Unexpected character') ||
          errorString.contains('Invalid JSON')) {
        debugPrint('JSON parsing error detected');
        throw Exception('AI_RESPONSE_PARSE_ERROR: Unable to process the AI response. Please try again.');
      }
      
      // Check for network-related exceptions
      if (errorString.contains('Failed host lookup') ||
          errorString.contains('SocketException') ||
          errorString.contains('No address associated with hostname') ||
          errorString.contains('Network is unreachable') ||
          errorString.contains('Connection refused') ||
          errorString.contains('Connection timed out')) {
        debugPrint('Network connectivity issue detected');
        throw Exception('NO_INTERNET_CONNECTION');
      }
      
      if (errorString.contains('API_KEY')) {
        debugPrint('API key issue detected');
        throw Exception('API_KEY_ERROR');
      }

      // Generic error - provide more context
      debugPrint('Unhandled error type: ${e.runtimeType}');
      throw Exception('ANALYSIS_FAILED: Unable to analyze the image. Please ensure you have a stable internet connection and try again with a clear photo of food.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add AI-detected meal to nutrition tracking
  Future<bool> addAIDetectedMeal(
      DetectedFoodItem detectedFood, String mealType) async {
    try {
      final meal = Meal(
        name: detectedFood.name,
        calories: detectedFood.calories,
        protein: detectedFood.protein,
        fat: detectedFood.fat,
        carbs: detectedFood.carbs,
        mealType: mealType,
        time: _getCurrentTimeString(),
        createdAt: DateTime.now(),
        source: 'ai_gemini',
      );

      await addMeal(meal);
      return true;
    } catch (e) {
      debugPrint('Error adding AI detected meal: $e');
      return false;
    }
  }

  // Get AI nutrition suggestion for text query via backend
  Future<NutritionData?> getAINutritionSuggestion(String foodQuery) async {
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('Getting AI nutrition suggestion (backend) for: $foodQuery');

      // PROACTIVE: Check internet connectivity before making API call
      final connectivityService = ConnectivityService();
      if (!connectivityService.isConnected) {
        debugPrint('No internet connection detected before text nutrition query');
        return _getBasicNutritionEstimate(foodQuery);
      }

      final headers = await TokenManager.getAuthHeaders();
      final url = '${ApiService.baseUrl}ai/nutrition-text';
      final resp = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({ 'query': foodQuery }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('REQUEST_TIMEOUT');
        },
      );

      if (resp.statusCode == 400) {
        // Handle non-edible item error
        Map<String, dynamic> errorData;
        try {
          errorData = json.decode(resp.body) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('Failed to parse 400 error response: $e');
          return _getBasicNutritionEstimate(foodQuery);
        }
        debugPrint('Non-edible item detected: ${errorData['message']}');
        return null; // Return null to indicate error
      }
      
      if (resp.statusCode == 401) {
        debugPrint('Backend error (401): Unauthorized - token may be expired');
        return _getBasicNutritionEstimate(foodQuery);
      }
      
      if (resp.statusCode == 502) {
        // Bad Gateway - AI service issue
        debugPrint('Backend error (502): AI service unavailable for text query');
        return _getBasicNutritionEstimate(foodQuery);
      }
      
      if (resp.statusCode == 500) {
        debugPrint('Backend error (500): Server error for text query');
        return _getBasicNutritionEstimate(foodQuery);
      }
      
      if (resp.statusCode != 200) {
        debugPrint('Backend AI error: ${resp.statusCode} ${resp.body}');
        return _getBasicNutritionEstimate(foodQuery);
      }

      // Parse successful response
      Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(resp.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Failed to parse AI text response JSON: $e');
        return _getBasicNutritionEstimate(foodQuery);
      }
      
      final nutritionData = NutritionData.fromJson(jsonData);
      debugPrint('AI nutrition data parsed successfully for: ${nutritionData.name}');
      return nutritionData;
    } catch (e) {
      debugPrint('Error getting AI nutrition suggestion: $e');

      // Provide specific fallback based on error type
      final errorString = e.toString();
      if (errorString.contains('REQUEST_TIMEOUT')) {
        debugPrint('Request timeout detected. Using fallback nutrition estimate.');
      } else if (errorString.contains('Failed host lookup') ||
          errorString.contains('SocketException') ||
          errorString.contains('No address associated with hostname') ||
          errorString.contains('Network is unreachable') ||
          errorString.contains('Connection refused') ||
          errorString.contains('Connection timed out')) {
        debugPrint('Network issue detected. Using fallback nutrition estimate.');
      } else if (errorString.contains('API_KEY') ||
          errorString.contains('403') ||
          errorString.contains('401')) {
        debugPrint('API key or authentication issue detected.');
      } else if (errorString.contains('FormatException') ||
          errorString.contains('type \'Null\' is not a subtype') ||
          errorString.contains('Unexpected character') ||
          errorString.contains('Invalid JSON')) {
        debugPrint('JSON parsing error detected. Using fallback nutrition estimate.');
      } else {
        debugPrint('Unknown error occurred: ${e.runtimeType}');
      }

      // Always return fallback data instead of null
      return _getBasicNutritionEstimate(foodQuery);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to provide basic nutrition estimates
  NutritionData _getBasicNutritionEstimate(String foodQuery) {
    debugPrint('Providing basic nutrition estimate for: $foodQuery');

    // Mark this as an estimate in the name
    final estimatedName = '$foodQuery (Estimated)';

    // Basic nutrition estimates based on common food types
    final query = foodQuery.toLowerCase();

    // Fruits
    if (query.contains('apple') ||
        query.contains('banana') ||
        query.contains('orange') ||
        query.contains('fruit') ||
        query.contains('berry')) {
      return NutritionData(
        name: estimatedName,
        calories: 60,
        protein: 0.5,
        fat: 0.2,
        carbs: 15.0,
        fiber: 3.0,
        sugar: 12.0,
        sodium: 1.0,
        weightGrams: 100,
      );
    }

    // Vegetables
    if (query.contains('vegetable') ||
        query.contains('carrot') ||
        query.contains('broccoli') ||
        query.contains('spinach') ||
        query.contains('lettuce') ||
        query.contains('tomato')) {
      return NutritionData(
        name: estimatedName,
        calories: 25,
        protein: 2.0,
        fat: 0.3,
        carbs: 5.0,
        fiber: 2.5,
        sugar: 3.0,
        sodium: 10.0,
        weightGrams: 100,
      );
    }

    // Meat/Protein
    if (query.contains('chicken') ||
        query.contains('beef') ||
        query.contains('pork') ||
        query.contains('fish') ||
        query.contains('meat') ||
        query.contains('protein')) {
      return NutritionData(
        name: estimatedName,
        calories: 200,
        protein: 25.0,
        fat: 10.0,
        carbs: 0.0,
        fiber: 0.0,
        sugar: 0.0,
        sodium: 50.0,
        weightGrams: 100,
      );
    }

    // Rice/Grains
    if (query.contains('rice') ||
        query.contains('pasta') ||
        query.contains('bread') ||
        query.contains('grain') ||
        query.contains('wheat') ||
        query.contains('quinoa')) {
      return NutritionData(
        name: estimatedName,
        calories: 130,
        protein: 4.0,
        fat: 1.0,
        carbs: 28.0,
        fiber: 1.5,
        sugar: 0.5,
        sodium: 2.0,
        weightGrams: 100,
      );
    }

    // Default fallback for unknown foods
    return NutritionData(
      name: estimatedName,
      calories: 120, // Average calories per 100g
      protein: 6.0,
      fat: 4.0,
      carbs: 15.0,
      fiber: 2.0,
      sugar: 5.0,
      sodium: 50.0,
      weightGrams: 100,
    );
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}
