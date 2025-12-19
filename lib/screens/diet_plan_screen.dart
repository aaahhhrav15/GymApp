import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/diet_plan_provider.dart';
import '../l10n/app_localizations.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({
    super.key,
  });

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Load diet plan data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DietPlanProvider>(context, listen: false).loadDietPlan();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Safe size helper method to prevent infinite/NaN values
  double _safeSize(double screenWidth, double multiplier, double fallback) {
    final result = screenWidth * multiplier;
    return result.isFinite ? result : fallback;
  }

  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'mid-morning snack':
        return Colors.green;
      case 'lunch':
        return Colors.blue;
      case 'evening snack':
        return Colors.purple;
      case 'dinner':
        return Colors.red;
      case 'night snack':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'mid-morning snack':
        return Icons.coffee;
      case 'lunch':
        return Icons.restaurant;
      case 'evening snack':
        return Icons.local_cafe;
      case 'dinner':
        return Icons.dinner_dining;
      case 'night snack':
        return Icons.nightlight;
      default:
        return Icons.fastfood;
    }
  }

  String _getLocalizedMealType(String mealType) {
    final l10n = AppLocalizations.of(context)!;
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return l10n.breakfast;
      case 'mid-morning snack':
        return l10n.midMorningSnack;
      case 'lunch':
        return l10n.lunch;
      case 'evening snack':
        return l10n.eveningSnack;
      case 'dinner':
        return l10n.dinner;
      case 'night snack':
        return l10n.nightSnack;
      default:
        return mealType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive dimensions
    final appBarPadding = _safeSize(screenWidth, 0.05, 20.0);
    final borderRadius = _safeSize(screenWidth, 0.03, 12.0);
    final titleFontSize = _safeSize(screenWidth, 0.06, 24.0);
    final subtitleFontSize = _safeSize(screenWidth, 0.035, 14.0);
    final iconSize = _safeSize(screenWidth, 0.06, 24.0);
    final spacing = _safeSize(screenWidth, 0.04, 16.0);
    final errorIconSize = _safeSize(screenWidth, 0.16, 64.0);
    final errorTitleFontSize = _safeSize(screenWidth, 0.045, 18.0);
    final errorBodyFontSize = _safeSize(screenWidth, 0.035, 14.0);
    final buttonPadding = _safeSize(screenWidth, 0.04, 16.0);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Custom App Bar
                      Container(
                        padding: EdgeInsets.all(appBarPadding),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.8),
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(borderRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: iconSize,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            SizedBox(width: spacing),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.myDietPlan,
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .yourPersonalizedNutritionGuide,
                                    style: TextStyle(
                                      fontSize: subtitleFontSize,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Scrollable content
                      Expanded(
                        child: Consumer<DietPlanProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            }

                            if (provider.error != null &&
                                provider.dietPlan == null) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: errorIconSize,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error
                                          .withOpacity(0.5),
                                    ),
                                    SizedBox(height: spacing),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .failedToLoadDietPlan,
                                      style: TextStyle(
                                        fontSize: errorTitleFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    SizedBox(height: spacing * 0.5),
                                    Text(
                                      provider.error!,
                                      style: TextStyle(
                                        fontSize: errorBodyFontSize,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                    SizedBox(height: spacing * 1.5),
                                    ElevatedButton(
                                      onPressed: () =>
                                          provider.refreshDietPlan(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: buttonPadding,
                                          vertical: buttonPadding * 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.retry,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontSize: errorBodyFontSize,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final dietPlan = provider.dietPlan;
                            if (dietPlan == null) {
                              return Center(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .noDietPlanAvailable,
                                  style: TextStyle(
                                    fontSize: errorBodyFontSize,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () => provider.refreshDietPlan(),
                              color: Theme.of(context).colorScheme.primary,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                    horizontal: appBarPadding),
                                child: Column(
                                  children: [
                                    if (provider.isRefreshing)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom: spacing * 0.75,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: spacing,
                                              height: spacing,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            SizedBox(width: spacing * 0.5),
                                            Text(
                                              'Refreshing...',
                                              style: TextStyle(
                                                fontSize:
                                                    subtitleFontSize * 0.8,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Show nutrition source indicator
                                    if (!provider.hasNutritionPlan)
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(spacing),
                                        margin:
                                            EdgeInsets.only(bottom: spacing),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              size: iconSize * 0.8,
                                            ),
                                            SizedBox(width: spacing * 0.75),
                                            Expanded(
                                              child: Text(
                                                'No personalized nutrition plan found. Showing default meal plan.',
                                                style: TextStyle(
                                                  fontSize:
                                                      subtitleFontSize * 0.8,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .tertiary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ), // Plan Overview Card
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: provider.hasNutritionPlan
                                              ? [
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withOpacity(0.8),
                                                ]
                                              : [
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .tertiary,
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .tertiary
                                                      .withOpacity(0.8),
                                                ],
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (provider.hasNutritionPlan
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .tertiary)
                                                .withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                        .withOpacity(0.2),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    provider.hasNutritionPlan
                                                        ? Icons.restaurant_menu
                                                        : Icons.fastfood,
                                                    size: 30,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        dietPlan.planName,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                        ),
                                                      ),
                                                      Text(
                                                        provider.hasNutritionPlan
                                                            ? AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .personalizedNutritionPlan
                                                            : AppLocalizations
                                                                    .of(context)!
                                                                .defaultNutritionPlan,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onPrimary
                                                              .withOpacity(0.8),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _buildNutritionStat(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .calories,
                                                    '${dietPlan.targets['calories'] ?? 2800}',
                                                    AppLocalizations.of(
                                                            context)!
                                                        .kcal,
                                                    Icons.local_fire_department,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: _buildNutritionStat(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .protein,
                                                    '${dietPlan.targets['protein'] ?? 150}',
                                                    'g',
                                                    Icons.fitness_center,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: _buildNutritionStat(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .carbs,
                                                    '${dietPlan.targets['carbs'] ?? 300}',
                                                    'g',
                                                    Icons.grain,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: _buildNutritionStat(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .fat,
                                                    '${dietPlan.targets['fat'] ?? 100}',
                                                    'g',
                                                    Icons.opacity,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Additional Notes Section
                                    if (dietPlan.additionalNotes.isNotEmpty)
                                      Container(
                                        width: double.infinity,
                                        margin:
                                            const EdgeInsets.only(bottom: 24),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer,
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer
                                                  .withOpacity(0.8),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.2),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withOpacity(0.2),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.note_alt_outlined,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .additionalNotes,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSecondaryContainer,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              dietPlan.additionalNotes,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondaryContainer
                                                    .withOpacity(0.8),
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Meals List
                                    ...dietPlan.meals.map((meal) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          color: Color.lerp(
                                            Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withOpacity(0.1),
                                            0.05,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .shadow
                                                  .withOpacity(0.12),
                                              blurRadius: 18,
                                              spreadRadius: 3,
                                              offset: const Offset(0, 6),
                                            ),
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .shadow
                                                  .withOpacity(0.05),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withOpacity(0.08),
                                            width: 1,
                                          ),
                                        ),
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            dividerColor: Colors.transparent,
                                          ),
                                          child: ExpansionTile(
                                            tilePadding:
                                                const EdgeInsets.all(20),
                                            childrenPadding: EdgeInsets.zero,
                                            backgroundColor: Colors.transparent,
                                            collapsedBackgroundColor:
                                                Colors.transparent,
                                            iconColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            collapsedIconColor:
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7),
                                            leading: Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _getMealColor(meal.mealType)
                                                        .withOpacity(0.8),
                                                    _getMealColor(
                                                        meal.mealType),
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _getMealColor(
                                                            meal.mealType)
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                _getMealIcon(meal.mealType),
                                                color: Colors.white,
                                                size: 26,
                                              ),
                                            ),
                                            title: Text(
                                              _getLocalizedMealType(
                                                  meal.mealType),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            subtitle: Container(
                                              margin:
                                                  const EdgeInsets.only(top: 4),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color:
                                                    _getMealColor(meal.mealType)
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '${meal.time} • ${meal.calories} kcal',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: _getMealColor(
                                                      meal.mealType),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  children:
                                                      meal.items.map((item) {
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 12),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surface,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .outline
                                                                .withOpacity(
                                                                    0.2)),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .shadow
                                                                .withOpacity(
                                                                    0.05),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 10,
                                                            height: 10,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  _getMealColor(
                                                                      meal.mealType),
                                                                  _getMealColor(meal
                                                                          .mealType)
                                                                      .withOpacity(
                                                                          0.7),
                                                                ],
                                                              ),
                                                              shape: BoxShape
                                                                  .circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: _getMealColor(meal
                                                                          .mealType)
                                                                      .withOpacity(
                                                                          0.3),
                                                                  blurRadius: 2,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 1),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 12),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  item.foodName,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurface,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 4),
                                                                Text(
                                                                  '${item.quantity} • ${item.calories} kcal',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurface
                                                                        .withOpacity(
                                                                            0.7),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 4),
                                                                Row(
                                                                  children: [
                                                                    _buildMacroChip(
                                                                        'P: ${item.protein}g',
                                                                        Colors
                                                                            .red),
                                                                    const SizedBox(
                                                                        width:
                                                                            6),
                                                                    _buildMacroChip(
                                                                        'C: ${item.carbs}g',
                                                                        Colors
                                                                            .blue),
                                                                    const SizedBox(
                                                                        width:
                                                                            6),
                                                                    _buildMacroChip(
                                                                        'F: ${item.fat}g',
                                                                        Colors
                                                                            .orange),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),

                                    const SizedBox(height: 24),

                                    // Info Card
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.info_outline,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              provider.hasNutritionPlan
                                                  ? 'This is your personalized diet plan designed to support your fitness goals. Follow the portions and timing for best results.'
                                                  : 'This is a default diet plan. Contact your gym trainer to get a personalized nutrition plan based on your goals.',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionStat(
      String label, String value, String unit, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive dimensions
    final iconSize = _safeSize(screenWidth, 0.05, 20.0);
    final valueFontSize = _safeSize(screenWidth, 0.04, 16.0);
    final labelFontSize = _safeSize(screenWidth, 0.025, 10.0);
    final spacing = _safeSize(screenWidth, 0.02, 8.0);

    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
          size: iconSize,
        ),
        SizedBox(height: spacing),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        Text(
          '$label ($unit)',
          style: TextStyle(
            fontSize: labelFontSize,
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMacroChip(String text, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive dimensions
    final horizontalPadding = _safeSize(screenWidth, 0.015, 6.0);
    final verticalPadding = _safeSize(screenWidth, 0.005, 2.0);
    final borderRadius = _safeSize(screenWidth, 0.02, 8.0);
    final fontSize = _safeSize(screenWidth, 0.025, 10.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
