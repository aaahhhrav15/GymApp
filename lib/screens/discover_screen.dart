// File: screens/discover_screen.dart
import 'package:flutter/material.dart';
import 'package:gym_app_2/screens/awareness_screen.dart';
import '../l10n/app_localizations.dart';
import 'reels_screen.dart';
import '../theme/app_theme.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Custom Tab Bar at the top
          SafeArea(
            child: Container(
              color: Colors.transparent,
              child: TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 3,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.6),
                labelStyle: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.reels),
                  Tab(text: AppLocalizations.of(context)!.awareness),
                ],
              ),
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Reels Tab
                const ReelsScreen(),

                // Products Tab (Empty for now)
                const AwarenessScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(double screenWidth, double screenHeight) {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: screenWidth * 0.12,
                color: Colors.green[300],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'Products Coming Soon',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'We\'re working on bringing you\namazing fitness products',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
// ===== COMMENTED OUT - OLD DISCOVER SCREEN =====

class _DiscoverPageState extends State<DiscoverPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  // Sample product data for search functionality
  final List<Product> _allProducts = [
    // Gym Equipment
    Product(
      'Dumbbells',
      'Gym Equipment',
      'High-quality adjustable dumbbells',
      'assets/images/dumbbells.jpg',
      4.8,
      299.99,
    ),
    Product(
      'Barbell Set',
      'Gym Equipment',
      'Professional weight lifting barbell',
      'assets/images/barbell.jpg',
      4.9,
      199.99,
    ),
    Product(
      'Treadmill',
      'Gym Equipment',
      'Electric treadmill with LCD display',
      'assets/images/treadmill.jpg',
      4.7,
      899.99,
    ),
    Product(
      'Exercise Bike',
      'Gym Equipment',
      'Stationary bike for cardio workout',
      'assets/images/exercise_bike.jpg',
      4.6,
      399.99,
    ),
      'Pull-up Bar',
      'Gym Equipment',
      'Doorway pull-up bar',
      'assets/images/pullup_bar.jpg',
      4.5,
      59.99,
    ),

    // Boxing Equipment
    Product(
      'Boxing Gloves',
      'Boxing Equipment',
      'Professional boxing gloves',
      'assets/images/boxing_gloves.jpg',
      4.8,
      79.99,
    ),
    Product(
      'Punching Bag',
      'Boxing Equipment',
      'Heavy bag for training',
      'assets/images/punching_bag.jpg',
      4.7,
      149.99,
    ),
    Product(
      'Boxing Wraps',
      'Boxing Equipment',
      'Hand wraps for protection',
      'assets/images/boxing_wraps.jpg',
      4.6,
      19.99,
    ),

    // Yoga Equipment
    Product(
      'Yoga Mat',
      'Yoga Equipment',
      'Non-slip premium yoga mat',
      'assets/images/yoga_mat.jpg',
      4.9,
      49.99,
    ),
    Product(
      'Yoga Blocks',
      'Yoga Equipment',
      'Foam yoga blocks for support',
      'assets/images/yoga_blocks.jpg',
      4.7,
      24.99,
    ),
    Product(
      'Yoga Strap',
      'Yoga Equipment',
      'Cotton yoga strap for stretching',
      'assets/images/yoga_strap.jpg',
      4.5,
      14.99,
    ),

    // Fitness Apparel
    Product(
      'Athletic Shorts',
      'Fitness Apparel',
      'Moisture-wicking workout shorts',
      'assets/images/athletic_shorts.jpg',
      4.6,
      39.99,
    ),
    Product(
      'Sports Bra',
      'Fitness Apparel',
      'High-support sports bra',
      'assets/images/sports_bra.jpg',
      4.8,
      34.99,
    ),
    Product(
      'Workout Tank Top',
      'Fitness Apparel',
      'Breathable tank top',
      'assets/images/tank_top.jpg',
      4.5,
      29.99,
    ),
    Product(
      'Compression Leggings',
      'Fitness Apparel',
      'High-performance leggings',
      'assets/images/leggings.jpg',
      4.9,
      59.99,
    ),

    // Supplements
    Product(
      'Whey Protein',
      'Supplements',
      'Premium whey protein powder',
      'assets/images/whey_protein.jpg',
      4.8,
      49.99,
    ),
    Product(
      'Creatine',
      'Supplements',
      'Pure creatine monohydrate',
      'assets/images/creatine.jpg',
      4.7,
      29.99,
    ),
    Product(
      'Pre-Workout',
      'Supplements',
      'Energy boosting pre-workout',
      'assets/images/pre_workout.jpg',
      4.6,
      39.99,
    ),
    Product(
      'BCAA',
      'Supplements',
      'Branched-chain amino acids',
      'assets/images/bcaa.jpg',
      4.5,
      34.99,
    ),

    // Protein
    Product(
      'Protein Bars',
      'Protein',
      'High-protein energy bars',
      'assets/images/protein_bars.jpg',
      4.7,
      24.99,
    ),
    Product(
      'Protein Shake',
      'Protein',
      'Ready-to-drink protein shake',
      'assets/images/protein_shake.jpg',
      4.6,
      3.99,
    ),
    Product(
      'Plant Protein',
      'Protein',
      'Vegan protein powder',
      'assets/images/plant_protein.jpg',
      4.8,
      44.99,
    ),

    // Footwear
    Product(
      'Running Shoes',
      'Footwear',
      'Lightweight running shoes',
      'assets/images/running_shoes.jpg',
      4.9,
      129.99,
    ),
    Product(
      'Cross Training Shoes',
      'Footwear',
      'Versatile training shoes',
      'assets/images/training_shoes.jpg',
      4.7,
      99.99,
    ),
    Product(
      'Weightlifting Shoes',
      'Footwear',
      'Specialized lifting shoes',
      'assets/images/lifting_shoes.jpg',
      4.8,
      149.99,
    ),

    // Gadgets & Accessories
    Product(
      'Fitness Tracker',
      'Gadgets & Accessories',
      'Smart fitness watch',
      'assets/images/fitness_tracker.jpg',
      4.8,
      199.99,
    ),
    Product(
      'Water Bottle',
      'Gadgets & Accessories',
      'Insulated water bottle',
      'assets/images/water_bottle.jpg',
      4.6,
      24.99,
    ),
    Product(
      'Gym Towel',
      'Gadgets & Accessories',
      'Quick-dry gym towel',
      'assets/images/gym_towel.jpg',
      4.5,
      19.99,
    ),
    Product(
      'Resistance Bands',
      'Gadgets & Accessories',
      'Set of resistance bands',
      'assets/images/resistance_bands.jpg',
      4.7,
      29.99,
    ),

    // Healthy Snacks
    Product(
      'Protein Cookies',
      'Healthy Snacks',
      'High-protein cookies',
      'assets/images/protein_cookies.jpg',
      4.6,
      12.99,
    ),
    Product(
      'Energy Balls',
      'Healthy Snacks',
      'Natural energy balls',
      'assets/images/energy_balls.jpg',
      4.7,
      8.99,
    ),
    Product(
      'Nuts Mix',
      'Healthy Snacks',
      'Mixed nuts for snacking',
      'assets/images/nuts_mix.jpg',
      4.8,
      15.99,
    ),
  ];

  // Categories for the grid display
  final List<CategoryItem> _categories = [
    CategoryItem('Gym Equipment', 'assets/images/gym_equipment.jpg'),
    CategoryItem('Boxing Equipment', 'assets/images/boxing_equipment.jpg'),
    CategoryItem('Yoga Equipment', 'assets/images/yoga_equipment.jpg'),
    CategoryItem('Fitness Apparel', 'assets/images/fitness_apparel.jpg'),
    CategoryItem('Supplements', 'assets/images/supplements.jpg'),
    CategoryItem('Protein', 'assets/images/protein.jpg'),
    CategoryItem('Footwear', 'assets/images/footwear.jpg'),
    CategoryItem('Gadgets & Accessories', 'assets/images/gadgets.jpg'),
    CategoryItem('Gyms', 'assets/images/gyms.jpg'),
    CategoryItem('Healthy Snacks', 'assets/images/healthy_snacks.jpg'),
  ];

  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;

      if (_isSearching) {
        _filteredProducts = _allProducts.where((product) {
          return product.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              product.category.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              product.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
      _filteredProducts.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 15.0,
            bottom: 120.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discover Title
              Row(
                children: [
                  const Text(
                    'Discover',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_isSearching)
                    TextButton(
                      onPressed: _clearSearch,
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 15),

              // Search Bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  border: Border.all(
                    color: _isSearching
                        ? Colors.green
                        : Colors.grey.withOpacity(0.1),
                    width: _isSearching ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _isSearching ? Colors.green : Colors.grey[400],
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: _clearSearch,
                              child: Icon(
                                Icons.clear_rounded,
                                color: Colors.grey[600],
                                size: 18,
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                color: Colors.grey[600],
                                size: 18,
                              ),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Search Results or Categories
              if (_isSearching) ...[
                _buildSearchResults(),
              ] else ...[
                _buildProperStaggeredGrid(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredProducts.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Found ${_filteredProducts.length} products',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredProducts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(_filteredProducts[index]);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: Image.asset(
                  product.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[500],
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Add to Cart Button
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_shopping_cart,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProperStaggeredGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double fullWidth = constraints.maxWidth;
        final double halfWidth = (constraints.maxWidth - 12) / 2;

        return Column(
          children: [
            // Row 1: Gym Equipment (Full Width)
            _buildCategoryCard(
              'Gym Equipment',
              'assets/images/gym_equipment.jpg',
              fullWidth,
              180.0,
            ),
            const SizedBox(height: 12),

            // Row 2: Boxing + Yoga (Side by Side)
            Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(
                    'Boxing Equipment',
                    'assets/images/boxing_equipment.jpg',
                    halfWidth,
                    160.0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCategoryCard(
                    'Yoga Equipment',
                    'assets/images/yoga_equipment.jpg',
                    halfWidth,
                    160.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 3: Fitness Apparel (Full Width)
            _buildCategoryCard(
              'Fitness Apparel',
              'assets/images/fitness_apparel.jpg',
              fullWidth,
              160.0,
            ),
            const SizedBox(height: 12),

            // Row 4: Supplements + Protein (Side by Side)
            Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(
                    'Supplements',
                    'assets/images/supplements.jpg',
                    halfWidth,
                    170.0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCategoryCard(
                    'Protein',
                    'assets/images/protein.jpg',
                    halfWidth,
                    170.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 5: Footwear (Full Width)
            _buildCategoryCard(
              'Footwear',
              'assets/images/footwear.jpg',
              fullWidth,
              150.0,
            ),
            const SizedBox(height: 12),

            // Row 6: Gadgets + Gyms (Side by Side)
            Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(
                    'Gadgets & Accessories',
                    'assets/images/gadgets.jpg',
                    halfWidth,
                    160.0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCategoryCard(
                    'Gyms',
                    'assets/images/gyms.jpg',
                    halfWidth,
                    160.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 7: Healthy Snacks (Full Width)
            _buildCategoryCard(
              'Healthy Snacks',
              'assets/images/healthy_snacks.jpg',
              fullWidth,
              140.0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(
    String title,
    String imagePath,
    double width,
    double height,
  ) {
    return GestureDetector(
      onTap: () {
        _showCategoryDetails(title);
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey[400]!, Colors.grey[600]!],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 32,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Add: $imagePath',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Dark overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),

                    // Title
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Shop Now Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shop Now',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.black87,
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
    );
  }

  void _showCategoryDetails(String categoryName) {
    // Filter products by category and navigate to category view
    final categoryProducts = _allProducts
        .where((product) => product.category == categoryName)
        .toList();

    // You can navigate to a detailed category page here
    // For now, show search results for that category
    setState(() {
      _searchController.text = categoryName;
      _searchQuery = categoryName;
      _isSearching = true;
      _filteredProducts = categoryProducts;
    });
  }
}

// Data models
class Product {
  final String name;
  final String category;
  final String description;
  final String imagePath;
  final double rating;
  final double price;

  Product(
    this.name,
    this.category,
    this.description,
    this.imagePath,
    this.rating,
    this.price,
  );
}

class CategoryItem {
  final String name;
  final String imagePath;

  CategoryItem(this.name, this.imagePath);
}

===== END OF COMMENTED OLD DISCOVER SCREEN =====
*/
