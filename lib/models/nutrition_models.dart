// lib/models/nutrition_models.dart

class NutritionGoals {
  final int calories;
  final int protein;
  final int fat;
  final int carbs;

  NutritionGoals({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory NutritionGoals.fromJson(Map<String, dynamic> json) {
    return NutritionGoals(
      calories: json['calories'] ?? 2200,
      protein: json['protein'] ?? 110,
      fat: json['fat'] ?? 67,
      carbs: json['carbs'] ?? 185,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }

  NutritionGoals copyWith({
    int? calories,
    int? protein,
    int? fat,
    int? carbs,
  }) {
    return NutritionGoals(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
    );
  }
}

class Meal {
  final String? id;
  final String name;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
  final String mealType;
  final String time;
  final DateTime createdAt;
  final String source;

  Meal({
    this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.mealType,
    required this.time,
    required this.createdAt,
    this.source = 'manual',
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'] ?? '',
      calories: json['calories'] ?? 0,
      protein: double.tryParse(json['protein'].toString()) ?? 0.0,
      fat: double.tryParse(json['fat'].toString()) ?? 0.0,
      carbs: double.tryParse(json['carbs'].toString()) ?? 0.0,
      mealType: json['meal_type'] ?? 'custom',
      time: json['time'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      source: json['source'] ?? 'manual',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'meal_type': mealType,
      'time': time,
      'created_at': createdAt.toIso8601String(),
      'source': source,
    };
  }

  Meal copyWith({
    String? id,
    String? name,
    int? calories,
    double? protein,
    double? fat,
    double? carbs,
    String? mealType,
    String? time,
    DateTime? createdAt,
    String? source,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      mealType: mealType ?? this.mealType,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
    );
  }
}

class NutritionTotals {
  final int calories;
  final double protein;
  final double fat;
  final double carbs;

  NutritionTotals({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory NutritionTotals.fromJson(Map<String, dynamic> json) {
    return NutritionTotals(
      calories: json['calories'] ?? 0,
      protein: double.tryParse(json['protein'].toString()) ?? 0.0,
      fat: double.tryParse(json['fat'].toString()) ?? 0.0,
      carbs: double.tryParse(json['carbs'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }

  static NutritionTotals fromMeals(List<Meal> meals) {
    int totalCalories = 0;
    double totalProtein = 0.0;
    double totalFat = 0.0;
    double totalCarbs = 0.0;

    for (var meal in meals) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalFat += meal.fat;
      totalCarbs += meal.carbs;
    }

    return NutritionTotals(
      calories: totalCalories,
      protein: totalProtein,
      fat: totalFat,
      carbs: totalCarbs,
    );
  }
}

class NutritionData {
  final String name;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final int weightGrams;

  NutritionData({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.fiber,
    this.sugar,
    this.sodium,
    this.weightGrams = 100,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      name: json['name'] ?? '',
      calories: json['calories'] ?? 0,
      protein: double.tryParse(json['protein'].toString()) ?? 0.0,
      fat: double.tryParse(json['fat'].toString()) ?? 0.0,
      carbs: double.tryParse(json['carbs'].toString()) ?? 0.0,
      fiber: json['fiber'] != null
          ? double.tryParse(json['fiber'].toString())
          : null,
      sugar: json['sugar'] != null
          ? double.tryParse(json['sugar'].toString())
          : null,
      sodium: json['sodium'] != null
          ? double.tryParse(json['sodium'].toString())
          : null,
      weightGrams: json['weight_grams'] ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'weight_grams': weightGrams,
    };
  }

  // Scale nutrition values based on weight
  NutritionData scaleToWeight(int newWeightGrams) {
    if (weightGrams == 0) return this;

    final scale = newWeightGrams / weightGrams;

    return NutritionData(
      name: name,
      calories: (calories * scale).round(),
      protein: protein * scale,
      fat: fat * scale,
      carbs: carbs * scale,
      fiber: fiber != null ? fiber! * scale : null,
      sugar: sugar != null ? sugar! * scale : null,
      sodium: sodium != null ? sodium! * scale : null,
      weightGrams: newWeightGrams,
    );
  }
}

class FoodItem {
  final String? id;
  final String name;
  final int caloriesPer100g;
  final double proteinPer100g;
  final double fatPer100g;
  final double carbsPer100g;

  FoodItem({
    this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.fatPer100g,
    required this.carbsPer100g,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'] ?? '',
      caloriesPer100g: json['calories_per_100g'] ?? 0,
      proteinPer100g:
          double.tryParse(json['protein_per_100g'].toString()) ?? 0.0,
      fatPer100g: double.tryParse(json['fat_per_100g'].toString()) ?? 0.0,
      carbsPer100g: double.tryParse(json['carbs_per_100g'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories_per_100g': caloriesPer100g,
      'protein_per_100g': proteinPer100g,
      'fat_per_100g': fatPer100g,
      'carbs_per_100g': carbsPer100g,
    };
  }

  // Calculate nutrition for specific weight
  NutritionData nutritionForWeight(int weightGrams) {
    final scale = weightGrams / 100.0;

    return NutritionData(
      name: name,
      calories: (caloriesPer100g * scale).round(),
      protein: proteinPer100g * scale,
      fat: fatPer100g * scale,
      carbs: carbsPer100g * scale,
      weightGrams: weightGrams,
    );
  }
}

class DetectedFoodItem {
  final String name;
  final int estimatedWeight;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
  final int confidence;

  DetectedFoodItem({
    required this.name,
    required this.estimatedWeight,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.confidence,
  });

  factory DetectedFoodItem.fromJson(Map<String, dynamic> json) {
    return DetectedFoodItem(
      name: json['name'] ?? '',
      estimatedWeight: json['estimated_weight'] ?? 100,
      calories: json['calories'] ?? 0,
      protein: double.tryParse(json['protein'].toString()) ?? 0.0,
      fat: double.tryParse(json['fat'].toString()) ?? 0.0,
      carbs: double.tryParse(json['carbs'].toString()) ?? 0.0,
      confidence: json['confidence'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'estimated_weight': estimatedWeight,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'confidence': confidence,
    };
  }

  Meal toMeal() {
    return Meal(
      name: name,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      mealType: 'ai_detected',
      time: DateTime.now().toString(),
      createdAt: DateTime.now(),
      source: 'image',
    );
  }
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  custom,
  aiDetected;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
      case MealType.custom:
        return 'Custom';
      case MealType.aiDetected:
        return 'AI Detected';
    }
  }

  static MealType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snack':
        return MealType.snack;
      case 'ai_detected':
        return MealType.aiDetected;
      default:
        return MealType.custom;
    }
  }
}
