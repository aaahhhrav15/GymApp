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

  // Theme-aware colors
  Color _getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF64B5F6) // Light blue for dark mode
        : const Color(0xFF1976D2); // Deep blue for light mode
  }

  Color _getSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF90CAF9)
        : const Color(0xFF0D47A1);
  }

  List<Color> _getGradientColors(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF0D1B2A),
            const Color(0xFF1B2838),
            const Color(0xFF233545),
          ]
        : [
            const Color(0xFFE3F2FD),
            const Color(0xFFBBDEFB),
            const Color(0xFF90CAF9),
          ];
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Responsive sizing
    final containerPadding = screenWidth * 0.04;
    final containerHeight = screenHeight * 0.17;
    final borderRadius = screenWidth * 0.05;
    final iconSize = screenWidth * 0.05;
    final spacingSmall = screenWidth * 0.015;
    final spacingMedium = screenHeight * 0.015;

    final primaryColor = _getPrimaryColor(context);
    final gradientColors = _getGradientColors(context);

    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        final l10n = AppLocalizations.of(context)!;

        if (waterProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(containerPadding),
            height: containerHeight,
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF0D1B2A)
                  : const Color(0xFFE3F2FD),
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
            child: Center(
              child: SizedBox(
                width: screenWidth * 0.05,
                height: screenWidth * 0.05,
                child: CircularProgressIndicator(
                  strokeWidth: screenWidth * 0.005,
                  valueColor: AlwaysStoppedAnimation(primaryColor),
                ),
              ),
            ),
          );
        }

        // Get current data from provider
        final currentIntake = waterProvider.currentIntake;
        final dailyGoal = waterProvider.dailyGoal;

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
              color: isDark 
                  ? const Color(0xFF0D1B2A)
                  : const Color(0xFFE3F2FD),
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
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.015),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(isDark ? 0.25 : 0.15),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Icon(
                        Icons.water_drop,
                        color: primaryColor,
                        size: iconSize,
                      ),
                    ),
                    SizedBox(width: spacingSmall),
                    Text(
                      l10n.water,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: screenWidth * 0.03,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                  ],
                ),

                SizedBox(height: spacingMedium),

                // Water drop and info
                Expanded(
                  child: Row(
                    children: [
                      // Water drop visualization - shifted left
                      Padding(
                        padding: EdgeInsets.only(right: screenWidth * 0.02),
                        child: SizedBox(
                          width: screenWidth * 0.13, // Slightly smaller to make room
                          height: screenWidth * 0.175,
                          child: CustomPaint(
                            size: Size(screenWidth * 0.13, screenWidth * 0.175),
                            painter: WaterDropPainter(
                              progress: progressPercentage,
                              waterColor: primaryColor,
                              lightWaterColor: primaryColor.withOpacity(isDark ? 0.3 : 0.25),
                              isDark: isDark,
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: screenWidth * 0.04),
                                child: Text(
                                  '$percentage%',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.032,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Water info - moved up
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start, // Align to top
                          children: [
                            SizedBox(height: screenHeight * 0.01), // Small top padding
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$currentCups/$targetCups ${l10n.glasses}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.062, // Larger font for glasses
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.grey[900],
                                ),
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(height: spacingSmall * 0.5),
                            Text(
                              '${currentLiters.toStringAsFixed(1)}L / ${targetLiters.toStringAsFixed(1)}L',
                              style: TextStyle(
                                fontSize: screenWidth * 0.028, // Consistent label size
                                color: isDark ? Colors.white60 : Colors.grey[600],
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
  final bool isDark;

  WaterDropPainter({
    required this.progress,
    required this.waterColor,
    required this.lightWaterColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Water drop outline path
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Create water drop shape
    path.moveTo(width * 0.5, height * 0.1);

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
      final fillHeight = height * 0.8 * progress;
      final fillTop = height * 0.9 - fillHeight;

      // Create clipping path for filled portion
      final fillPath = Path();
      fillPath.addRect(
        Rect.fromLTWH(0, fillTop, width, fillHeight + height * 0.1),
      );

      canvas.save();
      canvas.clipPath(path);
      canvas.clipPath(fillPath);

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
      ..color = waterColor.withOpacity(isDark ? 0.5 : 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, outlinePaint);
  }

  void _drawWave(Canvas canvas, Size size, double waveTop, Color color) {
    final wavePaint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final wavePath = Path();
    final waveHeight = 5.0;
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
