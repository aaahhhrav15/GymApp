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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive sizing
    final containerPadding = screenWidth * 0.04; // 4% of screen width
    final containerHeight = screenHeight * 0.17; // 17% of screen height
    final borderRadius = screenWidth * 0.05; // 5% of screen width
    final iconSize = screenWidth * 0.05; // 5% of screen width
    final arrowIconSize = screenWidth * 0.03; // 3% of screen width
    final spacingSmall = screenWidth * 0.015; // 1.5% of screen width
    final spacingMedium = screenWidth * 0.03; // 3% of screen width
    final gaugeSize = screenWidth * 0.2; // 20% of screen width

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(containerPadding),
        height: containerHeight,
        decoration: BoxDecoration(
          color: context.bmiBackground,
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
                  Icons.accessibility,
                  color: context.bmiPrimary,
                  size: iconSize,
                ),
                SizedBox(width: spacingSmall),
                Flexible(
                  child: Text(
                    l10n.bmi,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                ),
                const Spacer(), // Add spacer
                if (onTap != null) // Show arrow icon if tappable
                  Icon(
                    Icons.arrow_forward_ios,
                    size: arrowIconSize,
                    color: (Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.orange[800]!)
                        .withOpacity(0.6),
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
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            bmiValue > 0 ? status : l10n.unknown,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: bmiValue > 0
                                          ? _getStatusColor()
                                          : Colors.grey[600]!,
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
                      painter: BMIGaugePainter(bmiValue, screenWidth),
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
    if (bmiValue < 18.5) return Colors.blue[600]!;
    if (bmiValue < 25) return Colors.green[600]!;
    if (bmiValue < 30) return Colors.orange[600]!;
    return Colors.red[600]!;
  }
}

class BMIGaugePainter extends CustomPainter {
  final double bmiValue;
  final double screenWidth;

  BMIGaugePainter(this.bmiValue, this.screenWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 -
        screenWidth * 0.02; // Responsive padding

    // Define BMI ranges and colors
    final List<BMIRange> ranges = [
      BMIRange(15, 18.5, Colors.blue[300]!, 'Under'),
      BMIRange(18.5, 25, Colors.green[400]!, 'Normal'),
      BMIRange(25, 30, Colors.orange[400]!, 'Over'),
      BMIRange(30, 35, Colors.red[400]!, 'Obese'),
    ];

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = screenWidth * 0.02 // Responsive stroke width
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
    double totalRange = 20; // BMI range from 15 to 35

    for (var range in ranges) {
      final paint = Paint()
        ..color = range.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = screenWidth * 0.02 // Responsive stroke width
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
        : 20; // Default to 20 if no BMI
    double normalizedBMI = (clampedBMI - 15) / totalRange;
    double needleAngle = -math.pi * 0.75 + (math.pi * 1.5 * normalizedBMI);

    // Draw needle only if BMI value is available
    if (bmiValue > 0) {
      final needlePaint = Paint()
        ..color = Colors.black87
        ..strokeWidth = screenWidth * 0.008 // Responsive needle width
        ..strokeCap = StrokeCap.round;

      final needleEnd = Offset(
        center.dx + radius * 0.8 * math.cos(needleAngle),
        center.dy + radius * 0.8 * math.sin(needleAngle),
      );

      canvas.drawLine(center, needleEnd, needlePaint);

      // Draw center circle
      final centerPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
          center, screenWidth * 0.01, centerPaint); // Responsive center circle
    }

    // Draw labels
    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: screenWidth * 0.025, // Responsive font size
      fontWeight: FontWeight.w500,
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
      final labelRadius =
          radius + screenWidth * 0.06; // Increased distance from gauge
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
