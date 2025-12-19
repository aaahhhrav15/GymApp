import 'package:flutter/material.dart';
import '../screens/all_recipes_screen.dart';
import '../screens/cooking_steps_screen.dart';
import '../screens/recipe_detail_screen.dart';
import '../l10n/app_localizations.dart';

class RecipesWidget extends StatefulWidget {
  const RecipesWidget({super.key});

  @override
  State<RecipesWidget> createState() => _RecipesWidgetState();
}

class _RecipesWidgetState extends State<RecipesWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Indian healthy recipes data with cooking steps
  final List<Map<String, dynamic>> _recipes = [
    {
      'title': 'Oats Idli',
      'subtitle': 'Healthy South Indian Breakfast',
      'calories': '150 cal',
      'time': '20 min',
      'difficulty': 'Easy',
      'color': Colors.green,
      'imageUrl':
          'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'ingredients': [
        '1 cup Oats',
        '1/2 cup Semolina',
        '1/2 cup Yogurt',
        '1/4 cup Mixed Vegetables',
        '1 tsp Ginger-Green Chili paste',
        '1 tsp Mustard seeds',
        '1/2 tsp Turmeric',
        'Salt to taste',
        'Water as needed'
      ],
      'description': 'Nutritious steamed breakfast with fiber-rich oats',
      'cookingSteps': [
        'Dry roast oats in a pan for 2-3 minutes until fragrant. Let cool and grind to coarse powder.',
        'In a bowl, mix oats powder, semolina, yogurt, and water to make a smooth batter. Let it rest for 10 minutes.',
        'Heat oil in a pan, add mustard seeds. Once they splutter, add ginger-chili paste.',
        'Add mixed vegetables, turmeric, and salt. Cook for 2-3 minutes.',
        'Add this tempering to the batter and mix well. Adjust consistency with water.',
        'Grease idli molds and pour batter into each mold.',
        'Steam in an idli steamer for 12-15 minutes.',
        'Cool for 2 minutes, then gently remove idlis using a spoon.',
        'Serve hot with coconut chutney and sambar.'
      ],
    },
    {
      'title': 'Quinoa Pulao',
      'subtitle': 'Protein-Rich One Pot Meal',
      'calories': '280 cal',
      'time': '30 min',
      'difficulty': 'Medium',
      'color': Colors.orange,
      'imageUrl':
          'https://images.unsplash.com/photo-1596797038530-2c107229654b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'ingredients': [
        '1 cup Quinoa',
        '1 cup Mixed Vegetables',
        '1 Bay leaf',
        '4-5 Green cardamom',
        '1 inch Cinnamon stick',
        '1 tsp Cumin seeds',
        '1 tbsp Ghee',
        '2 cups Water',
        'Salt to taste'
      ],
      'description': 'Complete protein meal with aromatic Indian spices',
      'cookingSteps': [
        'Rinse quinoa thoroughly under cold water until water runs clear.',
        'Heat ghee in a heavy-bottomed pot over medium heat.',
        'Add bay leaf, cardamom, cinnamon, and cumin seeds. Sauté until fragrant.',
        'Add mixed vegetables and cook for 3-4 minutes until slightly tender.',
        'Add quinoa and stir gently for 2 minutes to toast lightly.',
        'Pour in water, add salt, and bring to a boil.',
        'Reduce heat to low, cover, and simmer for 15-18 minutes.',
        'Turn off heat and let it rest for 5 minutes without opening the lid.',
        'Fluff with a fork, remove whole spices, and serve hot.',
        'Garnish with fresh herbs and serve with raita.'
      ],
    },
    {
      'title': 'Moong Dal Chilla',
      'subtitle': 'High Protein Pancake',
      'calories': '120 cal',
      'time': '15 min',
      'difficulty': 'Easy',
      'color': Colors.yellow.shade700,
      'imageUrl':
          'https://images.unsplash.com/photo-1574484284002-952d92456975?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'ingredients': [
        '1 cup Moong Dal (soaked)',
        '1 small Onion (chopped)',
        '1 Tomato (chopped)',
        '1 Green chili',
        '1 tsp Ginger paste',
        '1/2 tsp Turmeric',
        '1/2 tsp Cumin powder',
        'Salt to taste',
        'Oil for cooking'
      ],
      'description': 'Protein-packed savory pancake with vegetables',
      'cookingSteps': [
        'Soak moong dal in water for 2-3 hours. Drain well.',
        'Grind dal with green chili and ginger paste to a smooth batter, adding minimal water.',
        'Transfer to a bowl and add turmeric, cumin powder, and salt. Mix well.',
        'Add chopped onions and tomatoes to the batter. Mix thoroughly.',
        'Heat a non-stick pan over medium heat and lightly grease with oil.',
        'Pour a ladleful of batter and spread evenly in a circular motion.',
        'Cook for 2-3 minutes until the bottom is golden brown.',
        'Flip carefully and cook the other side for 2 minutes.',
        'Serve hot with green chutney and yogurt.',
        'Repeat for remaining batter.'
      ],
    },
    {
      'title': 'Palak Paneer Bowl',
      'subtitle': 'Iron & Protein Rich Curry',
      'calories': '200 cal',
      'time': '25 min',
      'difficulty': 'Medium',
      'color': Colors.teal,
      'imageUrl':
          'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'ingredients': [
        '300g Fresh Spinach',
        '200g Paneer (cubed)',
        '1 large Onion',
        '2 Tomatoes',
        '3-4 Garlic cloves',
        '1 inch Ginger',
        '2 Green chilies',
        '1 tsp Cumin seeds',
        '1/2 tsp Garam masala',
        '1/4 cup Cream',
        'Salt to taste',
        'Oil for cooking'
      ],
      'description': 'Iron-rich spinach curry with cottage cheese',
      'cookingSteps': [
        'Blanch spinach in boiling water for 2 minutes. Drain and put in ice water.',
        'Blend blanched spinach to a smooth puree. Set aside.',
        'Heat oil in a pan, lightly fry paneer cubes until golden. Remove and set aside.',
        'In the same pan, add cumin seeds and let them splutter.',
        'Add chopped onions and sauté until golden brown.',
        'Add ginger-garlic paste and green chilies. Cook for 1 minute.',
        'Add chopped tomatoes and cook until soft and mushy.',
        'Add garam masala, salt, and cook for 2 minutes.',
        'Add spinach puree and simmer for 5-7 minutes.',
        'Gently add fried paneer cubes and cream. Simmer for 3 minutes.',
        'Serve hot with roti or rice.'
      ],
    },
    {
      'title': 'Ragi Roti',
      'subtitle': 'Calcium Rich Millet Bread',
      'calories': '95 cal',
      'time': '12 min',
      'difficulty': 'Easy',
      'color': Colors.brown,
      'imageUrl':
          'https://images.unsplash.com/photo-1606491956689-2ea866880c84?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'ingredients': [
        '1 cup Ragi Flour',
        '1 small Onion (finely chopped)',
        '2 Green chilies (chopped)',
        '2 tbsp Fresh coriander',
        '1/2 tsp Cumin seeds',
        '1/2 tsp Salt',
        'Water as needed',
        'Oil for cooking'
      ],
      'description': 'Nutritious millet flatbread rich in calcium',
      'cookingSteps': [
        'In a mixing bowl, combine ragi flour, salt, and cumin seeds.',
        'Add chopped onions, green chilies, and coriander to the flour.',
        'Gradually add warm water while mixing to form a soft dough.',
        'Knead the dough well for 2-3 minutes until smooth.',
        'Cover and let it rest for 10 minutes.',
        'Divide dough into small portions and roll into balls.',
        'On a floured surface, roll each ball into thin circular rotis.',
        'Heat a tawa or griddle over medium heat.',
        'Place the roti and cook for 1-2 minutes until bubbles form.',
        'Flip and cook the other side for 1 minute.',
        'Apply a little oil/ghee and serve hot with curry or chutney.'
      ],
    },
    {
      'title': 'Sambar Rice Bowl',
      'subtitle': 'Complete Protein Combination',
      'calories': '250 cal',
      'time': '35 min',
      'difficulty': 'Medium',
      'color': Colors.deepOrange,
      'imageUrl':
          'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'ingredients': [
        '1 cup Brown Rice',
        '1/2 cup Toor Dal',
        '1 cup Mixed Vegetables',
        '2 tbsp Sambar Powder',
        '1/2 tsp Turmeric',
        '2 tbsp Tamarind paste',
        '1 tsp Mustard seeds',
        '4-5 Curry leaves',
        '2 tbsp Oil',
        'Salt to taste'
      ],
      'description':
          'Traditional South Indian comfort food with complete proteins',
      'cookingSteps': [
        'Cook brown rice in a rice cooker or pot with 2 cups water until tender.',
        'Pressure cook toor dal with turmeric and 1.5 cups water for 3-4 whistles.',
        'Mash the cooked dal and set aside.',
        'Cut vegetables (drumstick, okra, tomato, onion) into medium pieces.',
        'Heat oil in a heavy-bottomed pot, add mustard seeds and curry leaves.',
        'Add vegetables and cook for 5-7 minutes until semi-tender.',
        'Add mashed dal, sambar powder, and 2 cups water. Bring to boil.',
        'Add tamarind paste and salt. Simmer for 10-15 minutes.',
        'Adjust consistency with water if needed.',
        'Serve hot sambar over brown rice.',
        'Garnish with fresh coriander and serve with papad.'
      ],
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final bannerHeight = screenHeight * 0.22; // Responsive height
    final titleFontSize = screenWidth * 0.045;
    final subtitleFontSize = screenWidth * 0.035;
    final bodyFontSize = screenWidth * 0.03;
    final indicatorSize = screenWidth * 0.02;
    final sectionPadding = screenWidth * 0.04;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sectionPadding),
          child: Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Theme.of(context).colorScheme.primary,
                size: screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                l10n.healthyRecipes,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to all recipes screen
                  _showAllRecipes(context);
                },
                child: Text(
                  l10n.viewAll,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: bodyFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.015),

        // Recipe Banners with PageView
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _recipes.length,
            itemBuilder: (context, index) {
              final recipe = _recipes[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: sectionPadding),
                child: _buildRecipeBanner(
                  recipe,
                  screenWidth,
                  screenHeight,
                  titleFontSize,
                  subtitleFontSize,
                  bodyFontSize,
                ),
              );
            },
          ),
        ),

        SizedBox(height: screenHeight * 0.015),

        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _recipes.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.008),
              width: _currentIndex == index ? indicatorSize * 2 : indicatorSize,
              height: indicatorSize,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(indicatorSize / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeBanner(
    Map<String, dynamic> recipe,
    double screenWidth,
    double screenHeight,
    double titleFontSize,
    double subtitleFontSize,
    double bodyFontSize,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showRecipeDetails(context, recipe),
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: recipe['color'].withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  recipe['imageUrl'],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            recipe['color']
                                .withOpacity(isDarkMode ? 0.3 : 0.15),
                            recipe['color']
                                .withOpacity(isDarkMode ? 0.5 : 0.25),
                          ],
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: recipe['color'],
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            recipe['color']
                                .withOpacity(isDarkMode ? 0.3 : 0.15),
                            recipe['color']
                                .withOpacity(isDarkMode ? 0.5 : 0.25),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: screenWidth * 0.1,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Dark Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with difficulty badge
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe['title'],
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  recipe['subtitle'],
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.025,
                              vertical: screenHeight * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: recipe['color'],
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
                            ),
                            child: Text(
                              recipe['difficulty'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: bodyFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.015),

                      // Description
                      Text(
                        recipe['description'],
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Bottom info row
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.local_fire_department,
                            recipe['calories'],
                            Colors.white.withOpacity(0.9),
                            screenWidth,
                            bodyFontSize,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          _buildInfoChip(
                            Icons.access_time,
                            recipe['time'],
                            Colors.white.withOpacity(0.9),
                            screenWidth,
                            bodyFontSize,
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.02),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: screenWidth * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    Color color,
    double screenWidth,
    double fontSize,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: screenWidth * 0.035,
            color: color,
          ),
          SizedBox(width: screenWidth * 0.01),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: fontSize * 0.9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, Map<String, dynamic> recipe) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: screenHeight * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(screenWidth * 0.06),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.02),
              width: screenWidth * 0.1,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe['title'],
                                style: TextStyle(
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                recipe['subtitle'],
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Info chips
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.local_fire_department,
                          recipe['calories'],
                          recipe['color'],
                          screenWidth,
                          screenWidth * 0.035,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        _buildInfoChip(
                          Icons.access_time,
                          recipe['time'],
                          recipe['color'],
                          screenWidth,
                          screenWidth * 0.035,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        _buildInfoChip(
                          Icons.bar_chart,
                          recipe['difficulty'],
                          recipe['color'],
                          screenWidth,
                          screenWidth * 0.035,
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Description
                    Text(
                      l10n.description,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      recipe['description'],
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Ingredients
                    Text(
                      l10n.keyIngredients,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Wrap(
                      spacing: screenWidth * 0.02,
                      runSpacing: screenHeight * 0.01,
                      children: (recipe['ingredients'] as List<String>)
                          .map((ingredient) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03,
                                  vertical: screenHeight * 0.008,
                                ),
                                decoration: BoxDecoration(
                                  color: recipe['color'].withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.02),
                                  border: Border.all(
                                    color: recipe['color'].withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  ingredient,
                                  style: TextStyle(
                                    color: recipe['color'],
                                    fontSize: screenWidth * 0.03,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),

                    const Spacer(),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Add to favorites functionality
                              Navigator.pop(context);
                              // Snackbar removed - no longer showing favorite save messages
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: recipe['color']),
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite_border,
                                    color: recipe['color']),
                                SizedBox(width: screenWidth * 0.015),
                                Text(
                                  l10n.save,
                                  style: TextStyle(
                                    color: recipe['color'],
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecipeDetailScreen(recipe: recipe),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: recipe['color']),
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline,
                                    color: recipe['color']),
                                SizedBox(width: screenWidth * 0.015),
                                Text(
                                  l10n.details,
                                  style: TextStyle(
                                    color: recipe['color'],
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to cooking steps screen
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CookingStepsScreen(recipe: recipe),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: recipe['color'],
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_arrow,
                                    color: Colors.white),
                                SizedBox(width: screenWidth * 0.015),
                                Text(
                                  l10n.cook,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllRecipes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AllRecipesScreen(),
      ),
    );
  }
}
