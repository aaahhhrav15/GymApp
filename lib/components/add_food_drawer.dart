// lib/components/add_food_drawer.dart
import 'package:flutter/material.dart';
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
  }) onAddFood;
  final bool isLoading;

  const AddFoodDrawer({
    super.key,
    required this.animation,
    required this.onClose,
    required this.onAddFood,
    this.isLoading = false,
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
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.edit,
                            color: Theme.of(context).colorScheme.primary,
                            size: screenWidth * 0.08),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'Enter Food Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          'Get nutrition values',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt,
                            color: Theme.of(context).colorScheme.secondary,
                            size: screenWidth * 0.08),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'Take Image',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          'AI will analyze',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Theme.of(context).colorScheme.secondary,
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
            SizedBox(height: screenHeight * 0.025),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Analyzing food...',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    'AI is getting nutrition information',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: screenHeight * 0.03),

          // Close button
          // SizedBox(
          //   width: double.infinity,
          //   height: screenHeight * 0.06,
          //   child: ElevatedButton(
          //     onPressed: widget.onClose,
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Theme.of(context).colorScheme.primary,
          //       foregroundColor: Theme.of(context).colorScheme.onPrimary,
          //       elevation: 2,
          //       shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(screenWidth * 0.03),
          //       ),
          //     ),
          //     child: Text(
          //       'Close',
          //       style: TextStyle(
          //           fontSize: screenWidth * 0.04,
          //           fontWeight: FontWeight.w600),
          //     ),
          //   ),
          // ),

          SizedBox(height: screenHeight * 0.025),
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
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Calories
                  _buildCustomInputField(
                    'Calories (kcal)',
                    _customCaloriesController,
                    'e.g., 250',
                    keyboardType: TextInputType.number,
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
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: _buildCustomInputField(
                          'Fat (g)',
                          _customFatController,
                          '0',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: _buildCustomInputField(
                          'Carbs (g)',
                          _customCarbsController,
                          '0',
                          keyboardType: TextInputType.number,
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
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
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
                  : Text(
                      'Add Food',
                      style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600),
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
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: screenHeight * 0.008),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                fontSize: screenWidth * 0.035),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenHeight * 0.015,
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.04)),
        title: Text('Enter Food Details',
            style: TextStyle(fontSize: screenWidth * 0.045)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _foodNameController,
              decoration: InputDecoration(
                labelText: 'Food Name',
                labelStyle: TextStyle(fontSize: screenWidth * 0.035),
                hintText: 'e.g., Apple, Chicken Breast',
                hintStyle: TextStyle(fontSize: screenWidth * 0.035),
                border: const OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: screenWidth * 0.035),
            ),
            SizedBox(height: screenHeight * 0.02),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (grams)',
                labelStyle: TextStyle(fontSize: screenWidth * 0.035),
                hintText: 'e.g., 100',
                hintStyle: TextStyle(fontSize: screenWidth * 0.035),
                border: const OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: screenWidth * 0.035),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(fontSize: screenWidth * 0.035)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _getAINutrition();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text('Get Nutrition',
                style: TextStyle(fontSize: screenWidth * 0.035)),
          ),
        ],
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

        // Show success message with nutrition details
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content:
        //         Text('Added: $foodName (${weight}g) - ${totalCalories} kcal'),
        //     backgroundColor: Colors.green,
        //     behavior: SnackBarBehavior.floating,
        //     shape:
        //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //     margin: const EdgeInsets.all(16),
        //   ),
        // );

        widget.onAddFood(
          name: '$foodName (${weight}g)',
          calories: totalCalories,
          protein: totalProtein,
          fat: totalFat,
          carbs: totalCarbs,
          mealType: _getMealTypeByTime(),
          source: 'ai_nutrition',
        );

        // Clear the form and close drawer
        _foodNameController.clear();
        _weightController.text = '100';
        widget.onClose();
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
      builder: (context) => Container(
        margin: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.015),
              width: screenWidth * 0.1,
              height: screenWidth * 0.01,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(screenWidth * 0.005),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Scan Food',
              style: TextStyle(
                  fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.02),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Icon(Icons.camera_alt,
                    color: Theme.of(context).colorScheme.primary,
                    size: screenWidth * 0.06),
              ),
              title: Text('Take Photo',
                  style: TextStyle(fontSize: screenWidth * 0.04)),
              subtitle: Text('Capture food with camera',
                  style: TextStyle(fontSize: screenWidth * 0.035)),
              onTap: () {
                Navigator.pop(context);
                _captureFromCamera();
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Icon(Icons.photo_library,
                    color: Theme.of(context).colorScheme.secondary,
                    size: screenWidth * 0.06),
              ),
              title: Text('Choose from Gallery',
                  style: TextStyle(fontSize: screenWidth * 0.04)),
              subtitle: Text('Select from photo library',
                  style: TextStyle(fontSize: screenWidth * 0.035)),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            SizedBox(height: screenHeight * 0.02),
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
    setState(() => _isAnalyzing = true);

    try {
      // Use the AI functionality from NutritionProvider
      final nutritionProvider = context.read<NutritionProvider>();
      final detectedFood =
          await nutritionProvider.analyzeImageForNutrition(image.path);

      if (detectedFood != null) {
        if (detectedFood.confidence < 60) {
          // Show warning for low confidence results
          _showLowConfidenceDialog(detectedFood);
        } else {
          _showAIResults([detectedFood]);
        }
      } else {
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
      
      // Snackbar removed - no longer showing error messages
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _showAIResults(List<DetectedFoodItem> foodItems) {
    // Calculate totals
    int totalCalories = foodItems.fold(0, (sum, item) => sum + item.calories);
    double totalProtein =
        foodItems.fold(0.0, (sum, item) => sum + item.protein);
    double totalFat = foodItems.fold(0.0, (sum, item) => sum + item.fat);
    double totalCarbs = foodItems.fold(0.0, (sum, item) => sum + item.carbs);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('AI Analysis Results'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detected Food Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: foodItems.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = foodItems[index];
                    return _buildDetectedFoodItem(item);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Estimated:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Calories: $totalCalories kcal'),
                    Text('Protein: ${totalProtein.round()}g'),
                    Text('Fat: ${totalFat.round()}g'),
                    Text('Carbs: ${totalCarbs.round()}g'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addDetectedFoods(foodItems);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Add to Meals'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedFoodItem(DetectedFoodItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getConfidenceColor(item.confidence).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${item.confidence}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getConfidenceColor(item.confidence),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Est. ${item.estimatedWeight}g',
          style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 2),
        Text(
          '${item.calories} kcal • P: ${item.protein.round()}g • F: ${item.fat.round()}g • C: ${item.carbs.round()}g',
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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

  Future<void> _addDetectedFoods(List<DetectedFoodItem> foodItems) async {
    // For simplicity, we'll combine all detected items into one meal
    // In a real app, you might want to let users add them individually

    int totalCalories = foodItems.fold(0, (sum, item) => sum + item.calories);
    double totalProtein =
        foodItems.fold(0.0, (sum, item) => sum + item.protein);
    double totalFat = foodItems.fold(0.0, (sum, item) => sum + item.fat);
    double totalCarbs = foodItems.fold(0.0, (sum, item) => sum + item.carbs);

    String combinedName = foodItems.length == 1
        ? foodItems.first.name
        : 'AI Detected Meal (${foodItems.length} items)';

    widget.onAddFood(
      name: combinedName,
      calories: totalCalories,
      protein: totalProtein,
      fat: totalFat,
      carbs: totalCarbs,
      mealType: _getMealTypeByTime(),
      source: 'image',
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

  void _showLowConfidenceDialog(DetectedFoodItem detectedFood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              'The AI provided a nutrition estimate with ${detectedFood.confidence}% confidence for:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detectedFood.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Estimated Weight: ${detectedFood.estimatedWeight}g'),
                  Text('Calories: ${detectedFood.calories} kcal'),
                  Text('Protein: ${detectedFood.protein.round()}g'),
                  Text('Fat: ${detectedFood.fat.round()}g'),
                  Text('Carbs: ${detectedFood.carbs.round()}g'),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addDetectedFoods([detectedFood]);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
            child: const Text('Add Anyway'),
          ),
        ],
      ),
    );
  }
}
