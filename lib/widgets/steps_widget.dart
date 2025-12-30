// File: widgets/steps_widget.dart - Theme-aware version
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/steps_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class StepsWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const StepsWidget({
    super.key,
    this.onTap,
  });

  @override
  State<StepsWidget> createState() => _StepsWidgetState();
}

class _StepsWidgetState extends State<StepsWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize steps provider if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceSyncAndRefresh();
    });
  }

  Future<void> _forceSyncAndRefresh() async {
    // Force sync from background service when widget is first built
    final stepsProvider = context.read<StepsProvider>();
    if (!stepsProvider.isInitialized) {
      await stepsProvider.refresh();
    } else {
      // Even if initialized, force sync to get latest background service data
      await stepsProvider.refresh();
    }
  }

  // Theme-aware colors
  Color _getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFFB74D) // Yellow/amber for dark mode
        : const Color(0xFFE64A19); // Deep orange for light mode
  }

  Color _getSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFFCC80) // Light yellow for dark mode
        : const Color(0xFFBF360C);
  }

  List<Color> _getGradientColors(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF2D2419), // Yellowish dark tone
            const Color(0xFF3D2F1F),
            const Color(0xFF4D3A25),
          ]
        : [
            const Color(0xFFFFF3E0),
            const Color(0xFFFFE0B2),
            const Color(0xFFFFCC80),
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
    final titleFontSize = screenWidth * 0.035;
    final mainNumberFontSize = screenWidth * 0.055; // Consistent main number
    final secondaryFontSize = screenWidth * 0.03; // Consistent secondary text
    final labelFontSize = screenWidth * 0.028; // Consistent labels
    final statusFontSize = screenWidth * 0.025; // Consistent status
    final spacingSmall = screenWidth * 0.015;
    final spacingMedium = screenHeight * 0.015;

    final primaryColor = _getPrimaryColor(context);
    final secondaryColor = _getSecondaryColor(context);
    final gradientColors = _getGradientColors(context);

    return Consumer<StepsProvider>(
      builder: (context, stepsProvider, child) {
        final l10n = AppLocalizations.of(context)!;

        if (stepsProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(containerPadding),
            height: containerHeight,
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF2D2419) // Yellowish dark tone
                  : const Color(0xFFFFF3E0),
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
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final currentSteps = stepsProvider.currentSteps;
        final targetSteps = stepsProvider.dailyGoal;
        final pedestrianStatus = stepsProvider.pedestrianStatus;
        final progressPercentage = stepsProvider.progressPercentage;
        final percentage = (progressPercentage * 100).round();

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.all(containerPadding),
            height: containerHeight,
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF2D2419) // Yellowish dark tone
                  : const Color(0xFFFFF3E0),
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
                // Header with icon and status
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.015),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(isDark ? 0.25 : 0.15),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Icon(
                        _getStatusIcon(pedestrianStatus),
                        color: primaryColor,
                        size: iconSize,
                      ),
                    ),
                    SizedBox(width: spacingSmall),
                    Text(
                      l10n.steps,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    // Status indicator
                    Container(
                      width: screenWidth * 0.02,
                      height: screenWidth * 0.02,
                      decoration: BoxDecoration(
                        color: _getStatusColor(pedestrianStatus),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(pedestrianStatus).withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: spacingSmall * 0.5),
                    if (widget.onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: screenWidth * 0.03,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                  ],
                ),

                SizedBox(height: spacingMedium),

                // Progress circle and steps info
                Expanded(
                  child: Row(
                    children: [
                      // Circular progress indicator
                      SizedBox(
                        width: screenWidth * 0.175,
                        height: screenWidth * 0.175,
                        child: Stack(
                          children: [
                            // Background circle
                            SizedBox(
                              width: screenWidth * 0.175,
                              height: screenWidth * 0.175,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: screenWidth * 0.015,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor.withOpacity(isDark ? 0.3 : 0.25),
                                ),
                              ),
                            ),
                            // Progress circle with animation
                            SizedBox(
                              width: screenWidth * 0.175,
                              height: screenWidth * 0.175,
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOutCubic,
                                tween: Tween<double>(
                                  begin: 0.0,
                                  end: progressPercentage,
                                ),
                                builder: (context, value, child) {
                                  return CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: screenWidth * 0.015,
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Percentage text in center
                            Center(
                              child: TweenAnimationBuilder<int>(
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOutCubic,
                                tween: IntTween(begin: 0, end: percentage),
                                builder: (context, value, child) {
                                  return Text(
                                    '$value%',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.bold,
                                      color: secondaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: spacingSmall),

                      // Steps info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated steps count
                            TweenAnimationBuilder<int>(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              tween: IntTween(begin: 0, end: currentSteps),
                              builder: (context, value, child) {
                                return FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _formatNumber(value),
                                    style: TextStyle(
                                      fontSize: mainNumberFontSize, // Consistent size
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.grey[900],
                                    ),
                                    maxLines: 1,
                                  ),
                                );
                              },
                            ),
                            Text(
                              '/ ${_formatNumber(targetSteps)}',
                              style: TextStyle(
                                fontSize: secondaryFontSize, // Consistent size
                                color: isDark ? Colors.white60 : Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: spacingSmall * 0.5),
                            // Status text
                            Row(
                              children: [
                                Text(
                                  _getStatusText(pedestrianStatus),
                                  style: TextStyle(
                                    fontSize: statusFontSize,
                                    color: isDark ? Colors.white54 : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (stepsProvider.isGoalAchieved) ...[
                                  SizedBox(width: spacingSmall * 0.5),
                                  Icon(
                                    Icons.star,
                                    size: statusFontSize * 1.2,
                                    color: Colors.amber,
                                  ),
                                ],
                              ],
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

  IconData _getStatusIcon(String pedestrianStatus) {
    switch (pedestrianStatus) {
      case 'walking':
        return Icons.directions_walk;
      case 'stopped':
        return Icons.pause_circle_outline;
      default:
        return Icons.directions_walk;
    }
  }

  Color _getStatusColor(String pedestrianStatus) {
    switch (pedestrianStatus) {
      case 'walking':
        return Colors.green;
      case 'stopped':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String pedestrianStatus) {
    final l10n = AppLocalizations.of(context)!;
    switch (pedestrianStatus) {
      case 'walking':
        return l10n.walking;
      case 'stopped':
        return l10n.stopped;
      default:
        return l10n.tracking;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K';
    }
    return number.toString();
  }
}
