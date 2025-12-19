import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../l10n/app_localizations.dart';

class SleepWidget extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? chartColor;
  final Color? deepChartColor;
  final VoidCallback? onTap;

  const SleepWidget({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.chartColor,
    this.deepChartColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<SleepProvider>(
      builder: (context, sleepProvider, child) {
        final l10n = AppLocalizations.of(context)!;

        // Initialize provider if not already done
        if (sleepProvider.currentSchedule == null && !sleepProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sleepProvider.initialize();
          });
        }

        if (sleepProvider.isLoading) {
          return _buildLoadingWidget(context, screenWidth, screenHeight);
        }

        return _buildSleepWidget(
          context,
          screenWidth,
          screenHeight,
          sleepProvider.todaysSleepHours.floor(),
          ((sleepProvider.todaysSleepHours -
                      sleepProvider.todaysSleepHours.floor()) *
                  60)
              .round(),
          sleepProvider.bedtime,
          sleepProvider.wakeTime,
          _getQualityText(context, sleepProvider.todaysSleepQuality),
          _generateChartData(sleepProvider.generateHourlySleepStages()),
        );
      },
    );
  }

  List<Map<String, dynamic>> _generateChartData(List<double> sleepStages) {
    final chartData = <double>[];
    final deepSleepData = <bool>[];
    for (int i = 0; i < sleepStages.length; i += 2) {
      chartData.add(sleepStages[i]);
      deepSleepData.add(sleepStages[i] > 3.5); // Deep sleep threshold
    }
    return [
      {'chartData': chartData, 'deepSleepData': deepSleepData}
    ];
  }

  Widget _buildSleepWidget(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    int sleepHours,
    int sleepMinutes,
    String sleepTime,
    String wakeTime,
    String quality,
    List<Map<String, dynamic>> chartInfo,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final chartData = chartInfo[0]['chartData'] as List<double>;
    final deepSleepData = chartInfo[0]['deepSleepData'] as List<bool>;

    // Responsive dimensions
    final containerPadding = screenWidth * 0.045;
    final borderRadius = screenWidth * 0.05;
    final spacingMedium = screenHeight * 0.025;
    final spacingSmall = screenHeight * 0.012;
    final spacingExtraSmall = screenHeight * 0.006;

    // Font sizes
    final titleFontSize = screenWidth * 0.04;
    final subtitleFontSize = screenWidth * 0.03;
    final durationFontSize = screenWidth * 0.04;
    final timeFontSize = screenWidth * 0.04;
    final labelFontSize = screenWidth * 0.028;

    // Icon sizes
    final mainIconSize = screenWidth * 0.05;
    final timeIconSize = screenWidth * 0.035;
    final arrowIconSize = screenWidth * 0.03;

    // Chart dimensions
    final chartHeight = screenHeight * 0.075;

    // Use original purple colors but make them theme-aware
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDarkMode
            ? const Color(0xFF2D1B3D) // Darker purple for dark mode
            : const Color(0xFFF3E5F5)); // Original light purple
    final iColor = iconColor ??
        (isDarkMode
            ? const Color(0xFFBA68C8) // Lighter purple for dark mode
            : const Color(0xFF8E24AA)); // Original purple[600]
    final tColor = textColor ??
        (isDarkMode
            ? const Color(0xFFE1BEE7) // Light purple text for dark mode
            : const Color(0xFF4A148C)); // Original purple[800]
    final cColor = chartColor ??
        (isDarkMode
            ? const Color(0xFF9C27B0) // Medium purple for dark mode
            : const Color(0xFFCE93D8)); // Original purple[300]
    final deepCColor = deepChartColor ??
        (isDarkMode
            ? const Color(0xFFAD42C4) // Brighter purple for dark mode
            : const Color(0xFF7B1FA2)); // Original purple[700]

    return GestureDetector(
      // Wrap with GestureDetector
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(containerPadding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(spacingExtraSmall),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(spacingSmall),
                  ),
                  child: Icon(Icons.bedtime_outlined,
                      color: iColor, size: mainIconSize),
                ),
                SizedBox(width: spacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.sleep,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: tColor,
                        ),
                      ),
                      SizedBox(height: spacingExtraSmall * 0.3),
                      Text(
                        '$quality ${l10n.sleepQuality.toLowerCase()}',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: tColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sleep Duration
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacingSmall,
                    vertical: spacingExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: Text(
                    '${sleepHours}h ${sleepMinutes}m',
                    style: TextStyle(
                      fontSize: durationFontSize,
                      fontWeight: FontWeight.bold,
                      color: tColor,
                    ),
                  ),
                ),
                // Add arrow icon if tappable
                if (onTap != null) ...[
                  SizedBox(width: spacingExtraSmall),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: arrowIconSize,
                    color: tColor.withOpacity(0.6),
                  ),
                ],
              ],
            ),

            SizedBox(height: spacingMedium),

            // Sleep Chart
            Container(
              height: chartHeight,
              padding: EdgeInsets.symmetric(horizontal: spacingExtraSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(spacingSmall),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  chartData.length,
                  (index) => _buildSleepBar(
                    chartData[index],
                    deepSleepData[index],
                    cColor,
                    deepCColor,
                    screenWidth,
                  ),
                ),
              ),
            ),

            SizedBox(height: spacingMedium * 0.8),

            // Sleep Time Info
            Row(
              children: [
                Expanded(
                  child: _buildTimeInfo(
                    l10n.bedtime,
                    sleepTime,
                    Icons.brightness_2,
                    tColor,
                    timeIconSize,
                    labelFontSize,
                    timeFontSize,
                    spacingExtraSmall,
                  ),
                ),
                Container(
                  width: 1,
                  height: screenHeight * 0.04,
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildTimeInfo(
                    l10n.wakeUp,
                    wakeTime,
                    Icons.wb_sunny,
                    tColor,
                    timeIconSize,
                    labelFontSize,
                    timeFontSize,
                    spacingExtraSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepBar(
    double height,
    bool isDeepSleep,
    Color lightColor,
    Color deepColor,
    double screenWidth,
  ) {
    final barWidth = screenWidth * 0.015;
    final barSpacing = screenWidth * 0.02;

    return Container(
      width: barWidth,
      height: height,
      margin: EdgeInsets.symmetric(vertical: barSpacing * 0.4),
      decoration: BoxDecoration(
        color: isDeepSleep ? deepColor : lightColor,
        borderRadius: BorderRadius.circular(barWidth * 0.5),
        boxShadow: [
          BoxShadow(
            color: (isDeepSleep ? deepColor : lightColor).withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(
    String label,
    String time,
    IconData icon,
    Color color,
    double iconSize,
    double labelFontSize,
    double timeFontSize,
    double spacing,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: color.withOpacity(0.7)),
            SizedBox(width: spacing * 0.7),
            Text(
              label,
              style: TextStyle(
                fontSize: labelFontSize,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing * 0.7),
        Text(
          time,
          style: TextStyle(
            fontSize: timeFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget(
      BuildContext context, double screenWidth, double screenHeight) {
    final containerPadding = screenWidth * 0.045;
    final borderRadius = screenWidth * 0.05;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E24AA)),
        ),
      ),
    );
  }

  String _getQualityText(BuildContext context, int qualityScore) {
    final l10n = AppLocalizations.of(context)!;
    if (qualityScore >= 90) return l10n.excellent;
    if (qualityScore >= 80) return l10n.good;
    if (qualityScore >= 70) return l10n.fair;
    if (qualityScore >= 60) return l10n.poor;
    return l10n.veryPoor;
  }
}
