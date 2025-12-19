import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/steps_provider.dart';
import '../l10n/app_localizations.dart';

class StepsDetailScreen extends StatefulWidget {
  const StepsDetailScreen({super.key});

  @override
  State<StepsDetailScreen> createState() => _StepsDetailScreenState();
}

class _StepsDetailScreenState extends State<StepsDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;

  String selectedDay = 'Today';
  String? _hoveredDay; // For tooltip display
  OverlayEntry? _tooltipOverlay;

  // Real data from service
  Map<String, int> weeklySteps = {};
  List<int> hourlySteps = [];

  // Track if we're viewing today or a historical day
  bool _isViewingToday = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeStepsData();
    _listenToStepsUpdates();
  }

  void _initializeAnimations() {
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
  }

  void _initializeStepsData() async {
    final stepsProvider = context.read<StepsProvider>();

    // Ensure provider is initialized and force sync from background service
    if (!stepsProvider.isInitialized) {
      await stepsProvider.refresh();
    } else {
      // Even if initialized, force sync to get latest background service data
      await stepsProvider.refresh();
    }

    // Load weekly and hourly data
    final weekly = await stepsProvider.getWeeklySteps();

    // Set today as the selected day first
    final today = _getDayAbbreviation(DateTime.now().weekday);
    setState(() {
      selectedDay = today;
      _isViewingToday = true;
      weeklySteps = weekly;
    });

    // Then load today's hourly data
    final hourly =
        await stepsProvider.getHourlySteps(); // This should return today's data

    setState(() {
      hourlySteps = hourly;
    });

    print('Initialized - Today: $today, Steps: ${stepsProvider.currentSteps}');
    print('Today\'s hourly data: $hourly');
  }

  void _listenToStepsUpdates() {
    // No longer needed as we use Consumer<StepsProvider> in build method
  }

  // Handle day tap - show tooltip and update hourly data
  void _onDayBarTapped(String day, Offset tapPosition) async {
    final stepsProvider = Provider.of<StepsProvider>(context, listen: false);
    final today = _getDayAbbreviation(DateTime.now().weekday);

    setState(() {
      selectedDay = day;
      _isViewingToday = (day == today);
    });

    // Show tooltip
    _showTooltip(day, tapPosition);

    // Load appropriate data based on selected day
    if (_isViewingToday) {
      // Load today's real-time data - provider will handle currentSteps
      final hourly = await stepsProvider.getHourlySteps();
      setState(() {
        hourlySteps = hourly;
      });
    } else {
      // Load historical data for selected day
      final hourly = await stepsProvider.getHourlySteps(day);
      setState(() {
        hourlySteps = hourly;
      });
    }

    // Restart chart animation
    _chartAnimationController.reset();
    _chartAnimationController.forward();
  }

  void _showTooltip(String day, Offset position) {
    _removeTooltip();

    final steps = weeklySteps[day] ?? 0;
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    final chartContainer = context.findRenderObject() as RenderBox?;
    
    if (chartContainer == null) return;

    // Calculate position relative to screen
    final globalPosition = chartContainer.localToGlobal(position);
    
    // Position tooltip above the bar
    final tooltipLeft = (globalPosition.dx - 50).clamp(10.0, screenSize.width - 110);
    final tooltipTop = globalPosition.dy - 80;

    _tooltipOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: tooltipLeft,
        top: tooltipTop,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatNumber(steps)} steps',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_tooltipOverlay!);

    // Auto-remove tooltip after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _removeTooltip();
    });
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

  @override
  void dispose() {
    _animationController.dispose();
    _chartAnimationController.dispose();
    _removeTooltip();
    super.dispose();
  }

  void _removeTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
    _hoveredDay = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final horizontalPadding = screenWidth * 0.06;
    final sectionSpacing = screenHeight * 0.02;
    final smallSpacing = screenHeight * 0.01;

    return Consumer<StepsProvider>(
      builder: (context, stepsProvider, child) {
        // Get current values from provider
        final currentSteps = _isViewingToday
            ? stepsProvider.currentSteps
            : weeklySteps[selectedDay] ?? 0;
        final dailyGoal = stepsProvider.dailyGoal;
        final pedestrianStatus = stepsProvider.pedestrianStatus;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        children: [
                          SizedBox(height: smallSpacing),
                          Consumer<StepsProvider>(
                            builder: (context, stepsProvider, child) {
                              if (!stepsProvider.isUsingRealPedometer) {
                                return _buildPermissionWarning(
                                    stepsProvider, l10n);
                              }
                              return SizedBox.shrink();
                            },
                          ),
                          _buildStepsCount(
                              currentSteps, dailyGoal, pedestrianStatus, l10n),
                          SizedBox(height: sectionSpacing),
                          _buildWeeklyChart(l10n),
                          SizedBox(height: sectionSpacing),
                          _buildHourlyBreakdown(currentSteps),
                          SizedBox(height: sectionSpacing * 1.25),
                          _buildActionButtons(dailyGoal, stepsProvider, l10n),
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

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive dimensions
    final headerPadding = screenWidth * 0.06;
    final buttonSize = screenWidth * 0.1;
    final buttonRadius = buttonSize * 0.5;
    final iconSize = screenWidth * 0.04;
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
                borderRadius: BorderRadius.circular(buttonRadius),
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
                AppLocalizations.of(context)!.stepsDetails,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ),
          // Placeholder to maintain spacing
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildPermissionWarning(
      StepsProvider stepsProvider, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.usingSimulatedStepData,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            l10n.simulatedStepDataMessage,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onErrorContainer
                  .withOpacity(0.8),
              height: 1.3,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await stepsProvider.retryPedometerSetup();
                      // Snackbar removed - no longer showing setup messages
                    } catch (e) {
                      // Snackbar removed - no longer showing error messages
                    }
                  },
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text(l10n.enableRealSteps),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCount(int currentSteps, int dailyGoal,
      String pedestrianStatus, AppLocalizations l10n) {
    return Column(
      children: [
        TweenAnimationBuilder<int>(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          tween: IntTween(begin: 0, end: currentSteps),
          builder: (context, value, child) {
            return Text(
              '${_formatNumber(value)} ${l10n.steps}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          _isViewingToday ? l10n.todaysCount : "$selectedDay's Count",
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: currentSteps >= dailyGoal
                ? Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3)
                : Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: currentSteps >= dailyGoal
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                currentSteps >= dailyGoal
                    ? Icons.check_circle
                    : Icons.trending_up,
                size: 16,
                color: currentSteps >= dailyGoal
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                currentSteps >= dailyGoal
                    ? l10n.goalAchieved
                    : l10n.stepsToGoal(dailyGoal - currentSteps),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: currentSteps >= dailyGoal
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        if (_isViewingToday) ...[
          const SizedBox(height: 8),
          // Pedestrian status indicator (only for today)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _getStatusText(pedestrianStatus, l10n),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
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

  Widget _buildWeeklyChart(AppLocalizations l10n) {
    if (weeklySteps.isEmpty) {
      return Container(
        height: 220,
        padding: const EdgeInsets.all(16),
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
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    final orderedDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final steps = orderedDays.map((day) => weeklySteps[day] ?? 0).toList();
    final nonZeroSteps = steps.where((s) => s > 0).toList();
    final maxSteps = nonZeroSteps.isNotEmpty
        ? nonZeroSteps.reduce(math.max)
        : 10000;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
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
          Expanded(
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(orderedDays.length, (index) {
                    final day = orderedDays[index];
                    final daySteps = steps[index];
                    final isSelected = day == selectedDay;
                    final isToday = day == _getDayAbbreviation(DateTime.now().weekday);
                    final isFutureDay = _isDayInFuture(day);
                    final barHeight = maxSteps > 0
                        ? (daySteps / maxSteps) * 100 * _chartAnimation.value
                        : 0.0;

                    return Expanded(
                      child: GestureDetector(
                        onTapDown: (details) {
                          final RenderBox? renderBox =
                              context.findRenderObject() as RenderBox?;
                          if (renderBox != null) {
                            final localPosition = renderBox.globalToLocal(
                                details.globalPosition);
                            _onDayBarTapped(day, localPosition);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Tooltip indicator when selected
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _formatNumber(daySteps),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                ),
                              // Bar
                              Container(
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : isToday
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.7)
                                          : isFutureDay
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .outline
                                                  .withOpacity(0.3)
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.5),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Day label
                              Text(
                                _getLocalizedDay(day, l10n),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : isToday
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : isFutureDay
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.4)
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
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

  Widget _buildHourlyBreakdown(int currentSteps) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inverseSurface,
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_walk,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.hourlySteps,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              const Spacer(),
              Text(
                _isViewingToday
                    ? '${_formatNumber(currentSteps)} ${AppLocalizations.of(context)!.today}'
                    : '${_formatNumber(currentSteps)} ${AppLocalizations.of(context)!.on} $selectedDay',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onInverseSurface
                      .withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildHourlyBars(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onInverseSurface
                          .withOpacity(0.6),
                      fontSize: 10)),
              Text('6',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onInverseSurface
                          .withOpacity(0.6),
                      fontSize: 10)),
              Text('12',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onInverseSurface
                          .withOpacity(0.6),
                      fontSize: 10)),
              Text('18',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onInverseSurface
                          .withOpacity(0.6),
                      fontSize: 10)),
              Text('24',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onInverseSurface
                          .withOpacity(0.6),
                      fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHourlyBars() {
    if (hourlySteps.isEmpty) {
      return List.generate(
          24,
          (index) => Container(
                width: 6,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ));
    }

    // Get the maximum steps for proper scaling
    final maxSteps = hourlySteps.reduce(math.max);
    final currentHour = DateTime.now().hour;

    return List.generate(24, (index) {
      final steps = hourlySteps[index];
      final height = maxSteps > 0 ? (steps / maxSteps) * 70 : 0.0;
      final isCurrentHour = index == currentHour && _isViewingToday;
      final isActive = steps > 0;

      return AnimatedBuilder(
        animation: _chartAnimation,
        builder: (context, child) {
          return Container(
            width: 6,
            height: height * _chartAnimation.value,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: isCurrentHour
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                  : isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
              boxShadow: isCurrentHour
                  ? [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          );
        },
      );
    });
  }

  Widget _buildActionButtons(
      int dailyGoal, StepsProvider stepsProvider, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _showGoalDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_outlined,
                color: Theme.of(context).colorScheme.onPrimary, size: 18),
            const SizedBox(width: 10),
            Text(
              '${l10n.setGoalTitle} (${_formatNumber(dailyGoal)})',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog() {
    final l10n = AppLocalizations.of(context)!;
    final stepsProvider = Provider.of<StepsProvider>(context, listen: false);
    final TextEditingController goalController = TextEditingController(
      text: stepsProvider.dailyGoal.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.setDailyGoal,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set your daily steps goal to stay motivated!',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.dailyStepsGoal,
                hintText: l10n.egTenThousand,
                prefixIcon: const Icon(Icons.flag_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton,
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () async {
              final newGoal = int.tryParse(goalController.text);
              if (newGoal != null && newGoal > 0) {
                await stepsProvider.setDailyGoal(newGoal);
                Navigator.pop(context);
                // Snackbar removed - no longer showing success messages
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.setGoalTitle,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
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

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K';
    }
    return number.toString();
  }
}
