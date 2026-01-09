// lib/components/add_food_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/nutrition_models.dart';
import '../providers/nutrition_provider.dart';

// Utility functions
String _getMealTypeByTime() {
  final hour = DateTime.now().hour;
  if (hour < 11) return 'breakfast';
  if (hour < 15) return 'lunch';
  if (hour < 19) return 'dinner';
  return 'snack';
}

bool _validateNutritionValues(
    int calories, double protein, double fat, double carbs) {
  return calories > 0 && protein >= 0 && fat >= 0 && carbs >= 0;
}

class AddFoodDrawer extends StatefulWidget {
  final Animation<double> animation;
  final VoidCallback onClose;
  final Function({
    required String name,
    required int calories,
    required double protein,
    required double fat,
    required double carbs,
    String mealType,
    String source,
    List<DetectedFoodItemBreakdown>? breakdown,
  }) onAddFood;
  final bool isLoading;
  final BuildContext? parentContext; // Parent context for showing dialogs

  const AddFoodDrawer({
    super.key,
    required this.animation,
    required this.onClose,
    required this.onAddFood,
    this.isLoading = false,
    this.parentContext,
  });

  @override
  State<AddFoodDrawer> createState() => _AddFoodDrawerState();
}

class _AddFoodDrawerState extends State<AddFoodDrawer> {
  int _selectedSlider = 0; // 0 for AI, 1 for Custom
  bool _isAnalyzing = false;

  // Form controllers for AI mode
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _weightController =
      TextEditingController(text: '100');

  // Form controllers for Custom mode
  final TextEditingController _customFoodNameController =
      TextEditingController();
  final TextEditingController _customCaloriesController =
      TextEditingController();
  final TextEditingController _customProteinController =
      TextEditingController();
  final TextEditingController _customFatController = TextEditingController();
  final TextEditingController _customCarbsController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _foodNameController.dispose();
    _weightController.dispose();
    _customFoodNameController.dispose();
    _customCaloriesController.dispose();
    _customProteinController.dispose();
    _customFatController.dispose();
    _customCarbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Drawer content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0) {
                    // Note: In real implementation, you'd need access to the AnimationController
                  }
                },
                child: Transform.translate(
                  offset: Offset(
                      0, (1 - widget.animation.value) * screenHeight * 0.6),
                  child: Container(
                    height: screenHeight * 0.6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(screenWidth * 0.06),
                        topRight: Radius.circular(screenWidth * 0.06),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withOpacity(0.26),
                          blurRadius: screenWidth * 0.05,
                          offset: Offset(0, -screenWidth * 0.01),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handle
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015),
                          child: Center(
                            child: Container(
                              width: screenWidth * 0.1,
                              height: screenWidth * 0.01,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.3),
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.005),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.01),

                        // Title with close button
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06),
                          child: Row(
                            children: [
                              Text(
                                'Add Food',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: widget.onClose,
                                child: Container(
                                  padding: EdgeInsets.all(screenWidth * 0.015),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainer,
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.03),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: screenWidth * 0.045,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.025),

                        // Slider selector
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06),
                          padding: EdgeInsets.all(screenWidth * 0.01),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.03),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedSlider = 0),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.015),
                                    decoration: BoxDecoration(
                                      color: _selectedSlider == 0
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                          : Theme.of(context)
                                              .colorScheme
                                              .surface
                                              .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02),
                                      border: Border.all(
                                        color: _selectedSlider == 0
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.3)
                                            : Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withOpacity(0.2),
                                        width: 1,
                                      ),
                                      boxShadow: _selectedSlider == 0
                                          ? [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.1),
                                                blurRadius: screenWidth * 0.01,
                                                offset: Offset(
                                                    0, screenWidth * 0.005),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'AI',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedSlider == 0
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedSlider = 1),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.015),
                                    decoration: BoxDecoration(
                                      color: _selectedSlider == 1
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer
                                          : Theme.of(context)
                                              .colorScheme
                                              .surface
                                              .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02),
                                      border: Border.all(
                                        color: _selectedSlider == 1
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.3)
                                            : Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withOpacity(0.2),
                                        width: 1,
                                      ),
                                      boxShadow: _selectedSlider == 1
                                          ? [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.1),
                                                blurRadius: screenWidth * 0.01,
                                                offset: Offset(
                                                    0, screenWidth * 0.005),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Custom',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedSlider == 1
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.025),

                        // Content based on selected slider
                        Expanded(
                          child: _selectedSlider == 0
                              ? _buildAIContent()
                              : _buildCustomContent(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAIContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        children: [
          // AI Options
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _isAnalyzing ? null : _showFoodNameInput,
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.025),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          child: Icon(
                            Icons.edit_note,
                            color: Colors.white,
                            size: screenWidth * 0.08,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Text(
                          'Enter Food Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          'Get nutrition values',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: GestureDetector(
                  onTap: _isAnalyzing ? null : _takeFoodImage,
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.025),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: screenWidth * 0.08,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Text(
                          'Take Image',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          'AI will analyze',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_isAnalyzing) ...[
            SizedBox(height: screenHeight * 0.03),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Analyzing food...',
                    style: TextStyle(
                      fontSize: screenWidth * 0.042,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Text(
                    'AI is getting nutrition information',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: screenHeight * 0.03),
        ],
      ),
    );
  }

  Widget _buildCustomContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Food Name
                  _buildCustomInputField(
                    'Food Name',
                    _customFoodNameController,
                    'e.g., Grilled Chicken',
                    icon: Icons.restaurant,
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Calories
                  _buildCustomInputField(
                    'Calories (kcal)',
                    _customCaloriesController,
                    'e.g., 250',
                    keyboardType: TextInputType.number,
                    icon: Icons.local_fire_department,
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Protein, Fat, Carbs in a row
                  Row(
                    children: [
                      Expanded(
                        child: _buildCustomInputField(
                          'Protein (g)',
                          _customProteinController,
                          '0',
                          keyboardType: TextInputType.number,
                          icon: Icons.fitness_center,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: _buildCustomInputField(
                          'Fat (g)',
                          _customFatController,
                          '0',
                          keyboardType: TextInputType.number,
                          icon: Icons.water_drop,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: _buildCustomInputField(
                          'Carbs (g)',
                          _customCarbsController,
                          '0',
                          keyboardType: TextInputType.number,
                          icon: Icons.energy_savings_leaf,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Add button
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.06,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _addCustomFood,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 4,
                shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: screenWidth * 0.05,
                      height: screenWidth * 0.05,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: screenWidth * 0.05,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'Add Food',
                          style: TextStyle(
                            fontSize: screenWidth * 0.042,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          SizedBox(height: screenHeight * 0.025),
        ],
      ),
    );
  }

  Widget _buildCustomInputField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine icon color based on label
    Color iconColor = Theme.of(context).colorScheme.primary;
    if (label.contains('Calories') || label.contains('kcal')) {
      iconColor = Colors.orange;
    } else if (label.contains('Protein')) {
      iconColor = Colors.blue;
    } else if (label.contains('Fat')) {
      iconColor = Colors.purple;
    } else if (label.contains('Carbs')) {
      iconColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: EdgeInsets.all(screenWidth * 0.015),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: screenWidth * 0.04,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.012),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              fontSize: screenWidth * 0.038,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: iconColor.withOpacity(0.6),
                    size: screenWidth * 0.05,
                  )
                : null,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              borderSide: BorderSide(
                color: iconColor,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.018,
            ),
          ),
        ),
      ],
    );
  }

  void _showFoodNameInput() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.06),
                    topRight: Radius.circular(screenWidth * 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.025),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Icon(
                        Icons.edit_note,
                        color: Colors.white,
                        size: screenWidth * 0.06,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Text(
                        'Enter Food Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.048,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: screenWidth * 0.05,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Food Name Field
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      child: TextField(
                        controller: _foodNameController,
                        style: TextStyle(fontSize: screenWidth * 0.04),
                        decoration: InputDecoration(
                          labelText: 'Food Name',
                          labelStyle: TextStyle(
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          hintText: 'e.g., Apple, Chicken Breast',
                          hintStyle: TextStyle(
                            fontSize: screenWidth * 0.038,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.restaurant,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.02,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    
                    // Weight Field
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: screenWidth * 0.04),
                        decoration: InputDecoration(
                          labelText: 'Weight (grams)',
                          labelStyle: TextStyle(
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          hintText: 'e.g., 100',
                          hintStyle: TextStyle(
                            fontSize: screenWidth * 0.038,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.scale,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.02,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(screenWidth * 0.06),
                    bottomRight: Radius.circular(screenWidth * 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _getAINutrition();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                          elevation: 4,
                          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              'Get Nutrition',
                              style: TextStyle(
                                fontSize: screenWidth * 0.042,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getAINutrition() async {
    if (_foodNameController.text.trim().isEmpty) {
      // Snackbar removed - no longer showing error messages
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final foodName = _foodNameController.text.trim();
      final weight = int.tryParse(_weightController.text) ?? 100;

      // Use the AI functionality from NutritionProvider
      final nutritionProvider = context.read<NutritionProvider>();
      final nutritionData =
          await nutritionProvider.getAINutritionSuggestion(foodName);

      if (nutritionData != null) {
        // Calculate nutrition based on the specified weight
        final weightMultiplier =
            weight / 100.0; // Convert to per specified weight

        final totalCalories =
            (nutritionData.calories * weightMultiplier).round();
        final totalProtein = nutritionData.protein * weightMultiplier;
        final totalFat = nutritionData.fat * weightMultiplier;
        final totalCarbs = nutritionData.carbs * weightMultiplier;

        // Check if we can show results (either widget is mounted or we have parentContext)
        final canShowResults = mounted || widget.parentContext != null;
        if (!canShowResults) {
          debugPrint('Widget disposed during analysis and no parent context, cannot show results');
          return;
        }

        // Show confirmation dialog with nutrition details
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final canShow = mounted || widget.parentContext != null;
          if (!canShow) {
            debugPrint('Cannot show nutrition confirmation - widget not mounted and no parent context');
            return;
          }
          
          _showNutritionConfirmationDialog(
            foodName: foodName,
            weight: weight,
            calories: totalCalories,
            protein: totalProtein,
            fat: totalFat,
            carbs: totalCarbs,
            nutritionData: nutritionData,
          );
        });
      } else {
        // Handle non-edible item or other error
        // Snackbar removed - no longer showing error messages
      }
    } catch (e) {
      // Snackbar removed - no longer showing error messages
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _takeFoodImage() async {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.015),
              width: screenWidth * 0.1,
              height: screenWidth * 0.01,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(screenWidth * 0.005),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.025),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan Food',
                          style: TextStyle(
                            fontSize: screenWidth * 0.048,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Text(
                          'AI will analyze your food image',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Options
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                children: [
                  // Camera Option
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _captureFromCamera();
                    },
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(screenWidth * 0.025),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: screenWidth * 0.06,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Take Photo',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.01),
                                Text(
                                  'Capture food with camera',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).colorScheme.primary,
                            size: screenWidth * 0.04,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenWidth * 0.04),
                  
                  // Gallery Option
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromGallery();
                    },
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.secondaryContainer,
                            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(screenWidth * 0.025),
                            ),
                            child: Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: screenWidth * 0.06,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Choose from Gallery',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.01),
                                Text(
                                  'Select from photo library',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).colorScheme.secondary,
                            size: screenWidth * 0.04,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }

  Future<void> _captureFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 40,
      );

      if (image != null) {
        await _analyzeImage(image);
      }
    } catch (e) {
      // Snackbar removed - no longer showing error messages
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
      );

      if (image != null) {
        await _analyzeImage(image);
      }
    } catch (e) {
      // Snackbar removed - no longer showing error messages
    }
  }

  Future<void> _analyzeImage(XFile image) async {
    if (!mounted) return;
    
    setState(() => _isAnalyzing = true);

    try {
      // Use the AI functionality from NutritionProvider
      final nutritionProvider = context.read<NutritionProvider>();
      debugPrint('Starting image analysis for: ${image.path}');
      final detectedFoodResponse =
          await nutritionProvider.analyzeImageForNutrition(image.path);

      // Check if we can show results (either widget is mounted or we have parentContext)
      final canShowResults = mounted || widget.parentContext != null;
      if (!canShowResults) {
        debugPrint('Widget disposed during analysis and no parent context, cannot show results');
        return;
      }

      debugPrint('Image analysis completed. Response: ${detectedFoodResponse != null ? "not null" : "null"}');
      if (detectedFoodResponse != null) {
        debugPrint('Detected food: ${detectedFoodResponse.mainItem.name}, Confidence: ${detectedFoodResponse.mainItem.confidence}');
        
        // Use post-frame callback to ensure context is valid when showing dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Check again if we can show results (either widget is mounted or we have parentContext)
          final canShow = mounted || widget.parentContext != null;
          if (!canShow) {
            debugPrint('Cannot show results - widget not mounted and no parent context');
            return;
          }
          
          if (detectedFoodResponse.mainItem.confidence < 60) {
            // Show warning for low confidence results
            debugPrint('Low confidence detected, showing warning dialog');
            _showLowConfidenceDialog(detectedFoodResponse);
          } else {
            debugPrint('Showing AI results dialog');
            _showAIResults(detectedFoodResponse);
          }
        });
      } else {
        debugPrint('No food detected in image');
        // Snackbar removed - no longer showing error messages
      }
    } catch (e) {
      // Handle specific error types with user-friendly messages
      final errorString = e.toString();
      String errorMessage;
      
      if (errorString.contains('IMAGE_TOO_CLOSE')) {
        final message = errorString.split('IMAGE_TOO_CLOSE:').length > 1
            ? errorString.split('IMAGE_TOO_CLOSE:')[1].trim()
            : 'Analysis failed. Please place your mobile phone at least 20cm away from the food and try again.';
        errorMessage = message;
      } else if (errorString.contains('IMAGE_FILE_NOT_FOUND') || 
                 errorString.contains('IMAGE_READ_ERROR') ||
                 errorString.contains('IMAGE_EMPTY')) {
        final message = errorString.split(':').length > 1
            ? errorString.split(':').sublist(1).join(':').trim()
            : 'Unable to access the selected image. Please try selecting the image again.';
        errorMessage = message;
      } else if (errorString.contains('AI_SERVICE_ERROR')) {
        final message = errorString.split('AI_SERVICE_ERROR:').length > 1
            ? errorString.split('AI_SERVICE_ERROR:')[1].trim()
            : 'AI service is temporarily unavailable. Please try again in a moment.';
        errorMessage = message;
      } else if (errorString.contains('AI_RESPONSE_PARSE_ERROR')) {
        final message = errorString.split('AI_RESPONSE_PARSE_ERROR:').length > 1
            ? errorString.split('AI_RESPONSE_PARSE_ERROR:')[1].trim()
            : 'Unable to process the AI response. Please try again.';
        errorMessage = message;
      } else if (errorString.contains('NO_INTERNET_CONNECTION')) {
        errorMessage = 'No internet connection. Please check your network and try again.';
      } else if (errorString.contains('REQUEST_TIMEOUT')) {
        errorMessage = 'Request timed out. Please check your internet connection and try again.';
      } else if (errorString.contains('NON_EDIBLE_ITEM')) {
        final message = errorString.split('NON_EDIBLE_ITEM:').length > 1
            ? errorString.split('NON_EDIBLE_ITEM:')[1].trim()
            : 'The image does not contain edible food items. Please take a photo of food.';
        errorMessage = message;
      } else if (errorString.contains('UNAUTHORIZED')) {
        errorMessage = 'Authentication failed. Please login again.';
      } else if (errorString.contains('SERVER_ERROR')) {
        errorMessage = 'Server error. Please try again later.';
      } else if (errorString.contains('BACKEND_ERROR')) {
        final statusCode = errorString.split('BACKEND_ERROR:').length > 1
            ? errorString.split('BACKEND_ERROR:')[1].trim()
            : 'unknown';
        errorMessage = 'Service error ($statusCode). Please try again later.';
      } else if (errorString.contains('API_KEY_ERROR')) {
        errorMessage = 'Service configuration error. Please contact support.';
      } else if (errorString.contains('ANALYSIS_FAILED')) {
        final message = errorString.split('ANALYSIS_FAILED:').length > 1
            ? errorString.split('ANALYSIS_FAILED:')[1].trim()
            : 'Unable to analyze the image. Please ensure you have a stable internet connection and try again with a clear photo of food.';
        errorMessage = message;
      } else {
        errorMessage = 'Unable to analyze the image. Please check your internet connection or try again.';
      }
      
      debugPrint('Error during image analysis: $errorMessage');
      // Snackbar removed - no longer showing error messages
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        debugPrint('Loading state cleared');
      }
    }
  }

  void _showAIResults(DetectedFoodItemsResponse response) {
    // Use parent context if available, otherwise use widget context
    final dialogContext = widget.parentContext ?? context;
    
    // If widget is not mounted, we must have parentContext to show dialog
    if (!mounted && widget.parentContext == null) {
      debugPrint('Cannot show AI results - widget not mounted and no parent context');
      return;
    }
    
    // Ensure the context is still valid
    try {
      MediaQuery.of(dialogContext);
    } catch (e) {
      debugPrint('Cannot show AI results - context is invalid: $e');
      return;
    }
    
    final mainItem = response.mainItem;
    final screenWidth = MediaQuery.of(dialogContext).size.width;
    final screenHeight = MediaQuery.of(dialogContext).size.height;

    showDialog(
      context: dialogContext,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.75,
            maxWidth: screenWidth * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.06),
                    topRight: Radius.circular(screenWidth * 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.025),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: screenWidth * 0.06,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Analysis Results',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.048,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.025,
                              vertical: screenWidth * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            ),
                            child: Text(
                              '${mainItem.confidence}% Confidence',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.032,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: screenWidth * 0.05,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Item Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                  ),
                                  child: Icon(
                                    Icons.restaurant,
                                    color: Colors.white,
                                    size: screenWidth * 0.05,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Expanded(
                                  child: Text(
                                    mainItem.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.045,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenWidth * 0.04),
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildNutritionBadge(
                                      'Weight',
                                      '${mainItem.estimatedWeight}g',
                                      Icons.scale,
                                      Theme.of(context).colorScheme.secondary,
                                      screenWidth,
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenWidth * 0.03),
                            // Nutrition Grid
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNutritionBadge(
                                    'Calories',
                                    '${mainItem.calories}',
                                    Icons.local_fire_department,
                                    Colors.orange,
                                    screenWidth,
                                    context,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: _buildNutritionBadge(
                                    'Protein',
                                    '${mainItem.protein.toStringAsFixed(1)}g',
                                    Icons.fitness_center,
                                    Colors.blue,
                                    screenWidth,
                                    context,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenWidth * 0.02),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNutritionBadge(
                                    'Fat',
                                    '${mainItem.fat.toStringAsFixed(1)}g',
                                    Icons.water_drop,
                                    Colors.purple,
                                    screenWidth,
                                    context,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: _buildNutritionBadge(
                                    'Carbs',
                                    '${mainItem.carbs.toStringAsFixed(1)}g',
                                    Icons.energy_savings_leaf,
                                    Colors.green,
                                    screenWidth,
                                    context,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Individual Items Breakdown (if multiple items)
                      if (response.hasMultipleItems) ...[
                        SizedBox(height: screenWidth * 0.05),
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: screenWidth * 0.05,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Text(
                              'Item Breakdown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.042,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        ...(response.items!.map((item) => _buildDetectedFoodItemBreakdown(item, screenWidth, dialogContext))),
                      ],
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(screenWidth * 0.06),
                    bottomRight: Radius.circular(screenWidth * 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _addDetectedFoods(response);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(dialogContext).colorScheme.primary,
                          foregroundColor: Theme.of(dialogContext).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                          elevation: 4,
                          shadowColor: Theme.of(dialogContext).colorScheme.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              'Add to Meals',
                              style: TextStyle(
                                fontSize: screenWidth * 0.042,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionBadge(String label, String value, IconData icon, Color color, double screenWidth, BuildContext badgeContext) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenWidth * 0.045),
          SizedBox(height: screenWidth * 0.01),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: screenWidth * 0.005),
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.028,
              color: Theme.of(badgeContext).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedFoodItemBreakdown(DetectedFoodItemBreakdown item, double screenWidth, BuildContext dialogContext) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Theme.of(dialogContext).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: Theme.of(dialogContext).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(dialogContext).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Icon(
                  Icons.fastfood,
                  color: Theme.of(dialogContext).colorScheme.onSecondaryContainer,
                  size: screenWidth * 0.04,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                    color: Theme.of(dialogContext).colorScheme.onSurface,
                  ),
                ),
              ),
              if (item.quantityDescription.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.025,
                    vertical: screenWidth * 0.015,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(dialogContext).colorScheme.secondaryContainer,
                        Theme.of(dialogContext).colorScheme.secondaryContainer.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Text(
                    item.quantityDescription,
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      color: Theme.of(dialogContext).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          Container(
            padding: EdgeInsets.all(screenWidth * 0.025),
            decoration: BoxDecoration(
              color: Theme.of(dialogContext).colorScheme.surface,
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniBadge(
                  '${item.estimatedWeight}g',
                  Icons.scale,
                  Theme.of(dialogContext).colorScheme.secondary,
                  screenWidth,
                ),
                _buildMiniBadge(
                  '${item.calories}',
                  Icons.local_fire_department,
                  Colors.orange,
                  screenWidth,
                ),
                _buildMiniBadge(
                  '${item.protein.toStringAsFixed(1)}g',
                  Icons.fitness_center,
                  Colors.blue,
                  screenWidth,
                ),
                _buildMiniBadge(
                  '${item.fat.toStringAsFixed(1)}g',
                  Icons.water_drop,
                  Colors.purple,
                  screenWidth,
                ),
                _buildMiniBadge(
                  '${item.carbs.toStringAsFixed(1)}g',
                  Icons.energy_savings_leaf,
                  Colors.green,
                  screenWidth,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String value, IconData icon, Color color, double screenWidth) {
    return Column(
      children: [
        Icon(icon, color: color, size: screenWidth * 0.035),
        SizedBox(height: screenWidth * 0.008),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.028,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80)
      return Colors.green; // Keep standard colors for confidence
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  Future<void> _addDetectedFoods(DetectedFoodItemsResponse response) async {
    // Use the main item for adding to meals (it contains the combined totals)
    final mainItem = response.mainItem;
    
    debugPrint('Adding detected food to meals: ${mainItem.name}');
    debugPrint('Nutrition: ${mainItem.calories} cal, P: ${mainItem.protein}g, F: ${mainItem.fat}g, C: ${mainItem.carbs}g');
    debugPrint('Breakdown items: ${response.items?.length ?? 0}');

    // Use post-frame callback to ensure widget is still valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        debugPrint('Executing onAddFood callback for image scan');
        widget.onAddFood(
          name: mainItem.name,
          calories: mainItem.calories,
          protein: mainItem.protein,
          fat: mainItem.fat,
          carbs: mainItem.carbs,
          mealType: _getMealTypeByTime(),
          source: 'image',
          breakdown: response.items, // Pass breakdown items if available
        );
        debugPrint('Food added successfully from image scan');
      } catch (e) {
        debugPrint('Error adding food from image scan: $e');
        debugPrint('Error stack trace: ${StackTrace.current}');
      }
    });
  }

  void _showNutritionConfirmationDialog({
    required String foodName,
    required int weight,
    required int calories,
    required double protein,
    required double fat,
    required double carbs,
    required NutritionData nutritionData,
  }) {
    // Use parent context if available, otherwise use widget context
    final dialogContext = widget.parentContext ?? context;
    
    // If widget is not mounted, we must have parentContext to show dialog
    if (!mounted && widget.parentContext == null) {
      debugPrint('Cannot show nutrition confirmation - widget not mounted and no parent context');
      return;
    }
    
    // Ensure the context is still valid
    try {
      MediaQuery.of(dialogContext);
    } catch (e) {
      debugPrint('Cannot show nutrition confirmation - context is invalid: $e');
      return;
    }
    
    final screenWidth = MediaQuery.of(dialogContext).size.width;
    final screenHeight = MediaQuery.of(dialogContext).size.height;

    showDialog(
      context: dialogContext,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.7,
            maxWidth: screenWidth * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.06),
                    topRight: Radius.circular(screenWidth * 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.025),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: screenWidth * 0.06,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Text(
                        'Nutrition Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.048,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: screenWidth * 0.05,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Name Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                  ),
                                  child: Icon(
                                    Icons.restaurant,
                                    color: Colors.white,
                                    size: screenWidth * 0.05,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        foodName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.045,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      SizedBox(height: screenWidth * 0.01),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.025,
                                          vertical: screenWidth * 0.01,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                        ),
                                        child: Text(
                                          'Weight: ${weight}g',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.032,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenWidth * 0.04),
                            // Nutrition Grid
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNutritionBadge(
                                    'Calories',
                                    '$calories',
                                    Icons.local_fire_department,
                                    Colors.orange,
                                    screenWidth,
                                    context,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: _buildNutritionBadge(
                                    'Protein',
                                    '${protein.toStringAsFixed(1)}g',
                                    Icons.fitness_center,
                                    Colors.blue,
                                    screenWidth,
                                    context,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenWidth * 0.02),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNutritionBadge(
                                    'Fat',
                                    '${fat.toStringAsFixed(1)}g',
                                    Icons.water_drop,
                                    Colors.purple,
                                    screenWidth,
                                    context,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: _buildNutritionBadge(
                                    'Carbs',
                                    '${carbs.toStringAsFixed(1)}g',
                                    Icons.energy_savings_leaf,
                                    Colors.green,
                                    screenWidth,
                                    context,
                                  ),
                                ),
                              ],
                            ),
                            if (nutritionData.fiber != null) ...[
                              SizedBox(height: screenWidth * 0.02),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNutritionBadge(
                                      'Fiber',
                                      '${(nutritionData.fiber! * (weight / 100.0)).toStringAsFixed(1)}g',
                                      Icons.eco,
                                      Colors.teal,
                                      screenWidth,
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(screenWidth * 0.06),
                    bottomRight: Radius.circular(screenWidth * 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          // Use post-frame callback to ensure widget is still valid
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            debugPrint('Adding food from text input: $foodName (${weight}g)');
                            try {
                              widget.onAddFood(
                                name: '$foodName (${weight}g)',
                                calories: calories,
                                protein: protein,
                                fat: fat,
                                carbs: carbs,
                                mealType: _getMealTypeByTime(),
                                source: 'ai_nutrition',
                                breakdown: null, // Text input doesn't have breakdown
                              );
                              debugPrint('Food callback executed successfully');
                            } catch (e) {
                              debugPrint('Error in onAddFood callback: $e');
                            }
                            // Clear the form and close drawer
                            if (mounted) {
                              _foodNameController.clear();
                              _weightController.text = '100';
                              widget.onClose();
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(dialogContext).colorScheme.primary,
                          foregroundColor: Theme.of(dialogContext).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                          elevation: 4,
                          shadowColor: Theme.of(dialogContext).colorScheme.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              'Add to Meals',
                              style: TextStyle(
                                fontSize: screenWidth * 0.042,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addCustomFood() {
    if (_customFoodNameController.text.trim().isEmpty) {
      // Snackbar removed - no longer showing error messages
      return;
    }

    final calories = int.tryParse(_customCaloriesController.text) ?? 0;
    final protein = double.tryParse(_customProteinController.text) ?? 0.0;
    final fat = double.tryParse(_customFatController.text) ?? 0.0;
    final carbs = double.tryParse(_customCarbsController.text) ?? 0.0;

    if (!_validateNutritionValues(calories, protein, fat, carbs)) {
      // Snackbar removed - no longer showing error messages
      return;
    }

    widget.onAddFood(
      name: _customFoodNameController.text.trim(),
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      mealType: _getMealTypeByTime(),
      source: 'manual',
    );

    _clearCustomForm();
  }

  void _clearCustomForm() {
    _customFoodNameController.clear();
    _customCaloriesController.clear();
    _customProteinController.clear();
    _customFatController.clear();
    _customCarbsController.clear();
  }

  void _showErrorSnackBar(String message) {
    // Snackbars removed - no longer showing error messages
  }

  void _showLowConfidenceDialog(DetectedFoodItemsResponse response) {
    // Use parent context if available, otherwise use widget context
    final dialogContext = widget.parentContext ?? context;
    
    // If widget is not mounted, we must have parentContext to show dialog
    if (!mounted && widget.parentContext == null) {
      debugPrint('Cannot show low confidence dialog - widget not mounted and no parent context');
      return;
    }
    
    // Ensure the context is still valid
    try {
      MediaQuery.of(dialogContext);
    } catch (e) {
      debugPrint('Cannot show low confidence dialog - context is invalid: $e');
      return;
    }
    
    final mainItem = response.mainItem;
    
    showDialog(
      context: dialogContext,
      builder: (builderContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text('Low Confidence Result'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The AI provided a nutrition estimate with ${mainItem.confidence}% confidence for:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(builderContext).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color:
                        Theme.of(builderContext).colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainItem.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Estimated Weight: ${mainItem.estimatedWeight}g'),
                  Text('Calories: ${mainItem.calories} kcal'),
                  Text('Protein: ${mainItem.protein.toStringAsFixed(1)}g'),
                  Text('Fat: ${mainItem.fat.toStringAsFixed(1)}g'),
                  Text('Carbs: ${mainItem.carbs.toStringAsFixed(1)}g'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This may not be entirely accurate. Consider verifying the values manually.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange[800],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _addDetectedFoods(response);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.secondary,
              foregroundColor: Theme.of(dialogContext).colorScheme.onSecondary,
            ),
            child: const Text('Add Anyway'),
          ),
        ],
      ),
    );
  }
}
