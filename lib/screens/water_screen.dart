// File: screens/water_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/water_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class WaterDetailScreen extends StatefulWidget {
  const WaterDetailScreen({super.key});

  @override
  State<WaterDetailScreen> createState() => _WaterDetailScreenState();
}

class _WaterDetailScreenState extends State<WaterDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _bottleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bottleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Initialize the provider after the widget is built to avoid build-time notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bottleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _bottleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bottleAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  // Initialize provider
  Future<void> _initializeProvider() async {
    final provider = Provider.of<WaterProvider>(context, listen: false);
    await provider.initialize();

    // Start bottle animation after data loads
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _bottleAnimationController.forward();
      }
    });
  }

  Future<void> _addWater(int amount, {String? customType}) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final success =
        await provider.addWaterIntake(amount, customType: customType);

    if (success) {
      // Trigger bottle animation
      _bottleAnimationController.reset();
      _bottleAnimationController.forward();

      // Snackbar removed - no longer showing success messages

      // Check if goal achieved
      if (provider.isGoalAchieved) {
        _showGoalAchievedDialog();
      }
    } else {
      // Snackbar removed - no longer showing error messages
    }
  }

  void _showAddWaterConfirmation(int amount, {String? customType}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF112240) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Color(0xFF29B6F6),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add Water Intake?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add ${amount}ml${customType != null ? ' (${customType})' : ''}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
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
                              l10n.cancel,
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
                        onTap: () {
                          Navigator.pop(context);
                          _addWater(amount, customType: customType);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF29B6F6).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Add',
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

  Future<void> _removeWater(int intakeId) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final success = await provider.removeWaterIntake(intakeId);

    if (success) {
      // Trigger bottle animation
      _bottleAnimationController.reset();
      _bottleAnimationController.forward();

      // Snackbar removed - no longer showing success messages
    } else {
      // Snackbar removed - no longer showing error messages
    }
  }

  Future<void> _updateDailyGoal(int newGoal) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final success = await provider.updateDailyGoal(newGoal);

    if (success) {
      // Snackbar removed - no longer showing success messages
    } else {
      // Snackbar removed - no longer showing error messages
    }
  }

  Future<void> _resetTodaysIntake() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final success = await provider.resetTodaysIntake();

    if (success) {
      _bottleAnimationController.reset();
      _bottleAnimationController.forward();

      // Snackbar removed - no longer showing success messages
    } else {
      // Snackbar removed - no longer showing error messages
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bottleAnimationController.dispose();
    super.dispose();
  }

  Map<String, String> _getLocalizedHydrationReminders(AppLocalizations l10n) {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 9) {
      return {
        'title': l10n.morningBooster,
        'message': l10n.startDayHydrated,
        'suggestion': l10n.waterJumpstartsMetabolism
      };
    } else if (hour >= 9 && hour < 12) {
      return {
        'title': l10n.preworkoutHydration,
        'message': l10n.stayHydratedDuringExercise,
        'suggestion': l10n.waterImprovesPerformance
      };
    } else if (hour >= 12 && hour < 15) {
      return {
        'title': l10n.stayOnTrack,
        'message': l10n.keepUpGoodWork,
        'suggestion': l10n.consistencyIsKey
      };
    } else if (hour >= 15 && hour < 18) {
      return {
        'title': l10n.energyDipFighter,
        'message': l10n.beatAfternoonSlump,
        'suggestion': l10n.dehydrationCausesFatigue
      };
    } else if (hour >= 18 && hour < 21) {
      return {
        'title': l10n.stayOnTrack,
        'message': l10n.keepUpGoodWork,
        'suggestion': l10n.consistencyIsKey
      };
    } else {
      return {
        'title': l10n.bedtimeHydration,
        'message': l10n.drinkWaterBeforeSleep,
        'suggestion': l10n.hydrationSupportsRecovery
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Responsive dimensions
    final horizontalPadding = screenWidth * 0.04;
    final sectionSpacing = screenHeight * 0.018;

    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF0A1929) : const Color(0xFFF0F8FF),
            body: Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF29B6F6),
              ),
            ),
          );
        }

        double progressPercentage = provider.progressPercentage;
        int percentage = provider.progressPercent;
        int remaining = provider.remaining;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0A1929) : const Color(0xFFF0F8FF),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: sectionSpacing),

                          // Main Progress Circle Section
                          _buildProgressCircle(provider, progressPercentage, percentage),

                          SizedBox(height: sectionSpacing),

                          // Stats Row
                          _buildStatsRow(provider, remaining),

                          SizedBox(height: sectionSpacing),

                          // Quick Add Buttons
                          _buildQuickAddButtons(),

                          SizedBox(height: sectionSpacing),

                          // Today's History
                          if (provider.todaysIntake.isNotEmpty)
                            _buildTodayHistory(provider),

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

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Responsive dimensions
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
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isDark ? null : [
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
                AppLocalizations.of(context)!.stayHydrated,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
            onTap: _showOptionsMenu,
              borderRadius: BorderRadius.circular(14),
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isDark ? null : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.more_vert,
                  size: iconSize * 0.7,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(WaterProvider provider, double progressPercentage, int percentage) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleSize = screenWidth * 0.55;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF112240) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Progress
          Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
          Container(
                width: circleSize,
                height: circleSize,
            decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark 
                      ? const Color(0xFF1A365D) 
                      : const Color(0xFFE3F2FD),
                ),
              ),
              // Progress ring
              SizedBox(
                width: circleSize,
                height: circleSize,
                child: AnimatedBuilder(
                  animation: _bottleAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CircularProgressPainter(
                        progress: progressPercentage * _bottleAnimation.value,
                        strokeWidth: 14,
                        backgroundColor: isDark 
                            ? const Color(0xFF2D4A77) 
                            : const Color(0xFFBBDEFB),
                        progressColor: const Color(0xFF29B6F6),
                      ),
                    );
                  },
                ),
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.water_drop,
                    size: 32,
                    color: const Color(0xFF29B6F6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.currentIntake}',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'ml',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                    '$percentage%',
                      style: const TextStyle(
                        fontSize: 16,
                      fontWeight: FontWeight.bold,
                        color: Color(0xFF29B6F6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Goal text
          Text(
            '${AppLocalizations.of(context)!.goal}: ${provider.dailyGoal}ml',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(WaterProvider provider, int remaining) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final reminder = _getLocalizedHydrationReminders(l10n);

    return Row(
                  children: [
        // Remaining Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
              color: isDark ? const Color(0xFF112240) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.3) 
                      : Colors.black.withOpacity(0.06),
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
                            ? const Color(0xFF29B6F6).withOpacity(0.15)
                            : const Color(0xFF4CAF50).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        remaining > 0 ? Icons.water_drop_outlined : Icons.check_circle,
                                size: 18,
                        color: remaining > 0 
                            ? const Color(0xFF29B6F6)
                            : const Color(0xFF4CAF50),
                              ),
                    ),
                    const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                        remaining > 0 ? l10n.remaining : l10n.goalAchievedStatus,
                                  style: TextStyle(
                          fontSize: 13,
                                    fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                                ),
                              ),
                            ],
                          ),
                const SizedBox(height: 12),
                            Text(
                  remaining > 0 ? '${remaining}ml' : l10n.excellent,
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
        // Tip Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF29B6F6),
                  const Color(0xFF0288D1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF29B6F6).withOpacity(0.3),
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
                        Icons.lightbulb_outline,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        reminder['title']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 12),
                Text(
                  reminder['message']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
          ),
        ],
    );
  }


  Widget _buildQuickAddButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF112240) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.06),
            blurRadius: 16,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF29B6F6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.quickAdd,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
            ),
          ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildQuickAddButton('100', 100, Icons.water_drop),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAddButton('250', 250, Icons.coffee),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAddButton('500', 500, Icons.local_drink),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showCustomAmountDialog,
              borderRadius: BorderRadius.circular(16),
              child: Container(
            width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF29B6F6),
                      Color(0xFF0288D1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF29B6F6).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                ),
                  ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const Icon(Icons.add, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.customAmount,
                      style: const TextStyle(
                        fontSize: 15,
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

  Widget _buildQuickAddButton(String label, int amount, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: () => _showAddWaterConfirmation(amount),
        borderRadius: BorderRadius.circular(16),
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF1A365D)
                : const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF29B6F6).withOpacity(0.3),
              width: 1.5,
            ),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF29B6F6),
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'ml',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayHistory(WaterProvider provider) {
    final intakeHistory = provider.getFormattedTodaysIntake();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF112240) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.06),
            blurRadius: 16,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history,
                  color: Color(0xFF29B6F6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                AppLocalizations.of(context)!.todaysIntake,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                AppLocalizations.of(context)!.drinksCount(intakeHistory.length),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF29B6F6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: intakeHistory.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final intake = intakeHistory[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showIntakeOptionsSheet(intake),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                      color: isDark 
                          ? const Color(0xFF1A365D)
                          : const Color(0xFFF5F9FF),
                      borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                          padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                            color: const Color(0xFF29B6F6).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                        Icons.water_drop,
                            color: Color(0xFF29B6F6),
                            size: 20,
                      ),
                    ),
                        const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${intake['amount']}ml',
                            style: TextStyle(
                                  fontSize: 17,
                              fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                              const SizedBox(height: 2),
                          Text(
                            intake['type'],
                            style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                  fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                    Text(
                      intake['time'],
                      style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              Icons.chevron_right,
                              color: isDark ? Colors.white38 : Colors.black26,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showIntakeOptionsSheet(Map<String, dynamic> intake) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF112240) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Color(0xFF29B6F6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${intake['amount']}ml',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${intake['type']} • ${intake['time']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Options
            _buildBottomSheetOption(
              icon: Icons.edit_outlined,
              iconColor: const Color(0xFF29B6F6),
              iconBgColor: const Color(0xFF29B6F6).withOpacity(0.15),
              title: l10n.edit,
              subtitle: 'Change amount or type',
              onTap: () {
                Navigator.pop(context);
                _showEditIntakeDialog(intake);
              },
              isDark: isDark,
            ),
            _buildBottomSheetOption(
              icon: Icons.delete_outline,
              iconColor: Colors.red[400]!,
              iconBgColor: Colors.red.withOpacity(0.12),
              title: l10n.delete,
              subtitle: 'Remove this entry',
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(intake);
              },
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            // Cancel button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(14),
                      child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                        ),
                      ),
                    ),
                  ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white30 : Colors.black26,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditIntakeDialog(Map<String, dynamic> intake) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController amountController = TextEditingController(
      text: intake['amount'].toString(),
    );
    final TextEditingController typeController = TextEditingController(
      text: intake['type'],
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF112240) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF29B6F6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Entry',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Amount field
              Text(
                l10n.amountMl,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., 250',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                  prefixIcon: Icon(
                    Icons.water_drop_outlined,
                    color: const Color(0xFF29B6F6),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A365D) : const Color(0xFFF5F9FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF29B6F6), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Type field
              Text(
                l10n.typeOptional,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: typeController,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: l10n.egPostWorkout,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                  prefixIcon: Icon(
                    Icons.label_outline,
                    color: const Color(0xFF29B6F6),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A365D) : const Color(0xFFF5F9FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF29B6F6), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
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
                              l10n.cancel,
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
                          final amount = int.tryParse(amountController.text);
                          if (amount != null && amount > 0 && amount <= 2000) {
                            Navigator.pop(context);
                            final customType = typeController.text.trim().isNotEmpty
                                ? typeController.text.trim()
                                : null;
                            await _updateWater(intake['id'], amount, customType: customType);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF29B6F6).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Save',
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

  Future<void> _updateWater(int intakeId, int amount, {String? customType}) async {
    final provider = Provider.of<WaterProvider>(context, listen: false);
    await provider.updateWaterIntake(intakeId, amount, customType: customType);
    
    // Trigger animation
    _bottleAnimationController.reset();
    _bottleAnimationController.forward();
  }

  void _showCustomAmountDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController amountController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF112240) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
          mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF29B6F6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.addCustomAmount,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            Text(
              l10n.enterWaterAmount,
              style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(height: 24),
              // Amount field
              Text(
                l10n.amountMl,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              decoration: InputDecoration(
                hintText: l10n.egAmount,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                  prefixIcon: const Icon(
                    Icons.water_drop_outlined,
                    color: Color(0xFF29B6F6),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A365D) : const Color(0xFFF5F9FF),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF29B6F6), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
              // Type field
              Text(
                l10n.typeOptional,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
            TextField(
              controller: typeController,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              decoration: InputDecoration(
                hintText: l10n.egPostWorkout,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                  prefixIcon: const Icon(
                    Icons.label_outline,
                    color: Color(0xFF29B6F6),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A365D) : const Color(0xFFF5F9FF),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF29B6F6), width: 2),
                ),
              ),
            ),
              const SizedBox(height: 24),
              // Buttons
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
                              l10n.cancel,
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
                        onTap: () {
              final amount = int.tryParse(amountController.text);
              if (amount != null && amount > 0 && amount <= 2000) {
                Navigator.pop(context);
                final customType = typeController.text.trim().isNotEmpty
                    ? typeController.text.trim()
                    : null;
                _showAddWaterConfirmation(amount, customType: customType);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF29B6F6).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              l10n.add,
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

  void _showDeleteConfirmation(Map<String, dynamic> intake) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF112240) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red[400],
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
          l10n.deleteWaterIntake,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
        ),
              ),
              const SizedBox(height: 12),
              Text(
          l10n.deleteWaterIntakeConfirm(
              intake['amount'].toString(), intake['time'].toString()),
                textAlign: TextAlign.center,
          style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
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
                              l10n.cancel,
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
                        onTap: () {
              Navigator.pop(context);
              _removeWater(intake['id']);
            },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              l10n.delete,
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

  void _showGoalAchievedDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF112240) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon with animation effect
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4CAF50).withOpacity(0.2),
                      const Color(0xFF4CAF50).withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '🎉',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.hydrationGoalAchieved,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.greatJobReachedGoal(provider.dailyGoal),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF43A047)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        l10n.awesome,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Auto close after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  void _showOptionsMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF112240) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Options
            Consumer<WaterProvider>(
              builder: (context, provider, child) => _buildBottomSheetOption(
                icon: Icons.flag_outlined,
                iconColor: const Color(0xFF29B6F6),
                iconBgColor: const Color(0xFF29B6F6).withOpacity(0.15),
                title: l10n.setDailyGoal,
                subtitle: l10n.currentGoal(provider.dailyGoal),
                onTap: () {
                  Navigator.pop(context);
                  _showGoalDialog();
                },
                isDark: isDark,
              ),
            ),
            _buildBottomSheetOption(
              icon: Icons.analytics_outlined,
              iconColor: const Color(0xFF4CAF50),
              iconBgColor: const Color(0xFF4CAF50).withOpacity(0.15),
              title: l10n.viewStatistics,
              subtitle: l10n.seeHydrationStats,
              onTap: () {
                Navigator.pop(context);
                _showStatsDialog();
              },
              isDark: isDark,
            ),
            _buildBottomSheetOption(
              icon: Icons.history,
              iconColor: const Color(0xFF9C27B0),
              iconBgColor: const Color(0xFF9C27B0).withOpacity(0.15),
              title: l10n.viewHistory,
              subtitle: l10n.seePastDaysIntake,
              onTap: () {
                Navigator.pop(context);
                _showHistoryDialog();
              },
              isDark: isDark,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Divider(height: 1),
            ),
            _buildBottomSheetOption(
              icon: Icons.refresh,
              iconColor: Colors.orange[600]!,
              iconBgColor: Colors.orange.withOpacity(0.15),
              title: l10n.resetToday,
              subtitle: l10n.clearAllIntake,
              onTap: () {
                Navigator.pop(context);
                _showResetDialog();
              },
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            // Close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        l10n.close,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController goalController = TextEditingController(
      text: provider.dailyGoal.toString(),
    );

    // Quick select options
    final quickOptions = [1500, 2000, 2500, 3000];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF112240) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
          mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flag_outlined,
                      color: Color(0xFF29B6F6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.setDailyGoal,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            Text(
              l10n.setYourDailyWaterGoal,
              style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
            ),
            const SizedBox(height: 20),
              // Quick select
              Text(
                'Quick Select',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              StatefulBuilder(
                builder: (context, setState) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickOptions.map((amount) {
                    final isSelected = goalController.text == amount.toString();
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            goalController.text = amount.toString();
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF29B6F6)
                                : (isDark ? const Color(0xFF1A365D) : const Color(0xFFF5F9FF)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF29B6F6)
                                  : (isDark ? Colors.white12 : Colors.black12),
                            ),
                          ),
                          child: Text(
                            '${amount}ml',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // Custom input
              Text(
                'Or enter custom amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              decoration: InputDecoration(
                hintText: 'e.g., 2000',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                  suffixText: 'ml',
                  suffixStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  prefixIcon: const Icon(
                    Icons.water_drop_outlined,
                    color: Color(0xFF29B6F6),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A365D) : const Color(0xFFF5F9FF),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF29B6F6), width: 2),
                ),
              ),
            ),
              const SizedBox(height: 8),
            Text(
              l10n.recommendedAmount,
              style: TextStyle(
                fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                fontStyle: FontStyle.italic,
              ),
            ),
              const SizedBox(height: 24),
              // Buttons
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
                              l10n.cancel,
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
                        onTap: () {
              final newGoal = int.tryParse(goalController.text);
              if (newGoal != null && newGoal > 0) {
                Navigator.pop(context);
                _updateDailyGoal(newGoal);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF29B6F6).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
            child: Text(
              l10n.setGoalButton,
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

  void _showStatsDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    // Show loading first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF112240) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const CircularProgressIndicator(
            color: Color(0xFF29B6F6),
          ),
        ),
      ),
    );

    try {
      final stats = await provider.getWaterStats();

      if (mounted) {
        Navigator.pop(context); // Close loading

        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF112240) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          color: Color(0xFF4CAF50),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                  l10n.hydrationStatistics,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                ),
              ],
            ),
                  const SizedBox(height: 24),
                  // Stats
                  _buildStatCard(
                      l10n.currentStreakDays,
                      '${stats['streakDays'] as int? ?? 0} ${l10n.days}',
                      Icons.local_fire_department,
                    Colors.orange,
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                      l10n.goalAchievement,
                      l10n.goalAchievementDays(
                          stats['goalAchievedDays'] as int? ?? 0,
                          stats['totalDaysTracked'] as int? ?? 1),
                    Icons.emoji_events_outlined,
                    const Color(0xFF4CAF50),
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                      l10n.averageDailyIntake,
                      '${stats['averageDailyIntake'] as int? ?? 0}ml',
                    Icons.show_chart,
                    const Color(0xFF29B6F6),
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                      l10n.thisWeekTotal,
                      '${stats['totalIntakeThisWeek'] as int? ?? 0}ml',
                      Icons.calendar_view_week,
                    const Color(0xFF9C27B0),
                    isDark,
                  ),
                  const SizedBox(height: 20),
                  // Today's progress
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF29B6F6).withOpacity(0.15),
                          const Color(0xFF29B6F6).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF29B6F6).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.todaysProgress,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                          value: (stats['completionPercentage'] as int? ?? 0) / 100.0,
                            backgroundColor: isDark ? const Color(0xFF1A365D) : const Color(0xFFE3F2FD),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF29B6F6)),
                            minHeight: 10,
                        ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.percentOfDailyGoal(
                              stats['completionPercentage'] as int? ?? 0),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF29B6F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Close button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            l10n.close,
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
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
      }
    }
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A365D) : const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    // Show loading first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF112240) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const CircularProgressIndicator(
            color: Color(0xFF29B6F6),
          ),
        ),
      ),
    );

    try {
      final historyResult = await provider.getWeeklyData();

      if (mounted) {
        Navigator.pop(context); // Close loading

        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF112240) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Color(0xFF9C27B0),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${l10n.waterIntakeHistoryTitle} (30 Days)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Content
                  Flexible(
                    child: historyResult.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF29B6F6).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.water_drop_outlined,
                                    size: 48,
                                    color: isDark ? Colors.white38 : Colors.black26,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.noHistoryAvailable,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.startTrackingHistory,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white38 : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: historyResult.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _HistoryDayItem(
                                dayData: historyResult[index],
                                isDark: isDark,
                                l10n: l10n,
                                provider: provider,
                                onEdit: (intake, date) => _showEditIntakeDialogForDate(intake, date),
                                onDelete: (intake, date) => _showDeleteConfirmationForDate(intake, date),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  // Close button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            l10n.close,
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
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
      }
    }
  }

  // History Day Item Widget with expandable breakdown
  Widget _HistoryDayItem({
    required Map<String, dynamic> dayData,
    required bool isDark,
    required AppLocalizations l10n,
    required WaterProvider provider,
    required Function(Map<String, dynamic>, DateTime) onEdit,
    required Function(Map<String, dynamic>, DateTime) onDelete,
  }) {
    return _HistoryDayItemWidget(
      dayData: dayData,
      isDark: isDark,
      l10n: l10n,
      provider: provider,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }

  // Edit intake dialog for previous days
  void _showEditIntakeDialogForDate(Map<String, dynamic> intake, DateTime date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController amountController = TextEditingController(
      text: intake['amount'].toString(),
    );
    final TextEditingController typeController = TextEditingController(
      text: intake['type'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF112240) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF29B6F6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Entry',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Amount field
              Text(
                l10n.amountMl,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., 250',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                  prefixIcon: const Icon(
                    Icons.water_drop_outlined,
                    color: Color(0xFF29B6F6),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A365D) : const Color(0xFFF5F9FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF29B6F6), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Type field
              Text(
                l10n.typeOptional,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: typeController,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: l10n.egPostWorkout,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                  prefixIcon: const Icon(
                    Icons.label_outline,
                    color: Color(0xFF29B6F6),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A365D) : const Color(0xFFF5F9FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF29B6F6), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
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
                              l10n.cancel,
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
                          final amount = int.tryParse(amountController.text);
                          if (amount != null && amount > 0 && amount <= 2000) {
                            Navigator.pop(context); // Close edit dialog
                            final customType = typeController.text.trim().isNotEmpty
                                ? typeController.text.trim()
                                : null;
                            final provider = Provider.of<WaterProvider>(context, listen: false);
                            final success = await provider.updateWaterIntakeForDate(
                              intakeId: intake['id'],
                              amount: amount,
                              date: date,
                              customType: customType,
                            );
                            if (success && context.mounted) {
                              // Close history dialog and show updated one
                              Navigator.pop(context);
                              _showHistoryDialog();
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF29B6F6).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Save',
                              style: TextStyle(
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

  // Delete confirmation for previous days
  void _showDeleteConfirmationForDate(Map<String, dynamic> intake, DateTime date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF112240) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red[400],
                  size: 32,
                          ),
                  ),
                  const SizedBox(height: 20),
              Text(
                l10n.deleteWaterIntake,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deleteWaterIntakeConfirm(
                  intake['amount'].toString(),
                  intake['time']?.toString() ?? 'N/A',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
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
                              l10n.cancel,
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
                          Navigator.pop(context); // Close delete confirmation dialog
                          final provider = Provider.of<WaterProvider>(context, listen: false);
                          final success = await provider.removeWaterIntakeForDate(intake['id'], date);
                          if (success && context.mounted) {
                            // Close history dialog and show updated one
                            Navigator.pop(context);
                            _showHistoryDialog();
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              l10n.delete,
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

  void _showResetDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF112240) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.refresh,
                  color: Colors.orange[600],
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.resetTodayTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.resetTodayConfirmation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
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
                              l10n.cancel,
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
                        onTap: () {
                          Navigator.pop(context);
                          _resetTodaysIntake();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.orange[600],
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              l10n.reset,
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

  void _showSuccessSnackBar(String message) {
    // Snackbars removed - no longer showing success messages
  }

  void _showErrorSnackBar(String message) {
    // Snackbars removed - no longer showing error messages
  }
}

// Separate StatefulWidget for history day item
class _HistoryDayItemWidget extends StatefulWidget {
  final Map<String, dynamic> dayData;
  final bool isDark;
  final AppLocalizations l10n;
  final WaterProvider provider;
  final Function(Map<String, dynamic>, DateTime) onEdit;
  final Function(Map<String, dynamic>, DateTime) onDelete;

  const _HistoryDayItemWidget({
    required this.dayData,
    required this.isDark,
    required this.l10n,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_HistoryDayItemWidget> createState() => _HistoryDayItemWidgetState();
}

class _HistoryDayItemWidgetState extends State<_HistoryDayItemWidget> {
  bool _isExpanded = false;
  List<Map<String, dynamic>> _intakeRecords = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.dayData['date']);
    final isGoalAchieved = widget.dayData['goal_achieved'] == 1;
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayName = dayNames[date.weekday - 1];
    final monthName = monthNames[date.month - 1];

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF1A365D)
            : (isGoalAchieved
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFF5F9FF)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isGoalAchieved
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                if (!_isExpanded) {
                  setState(() {
                    _isLoading = true;
                    _isExpanded = true;
                  });
                  try {
                    final records = await widget.provider.getIntakeForDate(date);
                    setState(() {
                      _intakeRecords = records;
                      _isLoading = false;
                    });
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                } else {
                  setState(() {
                    _isExpanded = false;
                  });
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isGoalAchieved
                            ? const Color(0xFF4CAF50).withOpacity(0.2)
                            : const Color(0xFF29B6F6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isGoalAchieved
                            ? Icons.check_circle
                            : Icons.water_drop,
                        color: isGoalAchieved
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF29B6F6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$dayName, ${date.day} $monthName ${date.year}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: widget.isDark ? Colors.white : Colors.black87,
                            ),
                            softWrap: true,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.l10n.drinksCount(widget.dayData['total_drinks'] as int? ?? 0),
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isDark ? Colors.white54 : Colors.black45,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.dayData['total_intake'] as int? ?? 0}ml',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isGoalAchieved
                            ? const Color(0xFF4CAF50)
                            : (widget.isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: widget.isDark ? Colors.white54 : Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF0F1B2E)
                    : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF29B6F6),
                        ),
                      ),
                    )
                  : _intakeRecords.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No intake records for this day',
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: _intakeRecords.map((intake) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? const Color(0xFF1A365D)
                                    : const Color(0xFFF5F9FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF29B6F6).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.water_drop,
                                      color: Color(0xFF29B6F6),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${intake['amount']}ml',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: widget.isDark ? Colors.white : Colors.black87,
                                          ),
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          intake['time'] ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: widget.isDark ? Colors.white54 : Colors.black45,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => widget.onEdit(intake, date),
                                          borderRadius: BorderRadius.circular(20),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                              color: const Color(0xFF29B6F6),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => widget.onDelete(intake, date),
                                          borderRadius: BorderRadius.circular(20),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: Colors.red[400],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
            ),
        ],
      ),
    );
  }
}

// Custom painter for circular progress
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}

// Custom painter for the water bottle (kept for potential future use)
class WaterBottlePainter extends CustomPainter {
  final double progress;
  final Color waterColor;
  final Color bottleColor;

  WaterBottlePainter({
    required this.progress,
    required this.waterColor,
    required this.bottleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Bottle outline
    final bottlePath = Path();
    final width = size.width;
    final height = size.height;

    // Bottle shape - more refined
    bottlePath.moveTo(width * 0.3, height * 0.08); // Top left
    bottlePath.lineTo(width * 0.7, height * 0.08); // Top right
    bottlePath.quadraticBezierTo(
        width * 0.75, height * 0.12, width * 0.8, height * 0.18); // Shoulder right curve
    bottlePath.lineTo(width * 0.8, height * 0.92); // Bottom right
    bottlePath.quadraticBezierTo(
        width * 0.8, height * 0.95, width * 0.75, height * 0.95); // Bottom right curve
    bottlePath.lineTo(width * 0.25, height * 0.95); // Bottom left
    bottlePath.quadraticBezierTo(
        width * 0.2, height * 0.95, width * 0.2, height * 0.92); // Bottom left curve
    bottlePath.lineTo(width * 0.2, height * 0.18); // Shoulder left
    bottlePath.quadraticBezierTo(
        width * 0.25, height * 0.12, width * 0.3, height * 0.08); // Shoulder left curve
    bottlePath.close();

    // Draw bottle background with gradient effect
    paint.color = bottleColor;
    canvas.drawPath(bottlePath, paint);

    // Draw water fill with gradient
    if (progress > 0) {
      final waterHeight = (height * 0.75) * progress; // 75% of bottle height for water
      final waterTop = height * 0.95 - waterHeight;

      final waterPath = Path();
      waterPath.moveTo(width * 0.2, height * 0.95);
      waterPath.lineTo(width * 0.8, height * 0.95);
      waterPath.lineTo(width * 0.8, waterTop);

      // Add wave effect at the top
      final waveHeight = 6.0;
      final waveFrequency = 3.0;

      for (double x = width * 0.8; x >= width * 0.2; x -= 1) {
        final normalizedX = (x - width * 0.2) / (width * 0.6);
        final y = waterTop + math.sin(normalizedX * waveFrequency * math.pi) * waveHeight;
        waterPath.lineTo(x, y);
      }

      waterPath.lineTo(width * 0.2, height * 0.95);
      waterPath.close();

      // Draw water with gradient
      final waterGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          waterColor.withOpacity(0.9),
          waterColor,
          waterColor.withOpacity(0.7),
        ],
      );
      paint.shader = waterGradient.createShader(
        Rect.fromLTWH(width * 0.2, waterTop, width * 0.6, waterHeight),
      );
      canvas.drawPath(waterPath, paint);
      paint.shader = null;
    }

    // Draw bottle outline with better styling
    paint.color = waterColor.withOpacity(0.4);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawPath(bottlePath, paint);

    // Draw bottle cap with gradient
    final capRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(width * 0.35, height * 0.02, width * 0.3, height * 0.1),
      const Radius.circular(6),
    );
    paint.style = PaintingStyle.fill;
    final capGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        waterColor.withOpacity(0.6),
        waterColor.withOpacity(0.4),
      ],
    );
    paint.shader = capGradient.createShader(capRect.outerRect);
    canvas.drawRRect(capRect, paint);
    paint.shader = null;

    // Cap outline
    paint.color = waterColor.withOpacity(0.5);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawRRect(capRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}




