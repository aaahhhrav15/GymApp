// lib/components/nutrition_summary_card.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/nutrition_models.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class NutritionSummaryCard extends StatelessWidget {
  final NutritionTotals currentTotals;
  final NutritionGoals goals;

  const NutritionSummaryCard({
    super.key,
    required this.currentTotals,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double calorieProgress =
        (currentTotals.calories / goals.calories).clamp(0.0, 1.0);
    int remaining = goals.calories - currentTotals.calories;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.06),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.06),
            blurRadius: screenWidth * 0.05,
            offset: Offset(0, screenWidth * 0.01),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with profile icon
          Row(
            children: [
              Container(
                width: screenWidth * 0.09,
                height: screenWidth * 0.09,
                decoration: BoxDecoration(
                  color: context.nutritionPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text('⚡',
                        style: TextStyle(fontSize: screenWidth * 0.045))),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.calorieGoal}: ${_formatNumber(goals.calories)} ${AppLocalizations.of(context)!.kcal}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      remaining > 0
                          ? '${AppLocalizations.of(context)!.remainingOnly} $remaining ${AppLocalizations.of(context)!.cal}'
                          : '${AppLocalizations.of(context)!.goalExceededBy} ${-remaining} ${AppLocalizations.of(context)!.cal}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: remaining > 0
                            ? context.nutritionPrimary
                            : Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.03),

          // Circular Progress and Macros
          Row(
            children: [
              // Multi-colored Circular Progress
              SizedBox(
                width: screenWidth * 0.35,
                height: screenWidth * 0.35,
                child: Stack(
                  children: [
                    // Custom painter for multi-colored progress
                    CustomPaint(
                      size: Size(screenWidth * 0.35, screenWidth * 0.35),
                      painter: MultiColorCircularProgressPainter(
                        calorieProgress: calorieProgress,
                        proteinProgress: (currentTotals.protein / goals.protein)
                            .clamp(0.0, 1.0),
                        fatProgress:
                            (currentTotals.fat / goals.fat).clamp(0.0, 1.0),
                        carbsProgress:
                            (currentTotals.carbs / goals.carbs).clamp(0.0, 1.0),
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                        fatColor: Theme.of(context).colorScheme.primary,
                        proteinColor: context.nutritionPrimary,
                        carbsColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    // Center text
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.consumed,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                          Text(
                            '${currentTotals.calories}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.cal,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: screenWidth * 0.06),

              // Macros
              Expanded(
                child: Column(
                  children: [
                    _buildMacroItem(
                      AppLocalizations.of(context)!.fat,
                      currentTotals.fat.round(),
                      goals.fat,
                      Theme.of(context).colorScheme.primary,
                      '🧈',
                      screenWidth,
                      screenHeight,
                      context,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildMacroItem(
                      AppLocalizations.of(context)!.protein,
                      currentTotals.protein.round(),
                      goals.protein,
                      context.nutritionPrimary,
                      '🥩',
                      screenWidth,
                      screenHeight,
                      context,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildMacroItem(
                      AppLocalizations.of(context)!.carbs,
                      currentTotals.carbs.round(),
                      goals.carbs,
                      Theme.of(context).colorScheme.secondary,
                      '🌿',
                      screenWidth,
                      screenHeight,
                      context,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(
    String name,
    int current,
    int target,
    Color color,
    String emoji,
    double screenWidth,
    double screenHeight,
    BuildContext context,
  ) {
    double progress = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: screenWidth * 0.04)),
            SizedBox(width: screenWidth * 0.02),
            Text(
              name,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.008),
        // Progress bar
        Container(
          height: screenHeight * 0.008,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(screenHeight * 0.004),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(screenHeight * 0.004),
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.005),
        Text(
          '${current}${AppLocalizations.of(context)!.grams} / ${target}${AppLocalizations.of(context)!.grams}',
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}k';
    }
    return number.toString();
  }
}

// Multi-color Circular Progress Painter
class MultiColorCircularProgressPainter extends CustomPainter {
  final double calorieProgress;
  final double proteinProgress;
  final double fatProgress;
  final double carbsProgress;
  final Color backgroundColor;
  final Color fatColor;
  final Color proteinColor;
  final Color carbsColor;

  MultiColorCircularProgressPainter({
    required this.calorieProgress,
    required this.proteinProgress,
    required this.fatProgress,
    required this.carbsProgress,
    required this.backgroundColor,
    required this.fatColor,
    required this.proteinColor,
    required this.carbsColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - size.width * 0.08; // Responsive padding
    final strokeWidth = size.width * 0.08; // Responsive stroke width

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw segments for each macro - each gets 1/3 of the circle
    final segments = [
      {
        'progress': fatProgress,
        'color': fatColor,
        'start': -math.pi / 2, // Start from top
      },
      {
        'progress': proteinProgress,
        'color': proteinColor,
        'start': -math.pi / 2 + (2 * math.pi * 0.33), // 1/3 around
      },
      {
        'progress': carbsProgress,
        'color': carbsColor,
        'start': -math.pi / 2 + (2 * math.pi * 0.66), // 2/3 around
      },
    ];

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final progress = segment['progress'] as double;
      final color = segment['color'] as Color;
      final startAngle = segment['start'] as double;

      if (progress > 0) {
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        // Each segment gets 1/3 of the circle (120 degrees)
        final sweepAngle = (2 * math.pi / 3) * progress;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
