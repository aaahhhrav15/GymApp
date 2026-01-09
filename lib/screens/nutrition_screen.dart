// lib/screens/nutrition_screen.dart - Redesigned with modern UI
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/nutrition_provider.dart';
import '../models/nutrition_models.dart';
import '../components/add_food_drawer.dart';
import '../widgets/nutrition_goal_dialog.dart';
import '../l10n/app_localizations.dart';

class NutritionDetailScreen extends StatefulWidget {
  const NutritionDetailScreen({super.key});

  @override
  State<NutritionDetailScreen> createState() => _NutritionDetailScreenState();
}

class _NutritionDetailScreenState extends State<NutritionDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressAnimationController;
  late AnimationController _drawerAnimationController;
  final ScrollController _scrollController = ScrollController();
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _drawerAnimation;

  bool _showAddFoodDrawer = false;
  bool _isAddingFood = false;
  int _selectedHistoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressAnimationController.dispose();
    _drawerAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

    _drawerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    // Start progress animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _progressAnimationController.forward();
      }
    });
  }

  void _toggleAddFoodDrawer() {
    setState(() {
      _showAddFoodDrawer = !_showAddFoodDrawer;
    });

    if (_showAddFoodDrawer) {
      _drawerAnimationController.forward();
    } else {
      _drawerAnimationController.reverse();
    }
  }

  Future<void> _addFood({
    required String name,
    required int calories,
    required double protein,
    required double fat,
    required double carbs,
    String mealType = 'custom',
    String source = 'manual',
  }) async {
    if (_isAddingFood) return;

    setState(() => _isAddingFood = true);

    try {
      final meal = Meal(
        name: name,
        calories: calories,
        protein: protein,
        fat: fat,
        carbs: carbs,
        mealType: mealType,
        time: DateTime.now().toString(),
        createdAt: DateTime.now(),
        source: source,
      );

      await context.read<NutritionProvider>().addMeal(meal);

      if (mounted) {
        _toggleAddFoodDrawer();
        // Restart progress animation
        _progressAnimationController.reset();
        _progressAnimationController.forward();
      }
    } catch (e) {
      debugPrint('Error adding food: $e');
    } finally {
      if (mounted) {
        setState(() => _isAddingFood = false);
      }
    }
  }

  Future<void> _deleteMeal(Meal meal) async {
    try {
      if (meal.id != null) {
        await context.read<NutritionProvider>().deleteMeal(meal.id!);
        // Restart progress animation
        _progressAnimationController.reset();
        _progressAnimationController.forward();
      }
    } catch (e) {
      debugPrint('Error deleting meal: $e');
    }
  }

  Future<void> _editMeal(String mealId, Meal updatedMeal) async {
    try {
      await context.read<NutritionProvider>().updateMeal(mealId, updatedMeal);
      // Restart progress animation
      _progressAnimationController.reset();
      _progressAnimationController.forward();
    } catch (e) {
      debugPrint('Error updating meal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Nutrition color scheme - vibrant green/teal
    final nutritionColor = isDark ? const Color(0xFF66BB6A) : const Color(0xFF4CAF50);
    final nutritionColorLight = isDark ? const Color(0xFFC8E6C9) : const Color(0xFFE8F5E9);
    final backgroundColor = isDark ? const Color(0xFF0D1F12) : const Color(0xFFF1F8E9);
    final cardColor = isDark ? const Color(0xFF1A2E1D) : Colors.white;

    final horizontalPadding = screenWidth * 0.04;
    final sectionSpacing = screenHeight * 0.018;

    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        if (nutritionProvider.isLoading) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: nutritionColor),
            ),
          );
        }

        final currentTotals = nutritionProvider.currentTotals;
        final goals = nutritionProvider.nutritionGoals;
        final calorieProgress = (currentTotals.calories / goals.calories).clamp(0.0, 1.0);
        final percentage = (calorieProgress * 100).toInt();

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                // Main content
                Column(
                  children: [
                    _buildHeader(isDark, nutritionColor, nutritionProvider),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(height: sectionSpacing),

                              // Main Progress Circle
                              _buildProgressCircle(
                                currentTotals,
                                goals,
                                calorieProgress,
                                percentage,
                                isDark,
                                nutritionColor,
                                nutritionColorLight,
                                cardColor,
                              ),

                              SizedBox(height: sectionSpacing),

                              // Macros Row
                              _buildMacrosRow(
                                currentTotals,
                                goals,
                                isDark,
                                nutritionColor,
                                cardColor,
                              ),

                              SizedBox(height: sectionSpacing),

                              // Meals List
                              _buildMealsList(
                                nutritionProvider,
                                isDark,
                                nutritionColor,
                                cardColor,
                              ),

                              SizedBox(height: sectionSpacing),

                              // Weekly History Chart
                              _buildWeeklyChart(
                                nutritionProvider,
                                isDark,
                                nutritionColor,
                                nutritionColorLight,
                                cardColor,
                              ),

                              SizedBox(height: screenHeight * 0.12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Add food drawer
                if (_showAddFoodDrawer)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(_drawerAnimationController),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: AddFoodDrawer(
                          animation: _drawerAnimation,
                          onClose: _toggleAddFoodDrawer,
                          onAddFood: _addFood,
                          isLoading: _isAddingFood,
                        ),
                      ),
                    ),
                  ),

                // Floating Action Button
                Positioned(
                  bottom: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: nutritionProvider.isLoading ? null : _toggleAddFoodDrawer,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [nutritionColor, nutritionColor.withOpacity(0.8)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: nutritionColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            _showAddFoodDrawer ? Icons.close : Icons.add,
                            key: ValueKey(_showAddFoodDrawer),
                            color: Colors.white,
                            size: 28,
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
      },
    );
  }

  Widget _buildHeader(bool isDark, Color nutritionColor, NutritionProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerPadding = screenWidth * 0.04;
    final buttonSize = screenWidth * 0.11;
    final iconSize = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.05;
    final l10n = AppLocalizations.of(context)!;

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
              child: Column(
                children: [
                  Text(
                    l10n.nutrition,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    _formatDisplayDate(provider.selectedDate),
                    style: TextStyle(
                      fontSize: titleFontSize * 0.6,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showGoalDialog(context, provider),
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
                  Icons.track_changes,
                  size: iconSize * 0.8,
                  color: nutritionColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(
    NutritionTotals currentTotals,
    NutritionGoals goals,
    double calorieProgress,
    int percentage,
    bool isDark,
    Color nutritionColor,
    Color nutritionColorLight,
    Color cardColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;

    final circleSize = math.min(screenWidth * 0.52, screenHeight * 0.28);
    final innerContentSize = circleSize * 0.7;
    final caloriesFontSize = math.min(circleSize * 0.16, 36.0);
    final labelFontSize = math.min(circleSize * 0.07, 14.0);
    final iconSize = math.min(circleSize * 0.11, 24.0);
    final iconPadding = math.min(circleSize * 0.04, 10.0);
    final strokeWidth = math.min(circleSize * 0.06, 12.0);

    final remaining = goals.calories - currentTotals.calories;
    final isGoalAchieved = currentTotals.calories >= goals.calories;

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
                    color: isDark ? const Color(0xFF2D3E2F) : nutritionColorLight,
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
                        painter: _NutritionCircularProgressPainter(
                          progress: calorieProgress * _progressAnimation.value,
                          strokeWidth: strokeWidth,
                          backgroundColor: isDark
                              ? const Color(0xFF4D5E4F)
                              : const Color(0xFFC8E6C9),
                          progressColor: nutritionColor,
                          isGoalAchieved: isGoalAchieved,
                        ),
                      );
                    },
                  ),
                ),
                // Center content
                SizedBox(
                  width: innerContentSize,
                  height: innerContentSize,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated icon
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.8, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: EdgeInsets.all(iconPadding),
                              decoration: BoxDecoration(
                                color: nutritionColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.restaurant_menu,
                                size: iconSize,
                                color: nutritionColor,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: circleSize * 0.03),
                      TweenAnimationBuilder<int>(
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutCubic,
                        tween: IntTween(begin: 0, end: currentTotals.calories),
                        builder: (context, value, child) {
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatNumber(value),
                              style: TextStyle(
                                fontSize: caloriesFontSize,
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
                          l10n.cal,
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
                            color: isGoalAchieved
                                ? const Color(0xFF4CAF50).withOpacity(0.15)
                                : nutritionColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isGoalAchieved)
                                Icon(
                                  Icons.check_circle,
                                  size: labelFontSize,
                                  color: const Color(0xFF4CAF50),
                                ),
                              if (isGoalAchieved) const SizedBox(width: 4),
                              Text(
                                isGoalAchieved ? l10n.goalAchieved : '$percentage%',
                                style: TextStyle(
                                  fontSize: labelFontSize * 0.9,
                                  fontWeight: FontWeight.bold,
                                  color: isGoalAchieved
                                      ? const Color(0xFF4CAF50)
                                      : nutritionColor,
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
          // Remaining/Goal info
          Text(
            remaining > 0
                ? '${l10n.remainingOnly} ${_formatNumber(remaining)} ${l10n.cal}'
                : '${l10n.goalExceededBy} ${_formatNumber(-remaining)} ${l10n.cal}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: remaining > 0 ? nutritionColor : Colors.red[400],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.calorieGoal}: ${_formatNumber(goals.calories)} ${l10n.kcal}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosRow(
    NutritionTotals currentTotals,
    NutritionGoals goals,
    bool isDark,
    Color nutritionColor,
    Color cardColor,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        // Protein
        Expanded(
          child: _buildMacroCard(
            l10n.protein,
            currentTotals.protein.round(),
            goals.protein,
            '🥩',
            const Color(0xFFE91E63),
            isDark,
            cardColor,
          ),
        ),
        const SizedBox(width: 10),
        // Fat
        Expanded(
          child: _buildMacroCard(
            l10n.fat,
            currentTotals.fat.round(),
            goals.fat,
            '🧈',
            const Color(0xFFFF9800),
            isDark,
            cardColor,
          ),
        ),
        const SizedBox(width: 10),
        // Carbs
        Expanded(
          child: _buildMacroCard(
            l10n.carbs,
            currentTotals.carbs.round(),
            goals.carbs,
            '🌾',
            const Color(0xFF2196F3),
            isDark,
            cardColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard(
    String name,
    int current,
    int target,
    String emoji,
    Color color,
    bool isDark,
    Color cardColor,
  ) {
    final progress = (current / target).clamp(0.0, 1.0);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
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
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress * _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.8), color],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '$current${l10n.grams}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            '/ $target${l10n.grams}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList(
    NutritionProvider nutritionProvider,
    bool isDark,
    Color nutritionColor,
    Color cardColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    if (nutritionProvider.meals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: nutritionColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 40,
                color: nutritionColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noMealsAddedYet,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tapToAddFirstMeal,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: nutritionColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.fastfood,
                  color: nutritionColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.todaysMeals,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: nutritionColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${nutritionProvider.meals.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: nutritionColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...nutritionProvider.meals.map((meal) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildMealCard(
                  meal,
                  isDark,
                  nutritionColor,
                  onDelete: () => _deleteMeal(meal),
                  onEdit: () => _showEditMealDialog(meal),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMealCard(
    Meal meal,
    bool isDark,
    Color nutritionColor, {
    required VoidCallback onDelete,
    required VoidCallback onEdit,
  }) {
    final typeColor = _getMealTypeColor(meal.mealType);
    final isAIMeal = meal.source == 'ai' || 
                     meal.source == 'image' || 
                     meal.source == 'ai_nutrition' || 
                     meal.source == 'ai_gemini';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showMealOptions(meal, onEdit, onDelete),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Meal type indicator
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              // Meal info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meal.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAIMeal)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: nutritionColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  meal.source == 'image' ? Icons.camera_alt : Icons.auto_awesome,
                                  size: 10,
                                  color: nutritionColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'AI',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: nutritionColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          meal.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatMealType(meal.mealType),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Nutrition chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildNutrientChip('${meal.calories} cal', Colors.red[400]!, isDark),
                        _buildNutrientChip('P: ${meal.protein.round()}g', const Color(0xFFE91E63), isDark),
                        _buildNutrientChip('F: ${meal.fat.round()}g', const Color(0xFFFF9800), isDark),
                        _buildNutrientChip('C: ${meal.carbs.round()}g', const Color(0xFF2196F3), isDark),
                      ],
                    ),
                  ],
                ),
              ),
              // More options
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: isDark ? Colors.white60 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showMealOptions(Meal meal, VoidCallback onEdit, VoidCallback onDelete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nutritionColor = isDark ? const Color(0xFF66BB6A) : const Color(0xFF4CAF50);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2E1D) : Colors.white,
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
                color: isDark ? Colors.white30 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              meal.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: nutritionColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.edit, color: nutritionColor, size: 22),
              ),
              title: Text(
                'Edit Meal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                'Modify nutrition values',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete, color: Colors.red[400], size: 22),
              ),
              title: Text(
                'Delete Meal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[400],
                ),
              ),
              subtitle: Text(
                'Remove from today\'s log',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditMealDialog(Meal meal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nutritionColor = isDark ? const Color(0xFF66BB6A) : const Color(0xFF4CAF50);

    final nameController = TextEditingController(text: meal.name);
    final caloriesController = TextEditingController(text: meal.calories.toString());
    final proteinController = TextEditingController(text: meal.protein.round().toString());
    final fatController = TextEditingController(text: meal.fat.round().toString());
    final carbsController = TextEditingController(text: meal.carbs.round().toString());

    // Automatically recalculate calories when macros change
    void _recalculateCalories() {
      final protein = double.tryParse(proteinController.text) ?? meal.protein;
      final fat = double.tryParse(fatController.text) ?? meal.fat;
      final carbs = double.tryParse(carbsController.text) ?? meal.carbs;

      // 4 kcal per g for protein & carbs, 9 kcal per g for fat
      final calories = (protein * 4 + carbs * 4 + fat * 9).round();
      caloriesController.text = calories.toString();
    }

    proteinController.addListener(_recalculateCalories);
    fatController.addListener(_recalculateCalories);
    carbsController.addListener(_recalculateCalories);

    // Ensure initial value is consistent with macros
    _recalculateCalories();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2E1D) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: nutritionColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: nutritionColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Edit Meal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Update the nutrition values',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                // Food Name
                _buildEditField('Food Name', nameController, isDark, nutritionColor),
                const SizedBox(height: 16),
                // Calories
                _buildEditField('Calories', caloriesController, isDark, nutritionColor,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                // Macros row
                Row(
                  children: [
                    Expanded(
                      child: _buildEditField('Protein (g)', proteinController, isDark, nutritionColor,
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEditField('Fat (g)', fatController, isDark, nutritionColor,
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEditField('Carbs (g)', carbsController, isDark, nutritionColor,
                          keyboardType: TextInputType.number),
                    ),
                  ],
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
                                'Cancel',
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
                            final protein =
                                double.tryParse(proteinController.text) ?? meal.protein;
                            final fat =
                                double.tryParse(fatController.text) ?? meal.fat;
                            final carbs =
                                double.tryParse(carbsController.text) ?? meal.carbs;

                            // Always derive calories from macros (4/4/9 rule)
                            final derivedCalories =
                                (protein * 4 + carbs * 4 + fat * 9).round();

                            final updatedMeal = meal.copyWith(
                              name: nameController.text.trim().isNotEmpty
                                  ? nameController.text.trim()
                                  : meal.name,
                              calories: derivedCalories,
                              protein: protein,
                              fat: fat,
                              carbs: carbs,
                            );
                            Navigator.pop(context);
                            _editMeal(meal.id!, updatedMeal);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [nutritionColor, nutritionColor.withOpacity(0.85)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: nutritionColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Save Changes',
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
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    bool isDark,
    Color accentColor, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(
    NutritionProvider nutritionProvider,
    bool isDark,
    Color nutritionColor,
    Color nutritionColorLight,
    Color cardColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;

    final chartHeight = math.min(screenHeight * 0.22, 180.0);
    final barMaxHeight = chartHeight * 0.5;

    final weeklyTotals = nutritionProvider.weeklyTotals;
    final weeklyGoals = nutritionProvider.weeklyGoals;

    if (weeklyTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort dates (oldest to newest)
    final sortedDates = weeklyTotals.keys.toList()..sort();
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Calculate max calories for scaling
    int maxCalories = 1;
    for (var date in sortedDates) {
      final calories = weeklyTotals[date]?.calories ?? 0;
      if (calories > maxCalories) maxCalories = calories;
    }

    // Calculate weekly totals
    int totalWeeklyCalories = 0;
    for (var date in sortedDates) {
      totalWeeklyCalories += weeklyTotals[date]?.calories ?? 0;
    }
    final avgCalories = totalWeeklyCalories ~/ 7;

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
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.022),
                decoration: BoxDecoration(
                  color: nutritionColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: nutritionColor,
                  size: 18,
                ),
              ),
              SizedBox(width: screenWidth * 0.025),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.sevenDayHistory,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Avg: ${_formatNumber(avgCalories)} cal/day',
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
                  color: nutritionColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_formatNumber(totalWeeklyCalories)} cal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: nutritionColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          // Chart
          SizedBox(
            height: chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(sortedDates.length, (index) {
                final dateStr = sortedDates[index];
                final date = DateTime.parse(dateStr);
                final dayCalories = weeklyTotals[dateStr]?.calories ?? 0;
                final dayGoal = weeklyGoals[dateStr]?.calories ?? 2200;
                final dayAbbr = _getDayAbbreviation(date.weekday);
                final isSelected = dateStr == nutritionProvider.selectedDate;
                final isTodayDate = dateStr == today;
                final barHeight = maxCalories > 0
                    ? (dayCalories / maxCalories) * barMaxHeight
                    : 0.0;
                final goalProgress = (dayCalories / dayGoal).clamp(0.0, 1.0);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onHistoryDateTap(dateStr, nutritionProvider),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.005),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Calorie count label (only for selected)
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
                                    color: nutritionColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _formatNumber(dayCalories),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Bar
                          Container(
                            height: barHeight.clamp(4.0, barMaxHeight),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [nutritionColor, nutritionColor.withOpacity(0.7)],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : isTodayDate
                                      ? nutritionColor.withOpacity(0.7)
                                      : goalProgress >= 0.9
                                          ? nutritionColor.withOpacity(0.5)
                                          : nutritionColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: nutritionColor.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Day label
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  dayAbbr,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected || isTodayDate ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected
                                        ? nutritionColor
                                        : isTodayDate
                                            ? nutritionColor.withOpacity(0.8)
                                            : (isDark ? Colors.white60 : Colors.black54),
                                  ),
                                ),
                              ),
                              if (!isTodayDate)
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${date.month}/${date.day}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                      color: isSelected
                                          ? nutritionColor.withOpacity(0.8)
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
                                    color: nutritionColor,
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

  void _showGoalDialog(BuildContext context, NutritionProvider nutritionProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NutritionGoalDialog(
          currentGoals: nutritionProvider.nutritionGoals,
          onSave: (newGoals) {
            nutritionProvider.updateNutritionGoals(newGoals);
            // Restart progress animation
            _progressAnimationController.reset();
            _progressAnimationController.forward();
          },
        );
      },
    );
  }

  Future<void> _onHistoryDateTap(
      String dateStr, NutritionProvider nutritionProvider) async {
    // Preserve current scroll offset so the page doesn't jump to top
    final currentOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;

    await nutritionProvider.changeSelectedDate(dateStr);

    // Restore scroll position after the frame is rebuilt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(currentOffset);
      }
    });
  }

  Color _getMealTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFF9800);
      case 'lunch':
        return const Color(0xFF4CAF50);
      case 'dinner':
        return const Color(0xFF2196F3);
      case 'snack':
        return const Color(0xFF9C27B0);
      case 'ai_detected':
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF607D8B);
    }
  }

  String _formatMealType(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snack';
      case 'ai_detected':
        return 'AI Scan';
      case 'custom':
        return 'Custom';
      default:
        return 'Meal';
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

  String _formatDisplayDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final today = DateTime.now();
      final l10n = AppLocalizations.of(context)!;

      if (date.day == today.day &&
          date.month == today.month &&
          date.year == today.year) {
        return l10n.today;
      }

      final yesterday = today.subtract(const Duration(days: 1));
      if (date.day == yesterday.day &&
          date.month == yesterday.month &&
          date.year == yesterday.year) {
        return l10n.yesterday;
      }

      final months = [
        l10n.jan, l10n.feb, l10n.mar, l10n.apr, l10n.may, l10n.jun,
        l10n.jul, l10n.aug, l10n.sep, l10n.oct, l10n.nov, l10n.dec,
      ];
      return '${months[date.month - 1]} ${date.day}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 10000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// Custom circular progress painter for nutrition
class _NutritionCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final bool isGoalAchieved;

  _NutritionCircularProgressPainter({
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
  bool shouldRepaint(covariant _NutritionCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.isGoalAchieved != isGoalAchieved;
  }
}
