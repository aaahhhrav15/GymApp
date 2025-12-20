import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../l10n/app_localizations.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/payment_provider.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';
import 'checkout_screen.dart';
import 'orders_screen.dart';
import 'package:gym_app_2/services/connectivity_service.dart';
import 'cart_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  final double _minPrice = 0;
  final double _maxPrice = 10000;
  String _sortBy = 'relevance';

  final List<String> productCategories = [
    'Protein',
    'Pre-Workout',
    'Post-Workout',
    'Vitamins',
    'Weight Loss',
    'Muscle Gain',
    'Health',
    'Energy',
  ];

  final Map<String, String> sortOptions = {
    'relevance': 'Best Match',
    'price_low_high': 'Price: Low to High',
    'price_high_low': 'Price: High to Low',
    'rating': 'Highest Rated',
    'newest': 'Newest First',
  };
  @override
  void initState() {
    super.initState();
    // Fetch products when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<CartProvider>().fetchCartItems();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh cart when screen becomes visible again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().refreshCart();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper method to get localized category name
  String _getLocalizedCategory(BuildContext context, String category) {
    final localizations = AppLocalizations.of(context)!;
    switch (category) {
      case 'Protein':
        return localizations.protein;
      case 'Pre-Workout':
        return localizations.preWorkout;
      case 'Post-Workout':
        return localizations.postWorkout;
      case 'Vitamins':
        return localizations.vitamins;
      case 'Weight Loss':
        return localizations.weightLoss;
      case 'Muscle Gain':
        return localizations.muscleGain;
      case 'Health':
        return localizations.health;
      case 'Energy':
        return localizations.energy;
      default:
        return category;
    }
  }

  // Helper method to get localized sort option
  String _getLocalizedSortOption(BuildContext context, String sortKey) {
    final localizations = AppLocalizations.of(context)!;
    switch (sortKey) {
      case 'relevance':
        return localizations.bestMatch;
      case 'price_low_high':
        return localizations.priceLowToHigh;
      case 'price_high_low':
        return localizations.priceHighToLow;
      case 'rating':
        return localizations.highestRated;
      case 'newest':
        return localizations.newestFirst;
      default:
        return sortKey;
    }
  }

  // Helper method to ensure safe size calculations
  double _safeSize(double screenSize, double multiplier, double fallback) {
    if (screenSize.isFinite && screenSize > 0) {
      return screenSize * multiplier;
    }
    return fallback;
  }

  List<Product> _getFilteredAndSortedProducts(List<Product> products) {
    List<Product> filtered = products;

    if (kDebugMode) {
      print('ProductsScreen: Starting with ${products.length} products');
    }

    // Filter by search text
    if (_searchController.text.isNotEmpty) {
      final beforeSearch = filtered.length;
      filtered = filtered.where((product) {
        return product.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            product.overview
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            product.manufacturedBy
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
      }).toList();
      if (kDebugMode) {
        print(
            'ProductsScreen: After search filter: ${beforeSearch} -> ${filtered.length}');
      }
    }

    // Filter by category
    if (_selectedCategory != null) {
      final beforeCategory = filtered.length;
      filtered = filtered.where((product) {
        return product.keyBenefits.any((benefit) => benefit
                .toLowerCase()
                .contains(_selectedCategory!.toLowerCase())) ||
            product.name
                .toLowerCase()
                .contains(_selectedCategory!.toLowerCase());
      }).toList();
      if (kDebugMode) {
        print(
            'ProductsScreen: After category filter: ${beforeCategory} -> ${filtered.length}');
      }
    }

    // Price filter removed - showing all products regardless of price

    // Sort products
    switch (_sortBy) {
      case 'price_low_high':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high_low':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
        // Assuming products have a createdAt field, otherwise use default order
        break;
      case 'rating':
        // Assuming products have a rating field, otherwise use default order
        break;
      default: // relevance
        break;
    }

    if (kDebugMode) {
      print(
          'ProductsScreen: Final filtered products count: ${filtered.length}');
      for (int i = 0; i < filtered.length; i++) {
        print(
            'Filtered product $i: ${filtered[i].name} - Price: ${filtered[i].price}');
      }
    }

    return filtered;
  }

  Widget _buildProductImage(Product product,
      {required double width, required double height}) {
    // Prioritize URL over base64
    if (product.hasImageUrl) {
      return _buildImageFromUrl(product.imageUrl!,
          width: width, height: height);
    } else if (product.hasImageBase64) {
      return _buildImageFromBase64(product.imageBase64!,
          width: width, height: height);
    } else {
      return _buildPlaceholderImage(width: width, height: height);
    }
  }

  Widget _buildImageFromUrl(String imageUrl,
      {required double width, required double height}) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholderImage(width: width, height: height);
      },
    );
  }

  Widget _buildImageFromBase64(String base64String,
      {required double width, required double height}) {
    try {
      // Remove data URL prefix if present
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      final bytes = base64Decode(cleanBase64);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage(width: width, height: height);
        },
      );
    } catch (e) {
      return _buildPlaceholderImage(width: width, height: height);
    }
  }

  Widget _buildPlaceholderImage(
      {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported,
        color: Theme.of(context).colorScheme.onSurface,
        size: width.isFinite && width > 0 ? width * 0.3 : 50.0,
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.06;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Badge
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: screenWidth *
                      0.35, // Increased height for better aspect ratio
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(screenWidth * 0.05),
                    ),
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(screenWidth * 0.05),
                    ),
                    child: _buildProductImage(
                      product,
                      width: double.infinity,
                      height: screenWidth * 0.35,
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenWidth * 0.015),
                  // Product Name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.2,
                          fontSize: screenWidth * 0.04,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: screenWidth * 0.015),

                  // Product Overview
                  Text(
                    product.overview,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          height: 1.3,
                          fontSize: screenWidth * 0.032,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: screenWidth * 0.02),

                  // Key Benefits (show first 1)
                  if (product.keyBenefits.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenWidth * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(screenWidth * 0.01),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        product.keyBenefits.first,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.028,
                            ),
                      ),
                    ),

                  SizedBox(height: screenWidth * 0.015),

                  // Price Section
                  Row(
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: screenWidth * 0.04,
                            ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenWidth * 0.015),

                  // Add to Cart and Buy Now buttons
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      final isInCart = cartProvider.isInCart(product.id);
                      final quantity = cartProvider.getQuantity(product.id);

                      return Row(
                        children: [
                          // Add to Cart / Quantity Controls
                          Expanded(
                            flex: 2,
                            child: isInCart
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                      vertical: screenWidth * 0.015,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await cartProvider
                                                .decrementQuantity(product.id);
                                          },
                                          child: Icon(
                                            Icons.remove,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            size: screenWidth * 0.04,
                                          ),
                                        ),
                                        Text(
                                          quantity.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await cartProvider
                                                .incrementQuantity(product.id);
                                          },
                                          child: Icon(
                                            Icons.add,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            size: screenWidth * 0.04,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: cartProvider.isLoading
                                        ? null
                                        : () async {
                                            final success = await cartProvider
                                                .addToCart(product.id);
                                            if (success && mounted) {
                                              // Snackbar removed - no longer showing success messages
                                            } else if (cartProvider.error !=
                                                    null &&
                                                mounted) {
                                              // Snackbar removed - no longer showing error messages
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      padding: EdgeInsets.symmetric(
                                          vertical: screenWidth * 0.02),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            screenWidth * 0.03),
                                      ),
                                      elevation: 2,
                                      shadowColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.3),
                                    ),
                                    child: cartProvider.isLoading
                                        ? SizedBox(
                                            width: screenWidth * 0.04,
                                            height: screenWidth * 0.04,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.shopping_cart_outlined,
                                                size: screenWidth * 0.04,
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.01),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .addToCart,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.032,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                      letterSpacing: 0.5,
                                                    ),
                                              ),
                                            ],
                                          ),
                                  ),
                          ),

                          SizedBox(width: screenWidth * 0.02),

                          // Buy Now Button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutScreen(
                                      product: product,
                                      quantity: 1,
                                      fromCart: false,
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2.0),
                                padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.02),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.03),
                                ),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.05),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.buyNow,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.032,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    final screenWidth = MediaQuery.of(context).size.width;
    final localizedLabel = label == 'All'
        ? AppLocalizations.of(context)!.all
        : _getLocalizedCategory(context, label);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label == 'All' ? null : label;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: screenWidth * 0.02),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.025,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(screenWidth * 0.08),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            localizedLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: screenWidth * 0.035,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => _showSortOptions(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.025,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(screenWidth * 0.08),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sort,
              color: Theme.of(context).colorScheme.onSurface,
              size: _safeSize(screenWidth, 0.04, 16.0),
            ),
            SizedBox(width: screenWidth * 0.015),
            Text(
              AppLocalizations.of(context)!.sort,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth * 0.035,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.04),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.sortBy,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: screenWidth * 0.04),
              ...sortOptions.entries.map((entry) {
                return ListTile(
                  title: Text(_getLocalizedSortOption(context, entry.key)),
                  leading: Radio<String>(
                    value: entry.key,
                    groupValue: _sortBy,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
              SizedBox(height: screenWidth * 0.02),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: _safeSize(screenWidth, 0.2, 80.0),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            _searchController.text.isNotEmpty
                ? AppLocalizations.of(context)!
                    .noProductsFound(_searchController.text)
                : AppLocalizations.of(context)!.noProductsAvailable,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenWidth * 0.02),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              child: Text(
                AppLocalizations.of(context)!.clearSearch,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isOnline = ConnectivityService().isConnected;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: _safeSize(screenWidth, 0.15, 60.0),
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            AppLocalizations.of(context)!.oopsSomethingWentWrong,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
          if (isOnline) ...[
            SizedBox(height: screenWidth * 0.06),
            ElevatedButton(
              onPressed: () {
                context.read<ProductProvider>().fetchProducts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenWidth * 0.04,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.tryAgain,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.06;
    final topSpacing = screenHeight * 0.025;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (provider.error != null) {
              return _buildErrorState(provider.error!);
            }

            final filteredProducts =
                _getFilteredAndSortedProducts(provider.products);

            return Column(
              children: [
                // Modern Search Header
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      // Top App Bar
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          topSpacing,
                          horizontalPadding,
                          topSpacing * 0.8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.products,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.08,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                            ),
                            // Orders Button
                            Container(
                              margin: EdgeInsets.only(right: screenWidth * 0.02),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.06),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .shadow
                                        .withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const OrdersScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.06),
                                  child: Padding(
                                    padding: EdgeInsets.all(screenWidth * 0.025),
                                    child: Icon(
                                      Icons.receipt_long,
                                      size: screenWidth * 0.05,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Consumer<CartProvider>(
                              builder: (context, cartProvider, child) {
                                return Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius: BorderRadius.circular(
                                            screenWidth * 0.06),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .shadow
                                                .withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const CartScreen(),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(
                                              screenWidth * 0.06),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                screenWidth * 0.025),
                                            child: Icon(
                                              Icons.shopping_cart_outlined,
                                              size: screenWidth * 0.05,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (cartProvider.cartCount > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              screenWidth * 0.008),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: BoxConstraints(
                                            minWidth: screenWidth * 0.04,
                                            minHeight: screenWidth * 0.04,
                                          ),
                                          child: Text(
                                            cartProvider.cartCount > 99
                                                ? '99+'
                                                : cartProvider.cartCount
                                                    .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onError,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: screenWidth * 0.025,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Search Bar
                      Container(
                        margin: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          topSpacing * 0.8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(screenWidth * 0.06),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .shadow
                                  .withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!
                              .searchProductsBrands,
                          hintStyle:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                    fontSize: screenWidth * 0.04,
                                  ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            child: Icon(
                              Icons.search,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.7),
                              size: _safeSize(screenWidth, 0.05, 20.0),
                            ),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  child: GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(screenWidth * 0.015),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(
                                            screenWidth * 0.02),
                                      ),
                                      child: Icon(
                                        Icons.clear,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                        size:
                                            _safeSize(screenWidth, 0.04, 16.0),
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenWidth * 0.04,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: screenWidth * 0.04,
                            ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),

                      // Filter Tags
                      Container(
                        height: screenWidth * 0.13,
                        margin: EdgeInsets.only(bottom: topSpacing * 0.8),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                          children: [
                            _buildFilterChip('All', _selectedCategory == null),
                            ...productCategories.map((category) =>
                                _buildFilterChip(
                                    category, _selectedCategory == category)),
                            Container(
                              margin: EdgeInsets.only(left: screenWidth * 0.03),
                              child: _buildSortButton(),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Container(
                        height: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ],
                  ),
                ),

                // Products List
                Expanded(
                  child: RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: () async {
                      Provider.of<ProductProvider>(context, listen: false)
                          .fetchProducts();
                    },
                    child: filteredProducts.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.only(
                              top: topSpacing * 0.4,
                              bottom: screenHeight * 0.15,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              return _buildProductCard(filteredProducts[index]);
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
