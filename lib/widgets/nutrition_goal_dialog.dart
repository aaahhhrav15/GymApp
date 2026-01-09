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
        TextEditingController(text: widget.currentGoals.protein.toInt().toString());
    _fatController =
        TextEditingController(text: widget.currentGoals.fat.toInt().toString());
    _carbsController =
        TextEditingController(text: widget.currentGoals.carbs.toInt().toString());
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
      final calories = int.parse(_caloriesController.text.trim());
      final protein = int.parse(_proteinController.text.trim());
      final fat = int.parse(_fatController.text.trim());
      final carbs = int.parse(_carbsController.text.trim());

      if (calories <= 0 || protein < 0 || fat < 0 || carbs < 0) {
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
      // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final nutritionColor = isDark ? const Color(0xFF66BB6A) : const Color(0xFF4CAF50);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
          maxWidth: screenWidth * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2E1D) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: nutritionColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.track_changes_rounded,
                      color: nutritionColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Daily Goals',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Set your daily nutrition targets',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calories
              _buildModernGoalField(
                label: 'Calories',
                controller: _caloriesController,
                suffix: 'kcal',
                icon: Icons.local_fire_department_rounded,
                color: Colors.orange,
                isDark: isDark,
                screenWidth: screenWidth,
              ),
              const SizedBox(height: 16),

              // Macros in a row
              Row(
                children: [
                  Expanded(
                    child: _buildModernGoalField(
                      label: 'Protein',
                      controller: _proteinController,
                      suffix: 'g',
                      icon: Icons.fitness_center_rounded,
                      color: const Color(0xFFE91E63),
                      isDark: isDark,
                      screenWidth: screenWidth,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildModernGoalField(
                      label: 'Fat',
                      controller: _fatController,
                      suffix: 'g',
                      icon: Icons.opacity_rounded,
                      color: const Color(0xFFFF9800),
                      isDark: isDark,
                      screenWidth: screenWidth,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildModernGoalField(
                      label: 'Carbs',
                      controller: _carbsController,
                      suffix: 'g',
                      icon: Icons.grain_rounded,
                      color: const Color(0xFF2196F3),
                      isDark: isDark,
                      screenWidth: screenWidth,
                      isCompact: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey[300]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveGoals,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: nutritionColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Goals',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernGoalField({
    required String label,
    required TextEditingController controller,
    required String suffix,
    required IconData icon,
    required Color color,
    required bool isDark,
    required double screenWidth,
    bool isCompact = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? 4 : 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: isCompact ? 14 : 16,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isCompact ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: isCompact ? 6 : 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: isCompact ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
              color: isDark ? Colors.white30 : Colors.black26,
              fontSize: isCompact ? 14 : 16,
            ),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: isCompact ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: color,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isCompact ? 10 : 16,
              vertical: isCompact ? 10 : 14,
            ),
            isDense: isCompact,
          ),
          scrollPadding: EdgeInsets.zero,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}
