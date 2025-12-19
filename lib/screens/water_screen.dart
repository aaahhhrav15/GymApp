// File: screens/water_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/water_provider.dart';
import '../l10n/app_localizations.dart';

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

    // Responsive dimensions
    final horizontalPadding = screenWidth * 0.06;
    final sectionSpacing = screenHeight * 0.025;
    final smallSpacing = screenHeight * 0.025;

    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        double progressPercentage = provider.progressPercentage;
        int percentage = provider.progressPercent;
        int remaining = provider.remaining;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
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
                      child: Column(
                        children: [
                          SizedBox(height: smallSpacing),

                          // Hydration reminder card
                          _buildHydrationReminderCard(provider),

                          SizedBox(height: smallSpacing),

                          // Main Water Tracking Section
                          _buildMainTrackingSection(
                            provider,
                            progressPercentage,
                            percentage,
                            remaining,
                          ),

                          SizedBox(height: sectionSpacing),

                          // Quick Add Buttons
                          _buildQuickAddButtons(),

                          const SizedBox(height: 30),

                          // Today's History
                          if (provider.todaysIntake.isNotEmpty)
                            _buildTodayHistory(provider),

                          const SizedBox(height: 100),
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
    final titleFontSize = screenWidth * 0.045;
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
                AppLocalizations.of(context)!.stayHydrated,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
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

  Widget _buildHydrationReminderCard(WaterProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final reminder = _getLocalizedHydrationReminders(l10n);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reminder['title']!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reminder['message']!,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              reminder['suggestion']!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTrackingSection(
    WaterProvider provider,
    double progressPercentage,
    int percentage,
    int remaining,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Goal and Completed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.goal,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.dailyGoal}ml',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppLocalizations.of(context)!.completed,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Water Bottle Visualization
          Row(
            children: [
              // Bottle
              Expanded(
                flex: 2,
                child: AnimatedBuilder(
                  animation: _bottleAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(120, 200),
                      painter: WaterBottlePainter(
                        progress: progressPercentage * _bottleAnimation.value,
                        waterColor: Theme.of(context).colorScheme.primary,
                        bottleColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 30),

              // Progress Info
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Status Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: remaining > 0
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.3)
                            : Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: remaining > 0
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3)
                              : Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                remaining > 0
                                    ? Icons.water_drop
                                    : Icons.check_circle,
                                color: remaining > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  remaining > 0
                                      ? AppLocalizations.of(context)!
                                          .almostThere
                                      : AppLocalizations.of(context)!
                                          .goalAchievedStatus,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: remaining > 0
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (remaining > 0) ...[
                            Text(
                              '${remaining}ml',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.remaining,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.8),
                              ),
                            ),
                          ] else ...[
                            Text(
                              AppLocalizations.of(context)!.excellent,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.keepItUp,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Current Intake Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${provider.currentIntake}ml',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.waterIntake,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
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
        ],
      ),
    );
  }

  Widget _buildQuickAddButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.quickAdd,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickAddButton('100ml', 100, Icons.water_drop),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAddButton('250ml', 250, Icons.wine_bar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAddButton('500ml', 500, Icons.local_drink),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showCustomAmountDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.customAmount,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(String label, int amount, IconData icon) {
    return GestureDetector(
      onTap: () => _addWater(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayHistory(WaterProvider provider) {
    final intakeHistory = provider.getFormattedTodaysIntake();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history,
                  color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.todaysIntake,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                AppLocalizations.of(context)!.drinksCount(intakeHistory.length),
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: intakeHistory.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final intake = intakeHistory[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.water_drop,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${intake['amount']}ml',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            intake['type'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      intake['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    GestureDetector(
                      onTap: () => _showDeleteConfirmation(intake),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .errorContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCustomAmountDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController typeController = TextEditingController();

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.addCustomAmount,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.enterWaterAmount,
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.amountMl,
                hintText: l10n.egAmount,
                prefixIcon: const Icon(Icons.water_drop),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typeController,
              decoration: InputDecoration(
                labelText: l10n.typeOptional,
                hintText: l10n.egPostWorkout,
                prefixIcon: const Icon(Icons.label_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(amountController.text);
              if (amount != null && amount > 0 && amount <= 2000) {
                Navigator.pop(context);
                final customType = typeController.text.trim().isNotEmpty
                    ? typeController.text.trim()
                    : null;
                _addWater(amount, customType: customType);
              } else {
                // Snackbar removed - no longer showing error messages
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.add,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> intake) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.deleteWaterIntake,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.deleteWaterIntakeConfirm(
              intake['amount'].toString(), intake['time'].toString()),
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeWater(intake['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.onError)),
          ),
        ],
      ),
    );
  }

  void _showGoalAchievedDialog() {
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success animation or icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.hydrationGoalAchieved,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.greatJobReachedGoal(provider.dailyGoal),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  l10n.awesome,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  void _showOptionsMenu() {
    final l10n = AppLocalizations.of(context)!;

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
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flag_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              title: Text(l10n.setDailyGoal),
              subtitle: Consumer<WaterProvider>(
                builder: (context, provider, child) =>
                    Text(l10n.currentGoal(provider.dailyGoal)),
              ),
              onTap: () {
                Navigator.pop(context);
                _showGoalDialog();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.analytics,
                    color: Theme.of(context).colorScheme.secondary, size: 20),
              ),
              title: Text(l10n.viewStatistics),
              subtitle: Text(l10n.seeHydrationStats),
              onTap: () {
                Navigator.pop(context);
                _showStatsDialog();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.refresh,
                    color: Theme.of(context).colorScheme.primary, size: 20),
              ),
              title: Text(l10n.resetToday),
              subtitle: Text(l10n.clearAllIntake),
              onTap: () {
                Navigator.pop(context);
                _showResetDialog();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .tertiaryContainer
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.history,
                    color: Theme.of(context).colorScheme.tertiary, size: 20),
              ),
              title: Text(l10n.viewHistory),
              subtitle: Text(l10n.seePastDaysIntake),
              onTap: () {
                Navigator.pop(context);
                _showHistoryDialog();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog() {
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController goalController = TextEditingController(
      text: provider.dailyGoal.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.setDailyGoal,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.setYourDailyWaterGoal,
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.dailyWaterGoal,
                hintText: 'e.g., 2000',
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.recommendedAmount,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              final newGoal = int.tryParse(goalController.text);
              if (newGoal != null && newGoal > 0) {
                Navigator.pop(context);
                _updateDailyGoal(newGoal);
              } else {
                // Snackbar removed - no longer showing error messages
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.setGoalButton,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog() async {
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    // Show loading first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary),
      ),
    );

    try {
      final stats = await provider.getWaterStats();

      if (mounted) {
        Navigator.pop(context); // Close loading

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.analytics,
                    color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  l10n.hydrationStatistics,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatRow(
                      l10n.currentStreakDays,
                      '${stats['streakDays']} ${l10n.days}',
                      Icons.local_fire_department,
                      Colors.orange),
                  _buildStatRow(
                      l10n.goalAchievement,
                      l10n.goalAchievementDays(
                          stats['goalAchievedDays'], stats['totalDaysTracked']),
                      Icons.flag,
                      Colors.green),
                  _buildStatRow(
                      l10n.averageDailyIntake,
                      '${stats['averageDailyIntake']}ml',
                      Icons.analytics,
                      Colors.blue),
                  _buildStatRow(
                      l10n.thisWeekTotal,
                      '${stats['totalIntakeThisWeek']}ml',
                      Icons.calendar_view_week,
                      Colors.purple),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.todaysProgress,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: stats['completionPercentage'] / 100,
                          backgroundColor: Colors.blue[200],
                          valueColor: AlwaysStoppedAnimation(Colors.blue[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.percentOfDailyGoal(
                              stats['completionPercentage']),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
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
                child:
                    Text(l10n.close, style: TextStyle(color: Colors.blue[600])),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        // Snackbar removed - no longer showing error messages
      }
    }
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog() async {
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    // Show loading first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      ),
    );

    try {
      final historyResult = await provider.getWeeklyData();

      if (mounted) {
        Navigator.pop(context); // Close loading

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.history, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  l10n.waterIntakeHistoryTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: historyResult.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noHistoryAvailable,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.startTrackingHistory,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: historyResult.length,
                      itemBuilder: (context, index) {
                        final dayData = historyResult[index];
                        final date = DateTime.parse(dayData['date']);
                        final isGoalAchieved = dayData['goal_achieved'] == 1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isGoalAchieved
                                ? Colors.green[50]
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isGoalAchieved
                                  ? Colors.green[200]!
                                  : Colors.grey[200]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isGoalAchieved
                                    ? Icons.check_circle
                                    : Icons.water_drop,
                                color: isGoalAchieved
                                    ? Colors.green[600]
                                    : Colors.blue[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${date.day}/${date.month}/${date.year}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      l10n.drinksCount(dayData['totalDrinks']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${dayData['totalIntake']}ml',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isGoalAchieved
                                      ? Colors.green[700]
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close,
                    style: TextStyle(color: Colors.purple[600])),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        // Snackbar removed - no longer showing error messages
      }
    }
  }

  void _showResetDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.resetTodayTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.resetTodayConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTodaysIntake();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                Text(l10n.reset, style: const TextStyle(color: Colors.white)),
          ),
        ],
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

// Custom painter for the water bottle
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

    // Bottle shape
    bottlePath.moveTo(width * 0.3, height * 0.1); // Top left
    bottlePath.lineTo(width * 0.7, height * 0.1); // Top right
    bottlePath.lineTo(width * 0.8, height * 0.2); // Shoulder right
    bottlePath.lineTo(width * 0.8, height * 0.9); // Bottom right
    bottlePath.lineTo(width * 0.2, height * 0.9); // Bottom left
    bottlePath.lineTo(width * 0.2, height * 0.2); // Shoulder left
    bottlePath.close();

    // Draw bottle background
    paint.color = bottleColor;
    canvas.drawPath(bottlePath, paint);

    // Draw water fill
    if (progress > 0) {
      final waterHeight =
          (height * 0.7) * progress; // 70% of bottle height for water
      final waterTop = height * 0.9 - waterHeight;

      final waterPath = Path();
      waterPath.moveTo(width * 0.2, height * 0.9);
      waterPath.lineTo(width * 0.8, height * 0.9);
      waterPath.lineTo(width * 0.8, waterTop);

      // Add wave effect at the top
      final waveHeight = 8.0;

      for (double x = width * 0.8; x >= width * 0.2; x -= 2) {
        final normalizedX = (x - width * 0.2) / (width * 0.6);
        final y = waterTop + math.sin(normalizedX * 2 * math.pi) * waveHeight;
        waterPath.lineTo(x, y);
      }

      waterPath.lineTo(width * 0.2, height * 0.9);
      waterPath.close();

      paint.color = waterColor;
      canvas.drawPath(waterPath, paint);
    }

    // Draw bottle outline
    paint.color = Colors.blue[300]!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(bottlePath, paint);

    // Draw bottle cap
    final capRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(width * 0.35, height * 0.05, width * 0.3, height * 0.08),
      const Radius.circular(4),
    );
    paint.style = PaintingStyle.fill;
    paint.color = Colors.blue[400]!;
    canvas.drawRRect(capRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
