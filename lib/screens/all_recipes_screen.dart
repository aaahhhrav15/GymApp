import 'package:flutter/material.dart';
import 'cooking_steps_screen.dart';
import 'recipe_detail_screen.dart';
import '../l10n/app_localizations.dart';

class AllRecipesScreen extends StatefulWidget {
  const AllRecipesScreen({super.key});

  @override
  State<AllRecipesScreen> createState() => _AllRecipesScreenState();
}

class _AllRecipesScreenState extends State<AllRecipesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Categories for filtering
  final List<String> _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Beverages',
  ];

  // Expanded list of Indian healthy recipes with images
  final List<Map<String, dynamic>> _allRecipes = [
    {
      'title': 'Oats Idli',
      'subtitle': 'Healthy South Indian Breakfast',
      'calories': '150 cal',
      'time': '20 min',
      'difficulty': 'Easy',
      'category': 'Breakfast',
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
      'description':
          'Nutritious steamed breakfast with fiber-rich oats and vegetables',
      'rating': 4.5,
      'servings': 4,
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
      'category': 'Lunch',
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
      'description':
          'Complete protein meal with aromatic Indian spices and colorful vegetables',
      'rating': 4.7,
      'servings': 3,
      'cookingSteps': [
        'Rinse quinoa under cold water until water runs clear. Drain and set aside.',
        'Heat ghee in a heavy-bottomed pot over medium heat.',
        'Add bay leaf, cardamom, cinnamon, and cumin seeds. Sauté until fragrant.',
        'Add mixed vegetables and cook for 3-4 minutes until slightly tender.',
        'Add drained quinoa and gently stir to coat with ghee and spices.',
        'Pour in water, add salt, and bring to a boil.',
        'Reduce heat to low, cover tightly, and simmer for 15 minutes.',
        'Turn off heat and let it rest for 5 minutes without opening the lid.',
        'Fluff gently with a fork, remove whole spices, and serve hot.'
      ],
    },
    {
      'title': 'Moong Dal Chilla',
      'subtitle': 'High Protein Pancake',
      'calories': '120 cal',
      'time': '15 min',
      'difficulty': 'Easy',
      'category': 'Breakfast',
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
      'rating': 4.3,
      'servings': 2,
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
      'category': 'Dinner',
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
      'rating': 4.6,
      'servings': 4,
      'cookingSteps': [
        'Blanch spinach in boiling water for 2 minutes. Drain and put in ice water.',
        'Blend blanched spinach to a smooth puree. Set aside.',
        'Heat oil in a pan, lightly fry paneer cubes until golden. Remove and set aside.',
        'In the same pan, add cumin seeds and let them splutter.',
        'Add chopped onions and sauté until golden brown.',
        'Add ginger-garlic paste and green chilies. Cook for 1 minute.',
        'Add chopped tomatoes and cook until they break down completely.',
        'Add spinach puree and bring to a gentle boil.',
        'Season with salt and garam masala. Simmer for 5 minutes.',
        'Add fried paneer cubes and cream. Mix gently.',
        'Simmer for 2-3 minutes and serve hot with rice or roti.'
      ],
    },
    {
      'title': 'Ragi Roti',
      'subtitle': 'Calcium Rich Millet Bread',
      'calories': '95 cal',
      'time': '12 min',
      'difficulty': 'Easy',
      'category': 'Lunch',
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
      'rating': 4.2,
      'servings': 3,
      'cookingSteps': [
        'In a mixing bowl, combine ragi flour and salt.',
        'Add chopped onions, green chilies, and coriander leaves.',
        'Add cumin seeds and mix all dry ingredients well.',
        'Gradually add water while mixing to form a soft, pliable dough.',
        'Knead gently for 2-3 minutes until smooth.',
        'Let the dough rest for 10 minutes.',
        'Divide into small portions and roll each into a thin circle.',
        'Heat a tawa or griddle over medium heat.',
        'Place the roti on the hot tawa and cook for 1-2 minutes.',
        'Flip and cook the other side until light brown spots appear.',
        'Serve hot with pickle, yogurt, or curry.'
      ],
    },
    {
      'title': 'Sambar Rice Bowl',
      'subtitle': 'Complete Protein Combination',
      'calories': '250 cal',
      'time': '35 min',
      'difficulty': 'Medium',
      'category': 'Dinner',
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
      'rating': 4.8,
      'servings': 4,
      'cookingSteps': [
        'Wash and cook brown rice with water until tender. Set aside.',
        'Pressure cook toor dal with turmeric and water until soft and mushy.',
        'Heat oil in a large pan, add mustard seeds and curry leaves.',
        'Add mixed vegetables and sauté for 3-4 minutes.',
        'Add sambar powder and cook for 1 minute until fragrant.',
        'Add cooked dal and mix well. Add water if needed for consistency.',
        'Add tamarind paste and salt. Bring to a boil.',
        'Simmer for 10-15 minutes until vegetables are cooked through.',
        'Taste and adjust salt and tamarind as needed.',
        'Serve hot sambar over brown rice.',
        'Garnish with fresh coriander and enjoy.'
      ],
    },
    {
      'title': 'Besan Dhokla',
      'subtitle': 'Steamed Gram Flour Cake',
      'calories': '140 cal',
      'time': '25 min',
      'difficulty': 'Medium',
      'category': 'Snacks',
      'color': Colors.amber,
      'imageUrl':
          'https://images.unsplash.com/photo-1601050690597-df0568f70950?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'ingredients': [
        '1 cup Besan (Gram flour)',
        '1/2 cup Yogurt',
        '1 tsp Ginger paste',
        '2 Green chilies (chopped)',
        '1 tsp Eno salt',
        '1/2 tsp Turmeric',
        '1 tsp Sugar',
        'Salt to taste',
        'Water as needed',
        'Oil for greasing'
      ],
      'description': 'Light and fluffy steamed snack from Gujarat',
      'rating': 4.4,
      'servings': 6,
      'cookingSteps': [
        'In a bowl, whisk together besan, yogurt, and water to make a smooth batter.',
        'Add ginger paste, green chilies, turmeric, sugar, and salt. Mix well.',
        'Let the batter rest for 10 minutes.',
        'Grease a steaming tray or plate with oil.',
        'Heat water in a steamer or pressure cooker.',
        'Add eno salt to the batter and mix quickly in one direction.',
        'Pour the batter immediately into the greased tray.',
        'Steam for 15-20 minutes until a toothpick comes out clean.',
        'Cool completely before cutting into squares.',
        'For tempering: heat oil, add mustard seeds and curry leaves.',
        'Pour tempering over dhokla and serve with chutney.'
      ],
    },
    {
      'title': 'Masala Buttermilk',
      'subtitle': 'Probiotic Spiced Drink',
      'calories': '80 cal',
      'time': '5 min',
      'difficulty': 'Easy',
      'category': 'Beverages',
      'color': Colors.lightBlue,
      'imageUrl':
          'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'ingredients': [
        '1 cup Fresh yogurt',
        '1/2 tsp Roasted cumin powder',
        '1/2 tsp Ginger paste',
        '1/4 tsp Black salt',
        '1/4 tsp Regular salt',
        '1 cup Chilled water',
        'Fresh mint leaves',
        'Chaat masala (optional)'
      ],
      'description': 'Refreshing probiotic drink with digestive spices',
      'rating': 4.1,
      'servings': 2,
      'cookingSteps': [
        'In a blender, add fresh yogurt and chilled water.',
        'Add ginger paste, roasted cumin powder, and both salts.',
        'Add fresh mint leaves for extra freshness.',
        'Blend everything until smooth and frothy.',
        'Taste and adjust salt and cumin as needed.',
        'Pour into glasses filled with ice cubes.',
        'Sprinkle chaat masala on top if desired.',
        'Garnish with mint leaves and serve immediately.',
        'Stir before drinking as ingredients may settle.',
        'Best enjoyed chilled on hot days.'
      ],
    },
    {
      'title': 'Methi Thepla',
      'subtitle': 'Fenugreek Flatbread',
      'calories': '110 cal',
      'time': '18 min',
      'difficulty': 'Easy',
      'category': 'Breakfast',
      'color': Colors.green,
      'imageUrl':
          'https://images.unsplash.com/photo-1628294895950-9805252327bc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'ingredients': [
        '2 cups Wheat flour',
        '1 cup Fresh fenugreek leaves',
        '1 tsp Ginger-chili paste',
        '1/2 tsp Turmeric',
        '1 tsp Coriander powder',
        '2 tbsp Oil',
        'Salt to taste',
        'Water as needed'
      ],
      'description': 'Nutritious Gujarati flatbread with iron-rich fenugreek',
      'rating': 4.3,
      'servings': 4,
      'cookingSteps': [
        'Clean and finely chop fresh fenugreek leaves.',
        'In a bowl, mix wheat flour, chopped fenugreek, and all spices.',
        'Add ginger-chili paste and oil. Mix well.',
        'Gradually add water to form a soft, pliable dough.',
        'Knead for 3-4 minutes until smooth. Rest for 15 minutes.',
        'Divide into small portions and roll into thin circles.',
        'Heat a tawa or griddle over medium heat.',
        'Cook each thepla for 1-2 minutes on each side.',
        'Apply a little oil on both sides while cooking.',
        'Serve hot with pickle, yogurt, or curry.',
        'Can be stored for 2-3 days and eaten cold.'
      ],
    },
    {
      'title': 'Sprouted Moong Salad',
      'subtitle': 'Raw Protein Power Bowl',
      'calories': '160 cal',
      'time': '10 min',
      'difficulty': 'Easy',
      'category': 'Snacks',
      'color': Colors.lightGreen,
      'imageUrl':
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'ingredients': [
        '1 cup Sprouted Moong Beans',
        '1 medium Cucumber (diced)',
        '2 medium Tomatoes (chopped)',
        '1 medium Onion (finely chopped)',
        '2 Green chilies (minced)',
        '1/4 cup Fresh coriander',
        '2 tbsp Lemon juice',
        '1 tsp Chat masala',
        '1/2 tsp Black salt',
        'Regular salt to taste',
        '1 tsp Olive oil',
        '1/2 tsp Cumin powder'
      ],
      'description':
          'Fresh and crunchy salad packed with plant protein and vitamins',
      'rating': 4.5,
      'servings': 2,
      'cookingSteps': [
        'Rinse sprouted moong beans in cold water and drain well.',
        'In a large mixing bowl, add the sprouted moong beans.',
        'Add diced cucumber, chopped tomatoes, and finely chopped onions.',
        'Add minced green chilies and fresh coriander leaves.',
        'In a small bowl, whisk together lemon juice, olive oil, chat masala, black salt, regular salt, and cumin powder.',
        'Pour the dressing over the sprouted moong mixture.',
        'Toss everything well to combine and coat evenly.',
        'Let the salad sit for 5 minutes to allow flavors to meld.',
        'Taste and adjust seasoning if needed.',
        'Garnish with extra coriander leaves and serve fresh.',
        'Best consumed immediately for maximum crunch and nutrition.'
      ],
    },
    {
      'title': 'Jowar Upma',
      'subtitle': 'Millet Breakfast Bowl',
      'calories': '180 cal',
      'time': '22 min',
      'difficulty': 'Medium',
      'category': 'Breakfast',
      'color': Colors.orange,
      'imageUrl':
          'https://images.unsplash.com/photo-1585937421612-70a008356fbe?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'ingredients': [
        '1 cup Jowar (Sorghum) flour',
        '1/2 cup Mixed vegetables (carrots, peas, beans)',
        '1 medium Onion (chopped)',
        '2 Green chilies (chopped)',
        '1 tsp Ginger paste',
        '1 tsp Mustard seeds',
        '1 tsp Cumin seeds',
        '8-10 Curry leaves',
        '1/4 cup Roasted peanuts',
        '2 tbsp Oil',
        'Salt to taste',
        '2.5 cups Water'
      ],
      'description': 'Wholesome breakfast made with gluten-free sorghum millet',
      'rating': 4.2,
      'servings': 3,
      'cookingSteps': [
        'Dry roast jowar flour in a heavy-bottomed pan for 3-4 minutes until aromatic. Set aside.',
        'Heat oil in the same pan, add mustard seeds and let them splutter.',
        'Add cumin seeds, curry leaves, and chopped green chilies.',
        'Add chopped onions and sauté until translucent.',
        'Add ginger paste and mixed vegetables. Cook for 3-4 minutes.',
        'Add 2.5 cups of water and bring to a boil. Add salt to taste.',
        'Gradually add the roasted jowar flour while stirring continuously to avoid lumps.',
        'Reduce heat to low and cook for 8-10 minutes, stirring frequently.',
        'Add roasted peanuts and mix well.',
        'Cook until the upma reaches a thick, porridge-like consistency.',
        'Garnish with fresh coriander and serve hot.',
        'Serve with coconut chutney or pickle for enhanced flavor.'
      ],
    },
    {
      'title': 'Green Tea Smoothie',
      'subtitle': 'Antioxidant Rich Drink',
      'calories': '120 cal',
      'time': '8 min',
      'difficulty': 'Easy',
      'category': 'Beverages',
      'color': Colors.green,
      'imageUrl':
          'https://images.unsplash.com/photo-1610970881699-44a5587cabec?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'ingredients': [
        '1 cup Brewed green tea (cooled)',
        '1 cup Fresh spinach leaves',
        '1 ripe Banana',
        '1 tbsp Honey',
        '1/2 cup Greek yogurt',
        '1/4 cup Fresh mint leaves',
        '1 tsp Lemon juice',
        '1/2 cup Ice cubes',
        '1 tbsp Chia seeds (optional)',
        '1/4 cup Coconut water'
      ],
      'description':
          'Healthy smoothie packed with antioxidants and natural sweetness',
      'rating': 4.0,
      'servings': 1,
      'cookingSteps': [
        'Brew 1 cup of green tea and let it cool completely in the refrigerator.',
        'Wash and thoroughly clean fresh spinach leaves.',
        'Peel the ripe banana and cut it into chunks.',
        'Add the cooled green tea to a blender.',
        'Add fresh spinach leaves, banana chunks, and Greek yogurt.',
        'Add honey, fresh mint leaves, and lemon juice for flavor.',
        'Pour in coconut water for added hydration and nutrients.',
        'Add ice cubes for a refreshing, chilled texture.',
        'Blend on high speed for 60-90 seconds until smooth and creamy.',
        'Add chia seeds if using and pulse briefly to mix.',
        'Taste and adjust sweetness with more honey if needed.',
        'Pour into a tall glass and serve immediately for best nutrition and taste.'
      ],
    },
    {
      'title': 'Ragi Malt',
      'subtitle': 'Calcium-Rich Energy Drink',
      'calories': '130 cal',
      'time': '10 min',
      'difficulty': 'Easy',
      'category': 'Beverages',
      'color': Colors.brown.shade700,
      'imageUrl':
          'https://images.unsplash.com/photo-1629116619758-ccaa11a8ad8f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjB8fG1pbGslMjBkcmlua3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '2 tbsp Ragi flour',
        '2 cups Milk (or plant-based milk)',
        '1-2 tbsp Jaggery or honey',
        '1/4 tsp Cardamom powder',
        '5-6 Almonds (chopped)',
        'Pinch of salt'
      ],
      'description':
          'Calcium and iron-rich nutritious drink perfect for post-workout recovery',
      'rating': 4.3,
      'servings': 2,
      'cookingSteps': [
        'Dry roast ragi flour on low heat for 2-3 minutes until aromatic.',
        'Take a small amount of cold milk and mix with the ragi flour to form a paste.',
        'Heat the remaining milk in a saucepan.',
        'Once the milk is warm, add the ragi paste while stirring continuously.',
        'Cook on medium heat for 3-4 minutes, stirring to avoid lumps.',
        'Add jaggery or honey and stir until dissolved.',
        'Add cardamom powder and a pinch of salt.',
        'Mix well and cook for another 2 minutes.',
        'Turn off heat and let it cool slightly.',
        'Serve warm or chilled, garnished with chopped almonds.'
      ],
    },
    {
      'title': 'Chickpea Spinach Curry',
      'subtitle': 'Protein-Rich Vegan Meal',
      'calories': '220 cal',
      'time': '25 min',
      'difficulty': 'Medium',
      'category': 'Dinner',
      'color': Colors.teal.shade600,
      'imageUrl':
          'https://images.unsplash.com/photo-1565557623262-b51c2513a641?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Y2hpY2twZWElMjBjdXJyeXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '1 cup Chickpeas (soaked overnight and boiled)',
        '2 cups Fresh spinach leaves',
        '1 large Onion (finely chopped)',
        '2 Tomatoes (pureed)',
        '3-4 Garlic cloves (minced)',
        '1 inch Ginger (grated)',
        '1 tsp Cumin seeds',
        '1 tsp Coriander powder',
        '1/2 tsp Turmeric powder',
        '1/2 tsp Garam masala',
        '1 tsp Red chili powder (adjust to taste)',
        '2 tbsp Oil',
        'Salt to taste',
        'Fresh coriander leaves for garnish'
      ],
      'description':
          'A hearty and nutritious curry combining protein-rich chickpeas and iron-packed spinach',
      'rating': 4.7,
      'servings': 3,
      'cookingSteps': [
        'Heat oil in a pan and add cumin seeds. Let them splutter.',
        'Add minced garlic and grated ginger. Sauté until golden brown.',
        'Add chopped onions and cook until translucent.',
        'Add tomato puree and cook for 3-4 minutes until oil separates.',
        'Add all spices (coriander, turmeric, red chili powder) and salt.',
        'Add boiled chickpeas and mix well with the masala.',
        'Add 1/2 cup water and cook for 5 minutes.',
        'Roughly chop spinach leaves and add to the curry.',
        'Cover and cook for another 5 minutes until spinach wilts.',
        'Add garam masala and mix well.',
        'Garnish with fresh coriander leaves.',
        'Serve hot with brown rice or whole wheat roti.'
      ],
    },
    {
      'title': 'Baked Vegetable Cutlets',
      'subtitle': 'Crunchy Healthy Snack',
      'calories': '120 cal',
      'time': '30 min',
      'difficulty': 'Medium',
      'category': 'Snacks',
      'color': Colors.amber.shade800,
      'imageUrl':
          'https://images.unsplash.com/photo-1612187209234-3ba801e64363?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fHZlZ2V0YWJsZSUyMHBhdHR5fGVufDB8fDB8fHww&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '2 medium Potatoes (boiled and mashed)',
        '1/2 cup Mixed vegetables (finely chopped)',
        '1/4 cup Green peas',
        '1/4 cup Carrots (grated)',
        '1/4 cup Beetroot (grated)',
        '2 tbsp Fresh coriander (chopped)',
        '1 Green chili (finely chopped)',
        '1/2 tsp Ginger paste',
        '1/2 tsp Cumin powder',
        '1/4 tsp Garam masala',
        '1/2 cup Oats (powdered)',
        '2 tbsp Breadcrumbs',
        '1 tbsp Olive oil',
        'Salt to taste'
      ],
      'description':
          'Crispy baked vegetable cutlets made healthier by avoiding deep frying',
      'rating': 4.4,
      'servings': 4,
      'cookingSteps': [
        'Preheat oven to 200°C (400°F) and line a baking tray with parchment paper.',
        'In a bowl, mix mashed potatoes with all chopped and grated vegetables.',
        'Add green chili, ginger paste, cumin powder, garam masala, and salt.',
        'Mix in fresh coriander leaves.',
        'In a separate plate, mix powdered oats and breadcrumbs.',
        'Divide the mixture into equal portions and shape into flat cutlets.',
        'Brush olive oil on both sides of each cutlet.',
        'Coat each cutlet with the oats and breadcrumbs mixture.',
        'Place on the prepared baking tray and bake for 15 minutes.',
        'Flip carefully and bake for another 10 minutes until golden brown.',
        'Serve hot with mint chutney or yogurt dip.'
      ],
    },
    {
      'title': 'Baked Sweet Potato Chaat',
      'subtitle': 'Fiber-Rich Street Food Style Snack',
      'calories': '140 cal',
      'time': '35 min',
      'difficulty': 'Easy',
      'category': 'Snacks',
      'color': Colors.deepOrange,
      'imageUrl':
          'https://images.unsplash.com/photo-1668236541806-42c4346c410f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTZ8fHN3ZWV0JTIwcG90YXRvfGVufDB8fDB8fHww&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '2 medium Sweet potatoes',
        '1/2 cup Yogurt (whisked)',
        '2 tbsp Mint chutney',
        '2 tbsp Tamarind chutney',
        '1/2 tsp Chaat masala',
        '1/2 tsp Cumin powder',
        '1/4 tsp Black salt',
        '1/4 cup Fresh pomegranate seeds',
        '2 tbsp Fresh coriander (chopped)',
        '1/4 cup Sprouted moong beans',
        '1 tbsp Lemon juice'
      ],
      'description':
          'A healthy twist to traditional chaat made with nutrient-rich sweet potatoes',
      'rating': 4.6,
      'servings': 2,
      'cookingSteps': [
        'Preheat oven to 200°C (400°F).',
        'Wash sweet potatoes thoroughly and pat dry.',
        'Prick the sweet potatoes all over with a fork.',
        'Bake for 25-30 minutes until tender when pierced with a knife.',
        'Let them cool slightly, then cut in half lengthwise.',
        'Scoop out some of the flesh to create a well (reserve the scooped flesh).',
        'Mix the reserved sweet potato flesh with chaat masala and cumin powder.',
        'Fill the sweet potato halves with this mixture.',
        'Top with whisked yogurt, mint chutney, and tamarind chutney.',
        'Sprinkle chaat masala, black salt, and cumin powder.',
        'Garnish with pomegranate seeds, sprouted moong, and fresh coriander.',
        'Drizzle lemon juice and serve immediately.'
      ],
    },
    {
      'title': 'Millet Veggie Bowl',
      'subtitle': 'Ancient Grain Superfood Meal',
      'calories': '280 cal',
      'time': '40 min',
      'difficulty': 'Medium',
      'category': 'Lunch',
      'color': Colors.amber.shade600,
      'imageUrl':
          'https://images.unsplash.com/photo-1546793665-c74683f339c1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8dmVnZ2llJTIwYm93bHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '1 cup Mixed millets (foxtail, little, barnyard)',
        '1 cup Mixed vegetables (carrots, peas, bell peppers)',
        '1/2 cup Broccoli florets',
        '1/2 cup Spinach (chopped)',
        '1/4 cup Tofu (cubed)',
        '1 tbsp Olive oil',
        '1 tsp Cumin seeds',
        '1/2 tsp Turmeric powder',
        '1 tsp Mixed herbs (thyme, oregano)',
        '1/4 cup Pomegranate seeds',
        '2 tbsp Pumpkin seeds',
        'Salt and pepper to taste',
        '1 tbsp Lemon juice'
      ],
      'description':
          'A nutrient-dense bowl combining ancient millets with colorful vegetables and proteins',
      'rating': 4.5,
      'servings': 2,
      'cookingSteps': [
        'Wash millets thoroughly and soak for 15 minutes. Drain well.',
        'In a pot, add 2 cups water and soaked millets with a pinch of salt.',
        'Bring to a boil, then reduce heat and cook covered for 15-20 minutes until tender.',
        'Let the millets rest for 5 minutes, then fluff with a fork.',
        'Heat olive oil in a pan, add cumin seeds and let them splutter.',
        'Add all vegetables (except spinach) and sauté for 5-7 minutes.',
        'Add turmeric powder, salt, and pepper. Mix well.',
        'Add spinach and cook for another 2 minutes until wilted.',
        'Add tofu cubes and mixed herbs. Cook for 3 more minutes.',
        'In a bowl, arrange cooked millets as the base.',
        'Top with the vegetable and tofu mixture.',
        'Sprinkle pomegranate and pumpkin seeds on top.',
        'Drizzle with lemon juice before serving.'
      ],
    },
    {
      'title': 'Beetroot Raita',
      'subtitle': 'Cooling Probiotic Side Dish',
      'calories': '85 cal',
      'time': '15 min',
      'difficulty': 'Easy',
      'category': 'Snacks',
      'color': Colors.pink.shade400,
      'imageUrl':
          'https://images.unsplash.com/photo-1626197711786-91d8872eb175?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fHlvZ3VydCUyMGRpc2h8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '1 cup Yogurt (whisked)',
        '1 medium Beetroot (boiled and grated)',
        '1/2 tsp Cumin powder',
        '1/4 tsp Black salt',
        'Salt to taste',
        '1 tsp Fresh mint leaves (chopped)',
        '1/2 tsp Ginger (grated)',
        '1 Green chili (finely chopped)',
        '1 tbsp Fresh coriander (chopped)'
      ],
      'description':
          'Cooling yogurt dip with nutrient-rich beetroot, perfect as a side dish',
      'rating': 4.2,
      'servings': 2,
      'cookingSteps': [
        'Wash, peel and boil beetroot until tender. Let it cool.',
        'Grate the boiled beetroot finely.',
        'In a bowl, whisk the yogurt until smooth.',
        'Add the grated beetroot to the yogurt.',
        'Add cumin powder, black salt, and regular salt.',
        'Mix in chopped mint leaves, grated ginger, and green chili.',
        'Add fresh coriander and mix everything well.',
        'Chill in the refrigerator for at least 30 minutes.',
        'Garnish with more fresh herbs before serving.',
        'Serve as a side dish with meals or as a dip with whole wheat crackers.'
      ],
    },
    {
      'title': 'Mixed Sprouts Salad',
      'subtitle': 'High-Protein Fresh Salad',
      'calories': '120 cal',
      'time': '10 min',
      'difficulty': 'Easy',
      'category': 'Lunch',
      'color': Colors.lightGreen,
      'imageUrl':
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8c2FsYWR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '2 cups Mixed sprouts (moong, chickpea, moth beans)',
        '1 small Cucumber (chopped)',
        '1 medium Tomato (deseeded and chopped)',
        '1 small Onion (finely chopped)',
        '1/2 Bell pepper (chopped)',
        '1/4 cup Fresh coriander (chopped)',
        '2 tbsp Lemon juice',
        '1 tsp Olive oil',
        '1/2 tsp Cumin powder',
        '1/2 tsp Chaat masala',
        '1/4 tsp Black pepper',
        'Salt to taste',
        '1 tbsp Peanuts (roasted and crushed)'
      ],
      'description':
          'Protein and fiber-rich salad with sprouted legumes and fresh vegetables',
      'rating': 4.7,
      'servings': 2,
      'cookingSteps': [
        'Rinse sprouted beans thoroughly under cold running water.',
        'If desired, steam the sprouts lightly for 2-3 minutes (optional for better digestibility).',
        'In a large bowl, combine sprouts with chopped cucumber, tomato, onion, and bell pepper.',
        'Add fresh coriander leaves.',
        'In a small bowl, whisk together lemon juice, olive oil, cumin powder, chaat masala, black pepper, and salt.',
        'Pour the dressing over the salad and toss well to combine.',
        'Sprinkle roasted crushed peanuts on top for added crunch.',
        'Let the salad sit for 5 minutes for flavors to meld.',
        'Serve chilled as a refreshing snack or light meal.',
        'Best consumed fresh for maximum nutritional benefits.'
      ],
    },
    {
      'title': 'Multigrain Pancakes',
      'subtitle': 'Wholesome Sweet Breakfast',
      'calories': '180 cal',
      'time': '20 min',
      'difficulty': 'Medium',
      'category': 'Breakfast',
      'color': Colors.brown.shade400,
      'imageUrl':
          'https://images.unsplash.com/photo-1606131731446-5568d87113aa?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cGFuY2FrZXN8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '1/2 cup Whole wheat flour',
        '1/4 cup Ragi flour',
        '1/4 cup Oats (powdered)',
        '1 Ripe banana (mashed)',
        '1 cup Milk (or plant-based alternative)',
        '1 tbsp Flaxseeds (ground)',
        '1/2 tsp Cinnamon powder',
        '1/4 tsp Cardamom powder',
        '1 tsp Baking powder',
        '1 tbsp Jaggery powder or honey',
        '1 tsp Ghee or coconut oil',
        'Fresh fruits for topping',
        '1 tbsp Greek yogurt (optional)'
      ],
      'description':
          'Nutritious multigrain pancakes naturally sweetened with banana and jaggery',
      'rating': 4.5,
      'servings': 2,
      'cookingSteps': [
        'In a large bowl, mix whole wheat flour, ragi flour, powdered oats, and ground flaxseeds.',
        'Add baking powder, cinnamon powder, and cardamom powder. Mix well.',
        'In another bowl, mash the ripe banana thoroughly.',
        'Add milk and jaggery powder or honey to the mashed banana and whisk well.',
        'Gradually add the wet ingredients to the dry ingredients, whisking to avoid lumps.',
        'Let the batter rest for 10 minutes to allow flaxseeds to bind the mixture.',
        'Heat a non-stick pan on medium heat and lightly grease with ghee or coconut oil.',
        'Pour a ladle of batter and spread gently into a circle.',
        'Cook for 2-3 minutes until bubbles form on the surface.',
        'Flip and cook the other side for 1-2 minutes until golden brown.',
        'Serve warm topped with fresh fruits and a dollop of Greek yogurt if desired.'
      ],
    },
    {
      'title': 'Paneer Tikka Salad',
      'subtitle': 'Grilled Protein Bowl',
      'calories': '210 cal',
      'time': '25 min',
      'difficulty': 'Medium',
      'category': 'Lunch',
      'color': Colors.red.shade400,
      'imageUrl':
          'https://images.unsplash.com/photo-1600699899970-b1c9fadd4f0d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzJ8fHNhbGFkfGVufDB8fDB8fHww&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '200g Paneer (cubed)',
        '1/2 cup Bell peppers (assorted colors, cubed)',
        '1/2 cup Onion (cubed)',
        '1 cup Mixed greens (lettuce, arugula, spinach)',
        '1/2 cup Cherry tomatoes (halved)',
        '1/4 cup Cucumber (sliced)',
        '2 tbsp Coriander leaves (chopped)',
        'For marinade:',
        '2 tbsp Hung curd',
        '1 tsp Ginger-garlic paste',
        '1/2 tsp Red chili powder',
        '1/2 tsp Turmeric powder',
        '1/2 tsp Garam masala',
        '1 tsp Lemon juice',
        '1 tsp Olive oil',
        'Salt to taste'
      ],
      'description':
          'A delightful combination of grilled marinated paneer with fresh vegetables',
      'rating': 4.8,
      'servings': 2,
      'cookingSteps': [
        'Mix all marinade ingredients in a bowl to create a smooth paste.',
        'Add paneer cubes, bell peppers, and onions to the marinade. Mix gently to coat evenly.',
        'Let it marinate for at least 15 minutes (or longer for better flavor).',
        'Preheat oven to 200°C (400°F) or heat a grill pan on medium heat.',
        'Thread marinated paneer and vegetables onto skewers (if using wooden skewers, soak them in water first).',
        'Grill for 8-10 minutes, turning occasionally, until paneer is golden and vegetables are slightly charred.',
        'In a large bowl, arrange mixed greens as the base.',
        'Top with cherry tomatoes, cucumber slices, and grilled paneer and vegetables.',
        'Drizzle with a light dressing of lemon juice, olive oil, and a pinch of salt if desired.',
        'Garnish with fresh coriander leaves and serve immediately while paneer is still warm.'
      ],
    },
    {
      'title': 'Coconut Water Refresh',
      'subtitle': 'Natural Electrolyte Drink',
      'calories': '70 cal',
      'time': '5 min',
      'difficulty': 'Easy',
      'category': 'Beverages',
      'color': Colors.cyan,
      'imageUrl':
          'https://images.unsplash.com/photo-1587067639204-bc10048ae5f5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGNvY29udXQlMjB3YXRlcnxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '2 cups Fresh coconut water',
        '1 tbsp Lime juice',
        '1 tsp Honey (optional)',
        '4-5 Mint leaves',
        '1/2 tsp Chia seeds (soaked)',
        'Ice cubes as needed',
        '1/4 tsp Himalayan pink salt (optional)'
      ],
      'description':
          'A natural sports drink packed with electrolytes, perfect for post-workout hydration',
      'rating': 4.6,
      'servings': 2,
      'cookingSteps': [
        'Chill fresh coconut water in the refrigerator for at least 30 minutes.',
        'Soak chia seeds in 2 tablespoons of water for 10 minutes until they form a gel.',
        'In a blender, add chilled coconut water, lime juice, and honey (if using).',
        'Add a few mint leaves, reserving some for garnish.',
        'Blend for 10-15 seconds until mint is incorporated.',
        'Add a pinch of pink salt if desired for extra electrolytes.',
        'Pour into serving glasses filled with ice cubes.',
        'Add soaked chia seeds and stir gently.',
        'Garnish with remaining mint leaves and a slice of lime.',
        'Serve immediately for maximum freshness and nutrient benefits.'
      ],
    },
    {
      'title': 'Grilled Fish with Herbs',
      'subtitle': 'Lean Protein Dinner',
      'calories': '190 cal',
      'time': '20 min',
      'difficulty': 'Medium',
      'category': 'Dinner',
      'color': Colors.blueGrey,
      'imageUrl':
          'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Z3JpbGxlZCUyMGZpc2h8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '2 Fish fillets (preferably local freshwater fish)',
        '1 tbsp Olive oil',
        '2 tbsp Fresh lemon juice',
        '2 Garlic cloves (minced)',
        '1 tbsp Fresh herbs (dill, parsley, coriander)',
        '1/2 tsp Black pepper',
        '1/2 tsp Turmeric powder',
        'Salt to taste',
        'Lemon wedges for serving',
        'Side salad of mixed greens'
      ],
      'description':
          'Light and protein-rich fish dish marinated with herbs and lemon',
      'rating': 4.5,
      'servings': 2,
      'cookingSteps': [
        'Wash fish fillets thoroughly and pat dry with paper towels.',
        'In a bowl, mix olive oil, lemon juice, minced garlic, and chopped fresh herbs.',
        'Add turmeric powder, black pepper, and salt to create a marinade.',
        'Place fish fillets in the marinade and coat evenly on both sides.',
        'Let it marinate for 10-15 minutes in the refrigerator.',
        'Preheat a grill pan or regular pan over medium-high heat.',
        'Lightly oil the pan to prevent sticking.',
        'Place fish fillets on the hot pan and cook for 3-4 minutes on each side.',
        'The fish is done when it flakes easily with a fork.',
        'Serve hot with lemon wedges and a side salad of mixed greens.',
        'Optionally drizzle with a little extra virgin olive oil before serving.'
      ],
    },
    {
      'title': 'Avocado Banana Smoothie',
      'subtitle': 'Creamy Superfood Blend',
      'calories': '200 cal',
      'time': '7 min',
      'difficulty': 'Easy',
      'category': 'Beverages',
      'color': Colors.green.shade700,
      'imageUrl':
          'https://images.unsplash.com/photo-1590301157890-4810ed352733?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8YXZvY2FkbyUyMHNtb290aGllfGVufDB8fDB8fHww&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '1 ripe Avocado (peeled and pitted)',
        '1 ripe Banana',
        '1 cup Spinach leaves',
        '1 cup Almond milk (or any plant-based milk)',
        '1 tbsp Chia seeds',
        '1 tbsp Honey or date syrup',
        '1/4 tsp Cinnamon powder',
        'Ice cubes (optional)',
        '1 tbsp Protein powder (optional)'
      ],
      'description':
          'Nutrient-dense smoothie rich in healthy fats, potassium, and fiber',
      'rating': 4.7,
      'servings': 2,
      'cookingSteps': [
        'Cut the avocado in half, remove the pit, and scoop out the flesh.',
        'Peel the banana and break into chunks.',
        'Wash spinach leaves thoroughly and pat dry.',
        'Add avocado, banana, and spinach to a blender.',
        'Pour in almond milk and add chia seeds.',
        'Add honey or date syrup for sweetness.',
        'Sprinkle cinnamon powder for flavor.',
        'Blend on high speed until completely smooth and creamy.',
        'Add ice cubes if you prefer a chilled smoothie and blend again.',
        'If desired, add protein powder for an extra protein boost.',
        'Pour into glasses and serve immediately for maximum nutritional benefit.'
      ],
    },
    {
      'title': 'Stuffed Bell Peppers',
      'subtitle': 'Colorful Quinoa-Filled Dinner',
      'calories': '210 cal',
      'time': '35 min',
      'difficulty': 'Medium',
      'category': 'Dinner',
      'color': Colors.red.shade700,
      'imageUrl':
          'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjJ8fHN0dWZmZWQlMjBwZXBwZXJ8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '4 medium Bell peppers (assorted colors)',
        '1 cup Quinoa (cooked)',
        '1/2 cup Black beans (cooked)',
        '1/2 cup Sweet corn kernels',
        '1 small Onion (finely chopped)',
        '2 Garlic cloves (minced)',
        '1 medium Tomato (diced)',
        '1/4 cup Fresh coriander (chopped)',
        '1/2 tsp Cumin powder',
        '1/2 tsp Paprika',
        '1/4 tsp Black pepper',
        '1 tbsp Olive oil',
        'Salt to taste',
        '1/4 cup Low-fat cheese (grated, optional)'
      ],
      'description':
          'Nutritious bell peppers stuffed with protein-rich quinoa and vegetables',
      'rating': 4.6,
      'servings': 4,
      'cookingSteps': [
        'Preheat oven to 375°F (190°C).',
        'Wash bell peppers, cut off the tops, and remove seeds and membranes.',
        'In a bowl, combine cooked quinoa, black beans, and corn kernels.',
        'Heat olive oil in a pan and sauté onions until translucent.',
        'Add minced garlic and cook for 30 seconds until fragrant.',
        'Add diced tomatoes and cook for 2-3 minutes until softened.',
        'Add the tomato mixture to the quinoa mixture along with spices and salt.',
        'Mix in chopped coriander and adjust seasoning if needed.',
        'Stuff each bell pepper with the quinoa mixture.',
        'Place stuffed peppers in a baking dish with a little water at the bottom.',
        'Cover with foil and bake for 20 minutes.',
        'Remove foil, sprinkle with grated cheese if using, and bake for 10 more minutes.',
        'Serve hot, garnished with additional fresh coriander if desired.'
      ],
    },
    {
      'title': 'Lemon Rice',
      'subtitle': 'Tangy South Indian Classic',
      'calories': '160 cal',
      'time': '15 min',
      'difficulty': 'Easy',
      'category': 'Lunch',
      'color': Colors.amber,
      'imageUrl':
          'https://images.unsplash.com/photo-1596097557993-54e1bbd4e1b0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTd8fHJpY2UlMjBkaXNofGVufDB8fDB8fHww&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '2 cups Cooked brown rice (cooled)',
        '2 tbsp Lemon juice',
        '1 tsp Mustard seeds',
        '1 tsp Urad dal',
        '1 tsp Chana dal',
        '10-12 Curry leaves',
        '2-3 Green chilies (slit)',
        '1/4 tsp Turmeric powder',
        '2 tbsp Peanuts',
        '1 tbsp Grated coconut (optional)',
        '1 tbsp Oil (preferably cold-pressed)',
        'Salt to taste',
        '2 tbsp Fresh coriander (chopped)'
      ],
      'description':
          'Quick and flavorful rice dish with the goodness of turmeric and lemon',
      'rating': 4.4,
      'servings': 3,
      'cookingSteps': [
        'Heat oil in a large pan over medium heat.',
        'Add mustard seeds and let them splutter.',
        'Add urad dal and chana dal, fry until they turn golden brown.',
        'Add peanuts and fry for 1-2 minutes until they start to change color.',
        'Add green chilies and curry leaves (be careful as they may splutter).',
        'Add turmeric powder and stir well.',
        'Add cooked brown rice and mix gently to avoid breaking the grains.',
        'Add salt and mix well until the rice is coated with the spices.',
        'Turn off the heat and add lemon juice. Mix thoroughly.',
        'If using, add grated coconut and mix gently.',
        'Garnish with fresh coriander leaves before serving.',
        'Serve warm or at room temperature, perfect for lunch boxes.'
      ],
    },
    {
      'title': 'Bajra Roti with Jaggery',
      'subtitle': 'Sweet Millet Flatbread',
      'calories': '140 cal',
      'time': '20 min',
      'difficulty': 'Medium',
      'category': 'Breakfast',
      'color': Colors.brown.shade500,
      'imageUrl':
          'https://images.unsplash.com/photo-1619535860434-806d13302402?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NjJ8fGluZGlhbiUyMGJyZWFkfGVufDB8fDB8fHww&auto=format&fit=crop&w=600&q=60',
      'ingredients': [
        '1 cup Bajra flour (pearl millet)',
        '1/4 cup Jaggery (powdered)',
        '1/2 tsp Cardamom powder',
        '1 tbsp Ghee',
        '1/2 cup Hot water',
        '2 tbsp Sesame seeds',
        'Pinch of salt',
        'Ghee for serving (optional)'
      ],
      'description':
          'Traditional Indian sweet flatbread made with nutrient-rich millet flour',
      'rating': 4.3,
      'servings': 4,
      'cookingSteps': [
        'In a mixing bowl, combine bajra flour and a pinch of salt.',
        'Add powdered jaggery and cardamom powder.',
        'Add ghee and mix well to incorporate into the flour.',
        'Gradually add hot water and knead into a soft dough.',
        'Cover the dough and let it rest for 10 minutes.',
        'Divide the dough into equal portions and shape into balls.',
        'Take one ball, flatten it slightly, and roll it between two pieces of plastic sheets or using flour for dusting.',
        'Roll into a circle of medium thickness (not too thin as bajra roti can break easily).',
        'Heat a tawa (griddle) on medium heat.',
        'Transfer the roti carefully to the hot tawa.',
        'Cook for 1-2 minutes until bubbles form, then flip.',
        'Apply ghee on both sides and cook until golden brown spots appear.',
        'Serve hot with additional ghee if desired.'
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getLocalizedCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case 'All':
        return l10n.all;
      case 'Breakfast':
        return l10n.breakfast;
      case 'Lunch':
        return l10n.lunch;
      case 'Dinner':
        return l10n.dinner;
      case 'Snacks':
        return l10n.snacks;
      case 'Beverages':
        return l10n.beverages;
      default:
        return category;
    }
  }

  List<Map<String, dynamic>> get _filteredRecipes {
    List<Map<String, dynamic>> filtered = _allRecipes;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((recipe) => recipe['category'] == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((recipe) {
        final title = recipe['title'].toString().toLowerCase();
        final subtitle = recipe['subtitle'].toString().toLowerCase();
        final ingredients =
            (recipe['ingredients'] as List<String>).join(' ').toLowerCase();
        final query = _searchQuery.toLowerCase();

        return title.contains(query) ||
            subtitle.contains(query) ||
            ingredients.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final appBarHeight = screenHeight * 0.08;
    final searchBarHeight = screenHeight * 0.06;
    final categoryChipHeight = screenHeight * 0.045;
    final padding = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.06;
    final subtitleFontSize = screenWidth * 0.035;
    final bodyFontSize = screenWidth * 0.03;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onSurface,
              size: screenWidth * 0.06,
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.healthyRecipes,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                // Snackbar removed - no longer showing favorites feature coming soon message
              },
              icon: Icon(
                Icons.favorite_border,
                color: Theme.of(context).colorScheme.primary,
                size: screenWidth * 0.06,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: EdgeInsets.all(padding),
            height: searchBarHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText:
                    AppLocalizations.of(context)!.searchRecipesIngredients,
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: subtitleFontSize,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                  size: screenWidth * 0.05,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          size: screenWidth * 0.045,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: searchBarHeight * 0.3,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Category Filter Chips
          Container(
            height: categoryChipHeight,
            margin: EdgeInsets.only(bottom: padding),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: padding),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return Container(
                  margin: EdgeInsets.only(right: screenWidth * 0.02),
                  child: FilterChip(
                    label: Text(
                      _getLocalizedCategory(context, category),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: bodyFontSize,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenWidth * 0.01,
                    ),
                  ),
                );
              },
            ),
          ),

          // Results Counter
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Row(
              children: [
                Text(
                  '${_filteredRecipes.length} recipes found',
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    _showSortOptions(context);
                  },
                  icon: Icon(
                    Icons.sort,
                    color: Theme.of(context).colorScheme.primary,
                    size: screenWidth * 0.05,
                  ),
                ),
              ],
            ),
          ),

          // Recipes Grid
          Expanded(
            child: _filteredRecipes.isEmpty
                ? _buildEmptyState(
                    screenWidth, screenHeight, subtitleFontSize, bodyFontSize)
                : GridView.builder(
                    padding: EdgeInsets.all(padding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 600 ? 3 : 2,
                      crossAxisSpacing: padding,
                      mainAxisSpacing: padding,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _filteredRecipes[index];
                      return _buildRecipeCard(
                        recipe,
                        screenWidth,
                        screenHeight,
                        subtitleFontSize,
                        bodyFontSize,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(
    Map<String, dynamic> recipe,
    double screenWidth,
    double screenHeight,
    double subtitleFontSize,
    double bodyFontSize,
  ) {
    return GestureDetector(
      onTap: () => _showRecipeDetails(context, recipe),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                          colors: [
                            recipe['color'].withOpacity(0.2),
                            recipe['color'].withOpacity(0.4),
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
                          colors: [
                            recipe['color'].withOpacity(0.3),
                            recipe['color'].withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: screenWidth * 0.08,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Dark Overlay for text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating and Difficulty
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenHeight * 0.003,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.02),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: screenWidth * 0.03,
                                ),
                                SizedBox(width: screenWidth * 0.005),
                                Text(
                                  recipe['rating'].toString(),
                                  style: TextStyle(
                                    fontSize: bodyFontSize * 0.8,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenHeight * 0.003,
                            ),
                            decoration: BoxDecoration(
                              color: recipe['color'],
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.02),
                            ),
                            child: Text(
                              recipe['difficulty'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: bodyFontSize * 0.8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Title and subtitle
                      Text(
                        recipe['title'],
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        recipe['subtitle'],
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      // Bottom info
                      Row(
                        children: [
                          _buildSmallInfoChip(
                            Icons.local_fire_department,
                            recipe['calories'],
                            Colors.white.withOpacity(0.9),
                            screenWidth,
                            bodyFontSize,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          _buildSmallInfoChip(
                            Icons.access_time,
                            recipe['time'],
                            Colors.white.withOpacity(0.9),
                            screenWidth,
                            bodyFontSize,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Colors.white.withOpacity(0.8),
                                size: screenWidth * 0.03,
                              ),
                              SizedBox(width: screenWidth * 0.005),
                              Text(
                                '${recipe['servings']}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: bodyFontSize * 0.8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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

  Widget _buildSmallInfoChip(
    IconData icon,
    String text,
    Color color,
    double screenWidth,
    double fontSize,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.015,
        vertical: screenWidth * 0.005,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(screenWidth * 0.015),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: screenWidth * 0.025,
            color: color,
          ),
          SizedBox(width: screenWidth * 0.005),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: fontSize * 0.7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    double screenWidth,
    double screenHeight,
    double subtitleFontSize,
    double bodyFontSize,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: screenWidth * 0.15,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            AppLocalizations.of(context)!.noRecipesFound,
            style: TextStyle(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            AppLocalizations.of(context)!.tryAdjustingFilters,
            style: TextStyle(
              fontSize: bodyFontSize,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _searchQuery = '';
                _searchController.clear();
              });
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, Map<String, dynamic> recipe) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.9,
        maxWidth: screenWidth,
      ),
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
              child: SingleChildScrollView(
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
                    Wrap(
                      spacing: screenWidth * 0.02,
                      runSpacing: screenHeight * 0.01,
                      children: [
                        _buildInfoChip(
                          Icons.local_fire_department,
                          recipe['calories'],
                          recipe['color'],
                          screenWidth,
                          screenWidth * 0.035,
                        ),
                        _buildInfoChip(
                          Icons.access_time,
                          recipe['time'],
                          recipe['color'],
                          screenWidth,
                          screenWidth * 0.035,
                        ),
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
                      'Description',
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
                      'Key Ingredients',
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Action buttons
                    Column(
                      children: [
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.favorite_border,
                                        color: recipe['color'],
                                        size: screenWidth * 0.04),
                                    SizedBox(width: screenWidth * 0.01),
                                    Flexible(
                                      child: Text(
                                        'Save',
                                        style: TextStyle(
                                          color: recipe['color'],
                                          fontSize: screenWidth * 0.028,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.015),
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: recipe['color'],
                                        size: screenWidth * 0.04),
                                    SizedBox(width: screenWidth * 0.01),
                                    Flexible(
                                      child: Text(
                                        'Details',
                                        style: TextStyle(
                                          color: recipe['color'],
                                          fontSize: screenWidth * 0.028,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to cooking steps screen if cookingSteps exist
                              if (recipe['cookingSteps'] != null) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CookingStepsScreen(recipe: recipe),
                                  ),
                                );
                              } else {
                                Navigator.pop(context);
                                // Snackbar removed - no longer showing cooking steps coming soon messages
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: recipe['color'],
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.018),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_arrow,
                                    color: Colors.white),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  'Start Cooking',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Add bottom padding for safe area
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom +
                            screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color,
      double screenWidth, double fontSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: screenWidth * 0.035, color: color),
          SizedBox(width: screenWidth * 0.01),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(screenWidth * 0.06),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
              width: screenWidth * 0.1,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Row(
                children: [
                  Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Sort options
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              children: [
                _buildSortOption('Rating (High to Low)', Icons.star),
                _buildSortOption(
                    'Cooking Time (Low to High)', Icons.access_time),
                _buildSortOption(
                    'Calories (Low to High)', Icons.local_fire_department),
                _buildSortOption('Alphabetical (A-Z)', Icons.sort_by_alpha),
              ],
            ),

            SizedBox(height: screenWidth * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.035,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        // Snackbar removed - no longer showing sort confirmation messages
      },
    );
  }
}
