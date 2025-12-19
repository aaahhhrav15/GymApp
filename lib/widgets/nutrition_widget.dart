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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final containerPadding = screenWidth * 0.03;
    final containerHeight = screenHeight * 0.175;
    final borderRadius = screenWidth * 0.05;
    final iconPadding = screenWidth * 0.015;
    final iconBorderRadius = screenWidth * 0.025;
    final spacingMedium = screenHeight * 0.015;
    final spacingSmall = screenHeight * 0.006;

    // Font sizes
    final titleFontSize = screenWidth * 0.0375;
    final caloriesFontSize = screenWidth * 0.045;
    final labelFontSize = screenWidth * 0.028;
    final percentageFontSize = screenWidth * 0.023;
    final loadingFontSize = screenWidth * 0.028;

    // Icon and circle sizes
    final mainIconSize = screenWidth * 0.045;
    final refreshIconSize = screenWidth * 0.035;
    final circleSize = screenWidth * 0.11;
    final strokeWidth = screenWidth * 0.0075;

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
              color: context.nutritionBackground,
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
                        color: context.nutritionPrimary,
                        size: mainIconSize,
                      ),
                    ),
                    SizedBox(width: spacingMedium * 0.7),
                    Expanded(
                      child: Text(
                        l10n.nutrition,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    // Refresh button
                    GestureDetector(
                      onTap: () =>
                          context.read<NutritionProvider>().refreshForNewDay(),
                      child: Container(
                        padding: EdgeInsets.all(spacingSmall * 0.7),
                        child: Icon(
                          Icons.refresh,
                          size: refreshIconSize,
                          color: context.nutritionPrimary,
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
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                            SizedBox(height: spacingSmall * 0.3),
                            Text(
                              l10n.calories,
                              style: TextStyle(
                                fontSize: labelFontSize,
                                color: (Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color ??
                                        Colors.black87)
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
                                  context.nutritionPrimary,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                '${(calorieProgress * 100).round()}%',
                                style: TextStyle(
                                  fontSize: percentageFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
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
                        Colors.blue[300]!,
                        Theme.of(context).textTheme.bodyLarge?.color,
                        screenWidth,
                      ),
                      _buildMacroInfo(
                        l10n.fat,
                        '${nutritionProvider.currentTotals.fat.toInt()}g',
                        Colors.orange[300]!,
                        Theme.of(context).textTheme.bodyLarge?.color,
                        screenWidth,
                      ),
                      _buildMacroInfo(
                        l10n.carbs,
                        '${nutritionProvider.currentTotals.carbs.toInt()}g',
                        Colors.green[300]!,
                        Theme.of(context).textTheme.bodyLarge?.color,
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
  ) {
    final spacingMedium = screenHeight * 0.015;
    final loadingIndicatorSize = screenWidth * 0.04;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      height: containerHeight,
      decoration: BoxDecoration(
        color: context.nutritionBackground,
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
                  color: context.nutritionPrimary,
                  size: mainIconSize,
                ),
              ),
              SizedBox(width: spacingMedium * 0.7),
              Text(
                l10n.nutrition,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: loadingIndicatorSize,
                height: loadingIndicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: screenWidth * 0.005,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.nutritionPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacingMedium * 0.5),
          Text(
            l10n.loadingNutritionData,
            style: TextStyle(
              fontSize: loadingFontSize,
              color: (Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black87)
                  .withOpacity(0.7),
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
    Color? textColor,
    double screenWidth,
  ) {
    final dotSize = screenWidth * 0.01;
    final labelFontSize = screenWidth * 0.02;
    final valueFontSize = screenWidth * 0.023;
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
                      color: (textColor ?? Colors.black87).withOpacity(0.7),
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.black87,
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
