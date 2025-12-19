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
    final titleFontSize = screenWidth * 0.035; // 3.5% of screen width
    final stepsFontSize = screenWidth * 0.06; // 6% of screen width
    final targetFontSize = screenWidth * 0.03; // 3% of screen width
    final statusFontSize = screenWidth * 0.025; // 2.5% of screen width
    final spacingSmall = screenWidth * 0.015; // 1.5% of screen width
    final spacingMedium = screenHeight * 0.015; // 1.5% of screen height

    return Consumer<StepsProvider>(
      builder: (context, stepsProvider, child) {
        final l10n = AppLocalizations.of(context)!;

        if (stepsProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(containerPadding),
            height: containerHeight,
            decoration: BoxDecoration(
              color: context.stepsBackground,
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
              child: CircularProgressIndicator(
                color: context.stepsPrimary,
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
              color: context.stepsBackground,
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
                // Header with icon and status
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(pedestrianStatus),
                      color: context.stepsPrimary,
                      size: iconSize,
                    ),
                    SizedBox(width: spacingSmall),
                    Text(
                      l10n.steps,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
                      ),
                    ),
                    SizedBox(width: spacingSmall * 0.5),
                    if (widget.onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: screenWidth * 0.03,
                        color: (Theme.of(context).textTheme.bodyLarge?.color ??
                                Colors.orange[800]!)
                            .withOpacity(0.6),
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
                                  context.stepsPrimary.withOpacity(0.3),
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
                                      context.stepsPrimary,
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
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: context.stepsSecondary,
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
                                      fontSize: stepsFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                    maxLines: 1,
                                  ),
                                );
                              },
                            ),
                            Text(
                              '/ ${_formatNumber(targetSteps)}',
                              style: TextStyle(
                                fontSize: targetFontSize,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
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
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (stepsProvider.isGoalAchieved) ...[
                                  SizedBox(width: spacingSmall * 0.5),
                                  Icon(
                                    Icons.star,
                                    size: statusFontSize,
                                    color: context.stepsPrimary,
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
