import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/token_manager.dart';

class DietPlan {
  final String id;
  final String planName;
  final Map<String, dynamic> targets;
  final Map<String, dynamic> totals;
  final String createdDate;
  final String additionalNotes;
  final List<Meal> meals;

  DietPlan({
    required this.id,
    required this.planName,
    required this.targets,
    required this.totals,
    required this.createdDate,
    required this.additionalNotes,
    required this.meals,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    return DietPlan(
      id: json['_id'] ?? '',
      planName: json['plan_name'] ?? 'Default Plan',
      targets: json['targets'] ?? {},
      totals: json['totals'] ?? {},
      createdDate: json['created_date'] ?? '',
      additionalNotes: json['additional_notes'] ?? '',
      meals: (json['meals'] as List<dynamic>?)
              ?.map((meal) => Meal.fromJson(meal))
              .toList() ??
          [],
    );
  }
}

class Meal {
  final String mealType;
  final String time;
  final int calories;
  final List<FoodItem> items;

  Meal({
    required this.mealType,
    required this.time,
    required this.calories,
    required this.items,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      mealType: json['meal_type'] ?? '',
      time: json['time'] ?? '',
      calories: json['calories'] ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => FoodItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class FoodItem {
  final String foodName;
  final String quantity;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.foodName,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      foodName: json['food_name'] ?? '',
      quantity: json['quantity'] ?? '',
      calories: json['calories'] ?? 0,
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
    );
  }
}

class DietPlanProvider with ChangeNotifier {
  // Use environment variable for base URL
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://65.0.5.24/';

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasNutritionPlan = false;
  DietPlan? _dietPlan;
  String? _error;

  // Session cache
  static DietPlan? _sessionDietCache;
  static bool _sessionHasNutritionPlan = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasNutritionPlan => _hasNutritionPlan;
  DietPlan? get dietPlan => _dietPlan;
  String? get error => _error;

  Future<void> loadDietPlan() async {
    // Show cached data instantly if available
    if (_sessionDietCache != null) {
      _dietPlan = _sessionDietCache!;
      _hasNutritionPlan = _sessionHasNutritionPlan;
      _isLoading = false;
      notifyListeners();

      // Fetch new data in background
      await _refreshDietData();
    } else {
      // No cache, show loader and fetch
      await _refreshDietData();
    }
  }

  Future<void> refreshDietPlan() async {
    await _refreshDietData();
  }

  Future<void> _refreshDietData() async {
    if (_dietPlan != null) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }
    _error = null;
    notifyListeners();

    try {
      // Get authentication headers with JWT token
      final headers = await TokenManager.getAuthHeaders();

      final response = await http.get(
        Uri.parse('${baseUrl}nutrition/plan'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _dietPlan = DietPlan.fromJson(data);
        _hasNutritionPlan = true;
        _error = null;

        // Cache the data
        _sessionDietCache = _dietPlan;
        _sessionHasNutritionPlan = true;
      } else if (response.statusCode == 404) {
        // No plan found, use default
        _dietPlan = _getDefaultDietPlan();
        _hasNutritionPlan = false;
        _error = null;

        // Cache the default data
        _sessionDietCache = _dietPlan;
        _sessionHasNutritionPlan = false;
      } else {
        throw Exception('Failed to load diet plan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading diet plan: $e');
      _dietPlan = _getDefaultDietPlan();
      _hasNutritionPlan = false;
      _error = 'Failed to load diet plan';

      // Cache the default data
      _sessionDietCache = _dietPlan;
      _sessionHasNutritionPlan = false;
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  DietPlan _getDefaultDietPlan() {
    return DietPlan(
      id: 'default',
      planName: 'Default Nutrition Plan',
      targets: {
        'calories': 2800,
        'protein': 150,
        'carbs': 300,
        'fat': 100,
      },
      totals: {
        'calories': 2800,
        'protein': 150,
        'carbs': 300,
        'fat': 100,
      },
      createdDate: '2024-01-15',
      additionalNotes: 'This is a default nutrition plan. Please consult with your gym trainer for a personalized plan based on your specific goals and requirements.',
      meals: [
        Meal(
          mealType: 'Breakfast',
          time: '07:00 AM',
          calories: 650,
          items: [
            FoodItem(
              foodName: 'Oatmeal with Berries',
              quantity: '1 bowl',
              calories: 320,
              protein: 12,
              carbs: 58,
              fat: 6,
            ),
            FoodItem(
              foodName: 'Greek Yogurt',
              quantity: '1 cup',
              calories: 150,
              protein: 20,
              carbs: 8,
              fat: 4,
            ),
            FoodItem(
              foodName: 'Banana',
              quantity: '1 medium',
              calories: 105,
              protein: 1,
              carbs: 27,
              fat: 0,
            ),
            FoodItem(
              foodName: 'Almonds',
              quantity: '15 pieces',
              calories: 75,
              protein: 3,
              carbs: 3,
              fat: 7,
            ),
          ],
        ),
        Meal(
          mealType: 'Mid-Morning Snack',
          time: '10:00 AM',
          calories: 200,
          items: [
            FoodItem(
              foodName: 'Protein Shake',
              quantity: '1 scoop',
              calories: 120,
              protein: 25,
              carbs: 3,
              fat: 1,
            ),
            FoodItem(
              foodName: 'Apple',
              quantity: '1 medium',
              calories: 80,
              protein: 0,
              carbs: 21,
              fat: 0,
            ),
          ],
        ),
        Meal(
          mealType: 'Lunch',
          time: '01:00 PM',
          calories: 750,
          items: [
            FoodItem(
              foodName: 'Grilled Chicken Breast',
              quantity: '150g',
              calories: 230,
              protein: 43,
              carbs: 0,
              fat: 5,
            ),
            FoodItem(
              foodName: 'Brown Rice',
              quantity: '1 cup cooked',
              calories: 220,
              protein: 5,
              carbs: 45,
              fat: 2,
            ),
            FoodItem(
              foodName: 'Mixed Vegetables',
              quantity: '1 cup',
              calories: 50,
              protein: 2,
              carbs: 10,
              fat: 0,
            ),
            FoodItem(
              foodName: 'Avocado',
              quantity: '1/2 medium',
              calories: 160,
              protein: 2,
              carbs: 9,
              fat: 15,
            ),
            FoodItem(
              foodName: 'Olive Oil',
              quantity: '1 tbsp',
              calories: 90,
              protein: 0,
              carbs: 0,
              fat: 10,
            ),
          ],
        ),
        Meal(
          mealType: 'Evening Snack',
          time: '04:30 PM',
          calories: 300,
          items: [
            FoodItem(
              foodName: 'Whole Grain Toast',
              quantity: '2 slices',
              calories: 160,
              protein: 6,
              carbs: 30,
              fat: 2,
            ),
            FoodItem(
              foodName: 'Peanut Butter',
              quantity: '2 tbsp',
              calories: 140,
              protein: 8,
              carbs: 6,
              fat: 12,
            ),
          ],
        ),
        Meal(
          mealType: 'Dinner',
          time: '07:30 PM',
          calories: 700,
          items: [
            FoodItem(
              foodName: 'Salmon Fillet',
              quantity: '120g',
              calories: 250,
              protein: 35,
              carbs: 0,
              fat: 12,
            ),
            FoodItem(
              foodName: 'Sweet Potato',
              quantity: '1 medium',
              calories: 130,
              protein: 2,
              carbs: 30,
              fat: 0,
            ),
            FoodItem(
              foodName: 'Quinoa',
              quantity: '1/2 cup cooked',
              calories: 110,
              protein: 4,
              carbs: 20,
              fat: 2,
            ),
            FoodItem(
              foodName: 'Spinach Salad',
              quantity: '2 cups',
              calories: 30,
              protein: 4,
              carbs: 4,
              fat: 0,
            ),
            FoodItem(
              foodName: 'Walnuts',
              quantity: '10 halves',
              calories: 180,
              protein: 4,
              carbs: 4,
              fat: 18,
            ),
          ],
        ),
        Meal(
          mealType: 'Night Snack',
          time: '09:30 PM',
          calories: 200,
          items: [
            FoodItem(
              foodName: 'Casein Protein',
              quantity: '1 scoop',
              calories: 120,
              protein: 25,
              carbs: 3,
              fat: 1,
            ),
            FoodItem(
              foodName: 'Berries',
              quantity: '1/2 cup',
              calories: 40,
              protein: 1,
              carbs: 9,
              fat: 0,
            ),
            FoodItem(
              foodName: 'Cottage Cheese',
              quantity: '1/4 cup',
              calories: 40,
              protein: 7,
              carbs: 2,
              fat: 1,
            ),
          ],
        ),
      ],
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Fetch all nutrition plans for debugging/history
  Future<List<DietPlan>> getAllNutritionPlans() async {
    try {
      final headers = await TokenManager.getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/nutrition/plans'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((plan) => DietPlan.fromJson(plan)).toList();
      } else {
        throw Exception(
            'Failed to load nutrition plans: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading nutrition plans: $e');
      return [];
    }
  }

  void clearCache() {
    _sessionDietCache = null;
    _sessionHasNutritionPlan = false;
    _dietPlan = null;
    _hasNutritionPlan = false;
    notifyListeners();
  }
}
