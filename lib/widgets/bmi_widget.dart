import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class BMIGaugeWidget extends StatelessWidget {
  final double bmiValue;
  final String status;
  final VoidCallback? onTap;

  const BMIGaugeWidget({
    super.key,
    required this.bmiValue,
    required this.status,
    this.onTap,
  });

  // Theme-aware colors - matching date of birth box (Colors.pink)
  Color _getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.pink[300]! // Light pink for dark mode
        : Colors.pink; // Material pink for light mode
  }

  Color _getSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.pink[200]!
        : Colors.pink[700]!;
  }

  List<Color> _getGradientColors(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF2D1A1F),
            const Color(0xFF3A2430),
            const Color(0xFF472E41),
          ]
        : [
            const Color(0xFFFCE4EC),
            const Color(0xFFF8BBD9),
            const Color(0xFFF48FB1),
          ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Responsive sizing
    final containerPadding = screenWidth * 0.04;
    final containerHeight = screenHeight * 0.17;
    final borderRadius = screenWidth * 0.05;
    final iconSize = screenWidth * 0.05;
    final arrowIconSize = screenWidth * 0.03;
    final spacingSmall = screenWidth * 0.015;
    final spacingMedium = screenWidth * 0.03;
    final gaugeSize = screenWidth * 0.2;

    final primaryColor = _getPrimaryColor(context);
    final gradientColors = _getGradientColors(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(containerPadding),
        height: containerHeight,
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF2D1A1F)
              : const Color(0xFFFCE4EC),
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
                    Icons.accessibility,
                    color: primaryColor,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: spacingSmall),
                Flexible(
                  child: Text(
                    l10n.bmi,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: arrowIconSize,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
              ],
            ),
            SizedBox(height: spacingMedium),

            // BMI Gauge
            Expanded(
              child: Row(
                children: [
                  // Left side - BMI value and status
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            bmiValue > 0
                                ? bmiValue.toStringAsFixed(1)
                                : l10n.unknown,
                            style: TextStyle(
                              fontSize: screenWidth * 0.055, // Consistent main number size
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.grey[900],
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            bmiValue > 0 ? status : l10n.unknown,
                            style: TextStyle(
                              fontSize: screenWidth * 0.028, // Consistent label size
                              color: bmiValue > 0
                                  ? _getStatusColor()
                                  : (isDark ? Colors.white54 : Colors.grey[600]),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side - Gauge
                  Expanded(
                    flex: 3,
                    child: CustomPaint(
                      size: Size(gaugeSize, gaugeSize),
                      painter: BMIGaugePainter(bmiValue, screenWidth, isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (bmiValue < 18.5) return Colors.lightBlue[400]!;
    if (bmiValue < 25) return Colors.green[500]!;
    if (bmiValue < 30) return Colors.orange[500]!;
    return Colors.red[500]!;
  }
}

class BMIGaugePainter extends CustomPainter {
  final double bmiValue;
  final double screenWidth;
  final bool isDark;

  BMIGaugePainter(this.bmiValue, this.screenWidth, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - screenWidth * 0.02;

    // Define BMI ranges and colors
    final List<BMIRange> ranges = [
      BMIRange(15, 18.5, Colors.blue[400]!, 'Under'),
      BMIRange(18.5, 25, Colors.green[500]!, 'Normal'),
      BMIRange(25, 30, Colors.orange[500]!, 'Over'),
      BMIRange(30, 35, Colors.red[500]!, 'Obese'),
    ];

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = screenWidth * 0.02
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      backgroundPaint,
    );

    // Draw colored segments
    double startAngle = -math.pi * 0.75;
    double totalRange = 20;

    for (var range in ranges) {
      final paint = Paint()
        ..color = range.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = screenWidth * 0.02
        ..strokeCap = StrokeCap.round;

      double rangeSize = range.max - range.min;
      double sweepAngle = (rangeSize / totalRange) * math.pi * 1.5;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Calculate needle position
    double clampedBMI = bmiValue > 0
        ? math.max(15, math.min(35, bmiValue))
        : 20;
    double normalizedBMI = (clampedBMI - 15) / totalRange;
    double needleAngle = -math.pi * 0.75 + (math.pi * 1.5 * normalizedBMI);

    // Draw needle only if BMI value is available
    if (bmiValue > 0) {
      final needlePaint = Paint()
        ..color = isDark ? Colors.white : Colors.grey[800]!
        ..strokeWidth = screenWidth * 0.008
        ..strokeCap = StrokeCap.round;

      final needleEnd = Offset(
        center.dx + radius * 0.8 * math.cos(needleAngle),
        center.dy + radius * 0.8 * math.sin(needleAngle),
      );

      canvas.drawLine(center, needleEnd, needlePaint);

      // Draw center circle
      final centerPaint = Paint()
        ..color = isDark ? Colors.white : Colors.grey[800]!
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, screenWidth * 0.01, centerPaint);
    }

    // Draw labels with proper visibility
    final textStyle = TextStyle(
      color: isDark ? Colors.white70 : Colors.grey[700],
      fontSize: screenWidth * 0.022,
      fontWeight: FontWeight.w600,
    );

    final labelPositions = [
      {'text': 'Under', 'angle': -math.pi * 0.7},
      {'text': 'Normal', 'angle': -math.pi * 0.25},
      {'text': 'Over', 'angle': math.pi * 0.25},
      {'text': 'Obese', 'angle': math.pi * 0.7},
    ];

    for (var label in labelPositions) {
      final textPainter = TextPainter(
        text: TextSpan(text: label['text'] as String, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final angle = label['angle'] as double;
      final labelRadius = radius + screenWidth * 0.055;
      final offset = Offset(
        center.dx + labelRadius * math.cos(angle) - textPainter.width / 2,
        center.dy + labelRadius * math.sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BMIRange {
  final double min;
  final double max;
  final Color color;
  final String label;

  BMIRange(this.min, this.max, this.color, this.label);
}
