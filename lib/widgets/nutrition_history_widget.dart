import 'package:flutter/material.dart';
import '../models/nutrition_models.dart';
import '../providers/nutrition_provider.dart';
import '../l10n/app_localizations.dart';

class NutritionHistoryWidget extends StatelessWidget {
  final NutritionProvider nutritionProvider;
  final Function(String) onDateSelect;

  const NutritionHistoryWidget({
    super.key,
    required this.nutritionProvider,
    required this.onDateSelect,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive sizing
    final containerPadding = screenWidth * 0.04; // 4% of screen width
    final iconSize = screenWidth * 0.05; // 5% of screen width
    final titleFontSize = screenWidth * 0.045; // 4.5% of screen width
    final spacingSmall = screenWidth * 0.03; // 3% of screen width
    final spacingMedium = screenHeight * 0.02; // 2% of screen height
    final borderRadius = screenWidth * 0.03; // 3% of screen width

    final weeklyTotals = nutritionProvider.weeklyTotals;
    final weeklyGoals = nutritionProvider.weeklyGoals;

    if (weeklyTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(screenWidth * 0.025),
                ),
                child: Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                  size: iconSize,
                ),
              ),
              SizedBox(width: spacingSmall),
              Text(
                AppLocalizations.of(context)!.sevenDayHistory,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: spacingMedium),

          // History list
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _buildHistoryItems(context, weeklyTotals, weeklyGoals),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHistoryItems(
    BuildContext context,
    Map<String, NutritionTotals> weeklyTotals,
    Map<String, NutritionGoals> weeklyGoals,
  ) {
    final sortedDates = weeklyTotals.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    return sortedDates.map((date) {
      final totals = weeklyTotals[date]!;
      final goals = weeklyGoals[date]!;
      final isSelected = date == nutritionProvider.selectedDate;
      final isToday = date == DateTime.now().toIso8601String().split('T')[0];

      return _buildHistoryItem(
        context,
        date,
        totals,
        goals,
        isSelected,
        isToday,
      );
    }).toList();
  }

  Widget _buildHistoryItem(
    BuildContext context,
    String date,
    NutritionTotals totals,
    NutritionGoals goals,
    bool isSelected,
    bool isToday,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive sizing for history item
    final itemPadding = screenWidth * 0.04; // 4% of screen width
    final borderRadius = screenWidth * 0.03; // 3% of screen width
    final dayNameFontSize = screenWidth * 0.035; // 3.5% of screen width
    final dateFontSize = screenWidth * 0.03; // 3% of screen width
    final caloriesFontSize = screenWidth * 0.03; // 3% of screen width
    final percentageFontSize = screenWidth * 0.025; // 2.5% of screen width
    final macroFontSize = screenWidth * 0.02; // 2% of screen width
    final todayFontSize = screenWidth * 0.025; // 2.5% of screen width
    final spacingTiny = screenHeight * 0.005; // 0.5% of screen height
    final spacingSmall = screenWidth * 0.02; // 2% of screen width
    final progressHeight = screenHeight * 0.004; // 0.4% of screen height
    final indicatorWidth = screenWidth * 0.01; // 1% of screen width
    final indicatorHeight = screenHeight * 0.025; // 2.5% of screen height

    final dateTime = DateTime.parse(date);
    final dayName = _getDayNameLocalized(dateTime, context);
    final formattedDate = _formatDateLocalized(dateTime, context);

    final calorieProgress = goals.calories > 0
        ? (totals.calories / goals.calories).clamp(0.0, 1.0)
        : 0.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onDateSelect(date),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.all(itemPadding),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.5)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Date info
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: dayNameFontSize,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (isToday) ...[
                          SizedBox(width: spacingSmall),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.015,
                              vertical: screenHeight * 0.002,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.01),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.today,
                              style: TextStyle(
                                fontSize: todayFontSize,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: spacingTiny),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: dateFontSize,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Calories progress
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${totals.calories}/${goals.calories}',
                      style: TextStyle(
                        fontSize: caloriesFontSize,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: spacingTiny),
                    LinearProgressIndicator(
                      value: calorieProgress,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainer,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(calorieProgress, context),
                      ),
                      minHeight: progressHeight,
                    ),
                    SizedBox(height: spacingTiny),
                    Text(
                      '${(calorieProgress * 100).round()}%',
                      style: TextStyle(
                        fontSize: percentageFontSize,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Macros summary
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMacroSummary(
                      'P',
                      '${totals.protein.toInt()}g',
                      Theme.of(context).colorScheme.tertiary,
                      context,
                    ),
                    _buildMacroSummary(
                      'F',
                      '${totals.fat.toInt()}g',
                      Theme.of(context).colorScheme.secondary,
                      context,
                    ),
                    _buildMacroSummary(
                      'C',
                      '${totals.carbs.toInt()}g',
                      Theme.of(context).colorScheme.primary,
                      context,
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Container(
                  width: indicatorWidth,
                  height: indicatorHeight,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(screenWidth * 0.005),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroSummary(
      String label, String value, Color color, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive sizing for macro summary
    final macroBoxSize = screenWidth * 0.03; // 3% of screen width
    final macroFontSize = screenWidth * 0.02; // 2% of screen width
    final spacingTiny = screenHeight * 0.002; // 0.2% of screen height
    final borderRadius = screenWidth * 0.005; // 0.5% of screen width

    return Column(
      children: [
        Container(
          width: macroBoxSize,
          height: macroBoxSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        SizedBox(height: spacingTiny),
        Text(
          value,
          style: TextStyle(
            fontSize: macroFontSize,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress, BuildContext context) {
    if (progress < 0.5) {
      return Theme.of(context).colorScheme.error;
    } else if (progress < 0.9) {
      return Theme.of(context).colorScheme.primary;
    } else if (progress <= 1.0) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  String _getDayName(DateTime date) {
    // Day names will be handled by localization context when this is called
    // This method should receive context as a parameter
    return '';
  }

  String _getDayNameLocalized(DateTime date, BuildContext context) {
    final days = [
      AppLocalizations.of(context)!.sun,
      AppLocalizations.of(context)!.mon,
      AppLocalizations.of(context)!.tue,
      AppLocalizations.of(context)!.wed,
      AppLocalizations.of(context)!.thu,
      AppLocalizations.of(context)!.fri,
      AppLocalizations.of(context)!.sat,
    ];
    return days[date.weekday % 7];
  }

  String _formatDate(DateTime date) {
    // Month names will be handled by localization context when this is called
    // This method should receive context as a parameter
    return '';
  }

  String _formatDateLocalized(DateTime date, BuildContext context) {
    final months = [
      AppLocalizations.of(context)!.jan,
      AppLocalizations.of(context)!.feb,
      AppLocalizations.of(context)!.mar,
      AppLocalizations.of(context)!.apr,
      AppLocalizations.of(context)!.may,
      AppLocalizations.of(context)!.jun,
      AppLocalizations.of(context)!.jul,
      AppLocalizations.of(context)!.aug,
      AppLocalizations.of(context)!.sep,
      AppLocalizations.of(context)!.oct,
      AppLocalizations.of(context)!.nov,
      AppLocalizations.of(context)!.dec,
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
