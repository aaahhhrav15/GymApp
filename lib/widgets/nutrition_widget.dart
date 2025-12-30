// lib/widgets/nutrition_widget.dart - Updated to use NutritionProvider and Theme-aware colors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class NutritionWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const NutritionWidget({
    super.key,
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

  // Theme-aware colors
  Color _getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF81C784) // Light green for dark mode
        : const Color(0xFF388E3C); // Deep green for light mode
  }

  Color _getSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFA5D6A7)
        : const Color(0xFF1B5E20);
  }

  List<Color> _getGradientColors(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF1A2E1A),
            const Color(0xFF243D24),
            const Color(0xFF2E4C2E),
          ]
        : [
            const Color(0xFFE8F5E9),
            const Color(0xFFC8E6C9),
            const Color(0xFFA5D6A7),
          ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Responsive dimensions
    final containerPadding = screenWidth * 0.03;
    final containerHeight = screenHeight * 0.175;
    final borderRadius = screenWidth * 0.05;
    final iconPadding = screenWidth * 0.015;
    final iconBorderRadius = screenWidth * 0.02;
    final spacingMedium = screenHeight * 0.015;
    final spacingSmall = screenHeight * 0.006;

    // Font sizes - consistent across all widgets
    final titleFontSize = screenWidth * 0.0375;
    final mainNumberFontSize = screenWidth * 0.055; // Consistent main number size
    final secondaryFontSize = screenWidth * 0.03; // Consistent secondary text
    final labelFontSize = screenWidth * 0.028; // Consistent labels
    final percentageFontSize = screenWidth * 0.023;
    final loadingFontSize = screenWidth * 0.028;

    // Icon and circle sizes
    final mainIconSize = screenWidth * 0.045;
    final refreshIconSize = screenWidth * 0.035;
    final circleSize = screenWidth * 0.11;
    final strokeWidth = screenWidth * 0.0075;

    final primaryColor = _getPrimaryColor(context);
    final gradientColors = _getGradientColors(context);

    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        if (nutritionProvider.isLoading) {
          return _buildLoadingWidget(
            l10n,
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
            primaryColor,
            gradientColors,
            isDark,
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
              color: isDark 
                  ? const Color(0xFF1A2E1A)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: primaryColor.withOpacity(isDark ? 0.4 : 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(isDark ? 0.2 : 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
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
                        color: primaryColor.withOpacity(isDark ? 0.25 : 0.15),
                        borderRadius: BorderRadius.circular(iconBorderRadius),
                      ),
                      child: Icon(
                        Icons.restaurant_menu,
                        color: primaryColor,
                        size: mainIconSize,
                      ),
                    ),
                    SizedBox(width: spacingMedium * 0.7),
                    Expanded(
                      child: Text(
                        l10n.nutrition,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.grey[800],
                        ),
                      ),
                    ),
                    // Refresh button
                    GestureDetector(
                      onTap: () =>
                          context.read<NutritionProvider>().refreshForNewDay(),
                      child: Container(
                        padding: EdgeInsets.all(spacingSmall * 0.7),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(screenWidth * 0.015),
                        ),
                        child: Icon(
                          Icons.refresh,
                          size: refreshIconSize,
                          color: primaryColor,
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
                                fontSize: screenWidth * 0.048, // Smaller than other main numbers
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.grey[900],
                              ),
                            ),
                            SizedBox(height: spacingSmall * 0.3),
                            Text(
                              l10n.calories,
                              style: TextStyle(
                                fontSize: labelFontSize,
                                color: isDark ? Colors.white60 : Colors.grey[600],
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
                                backgroundColor: primaryColor.withOpacity(isDark ? 0.3 : 0.25),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                '${(calorieProgress * 100).round()}%',
                                style: TextStyle(
                                  fontSize: percentageFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.grey[800],
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
                SizedBox(
                  height: screenHeight * 0.023,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMacroInfo(
                        l10n.protein,
                        '${nutritionProvider.currentTotals.protein.toInt()}g',
                        isDark ? Colors.blue[300]! : Colors.blue[600]!,
                        isDark,
                        screenWidth,
                      ),
                      _buildMacroInfo(
                        l10n.fat,
                        '${nutritionProvider.currentTotals.fat.toInt()}g',
                        isDark ? Colors.orange[300]! : Colors.orange[600]!,
                        isDark,
                        screenWidth,
                      ),
                      _buildMacroInfo(
                        l10n.carbs,
                        '${nutritionProvider.currentTotals.carbs.toInt()}g',
                        isDark ? Colors.purple[300]! : Colors.purple[600]!,
                        isDark,
                        screenWidth,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget(
    AppLocalizations l10n,
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
    Color primaryColor,
    List<Color> gradientColors,
    bool isDark,
  ) {
    final spacingMedium = screenHeight * 0.015;
    final loadingIndicatorSize = screenWidth * 0.04;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      height: containerHeight,
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1A2E1A)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: primaryColor.withOpacity(isDark ? 0.4 : 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(isDark ? 0.2 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 2,
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
                  color: primaryColor.withOpacity(isDark ? 0.25 : 0.15),
                  borderRadius: BorderRadius.circular(iconBorderRadius),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: primaryColor,
                  size: mainIconSize,
                ),
              ),
              SizedBox(width: spacingMedium * 0.7),
              Text(
                l10n.nutrition,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: loadingIndicatorSize,
                height: loadingIndicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: screenWidth * 0.005,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ],
          ),
          SizedBox(height: spacingMedium * 0.5),
          Text(
            l10n.loadingNutritionData,
            style: TextStyle(
              fontSize: loadingFontSize,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(
    String label,
    String value,
    Color color,
    bool isDark,
    double screenWidth,
  ) {
    final dotSize = screenWidth * 0.012;
    final labelFontSize = screenWidth * 0.02;
    final valueFontSize = screenWidth * 0.024;
    final dotSpacing = screenWidth * 0.005;

    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: dotSpacing),
          Flexible(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
