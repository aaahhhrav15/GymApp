import 'package:flutter/material.dart';
import '../models/nutrition_models.dart';
import '../theme/app_theme.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final Function(Meal)? onEdit;
  final Function(Meal)? onDelete;
  final Function(Meal)? onDuplicate;

  const MealCard({
    super.key,
    required this.meal,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Color typeColor = _getMealTypeColor(meal.mealType, context);

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            blurRadius: screenWidth * 0.025,
            offset: Offset(0, screenWidth * 0.005),
          ),
        ],
      ),
      child: Row(
        children: [
          // Meal type indicator
          Container(
            width: screenWidth * 0.01,
            height: screenHeight * 0.06,
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(screenWidth * 0.005),
            ),
          ),
          SizedBox(width: screenWidth * 0.04),

          // Meal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.name,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Text(
                        _formatMealType(meal.mealType),
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.005),
                Row(
                  children: [
                    Text(
                      meal.time,
                      style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6)),
                    ),
                    if (meal.source == 'ai' || meal.source == 'image') ...[
                      SizedBox(width: screenWidth * 0.02),
                      Icon(
                        meal.source == 'image'
                            ? Icons.camera_alt
                            : Icons.auto_awesome,
                        size: screenWidth * 0.035,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Text(
                        'AI',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                Wrap(
                  spacing: screenWidth * 0.02,
                  children: [
                    _buildNutrientChip(
                      '${meal.calories} cal',
                      Theme.of(context).colorScheme.error,
                      screenWidth,
                      screenHeight,
                    ),
                    _buildNutrientChip(
                      'P: ${meal.protein.round()}g',
                      context.nutritionPrimary,
                      screenWidth,
                      screenHeight,
                    ),
                    _buildNutrientChip(
                      'F: ${meal.fat.round()}g',
                      Theme.of(context).colorScheme.primary,
                      screenWidth,
                      screenHeight,
                    ),
                    _buildNutrientChip(
                      'C: ${meal.carbs.round()}g',
                      Theme.of(context).colorScheme.secondary,
                      screenWidth,
                      screenHeight,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // More options
          GestureDetector(
            onTap: () => _showMealOptions(context),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: Icon(Icons.more_vert,
                  size: screenWidth * 0.04,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientChip(
      String text, Color color, double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.015, vertical: screenHeight * 0.004),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.015),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenWidth * 0.025,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getMealTypeColor(String type, BuildContext context) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return context.nutritionPrimary;
      case 'lunch':
        return Theme.of(context).colorScheme.secondary;
      case 'dinner':
        return Theme.of(context).colorScheme.primary;
      case 'snack':
        return Theme.of(context).colorScheme.tertiary;
      case 'ai_detected':
        return Theme.of(context).colorScheme.primary.withOpacity(0.8);
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }

  String _formatMealType(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snack';
      case 'ai_detected':
        return 'AI Scan';
      case 'custom':
        return 'Custom';
      default:
        return 'Meal';
    }
  }

  void _showMealOptions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.015),
              width: screenWidth * 0.1,
              height: screenWidth * 0.01,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(screenWidth * 0.005),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              meal.name,
              style: TextStyle(
                  fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.02),
            if (onEdit != null)
              ListTile(
                leading: Icon(Icons.edit, size: screenWidth * 0.06),
                title: Text('Edit Meal',
                    style: TextStyle(fontSize: screenWidth * 0.04)),
                onTap: () {
                  Navigator.pop(context);
                  onEdit!(meal);
                },
              ),
            if (onDuplicate != null)
              ListTile(
                leading: Icon(Icons.copy, size: screenWidth * 0.06),
                title: Text('Duplicate Meal',
                    style: TextStyle(fontSize: screenWidth * 0.04)),
                onTap: () {
                  Navigator.pop(context);
                  onDuplicate!(meal);
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                    size: screenWidth * 0.06),
                title: Text(
                  'Delete Meal',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: screenWidth * 0.04),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete!(meal);
                },
              ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}
