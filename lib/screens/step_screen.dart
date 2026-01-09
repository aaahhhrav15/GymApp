import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/steps_provider.dart';
import '../providers/profile_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class StepsDetailScreen extends StatefulWidget {
  const StepsDetailScreen({super.key});

  @override
  State<StepsDetailScreen> createState() => _StepsDetailScreenState();
}

class _StepsDetailScreenState extends State<StepsDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressAnimationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _chartAnimation;

  String selectedDay = 'Today';
  Map<String, int> weeklySteps = {};
  bool _isViewingToday = true;
  int _currentPeriodOffset = 0; // 0 = today-6, 1 = today-13, 2 = today-20, 3 = today-27
  Map<String, int> _periodSteps = {}; // Map of date strings to step counts

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStepsData();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _chartAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
    
    // Start progress and chart animations after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _progressAnimationController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _chartAnimationController.forward();
      }
    });
  }

  void _initializeStepsData() async {
    final stepsProvider = context.read<StepsProvider>();

    if (!stepsProvider.isInitialized) {
      await stepsProvider.refresh();
    } else {
      await stepsProvider.refresh();
    }

    await _loadPeriodData(stepsProvider, 0);
  }

  Future<void> _loadPeriodData(StepsProvider stepsProvider, int offset) async {
    final periodData = await stepsProvider.getStepsFor7DayPeriod(offset, todaySteps: stepsProvider.currentSteps);
    final today = DateTime.now();
    final todayDateStr = _formatDate(today);

    setState(() {
      _currentPeriodOffset = offset;
      _periodSteps = periodData;
      
      // Set selected day to today if in current period, otherwise to the most recent day
      if (offset == 0 && periodData.containsKey(todayDateStr)) {
        selectedDay = _getDayAbbreviation(today.weekday);
      _isViewingToday = true;
      } else {
        // Find the most recent day in this period
        final sortedDates = periodData.keys.toList()..sort((a, b) => b.compareTo(a));
        if (sortedDates.isNotEmpty) {
          final mostRecentDate = DateTime.parse(sortedDates.first);
          selectedDay = _formatDateForDisplay(mostRecentDate);
          _isViewingToday = false;
        }
      }
    });
    
    // Convert period data to weekly format for backward compatibility
    _convertPeriodToWeeklyFormat();
  }

  void _convertPeriodToWeeklyFormat() {
    // Convert date-based map to day-based map for display
    // Sort dates and map each to its day abbreviation
    Map<String, int> converted = {};
    final sortedDates = _periodSteps.keys.toList()..sort();
    
    for (var dateStr in sortedDates) {
      final date = DateTime.parse(dateStr);
      final dayAbbr = _getDayAbbreviation(date.weekday);
      converted[dayAbbr] = _periodSteps[dateStr] ?? 0;
    }
    
    weeklySteps = converted;
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  String _formatDateForDisplay(DateTime date) {
    final today = DateTime.now();
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return _getDayAbbreviation(date.weekday);
    }
    // Return date string like "12/25" for display
    return '${date.month}/${date.day}';
  }

  void _onDaySelected(String day) async {
    // Legacy method for backward compatibility
    final today = DateTime.now();
    final todayDateStr = _formatDate(today);
    
    // Find the date that matches this day selection
    String? matchedDateStr;
    for (var entry in _periodSteps.entries) {
      final date = DateTime.parse(entry.key);
      final dayAbbr = _getDayAbbreviation(date.weekday);
      if (dayAbbr == day || day == _formatDateForDisplay(date)) {
        matchedDateStr = entry.key;
        break;
      }
    }
    
    if (matchedDateStr != null) {
      final matchedDate = DateTime.parse(matchedDateStr);
      _onDateSelected(matchedDateStr, day, _formatDateForDisplay(matchedDate));
    }
  }
  
  void _onDateSelected(String dateStr, String dayAbbr, String dateDisplay) async {
    final today = DateTime.now();
    final todayDateStr = _formatDate(today);

    setState(() {
      // Store the display format for selection
      selectedDay = dateDisplay;
      
      // Check if selected day is today
      _isViewingToday = dateStr == todayDateStr;
    });
  }
  
  Future<void> _navigatePeriod(int direction) async {
    final stepsProvider = context.read<StepsProvider>();
    final newOffset = _currentPeriodOffset + direction;
    
    // Clamp between 0 and 3 (0 = last 7 days, 3 = 28-21 days ago)
    if (newOffset >= 0 && newOffset <= 3) {
      await _loadPeriodData(stepsProvider, newOffset);

    // Restart animations
    _progressAnimationController.reset();
    _progressAnimationController.forward();
    _chartAnimationController.reset();
    _chartAnimationController.forward();
    }
  }
  
  String _getPeriodLabel() {
    if (_currentPeriodOffset == 0) {
      return 'Last 7 Days';
    } else {
      final startDay = _currentPeriodOffset * 7 + 1;
      final endDay = (_currentPeriodOffset + 1) * 7;
      return 'Days $endDay-$startDay Ago';
    }
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return 'Mon';
    }
  }

  String _getLocalizedDay(String day, AppLocalizations l10n) {
    switch (day) {
      case 'Mon':
        return l10n.mon;
      case 'Tue':
        return l10n.tue;
      case 'Wed':
        return l10n.wed;
      case 'Thu':
        return l10n.thu;
      case 'Fri':
        return l10n.fri;
      case 'Sat':
        return l10n.sat;
      case 'Sun':
        return l10n.sun;
      default:
        return day;
    }
  }

  bool _isDayInFuture(String day) {
    final now = DateTime.now();
    final today = _getDayAbbreviation(now.weekday);
    final todayIndex = _getDayIndex(today);
    final dayIndex = _getDayIndex(day);
    return dayIndex > todayIndex;
  }

  int _getDayIndex(String dayAbbr) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.indexOf(dayAbbr);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressAnimationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final horizontalPadding = screenWidth * 0.04;
    final sectionSpacing = screenHeight * 0.018;

    // Steps color scheme - warm orange/amber
    final stepsColor = isDark ? const Color(0xFFFFB74D) : const Color(0xFFFF9800);
    final stepsColorLight = isDark ? const Color(0xFFFFE0B2) : const Color(0xFFFFF3E0);
    final backgroundColor = isDark ? const Color(0xFF1A1512) : const Color(0xFFFFF8F0);
    final cardColor = isDark ? const Color(0xFF2D2319) : Colors.white;

    return Consumer<StepsProvider>(
      builder: (context, stepsProvider, child) {
        // Get steps for selected day
        int currentSteps = 0;
        if (_isViewingToday) {
          currentSteps = stepsProvider.currentSteps;
        } else {
          // Find the date that matches the selected day
          for (var entry in _periodSteps.entries) {
            final date = DateTime.parse(entry.key);
            final dayAbbr = _getDayAbbreviation(date.weekday);
            final dateDisplay = _formatDateForDisplay(date);
            if (dayAbbr == selectedDay || selectedDay == dateDisplay || selectedDay == entry.key) {
              currentSteps = entry.value;
              break;
            }
          }
        }
        final dailyGoal = stepsProvider.dailyGoal;
        final pedestrianStatus = stepsProvider.pedestrianStatus;
        final progressPercentage = (currentSteps / dailyGoal).clamp(0.0, 1.0);
        final percentage = (progressPercentage * 100).toInt();

        if (stepsProvider.isLoading) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: stepsColor),
            ),
          );
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(isDark, stepsColor),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: sectionSpacing),

                          // Permission warning if needed
                          if (!stepsProvider.isUsingRealPedometer)
                            _buildPermissionWarning(stepsProvider, l10n, isDark, stepsColor, cardColor),

                          // Main Progress Circle
                          _buildProgressCircle(
                            currentSteps,
                            dailyGoal,
                            progressPercentage,
                            percentage,
                            pedestrianStatus,
                            isDark,
                            stepsColor,
                            stepsColorLight,
                            cardColor,
                            l10n,
                          ),

                          SizedBox(height: sectionSpacing),

                          // Stats Row
                          _buildStatsRow(
                            currentSteps,
                            dailyGoal,
                            isDark,
                            stepsColor,
                            cardColor,
                            l10n,
                          ),

                          SizedBox(height: sectionSpacing),

                          // Weekly Chart
                          _buildWeeklyChart(isDark, stepsColor, stepsColorLight, cardColor, l10n),

                          SizedBox(height: sectionSpacing),

                          // Set Goal Button
                          _buildSetGoalButton(dailyGoal, stepsProvider, isDark, stepsColor, l10n),

                          SizedBox(height: screenHeight * 0.1),
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

  Widget _buildHeader(bool isDark, Color stepsColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerPadding = screenWidth * 0.04;
    final buttonSize = screenWidth * 0.11;
    final iconSize = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.05;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: headerPadding,
        vertical: screenWidth * 0.03,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: iconSize * 0.7,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.stepsDetails,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          SizedBox(width: buttonSize),
        ],
      ),
    );
  }

  Widget _buildPermissionWarning(
    StepsProvider stepsProvider,
    AppLocalizations l10n,
    bool isDark,
    Color stepsColor,
    Color cardColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red[400],
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.usingSimulatedStepData,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.simulatedStepDataMessage,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await stepsProvider.retryPedometerSetup();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [stepsColor, stepsColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: stepsColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      l10n.enableRealSteps,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(
    int currentSteps,
    int dailyGoal,
    double progressPercentage,
    int percentage,
    String pedestrianStatus,
    bool isDark,
    Color stepsColor,
    Color stepsColorLight,
    Color cardColor,
    AppLocalizations l10n,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive circle size - smaller on smaller screens
    final circleSize = math.min(screenWidth * 0.52, screenHeight * 0.28);
    final innerContentSize = circleSize * 0.7; // Content area inside the ring
    
    // Responsive font sizes
    final stepsFontSize = math.min(circleSize * 0.18, 38.0);
    final labelFontSize = math.min(circleSize * 0.07, 14.0);
    final iconSize = math.min(circleSize * 0.11, 24.0);
    final iconPadding = math.min(circleSize * 0.04, 10.0);
    final strokeWidth = math.min(circleSize * 0.06, 12.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Progress
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF3D2E1F) : stepsColorLight,
                  ),
                ),
                // Progress ring
                SizedBox(
                  width: circleSize,
                  height: circleSize,
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _CircularProgressPainter(
                          progress: progressPercentage * _progressAnimation.value,
                          strokeWidth: strokeWidth,
                          backgroundColor: isDark
                              ? const Color(0xFF5D4E3F)
                              : const Color(0xFFFFE0B2),
                          progressColor: stepsColor,
                          isGoalAchieved: currentSteps >= dailyGoal,
                        ),
                      );
                    },
                  ),
                ),
                // Center content - constrained to fit inside circle
                SizedBox(
                  width: innerContentSize,
                  height: innerContentSize,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated step icon
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.8, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: EdgeInsets.all(iconPadding),
                              decoration: BoxDecoration(
                                color: stepsColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.directions_walk_rounded,
                                size: iconSize,
                                color: stepsColor,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: circleSize * 0.03),
                      TweenAnimationBuilder<int>(
                        duration: const Duration(milliseconds: 1200),
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
                                color: isDark ? Colors.white : Colors.black87,
                                letterSpacing: -1,
                              ),
                            ),
                          );
                        },
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.steps.toLowerCase(),
                          style: TextStyle(
                            fontSize: labelFontSize,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                      SizedBox(height: circleSize * 0.02),
                      // Percentage badge
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: circleSize * 0.06,
                            vertical: circleSize * 0.02,
                          ),
                          decoration: BoxDecoration(
                            color: currentSteps >= dailyGoal
                                ? const Color(0xFF4CAF50).withOpacity(0.15)
                                : stepsColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (currentSteps >= dailyGoal)
                                Icon(
                                  Icons.check_circle,
                                  size: labelFontSize,
                                  color: const Color(0xFF4CAF50),
                                ),
                              if (currentSteps >= dailyGoal) SizedBox(width: 4),
                              Text(
                                currentSteps >= dailyGoal ? l10n.goalAchieved : '$percentage%',
                                style: TextStyle(
                                  fontSize: labelFontSize * 0.9,
                                  fontWeight: FontWeight.bold,
                                  color: currentSteps >= dailyGoal
                                      ? const Color(0xFF4CAF50)
                                      : stepsColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          // Day indicator
          Text(
            _isViewingToday 
                ? l10n.todaysCount 
                : _currentPeriodOffset == 0 
                    ? "$selectedDay's Count"
                    : "$selectedDay Steps",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          // Pedestrian status (only for today)
          if (_isViewingToday) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: stepsColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: stepsColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(pedestrianStatus),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(pedestrianStatus, l10n),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: stepsColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'walking':
        return const Color(0xFF4CAF50);
      case 'stopped':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getStatusText(String pedestrianStatus, AppLocalizations l10n) {
    switch (pedestrianStatus) {
      case 'walking':
        return l10n.walking;
      case 'stopped':
        return l10n.stopped;
      default:
        return l10n.trackingSteps;
    }
  }

  // Calculate distance in km based on height (stride length)
  double _calculateDistance(int steps, double? heightCm) {
    if (heightCm != null && heightCm > 0) {
      // Stride length formula: height in cm * 0.43 for walking (average)
      // Convert to meters: stride_length_m = (height_cm / 100) * 0.43
      // Distance in km = (steps * stride_length_m) / 1000
      final strideLengthM = (heightCm / 100) * 0.43;
      final distanceM = steps * strideLengthM;
      return distanceM / 1000; // Convert to km
    } else {
      // Fallback: average stride length of 0.762 meters (30 inches)
      return (steps * 0.762) / 1000;
    }
  }

  // Calculate calories burned based on weight and distance
  int _calculateCalories(int steps, double? weightKg, double? heightCm) {
    // Calculate distance first
    final distanceKm = _calculateDistance(steps, heightCm);
    
    if (weightKg != null && weightKg > 0) {
      // Calories formula: MET * weight (kg) * time (hours)
      // Walking at moderate pace (3-4 mph) has MET value of 3.8
      // Time = distance / speed (assuming 4 km/h average walking speed)
      final speedKmPerHour = 4.0; // Average walking speed
      final timeHours = distanceKm / speedKmPerHour;
      final metValue = 3.8; // MET value for walking at moderate pace
      final calories = metValue * weightKg * timeHours;
      return calories.round();
    } else {
      // Fallback: Simple formula 0.04 calories per step (average for 70kg person)
      return (steps * 0.04).round();
    }
  }

  Widget _buildStatsRow(
    int currentSteps,
    int dailyGoal,
    bool isDark,
    Color stepsColor,
    Color cardColor,
    AppLocalizations l10n,
  ) {
    final remaining = (dailyGoal - currentSteps).clamp(0, dailyGoal);
    
    // Get user profile for height and weight
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final userProfile = profileProvider.userProfile;
    final heightCm = userProfile?.height;
    final weightKg = userProfile?.weight;
    
    // Calculate distance and calories based on user's height and weight
    final distanceKm = _calculateDistance(currentSteps, heightCm);
    final caloriesBurned = _calculateCalories(currentSteps, weightKg, heightCm);

    return Row(
      children: [
        // Remaining/Calories Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06),
                  blurRadius: 12,
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
                        color: remaining > 0
                            ? stepsColor.withOpacity(0.15)
                            : const Color(0xFF4CAF50).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        remaining > 0 ? Icons.flag_outlined : Icons.emoji_events,
                        size: 18,
                        color: remaining > 0 ? stepsColor : const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        remaining > 0 ? l10n.stepsToGoal(remaining) : l10n.goalAchieved,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  remaining > 0 ? _formatNumber(remaining) : '🎉',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: remaining > 0
                        ? (isDark ? Colors.white : Colors.black87)
                        : const Color(0xFF4CAF50),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Distance/Calories Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [stepsColor, stepsColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: stepsColor.withOpacity(0.3),
                  blurRadius: 12,
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$caloriesBurned kcal',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(
    bool isDark,
    Color stepsColor,
    Color stepsColorLight,
    Color cardColor,
    AppLocalizations l10n,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive chart height - increased to accommodate labels and prevent overflow
    final chartHeight = math.min(screenHeight * 0.24, 200.0);
    final barMaxHeight = chartHeight * 0.48; // Leave more room for labels at top and bottom
    
    if (_periodSteps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: chartHeight + 60,
          child: Center(
            child: CircularProgressIndicator(color: stepsColor),
          ),
        ),
      );
    }

    // Get sorted dates for the current period (oldest to newest)
    final sortedDates = _periodSteps.keys.toList()..sort();
    final steps = sortedDates.map((date) => _periodSteps[date] ?? 0).toList();
    final nonZeroSteps = steps.where((s) => s > 0).toList();
    final maxSteps = nonZeroSteps.isNotEmpty ? nonZeroSteps.reduce(math.max) : 10000;
    final totalWeeklySteps = steps.fold(0, (sum, s) => sum + s);
    final avgSteps = totalWeeklySteps ~/ 7;
    final today = DateTime.now();
    final todayDateStr = _formatDate(today);

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Navigation
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.022),
                decoration: BoxDecoration(
                  color: stepsColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: stepsColor,
                  size: 18,
                ),
              ),
              SizedBox(width: screenWidth * 0.025),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPeriodLabel(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Avg: ${_formatNumber(avgSteps)} steps/day',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.025,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: stepsColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _formatNumber(totalWeeklySteps),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: stepsColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous period button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _currentPeriodOffset < 3 ? () => _navigatePeriod(1) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _currentPeriodOffset < 3
                          ? stepsColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: _currentPeriodOffset < 3
                          ? null
                          : Border.all(color: (isDark ? Colors.white12 : Colors.grey[300] ?? Colors.grey), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 14,
                          color: _currentPeriodOffset < 3
                              ? stepsColor
                              : (isDark ? Colors.white38 : Colors.black38),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _currentPeriodOffset < 3
                                ? stepsColor
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Period indicator
              Text(
                '${_currentPeriodOffset + 1} / 4',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              // Next period button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _currentPeriodOffset > 0 ? () => _navigatePeriod(-1) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _currentPeriodOffset > 0
                          ? stepsColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: _currentPeriodOffset > 0
                          ? null
                          : Border.all(color: (isDark ? Colors.white12 : Colors.grey[300] ?? Colors.grey), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _currentPeriodOffset > 0
                                ? stepsColor
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: _currentPeriodOffset > 0
                              ? stepsColor
                              : (isDark ? Colors.white38 : Colors.black38),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          // Chart
          SizedBox(
            height: chartHeight,
            child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(sortedDates.length, (index) {
                    final dateStr = sortedDates[index];
                    final date = DateTime.parse(dateStr);
                    final daySteps = steps[index];
                    final dayAbbr = _getDayAbbreviation(date.weekday);
                    final dateDisplay = _formatDateForDisplay(date);
                    final isSelected = selectedDay == dayAbbr || selectedDay == dateDisplay || selectedDay == dateStr;
                    final isTodayDate = dateStr == todayDateStr;
                    final isFutureDay = date.isAfter(today);
                    final barHeight = maxSteps > 0
                        ? (daySteps / maxSteps) * barMaxHeight
                        : 0.0;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onDateSelected(dateStr, dayAbbr, dateDisplay),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.005),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                // Step count label (only for selected) - instant show/hide, scales to fit
                                if (isSelected)
                                  Container(
                                    constraints: const BoxConstraints(maxHeight: 24),
                                    margin: const EdgeInsets.only(bottom: 2),
                                    alignment: Alignment.bottomCenter,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: stepsColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _formatNumber(daySteps),
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              // Bar - with constrained max height
                                Container(
                                height: barHeight.clamp(4.0, barMaxHeight),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [stepsColor, stepsColor.withOpacity(0.7)],
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : isTodayDate
                                          ? stepsColor.withOpacity(0.7)
                                          : isFutureDay
                                              ? (isDark ? Colors.white12 : Colors.grey[300])
                                              : stepsColor.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: stepsColor.withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Day label - flexible height (show month/day for past periods)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                      _getLocalizedDay(dayAbbr, l10n),
                                    style: TextStyle(
                                      fontSize: 10,
                                        fontWeight: isSelected || isTodayDate ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected
                                          ? stepsColor
                                            : isTodayDate
                                              ? stepsColor.withOpacity(0.8)
                                              : isFutureDay
                                                  ? (isDark ? Colors.white38 : Colors.black38)
                                                  : (isDark ? Colors.white60 : Colors.black54),
                                    ),
                                  ),
                                ),
                                  if (_currentPeriodOffset > 0 || !isTodayDate)
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '${date.month}/${date.day}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w400,
                                          color: isSelected
                                              ? stepsColor.withOpacity(0.8)
                                              : (isDark ? Colors.white54 : Colors.black45),
                                        ),
                                      ),
                                    ),
                                  // Today indicator dot
                                  if (isTodayDate)
                                    Container(
                                      margin: const EdgeInsets.only(top: 3),
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: stepsColor,
                                          shape: BoxShape.circle,
                                        ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetGoalButton(
    int dailyGoal,
    StepsProvider stepsProvider,
    bool isDark,
    Color stepsColor,
    AppLocalizations l10n,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showGoalDialog(stepsProvider, stepsColor, isDark, l10n),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [stepsColor, stepsColor.withOpacity(0.85)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: stepsColor.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flag_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                '${l10n.setGoalTitle} (${_formatNumber(dailyGoal)})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalDialog(
    StepsProvider stepsProvider,
    Color stepsColor,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final TextEditingController goalController = TextEditingController(
      text: stepsProvider.dailyGoal.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2319) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: stepsColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flag_rounded,
                  color: stepsColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.setDailyGoal,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set your daily steps goal to stay motivated!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: goalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: l10n.egTenThousand,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: stepsColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              l10n.cancelButton,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final newGoal = int.tryParse(goalController.text);
                          if (newGoal != null && newGoal > 0) {
                            await stepsProvider.setDailyGoal(newGoal);
                            Navigator.pop(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [stepsColor, stepsColor.withOpacity(0.85)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: stepsColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              l10n.setGoalTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K';
    }
    return number.toString();
  }
}

// Custom circular progress painter
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final bool isGoalAchieved;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
    this.isGoalAchieved = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (isGoalAchieved) {
      progressPaint.color = const Color(0xFF4CAF50);
    } else {
      progressPaint.shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          progressColor.withOpacity(0.6),
          progressColor,
          progressColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    }

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw end cap glow effect
    if (progress > 0.01) {
      final endAngle = -math.pi / 2 + sweepAngle;
      final endPoint = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      final glowPaint = Paint()
        ..color = (isGoalAchieved ? const Color(0xFF4CAF50) : progressColor).withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(endPoint, strokeWidth / 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.isGoalAchieved != isGoalAchieved;
  }
}
