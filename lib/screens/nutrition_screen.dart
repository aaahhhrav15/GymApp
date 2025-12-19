// lib/screens/nutrition_screen.dart - Updated to use NutritionProvider
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/nutrition_models.dart';
import '../components/nutrition_summary_card.dart';
import '../components/meal_card.dart';
import '../components/add_food_drawer.dart';
import '../widgets/nutrition_goal_dialog.dart';
import '../widgets/nutrition_history_widget.dart';
import 'package:gym_app_2/services/connectivity_service.dart';
import '../l10n/app_localizations.dart';

class NutritionDetailScreen extends StatefulWidget {
  const NutritionDetailScreen({super.key});

  @override
  State<NutritionDetailScreen> createState() => _NutritionDetailScreenState();
}

class _NutritionDetailScreenState extends State<NutritionDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _drawerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _drawerAnimation;

  bool _showAddFoodDrawer = false;
  bool _isAddingFood = false;

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
    _drawerAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _drawerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
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
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(AppLocalizations.of(context)!.foodAddedSuccessfully),
        //     backgroundColor: Theme.of(context).colorScheme.primary,
        //   ),
        // );
      }
    } catch (e) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //         AppLocalizations.of(context)!.failedToAddFood(e.toString())),
        //     backgroundColor: Theme.of(context).colorScheme.error,
        //   ),
        // );
      }
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

        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content:
          //         Text(AppLocalizations.of(context)!.mealDeletedSuccessfully),
          //     backgroundColor: Theme.of(context).colorScheme.primary,
          //   ),
          // );
        }
      }
    } catch (e) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //         AppLocalizations.of(context)!.failedToDeleteMeal(e.toString())),
        //     backgroundColor: Theme.of(context).colorScheme.error,
        //   ),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final cardPadding = screenWidth * 0.04;
    final bottomPadding = screenHeight * 0.1;

    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        return Scaffold(
          backgroundColor:
              Theme.of(context).colorScheme.background, // Match app theme
          body: SafeArea(
            child: Stack(
              children: [
                // Main content
                Column(
                  children: [
                    // Header
                    _buildHeader(context, nutritionProvider),

                    // Body
                    Expanded(
                      child: nutritionProvider.isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary),
                              ),
                            )
                          : FadeTransition(
                              opacity: _fadeAnimation,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    // Nutrition summary card
                                    Padding(
                                      padding: EdgeInsets.all(cardPadding),
                                      child: NutritionSummaryCard(
                                        currentTotals:
                                            nutritionProvider.currentTotals,
                                        goals: nutritionProvider.nutritionGoals,
                                      ),
                                    ),

                                    // Meals list
                                    _buildMealsList(nutritionProvider),

                                    // History section
                                    NutritionHistoryWidget(
                                      nutritionProvider: nutritionProvider,
                                      onDateSelect: (date) => nutritionProvider
                                          .changeSelectedDate(date),
                                    ),

                                    // Add some bottom padding for the floating button
                                    SizedBox(height: bottomPadding),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),

                // Add food drawer (slides up from bottom)
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
                  child: FloatingActionButton(
                    heroTag: "add_food_button",
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: nutritionProvider.isLoading
                        ? null
                        : _toggleAddFoodDrawer,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _showAddFoodDrawer
                          ? Icon(Icons.close,
                              key: const ValueKey('close'),
                              color: Theme.of(context).colorScheme.onPrimary)
                          : Icon(Icons.add,
                              key: const ValueKey('add'),
                              color: Theme.of(context).colorScheme.onPrimary),
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

  Widget _buildHeader(
      BuildContext context, NutritionProvider nutritionProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.nutrition,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDisplayDate(nutritionProvider.selectedDate, context),
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Goal setting button
          IconButton(
            onPressed: () => _showGoalDialog(context, nutritionProvider),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.track_changes,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              // Refresh data for new day if needed
              context.read<NutritionProvider>().refreshForNewDay();
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList(NutritionProvider nutritionProvider) {
    if (nutritionProvider.meals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noMealsAddedYet,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.tapToAddFirstMeal,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.todaysMeals,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...nutritionProvider.meals
              .map((meal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: MealCard(
                      meal: meal,
                      onDelete: (mealToDelete) => _deleteMeal(mealToDelete),
                      onEdit: (updatedMeal) => _editMeal(meal.id!, updatedMeal),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Future<void> _editMeal(String mealId, Meal updatedMeal) async {
    try {
      await context.read<NutritionProvider>().updateMeal(mealId, updatedMeal);

      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content:
        //         Text(AppLocalizations.of(context)!.mealUpdatedSuccessfully),
        //     backgroundColor: Theme.of(context).colorScheme.primary,
        //   ),
        // );
      }
    } catch (e) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //         AppLocalizations.of(context)!.failedToUpdateMeal(e.toString())),
        //     backgroundColor: Theme.of(context).colorScheme.error,
        //   ),
        // );
      }
    }
  }

  void _showGoalDialog(
      BuildContext context, NutritionProvider nutritionProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NutritionGoalDialog(
          currentGoals: nutritionProvider.nutritionGoals,
          onSave: (newGoals) {
            nutritionProvider.updateNutritionGoals(newGoals);
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(
            //         AppLocalizations.of(context)!.goalsUpdatedSuccessfully),
            //     backgroundColor: Theme.of(context).colorScheme.primary,
            //   ),
            // );
          },
        );
      },
    );
  }

  String _formatDisplayDate(String dateString, BuildContext context) {
    try {
      final date = DateTime.parse(dateString);
      final today = DateTime.now();

      if (date.day == today.day &&
          date.month == today.month &&
          date.year == today.year) {
        return AppLocalizations.of(context)!.today;
      }

      final yesterday = today.subtract(const Duration(days: 1));
      if (date.day == yesterday.day &&
          date.month == yesterday.month &&
          date.year == yesterday.year) {
        return AppLocalizations.of(context)!.yesterday;
      }

      final months = [
        AppLocalizations.of(context)!.jan,
        AppLocalizations.of(context)!.feb,
        AppLocalizations.of(context)!.mar,
        AppLocalizations.of(context)!.apr,
        AppLocalizations.of(context)!.may,
        AppLocalizations.of(context)!.jun,
        AppLocalizations.of(context)!.jul,
        AppLocalizations.of(context)!.aug,
        AppLocalizations.of(context)!.sep,
        AppLocalizations.of(context)!.oct,
        AppLocalizations.of(context)!.nov,
        AppLocalizations.of(context)!.dec,
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
