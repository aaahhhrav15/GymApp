import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/nutrition_provider.dart';
import '../models/nutrition_models.dart';

class AIMealAnalysisScreen extends StatefulWidget {
  const AIMealAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AIMealAnalysisScreen> createState() => _AIMealAnalysisScreenState();
}

class _AIMealAnalysisScreenState extends State<AIMealAnalysisScreen> {
  File? _selectedImage;
  DetectedFoodItemsResponse? _detectedFood;
  bool _isAnalyzing = false;
  String _selectedMealType = 'breakfast';
  final ImagePicker _picker = ImagePicker();

  final List<String> _mealTypes = [
    'breakfast',
    'lunch',
    'dinner',
    'snack',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'AI Meal Analysis',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: screenWidth * 0.12,
                      color: Colors.white,
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      'AI-Powered Nutrition Analysis',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      'Take a photo of your meal and let AI analyze its nutritional content',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenWidth * 0.06),

              // Image Selection Section
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select Meal Image',
                      style: TextStyle(
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.04),

                    // Image Preview or Placeholder
                    Container(
                      height: screenHeight * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: screenWidth * 0.15,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: screenWidth * 0.02),
                                Text(
                                  'No image selected',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                    ),

                    SizedBox(height: screenWidth * 0.04),

                    // Camera and Gallery Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: Icon(
                              Icons.camera_alt,
                              size: screenWidth * 0.05,
                            ),
                            label: Text(
                              'Camera',
                              style: TextStyle(
                                fontSize: screenWidth * 0.038,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.04),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.025),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: Icon(
                              Icons.photo_library,
                              size: screenWidth * 0.05,
                            ),
                            label: Text(
                              'Gallery',
                              style: TextStyle(
                                fontSize: screenWidth * 0.038,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.04),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.025),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (_selectedImage != null) ...[
                SizedBox(height: screenWidth * 0.06),

                // Analyze Button
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Analyze Meal',
                        style: TextStyle(
                          fontSize: screenWidth * 0.042,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      ElevatedButton(
                        onPressed: _isAnalyzing ? null : _analyzeImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.04),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.025),
                          ),
                        ),
                        child: _isAnalyzing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: screenWidth * 0.05,
                                    width: screenWidth * 0.05,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Text(
                                    'Analyzing...',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.psychology,
                                    size: screenWidth * 0.05,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    'Analyze with AI',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],

              // Analysis Results
              if (_detectedFood != null) ...[
                SizedBox(height: screenWidth * 0.06),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant,
                            color: Colors.deepPurple,
                            size: screenWidth * 0.06,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Text(
                              'Analysis Results',
                              style: TextStyle(
                                fontSize: screenWidth * 0.042,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenWidth * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: _getConfidenceColor(
                                  _detectedFood!.mainItem.confidence),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.04),
                            ),
                            child: Text(
                              '${_detectedFood!.mainItem.confidence}% confident',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.04),

                      // Main Item Section
                      Text(
                        'Main Item',
                        style: TextStyle(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      // Meal Name
                      Text(
                        _detectedFood!.mainItem.name,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Text(
                        'Estimated Weight: ${_detectedFood!.mainItem.estimatedWeight}g',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: screenWidth * 0.04),

                      // Nutrition Information
                      Row(
                        children: [
                          Expanded(
                              child: _buildNutritionCard(
                                  'Calories',
                                  '${_detectedFood!.mainItem.calories}',
                                  'kcal',
                                  Colors.red,
                                  screenWidth)),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                              child: _buildNutritionCard(
                                  'Protein',
                                  '${_detectedFood!.mainItem.protein.toStringAsFixed(1)}',
                                  'g',
                                  Colors.blue,
                                  screenWidth)),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.03),
                      Row(
                        children: [
                          Expanded(
                              child: _buildNutritionCard(
                                  'Fat',
                                  '${_detectedFood!.mainItem.fat.toStringAsFixed(1)}',
                                  'g',
                                  Colors.orange,
                                  screenWidth)),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                              child: _buildNutritionCard(
                                  'Carbs',
                                  '${_detectedFood!.mainItem.carbs.toStringAsFixed(1)}',
                                  'g',
                                  Colors.green,
                                  screenWidth)),
                        ],
                      ),

                      // Individual Items Breakdown (if multiple items)
                      if (_detectedFood!.hasMultipleItems) ...[
                        SizedBox(height: screenWidth * 0.06),
                        Divider(),
                        SizedBox(height: screenWidth * 0.04),
                        Text(
                          'Item Breakdown',
                          style: TextStyle(
                            fontSize: screenWidth * 0.042,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        ...(_detectedFood!.items!.map((item) => _buildItemBreakdownCard(item, screenWidth))),
                      ],

                      SizedBox(height: screenWidth * 0.06),

                      // Meal Type Selection
                      Text(
                        'Select Meal Type',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.03),

                      DropdownButtonFormField<String>(
                        value: _selectedMealType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.025),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenWidth * 0.035,
                          ),
                        ),
                        items: _mealTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type.substring(0, 1).toUpperCase() +
                                  type.substring(1),
                              style: TextStyle(fontSize: screenWidth * 0.04),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedMealType = newValue;
                            });
                          }
                        },
                      ),

                      SizedBox(height: screenWidth * 0.06),

                      // Add to Nutrition Button
                      ElevatedButton(
                        onPressed: _addToNutrition,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.04),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.025),
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
                              'Add to Nutrition',
                              style: TextStyle(
                                fontSize: screenWidth * 0.042,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _detectedFood = null; // Clear previous results
        });
      }
    } catch (e) {
      _showErrorDialog('Error selecting image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final nutritionProvider =
          Provider.of<NutritionProvider>(context, listen: false);
      final result = await nutritionProvider
          .analyzeImageForNutrition(_selectedImage!.path);

      setState(() {
        _detectedFood = result;
      });

      if (result == null) {
        _showErrorDialog(
            'Failed to analyze the image. Please try again with a clearer image of food.');
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
        errorMessage = 'No internet connection detected. Please check your network connection and try again.';
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
        errorMessage = 'Server error occurred. Please try again later.';
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
        errorMessage = 'Failed to analyze the image. Please check your internet connection and try again with a clearer image of food.';
      }
      
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _addToNutrition() async {
    if (_detectedFood == null) return;

    try {
      final nutritionProvider =
          Provider.of<NutritionProvider>(context, listen: false);
      final success = await nutritionProvider.addAIDetectedMeal(
          _detectedFood!.mainItem, _selectedMealType);

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Failed to add meal to nutrition tracking.');
      }
    } catch (e) {
      _showErrorDialog('Error adding meal: $e');
    }
  }

  Widget _buildItemBreakdownCard(DetectedFoodItemBreakdown item, double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              if (item.quantityDescription.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.025,
                    vertical: screenWidth * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Text(
                    item.quantityDescription,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.calories} kcal',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.red[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'P: ${item.protein.toStringAsFixed(1)}g',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'F: ${item.fat.toStringAsFixed(1)}g',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'C: ${item.carbs.toStringAsFixed(1)}g',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            'Weight: ${item.estimatedWeight}g',
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(String label, String value, String unit,
      Color color, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.042,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: screenWidth * 0.028,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Meal has been added to your nutrition tracking!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to nutrition screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
