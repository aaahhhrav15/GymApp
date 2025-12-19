// File: widgets/water_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/water_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class WaterWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const WaterWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive sizing
    final containerPadding = screenWidth * 0.04; // 4% of screen width
    final containerHeight = screenHeight * 0.17; // 17% of screen height
    final borderRadius = screenWidth * 0.05; // 5% of screen width
    final iconSize = screenWidth * 0.05; // 5% of screen width
    final spacingSmall = screenWidth * 0.015; // 1.5% of screen width
    final spacingMedium = screenHeight * 0.015; // 1.5% of screen height

    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        final l10n = AppLocalizations.of(context)!;

        if (waterProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(containerPadding),
            height: containerHeight,
            decoration: BoxDecoration(
              color: context.waterBackground,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: screenWidth * 0.05,
                height: screenWidth * 0.05,
                child: CircularProgressIndicator(
                  strokeWidth: screenWidth * 0.005,
                  valueColor: const AlwaysStoppedAnimation(Colors.blue),
                ),
              ),
            ),
          );
        }

        // Get current data from provider
        final currentIntake = waterProvider.currentIntake; // in ml
        final dailyGoal = waterProvider.dailyGoal; // in ml

        // Convert to cups (assuming 250ml per cup)
        final currentCups = (currentIntake / 250).round();
        final targetCups = (dailyGoal / 250).round();

        // Convert to liters
        final currentLiters = currentIntake / 1000.0;
        final targetLiters = dailyGoal / 1000.0;

        double progressPercentage =
            dailyGoal > 0 ? (currentIntake / dailyGoal).clamp(0.0, 1.0) : 0.0;
        int percentage = (progressPercentage * 100).round();

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(containerPadding),
            height: containerHeight,
            decoration: BoxDecoration(
              color: context.waterBackground,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: context.waterPrimary,
                      size: iconSize,
                    ),
                    SizedBox(width: spacingSmall),
                    Text(
                      l10n.water,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                    ),
                    const Spacer(),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: screenWidth * 0.03,
                        color: (Theme.of(context).textTheme.bodyLarge?.color ??
                                Colors.blue[800]!)
                            .withOpacity(0.6),
                      ),
                  ],
                ),

                SizedBox(height: spacingMedium),

                // Water drop and info
                Expanded(
                  child: Row(
                    children: [
                      // Water drop visualization
                      SizedBox(
                        width: screenWidth * 0.15,
                        height: screenWidth * 0.175,
                        child: CustomPaint(
                          size: Size(screenWidth * 0.15, screenWidth * 0.175),
                          painter: WaterDropPainter(
                            progress: progressPercentage,
                            waterColor: context.waterPrimary,
                            lightWaterColor:
                                context.waterPrimary.withOpacity(0.3),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: screenWidth * 0.04),
                              child: Text(
                                '$percentage%',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: spacingSmall),

                      // Water info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$currentCups/$targetCups ${l10n.glasses}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(height: spacingSmall * 0.5),
                            Text(
                              '${currentLiters.toStringAsFixed(1)}L / ${targetLiters.toStringAsFixed(1)}L',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class WaterDropPainter extends CustomPainter {
  final double progress;
  final Color waterColor;
  final Color lightWaterColor;

  WaterDropPainter({
    required this.progress,
    required this.waterColor,
    required this.lightWaterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Water drop outline path
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Create water drop shape
    path.moveTo(width * 0.5, height * 0.1); // Top point

    // Right curve
    path.quadraticBezierTo(
      width * 0.85,
      height * 0.4,
      width * 0.85,
      height * 0.65,
    );

    // Bottom curve
    path.quadraticBezierTo(
      width * 0.85,
      height * 0.9,
      width * 0.5,
      height * 0.9,
    );

    path.quadraticBezierTo(
      width * 0.15,
      height * 0.9,
      width * 0.15,
      height * 0.65,
    );

    // Left curve
    path.quadraticBezierTo(
      width * 0.15,
      height * 0.4,
      width * 0.5,
      height * 0.1,
    );

    path.close();

    // Draw light water background (empty part)
    final lightPaint = Paint()
      ..color = lightWaterColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, lightPaint);

    // Draw filled water based on progress
    if (progress > 0) {
      final fillHeight = height * 0.8 * progress; // 80% of drop height for fill
      final fillTop = height * 0.9 - fillHeight; // Start from bottom

      // Create clipping path for filled portion
      final fillPath = Path();
      fillPath.addRect(
        Rect.fromLTWH(0, fillTop, width, fillHeight + height * 0.1),
      );

      canvas.save();
      canvas.clipPath(path); // Clip to drop shape
      canvas.clipPath(fillPath); // Clip to fill area

      // Draw filled water
      final waterPaint = Paint()
        ..color = waterColor
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, waterPaint);

      // Add water wave effect
      _drawWave(canvas, size, fillTop, waterColor);

      canvas.restore();
    }

    // Draw drop outline
    final outlinePaint = Paint()
      ..color = waterColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, outlinePaint);
  }

  void _drawWave(Canvas canvas, Size size, double waveTop, Color color) {
    final wavePaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final wavePath = Path();
    final waveHeight = 6.0;
    final waveLength = size.width / 2;

    wavePath.moveTo(0, waveTop);

    for (double x = 0; x <= size.width; x += 1) {
      final y = waveTop + math.sin((x / waveLength) * 2 * math.pi) * waveHeight;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
