import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/nutrition_models.dart';

class NutritionGoalDialog extends StatefulWidget {
  final NutritionGoals currentGoals;
  final Function(NutritionGoals) onSave;

  const NutritionGoalDialog({
    super.key,
    required this.currentGoals,
    required this.onSave,
  });

  @override
  State<NutritionGoalDialog> createState() => _NutritionGoalDialogState();
}

class _NutritionGoalDialogState extends State<NutritionGoalDialog> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;

  @override
  void initState() {
    super.initState();
    _caloriesController =
        TextEditingController(text: widget.currentGoals.calories.toString());
    _proteinController =
        TextEditingController(text: widget.currentGoals.protein.toString());
    _fatController =
        TextEditingController(text: widget.currentGoals.fat.toString());
    _carbsController =
        TextEditingController(text: widget.currentGoals.carbs.toString());
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  void _saveGoals() {
    try {
      final calories = int.parse(_caloriesController.text);
      final protein = int.parse(_proteinController.text);
      final fat = int.parse(_fatController.text);
      final carbs = int.parse(_carbsController.text);

      if (calories <= 0 || protein < 0 || fat < 0 || carbs < 0) {
        // Snackbar removed - no longer showing error messages
        return;
      }

      final newGoals = NutritionGoals(
        calories: calories,
        protein: protein,
        fat: fat,
        carbs: carbs,
      );

      widget.onSave(newGoals);
      Navigator.of(context).pop();
    } catch (e) {
      // Snackbar removed - no longer showing error messages
    }
  }

  void _showErrorSnackBar(String message) {
    // Snackbars removed - no longer showing error messages
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive sizing
    final dialogPadding = screenWidth * 0.05; // 5% of screen width
    final borderRadius = screenWidth * 0.05; // 5% of screen width
    final iconSize = screenWidth * 0.05; // 5% of screen width
    final headerFontSize = screenWidth * 0.045; // 4.5% of screen width
    final bodyFontSize = screenWidth * 0.035; // 3.5% of screen width
    final smallFontSize = screenWidth * 0.03; // 3% of screen width
    final spacingSmall = screenHeight * 0.015; // 1.5% of screen height
    final spacingMedium = screenHeight * 0.025; // 2.5% of screen height
    final spacingLarge = screenHeight * 0.03; // 3% of screen height
    final buttonHeight = screenHeight * 0.06; // 6% of screen height

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        padding: EdgeInsets.all(dialogPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(screenWidth * 0.025),
                  ),
                  child: Icon(
                    Icons.track_changes,
                    color: Colors.green[600],
                    size: iconSize,
                  ),
                ),
                SizedBox(width: spacingSmall),
                Expanded(
                  child: Text(
                    'Set Daily Goals',
                    style: TextStyle(
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close,
                      color: Colors.grey[600], size: iconSize),
                ),
              ],
            ),

            SizedBox(height: spacingMedium),

            Text(
              'Set your daily nutrition targets:',
              style: TextStyle(
                fontSize: bodyFontSize,
                color: Colors.black54,
              ),
            ),

            SizedBox(height: spacingMedium),

            // Calories
            _buildGoalField(
              label: 'Calories',
              controller: _caloriesController,
              suffix: 'kcal',
              icon: Icons.local_fire_department,
              color: Colors.orange,
              context: context,
            ),

            SizedBox(height: spacingSmall),

            // Protein
            _buildGoalField(
              label: 'Protein',
              controller: _proteinController,
              suffix: 'g',
              icon: Icons.fitness_center,
              color: Colors.blue,
              context: context,
            ),

            SizedBox(height: spacingSmall),

            // Fat
            _buildGoalField(
              label: 'Fat',
              controller: _fatController,
              suffix: 'g',
              icon: Icons.opacity,
              color: Colors.amber,
              context: context,
            ),

            SizedBox(height: spacingSmall),

            // Carbs
            _buildGoalField(
              label: 'Carbohydrates',
              controller: _carbsController,
              suffix: 'g',
              icon: Icons.grain,
              color: Colors.green,
              context: context,
            ),

            SizedBox(height: spacingLarge),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: buttonHeight * 0.2),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: bodyFontSize,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spacingSmall),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveGoals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: buttonHeight * 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                    ),
                    child: Text(
                      'Save Goals',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: bodyFontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalField({
    required String label,
    required TextEditingController controller,
    required String suffix,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive sizing for field
    final iconSize = screenWidth * 0.04; // 4% of screen width
    final labelFontSize = screenWidth * 0.03; // 3% of screen width
    final inputFontSize = screenWidth * 0.035; // 3.5% of screen width
    final spacingSmall = screenWidth * 0.03; // 3% of screen width
    final spacingTiny = screenHeight * 0.005; // 0.5% of screen height
    final borderRadius = screenWidth * 0.02; // 2% of screen width
    final containerPadding = screenWidth * 0.02; // 2% of screen width
    final inputPadding = screenWidth * 0.03; // 3% of screen width

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            icon,
            color: color,
            size: iconSize,
          ),
        ),
        SizedBox(width: spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: spacingTiny),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(fontSize: inputFontSize),
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: suffix,
                  suffixStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: labelFontSize,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: inputPadding,
                    vertical: inputPadding * 0.67,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
