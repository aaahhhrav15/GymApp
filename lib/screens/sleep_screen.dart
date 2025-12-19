import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import 'dart:math' as math;
import '../l10n/app_localizations.dart';

class SleepDetailScreen extends StatefulWidget {
  const SleepDetailScreen({super.key});

  @override
  State<SleepDetailScreen> createState() => _SleepDetailScreenState();
}

class _SleepDetailScreenState extends State<SleepDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;

  String selectedPeriod = 'Weekly';
  String selectedDay = 'Thu';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _chartAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _chartAnimationController.forward();
    });

    // Initialize sleep provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SleepProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, sleepProvider, child) {
        // Initialize provider if not already done
        if (sleepProvider.currentSchedule == null && !sleepProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sleepProvider.initialize();
          });
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Responsive dimensions
        final horizontalPadding = screenWidth * 0.06;
        final sectionSpacing = screenHeight * 0.02;
        final smallSpacing = screenHeight * 0.01;
        final iconSize = screenWidth * 0.04;
        final buttonIconSize = screenWidth * 0.045;
        final cardPadding = screenWidth * 0.04;
        final containerHeight = screenHeight * 0.25;
        final chartHeight = screenHeight * 0.1;
        final buttonHeight = screenHeight * 0.045;
        final fontSize16 = screenWidth * 0.04;
        final fontSize14 = screenWidth * 0.035;
        final fontSize18 = screenWidth * 0.045;
        final fontSize32 = screenWidth * 0.08;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header
                  _buildHeader(buttonIconSize, iconSize, fontSize18),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        children: [
                          SizedBox(height: smallSpacing),
                          // Sleep Count
                          _buildSleepCount(sleepProvider, fontSize32,
                              fontSize14, cardPadding, iconSize, fontSize14),

                          SizedBox(height: sectionSpacing),
                          // Sleep Duration Chart
                          _buildSleepDurationChart(
                              sleepProvider, containerHeight, cardPadding),

                          SizedBox(height: sectionSpacing),
                          // Sleep Quality Chart
                          _buildSleepQualityChart(
                              sleepProvider,
                              containerHeight,
                              cardPadding,
                              chartHeight,
                              fontSize16,
                              fontSize14),

                          SizedBox(height: sectionSpacing * 1.25),
                          // Sleep Schedule
                          _buildSleepSchedule(sleepProvider, cardPadding,
                              fontSize16, fontSize14, buttonHeight),

                          SizedBox(height: sectionSpacing * 1.25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(double buttonSize, double iconSize, double fontSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive dimensions
    final headerPadding = screenWidth * 0.06;
    final topPadding = screenWidth * 0.03;
    final bottomPadding = screenWidth * 0.02;

    return Container(
      padding: EdgeInsets.fromLTRB(
        headerPadding,
        topPadding,
        headerPadding,
        bottomPadding,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(buttonSize / 2),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: iconSize,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.sleepReport,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _showOptionsMenu,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(buttonSize / 2),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.more_vert,
                size: iconSize,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCount(
      SleepProvider sleepProvider,
      double largeFontSize,
      double smallFontSize,
      double padding,
      double iconSize,
      double badgeFontSize) {
    final selectedData = sleepProvider.getSleepDataForDay(selectedDay) ??
        {'hours': 0.0, 'quality': 0, 'deepSleep': 0.0};
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!
              .hSleep(selectedData['hours'].toString()),
          style: TextStyle(
            fontSize: largeFontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: smallFontSize * 0.3),
        Text(
          AppLocalizations.of(context)!.todaysSleep,
          style: TextStyle(
            fontSize: smallFontSize,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: smallFontSize * 0.6),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: padding * 0.3, vertical: padding * 0.15),
          decoration: BoxDecoration(
            color: (selectedData['quality'] as int) >= 80
                ? const Color(0xFFF3E5F5).withOpacity(0.7)
                : const Color(0xFFFFF3E0).withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (selectedData['quality'] as int) >= 80
                  ? const Color(0xFFCE93D8)
                  : const Color(0xFFFFCC02),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                (selectedData['quality'] as int) >= 80
                    ? Icons.check_circle
                    : Icons.trending_up,
                size: iconSize,
                color: (selectedData['quality'] as int) >= 80
                    ? const Color(0xFF8E24AA)
                    : const Color(0xFFFF8F00),
              ),
              SizedBox(width: iconSize * 0.4),
              Text(
                (selectedData['quality'] as int) >= 80
                    ? 'Great Sleep Quality!'
                    : '${selectedData['quality']}% Quality',
                style: TextStyle(
                  fontSize: badgeFontSize,
                  fontWeight: FontWeight.w600,
                  color: (selectedData['quality'] as int) >= 80
                      ? const Color(0xFF4A148C)
                      : const Color(0xFFE65100),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSleepDurationChart(
      SleepProvider sleepProvider, double containerHeight, double padding) {
    return Container(
      height: containerHeight,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Chart
          Expanded(
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 100),
                  painter: SleepDurationChartPainter(
                    sleepData: sleepProvider.weeklySleepDataMap,
                    selectedDay: selectedDay,
                    animationProgress: _chartAnimation.value,
                  ),
                );
              },
            ),
          ),

          SizedBox(height: padding * 0.75),
          // Day Labels - Scrollable like step screen
          SizedBox(
            height: padding * 2.25,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sleepProvider.weeklySleepDataMap.keys.map((day) {
                  final isSelected = day == selectedDay;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: padding * 0.5),
                      padding: EdgeInsets.symmetric(
                        horizontal: padding,
                        vertical: padding * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8E24AA).withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(padding * 1.125),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF8E24AA).withOpacity(0.3))
                            : null,
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF4A148C)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepQualityChart(
      SleepProvider sleepProvider,
      double containerHeight,
      double padding,
      double chartHeight,
      double fontSize16,
      double fontSize14) {
    final selectedData = sleepProvider.getSleepDataForDay(selectedDay) ??
        {'quality': 85.0, 'mood': 'Good'};
    final qualityPercentage = (selectedData['quality'] as num).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8E24AA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bedtime_outlined,
                  color: const Color(0xFFBA68C8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Sleep Quality',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${qualityPercentage.toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Sleep stages chart
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(24, (index) {
                final sleepStages = sleepProvider.generateHourlySleepStages();
                final stage = sleepStages[index];
                final maxStage = sleepStages.reduce(math.max);
                final height = (stage / maxStage) * 70;

                // Determine color based on sleep stage
                Color barColor;
                if (stage <= 1.5) {
                  barColor = Colors.red[300]!; // Awake
                } else if (stage <= 3) {
                  barColor = Colors.orange[300]!; // Light sleep
                } else if (stage <= 4.5) {
                  barColor = Colors.blue[400]!; // Deep sleep
                } else {
                  barColor = Colors.purple[400]!; // REM sleep
                }

                return AnimatedBuilder(
                  animation: _chartAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 6,
                      height: height * _chartAnimation.value,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                );
              }),
            ),
          ),

          const SizedBox(height: 12),
          // Hour Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '22:00',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                    fontSize: 10),
              ),
              Text(
                '00:00',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                    fontSize: 10),
              ),
              Text(
                '02:00',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                    fontSize: 10),
              ),
              Text(
                '04:00',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                    fontSize: 10),
              ),
              Text(
                '06:00',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                    fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepSchedule(SleepProvider sleepProvider, double padding,
      double fontSize16, double fontSize14, double buttonHeight) {
    return Column(
      children: [
        // Schedule Button
        GestureDetector(
          onTap: _showScheduleDialog,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.31),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(padding),
              border: Border.all(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule_outlined,
                    color: Theme.of(context).colorScheme.onSurface, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Set Sleep Schedule',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        // Sleep Target Button
        GestureDetector(
          onTap: _showTargetDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF8E24AA),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8E24AA).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flag_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Set Sleep Target (${sleepProvider.sleepTargetHours}h${sleepProvider.sleepTargetMinutes > 0 ? ' ${sleepProvider.sleepTargetMinutes}m' : ''})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Set Sleep Target'),
              onTap: () {
                Navigator.pop(context);
                _showTargetDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Sleep Reminders'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Sleep Reminders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Sleep Data'),
              onTap: () {
                Navigator.pop(context);
                _shareSleepData();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showScheduleDialog() {
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
    // Parse current times
    final bedtimeParts = sleepProvider.bedtime.split(':');
    final wakeTimeParts = sleepProvider.wakeTime.split(':');

    final bedtimeHourController = TextEditingController(text: bedtimeParts[0]);
    final bedtimeMinuteController = TextEditingController(
      text: bedtimeParts[1],
    );
    final wakeHourController = TextEditingController(text: wakeTimeParts[0]);
    final wakeMinuteController = TextEditingController(text: wakeTimeParts[1]);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Set Sleep Schedule',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set your ideal bedtime and wake-up time',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

                // Bedtime input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bedtime,
                            color: Colors.purple[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Bedtime',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Bedtime hour
                          Expanded(
                            child: TextFormField(
                              controller: bedtimeHourController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF8E24AA),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                hintText: 'HH',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.4)),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Bedtime minute
                          Expanded(
                            child: TextFormField(
                              controller: bedtimeMinuteController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF8E24AA),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                hintText: 'MM',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.4)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Wake time input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: Colors.orange[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Wake Up',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Wake hour
                          Expanded(
                            child: TextFormField(
                              controller: wakeHourController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.orange[600]!,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                hintText: 'HH',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.4)),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Wake minute
                          Expanded(
                            child: TextFormField(
                              controller: wakeMinuteController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.orange[600]!,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                hintText: 'MM',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.4)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Sleep duration display
                Builder(
                  builder: (context) {
                    final bedHour =
                        int.tryParse(bedtimeHourController.text) ?? 22;
                    final bedMin =
                        int.tryParse(bedtimeMinuteController.text) ?? 30;
                    final wakeHour = int.tryParse(wakeHourController.text) ?? 6;
                    final wakeMin =
                        int.tryParse(wakeMinuteController.text) ?? 2;

                    final bedtimeMinutes = bedHour * 60 + bedMin;
                    final wakeTimeMinutes = wakeHour * 60 + wakeMin;
                    final sleepDuration = wakeTimeMinutes > bedtimeMinutes
                        ? wakeTimeMinutes - bedtimeMinutes
                        : (24 * 60) - bedtimeMinutes + wakeTimeMinutes;
                    final hours = sleepDuration ~/ 60;
                    final minutes = sleepDuration % 60;

                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.green[600],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sleep Duration: ${hours}h ${minutes}m',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                final bedHour = int.tryParse(bedtimeHourController.text);
                final bedMin = int.tryParse(bedtimeMinuteController.text);
                final wakeHour = int.tryParse(wakeHourController.text);
                final wakeMin = int.tryParse(wakeMinuteController.text);

                if (bedHour != null &&
                    bedMin != null &&
                    wakeHour != null &&
                    wakeMin != null &&
                    bedHour >= 0 &&
                    bedHour <= 23 &&
                    bedMin >= 0 &&
                    bedMin <= 59 &&
                    wakeHour >= 0 &&
                    wakeHour <= 23 &&
                    wakeMin >= 0 &&
                    wakeMin <= 59) {
                  final newBedtime =
                      '${bedHour.toString().padLeft(2, '0')}:${bedMin.toString().padLeft(2, '0')}';
                  final newWakeTime =
                      '${wakeHour.toString().padLeft(2, '0')}:${wakeMin.toString().padLeft(2, '0')}';

                  await sleepProvider.updateSleepSchedule(
                    bedtime: newBedtime,
                    wakeTime: newWakeTime,
                    targetHours: sleepProvider.sleepTargetHours,
                    targetMinutes: sleepProvider.sleepTargetMinutes,
                  );
                  Navigator.pop(context);
                  // Snackbar removed - no longer showing success messages
                } else {
                  // Snackbar removed - no longer showing error messages
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E24AA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save Schedule',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTargetDialog() {
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
    int tempHours = sleepProvider.sleepTargetHours;
    int tempMinutes = sleepProvider.sleepTargetMinutes;

    final hoursController = TextEditingController(text: tempHours.toString());
    final minutesController = TextEditingController(
      text: tempMinutes.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Set Sleep Target',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set your ideal sleep duration goal',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6)),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E24AA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF8E24AA).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flag,
                              color: const Color(0xFF8E24AA), size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Sleep Target',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6A1B9A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Hours and Minutes input fields
                      Row(
                        children: [
                          // Hours input
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Hours',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: hoursController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: const Color(0xFFBA68C8),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: const Color(0xFF8E24AA),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).colorScheme.surface,
                                    hintText: '8',
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    final hours = int.tryParse(value);
                                    if (hours != null &&
                                        hours >= 4 &&
                                        hours <= 12) {
                                      setDialogState(() {
                                        tempHours = hours;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Minutes input
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Minutes',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: minutesController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: const Color(0xFFBA68C8),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: const Color(0xFF8E24AA),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).colorScheme.surface,
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    final minutes = int.tryParse(value);
                                    if (minutes != null &&
                                        minutes >= 0 &&
                                        minutes <= 59) {
                                      setDialogState(() {
                                        tempMinutes = minutes;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Total duration display
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.green[600],
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Target: ${tempHours}h ${tempMinutes > 0 ? '${tempMinutes}m' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                final finalHours =
                    int.tryParse(hoursController.text) ?? tempHours;
                final finalMinutes =
                    int.tryParse(minutesController.text) ?? tempMinutes;

                if (finalHours >= 4 &&
                    finalHours <= 12 &&
                    finalMinutes >= 0 &&
                    finalMinutes <= 59) {
                  await sleepProvider.updateSleepSchedule(
                    bedtime: sleepProvider.bedtime,
                    wakeTime: sleepProvider.wakeTime,
                    targetHours: finalHours,
                    targetMinutes: finalMinutes,
                  );
                  Navigator.pop(context);
                  // Snackbar removed - no longer showing success messages
                } else {
                  // Snackbar removed - no longer showing error messages
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E24AA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Set Target',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareSleepData() {
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
    final selectedData = sleepProvider.getSleepDataForDay(selectedDay) ??
        {
          'hours': 8.0,
          'quality': 85.0,
          'deepSleep': 2.5,
        };
    final shareText = '''
😴 Sleep Report for $selectedDay
⏰ Sleep Duration: ${selectedData['hours']} hours
📊 Sleep Quality: ${selectedData['quality']}%
🌙 Deep Sleep: ${selectedData['deepSleep']} hours

Keep prioritizing your sleep! 💤

#SleepHealth #Wellness #HealthyLifestyle
    ''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Share Sleep Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(shareText),
            const SizedBox(height: 16),
            const Text(
              'This would open share dialog in a real app',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Snackbar removed - no longer showing success messages
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E24AA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Share', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    // Snackbar removed - no longer showing coming soon messages
  }

  void _showSuccessSnackBar(String message) {
    // Snackbars removed - no longer showing success messages
  }
}

// Custom painter for sleep duration chart
class SleepDurationChartPainter extends CustomPainter {
  final Map<String, Map<String, dynamic>> sleepData;
  final String selectedDay;
  final double animationProgress;

  SleepDurationChartPainter({
    required this.sleepData,
    required this.selectedDay,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Create gradient
    final gradient = LinearGradient(
      colors: [Colors.purple[300]!, Colors.purple[400]!, Colors.purple[500]!],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = gradient.createShader(rect);

    final maxHours = sleepData.values
        .map((data) => data['hours'] as double)
        .reduce(math.max);
    final minHours = sleepData.values
        .map((data) => data['hours'] as double)
        .reduce(math.min);
    final hourRange = maxHours - minHours;

    final path = Path();
    final points = <Offset>[];

    // Calculate points
    final days = sleepData.keys.toList();
    for (int i = 0; i < days.length; i++) {
      final x = (i / (days.length - 1)) * size.width;
      final normalizedValue = hourRange > 0
          ? (sleepData[days[i]]!['hours'] - minHours) / hourRange
          : 0.5;
      final y = size.height -
          (normalizedValue * size.height * 0.8) -
          size.height * 0.1;
      points.add(Offset(x, y));
    }

    // Create smooth curve
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length; i++) {
        final p0 = i > 0 ? points[i - 1] : points[0];
        final p1 = points[i];
        final p2 = i < points.length - 1 ? points[i + 1] : points[i];

        final cp1x = p0.dx + (p1.dx - p0.dx) * 0.5;
        final cp1y = p0.dy;
        final cp2x = p1.dx - (p2.dx - p1.dx) * 0.5;
        final cp2y = p1.dy;

        path.cubicTo(cp1x, cp1y, cp2x, cp2y, p1.dx, p1.dy);
      }
    }

    // Draw animated path
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isNotEmpty) {
      final pathMetric = pathMetrics.first;
      final extractedPath = pathMetric.extractPath(
        0,
        pathMetric.length * animationProgress,
      );
      canvas.drawPath(extractedPath, paint);
    }

    // Draw points
    final pointPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      if (i / points.length <= animationProgress) {
        final isSelected = days[i] == selectedDay;
        pointPaint.color =
            isSelected ? const Color(0xFF8E24AA) : const Color(0xFFBA68C8);

        canvas.drawCircle(points[i], isSelected ? 6 : 4, pointPaint);

        if (isSelected) {
          // Draw white border for selected point
          final borderPaint = Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.white;
          canvas.drawCircle(points[i], 4, borderPaint);
          pointPaint.color = const Color(0xFF8E24AA);
          canvas.drawCircle(points[i], 3, pointPaint);

          // Draw sleep duration label
          final textPainter = TextPainter(
            text: TextSpan(
              text: '${sleepData[days[i]]!['hours']}h',
              style: TextStyle(
                color: const Color(0xFF8E24AA),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();

          final labelOffset = Offset(
            points[i].dx - textPainter.width / 2,
            points[i].dy - 25,
          );

          // Draw background for label
          final labelBgPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;

          final labelRect = Rect.fromLTWH(
            labelOffset.dx - 4,
            labelOffset.dy - 2,
            textPainter.width + 8,
            textPainter.height + 4,
          );

          canvas.drawRRect(
            RRect.fromRectAndRadius(labelRect, const Radius.circular(8)),
            labelBgPaint,
          );

          textPainter.paint(canvas, labelOffset);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
