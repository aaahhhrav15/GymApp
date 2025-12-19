// lib/widgets/nutrition_widget.dart - Updated to use NutritionProvider
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';

class NutritionWidget extends StatefulWidget {
  final Color backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? progressColor;
  final VoidCallback? onTap;

  const NutritionWidget({
    super.key,
    this.backgroundColor = const Color(0xFFFCE4EC),
    this.iconColor,
    this.textColor,
    this.progressColor,
    this.onTap,
  });

  @override
  State<NutritionWidget> createState() => _NutritionWidgetState();
}

class _NutritionWidgetState extends State<NutritionWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize nutrition provider when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final containerPadding = screenWidth * 0.04;
    final containerHeight = screenHeight * 0.175;
    final borderRadius = screenWidth * 0.05;
    final iconPadding = screenWidth * 0.02;
    final iconBorderRadius = screenWidth * 0.03;
    final spacingMedium = screenHeight * 0.015;
    final spacingSmall = screenHeight * 0.006;

    // Font sizes
    final titleFontSize = screenWidth * 0.04;
    final caloriesFontSize = screenWidth * 0.045;
    final labelFontSize = screenWidth * 0.028;
    final percentageFontSize = screenWidth * 0.023;
    final loadingFontSize = screenWidth * 0.028;

    // Icon and circle sizes
    final mainIconSize = screenWidth * 0.05;
    final refreshIconSize = screenWidth * 0.035;
    final circleSize = screenWidth * 0.11;
    final strokeWidth = screenWidth * 0.008;

    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        if (nutritionProvider.isLoading) {
          return _buildLoadingWidget(
            screenWidth,
            screenHeight,
            containerPadding,
            containerHeight,
            borderRadius,
            iconPadding,
            iconBorderRadius,
            titleFontSize,
            mainIconSize,
            loadingFontSize,
          );
        }

        double calorieProgress = nutritionProvider.nutritionGoals.calories > 0
            ? (nutritionProvider.currentTotals.calories /
                    nutritionProvider.nutritionGoals.calories)
                .clamp(0.0, 1.0)
            : 0.0;

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.all(containerPadding),
            height: containerHeight,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and icon
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(iconBorderRadius),
                      ),
                      child: Icon(
                        Icons.restaurant_menu,
                        color: widget.iconColor ?? Colors.pink[600],
                        size: mainIconSize,
                      ),
                    ),
                    SizedBox(width: spacingMedium),
                    Expanded(
                      child: Text(
                        'Nutrition',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: widget.textColor ?? Colors.black87,
                        ),
                      ),
                    ),
                    // Refresh button
                    GestureDetector(
                      onTap: () =>
                          context.read<NutritionProvider>().refreshForNewDay(),
                      child: Container(
                        padding: EdgeInsets.all(spacingSmall),
                        child: Icon(
                          Icons.refresh,
                          size: refreshIconSize,
                          color: widget.iconColor ?? Colors.pink[600],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: spacingMedium),

                // Calories progress
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${nutritionProvider.currentTotals.calories}/${nutritionProvider.nutritionGoals.calories}',
                              style: TextStyle(
                                fontSize: caloriesFontSize,
                                fontWeight: FontWeight.bold,
                                color: widget.textColor ?? Colors.black87,
                              ),
                            ),
                            SizedBox(height: spacingSmall),
                            Text(
                              'Calories',
                              style: TextStyle(
                                fontSize: labelFontSize,
                                color: (widget.textColor ?? Colors.black87)
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Circular progress indicator
                      SizedBox(
                        width: circleSize,
                        height: circleSize,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: circleSize,
                              height: circleSize,
                              child: CircularProgressIndicator(
                                value: calorieProgress,
                                strokeWidth: strokeWidth,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.progressColor ?? Colors.pink[600]!,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                '${(calorieProgress * 100).round()}%',
                                style: TextStyle(
                                  fontSize: percentageFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: widget.textColor ?? Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: spacingSmall),

                // Macros row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMacroInfo(
                      'Protein',
                      '${nutritionProvider.currentTotals.protein.toInt()}g',
                      Colors.blue[300]!,
                      widget.textColor,
                      screenWidth,
                    ),
                    _buildMacroInfo(
                      'Fat',
                      '${nutritionProvider.currentTotals.fat.toInt()}g',
                      Colors.orange[300]!,
                      widget.textColor,
                      screenWidth,
                    ),
                    _buildMacroInfo(
                      'Carbs',
                      '${nutritionProvider.currentTotals.carbs.toInt()}g',
                      Colors.green[300]!,
                      widget.textColor,
                      screenWidth,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget(
    double screenWidth,
    double screenHeight,
    double containerPadding,
    double containerHeight,
    double borderRadius,
    double iconPadding,
    double iconBorderRadius,
    double titleFontSize,
    double mainIconSize,
    double loadingFontSize,
  ) {
    return Container(
      padding: EdgeInsets.all(containerPadding),
      height: containerHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(iconBorderRadius),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: widget.iconColor ?? Colors.pink[600],
                  size: mainIconSize,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Text(
                'Nutrition',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: widget.textColor ?? Colors.black87,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: screenWidth * 0.04,
                height: screenWidth * 0.04,
                child: CircularProgressIndicator(
                  strokeWidth: screenWidth * 0.005,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.progressColor ?? Colors.pink[600]!,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'Loading nutrition data...',
            style: TextStyle(
              fontSize: loadingFontSize,
              color: (widget.textColor ?? Colors.black87).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value, Color color,
      Color? textColor, double screenWidth) {
    final dotSize = screenWidth * 0.02;
    final labelFontSize = screenWidth * 0.025;
    final valueFontSize = screenWidth * 0.03;
    final spacingSmall = screenWidth * 0.01;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: spacingSmall),
            Text(
              label,
              style: TextStyle(
                fontSize: labelFontSize,
                color: (textColor ?? Colors.black87).withOpacity(0.7),
              ),
            ),
          ],
        ),
        SizedBox(height: spacingSmall * 0.5),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
