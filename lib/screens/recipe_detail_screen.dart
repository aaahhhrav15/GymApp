import 'package:flutter/material.dart';
import 'cooking_steps_screen.dart';
import '../l10n/app_localizations.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: screenHeight * 0.35,
            pinned: true,
            backgroundColor: widget.recipe['color'],
            leading: Container(
              margin: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: widget.recipe['color'],
                  size: screenWidth * 0.05,
                ),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    // Snackbar removed - no longer showing favorite status messages
                  },
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : widget.recipe['color'],
                    size: screenWidth * 0.05,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.recipe['color'].withOpacity(0.8),
                      widget.recipe['color'],
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: Image.network(
                        widget.recipe['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.recipe['color'].withOpacity(0.6),
                                  widget.recipe['color'],
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.restaurant_menu,
                                color: Colors.white,
                                size: screenWidth * 0.15,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              widget.recipe['color'].withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Recipe Title
                    Positioned(
                      bottom: screenHeight * 0.02,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.recipe['title'],
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            widget.recipe['subtitle'],
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.white.withOpacity(0.9),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 5,
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
            ),
          ),

          // Recipe Info
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                children: [
                  // Quick Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          Icons.access_time,
                          AppLocalizations.of(context)!.cookTime,
                          widget.recipe['time'],
                          widget.recipe['color'],
                          screenWidth,
                          screenHeight,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: _buildInfoCard(
                          Icons.bar_chart,
                          AppLocalizations.of(context)!.difficulty,
                          widget.recipe['difficulty'],
                          widget.recipe['color'],
                          screenWidth,
                          screenHeight,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: _buildInfoCard(
                          Icons.local_fire_department,
                          AppLocalizations.of(context)!.calories,
                          widget.recipe['calories'],
                          widget.recipe['color'],
                          screenWidth,
                          screenHeight,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: widget.recipe['color'],
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          Theme.of(context).colorScheme.onSurface,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.035,
                      ),
                      tabs: [
                        Tab(text: AppLocalizations.of(context)!.overview),
                        Tab(text: AppLocalizations.of(context)!.ingredients),
                        Tab(text: AppLocalizations.of(context)!.instructions),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Tab Content
                  SizedBox(
                    height: screenHeight * 0.4,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(screenWidth, screenHeight),
                        _buildIngredientsTab(screenWidth, screenHeight),
                        _buildInstructionsTab(screenWidth, screenHeight),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(screenWidth * 0.05),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CookingStepsScreen(recipe: widget.recipe),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)!.startCooking,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.recipe['color'],
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color,
      double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenWidth * 0.06),
          SizedBox(height: screenHeight * 0.005),
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: screenHeight * 0.002),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.aboutThisRecipe,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Text(
            widget.recipe['description'],
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.6,
            ),
          ),
          SizedBox(height: screenHeight * 0.03),

          // Nutritional Benefits
          Text(
            AppLocalizations.of(context)!.healthBenefits,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          _buildBenefitTile(
            Icons.favorite,
            AppLocalizations.of(context)!.heartHealthy,
            AppLocalizations.of(context)!.heartHealthyDesc,
            Colors.red,
            screenWidth,
            screenHeight,
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildBenefitTile(
            Icons.fitness_center,
            AppLocalizations.of(context)!.highProtein,
            AppLocalizations.of(context)!.highProteinDesc,
            Colors.orange,
            screenWidth,
            screenHeight,
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildBenefitTile(
            Icons.eco,
            AppLocalizations.of(context)!.naturalIngredients,
            AppLocalizations.of(context)!.naturalIngredientsDesc,
            Colors.green,
            screenWidth,
            screenHeight,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(double screenWidth, double screenHeight) {
    final ingredients = widget.recipe['ingredients'] as List<String>;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients (${ingredients.length} items)',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ...ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;

            return Container(
              margin: EdgeInsets.only(bottom: screenHeight * 0.015),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                border: Border.all(
                  color: widget.recipe['color'].withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.08,
                    decoration: BoxDecoration(
                      color: widget.recipe['color'],
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInstructionsTab(double screenWidth, double screenHeight) {
    final steps = widget.recipe['cookingSteps'] as List<String>;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.cookingSteps,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.025,
                  vertical: screenWidth * 0.01,
                ),
                decoration: BoxDecoration(
                  color: widget.recipe['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Text(
                  '${steps.length} steps',
                  style: TextStyle(
                    color: widget.recipe['color'],
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step indicator
                  Column(
                    children: [
                      Container(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        decoration: BoxDecoration(
                          color: widget.recipe['color'],
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.04),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: screenHeight * 0.04,
                          color: widget.recipe['color'].withOpacity(0.3),
                          margin: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01),
                        ),
                    ],
                  ),

                  SizedBox(width: screenWidth * 0.03),

                  // Step content
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(
                          color: widget.recipe['color'].withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBenefitTile(IconData icon, String title, String description,
      Color color, double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: screenWidth * 0.05),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
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
    );
  }
}
