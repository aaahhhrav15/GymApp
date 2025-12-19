import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:gym_app_2/services/connectivity_service.dart';
import '../l10n/app_localizations.dart';
import '../models/product_model.dart';
import 'checkout_screen.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Helper method to get localized section titles
  String _getSectionTitle(BuildContext context, String title) {
    final localizations = AppLocalizations.of(context)!;
    switch (title) {
      case 'Overview':
        return localizations.overview;
      case 'Key Benefits':
        return localizations.keyBenefits;
      case 'Fast Facts':
        return localizations.fastFacts;
      case 'Usage':
        return localizations.usage;
      case 'Storage':
        return localizations.storage;
      case 'Disclaimer':
        return localizations.disclaimer;
      case 'Product Details':
        return localizations.productDetails;
      default:
        return title;
    }
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
        size: width * 0.3,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final isOnline = ConnectivityService().isConnected;
    if (!isOnline) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(AppLocalizations.of(context)!.noInternetConnection),
        //     backgroundColor: Theme.of(context).colorScheme.error,
        //   ),
        // );
      }
      return;
    }
    print('Attempting to launch URL: $url');

    try {
      final Uri uri = Uri.parse(url);

      // Show loading indicator
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(AppLocalizations.of(context)!.openingBrowser),
        //     duration: const Duration(seconds: 1),
        //     backgroundColor: Theme.of(context).colorScheme.primary,
        //   ),
        // );
      }

      bool launched = false;

      // Method 1: Try platformDefault mode (recommended for most cases)
      try {
        print('Trying LaunchMode.platformDefault...');
        launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        print('LaunchMode.platformDefault result: $launched');
      } catch (e) {
        print('LaunchMode.platformDefault failed: $e');
        launched = false;
      }

      // Method 2: If platformDefault failed, try externalApplication mode
      if (!launched) {
        try {
          print('Trying LaunchMode.externalApplication...');
          launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          print('LaunchMode.externalApplication result: $launched');
        } catch (e) {
          print('LaunchMode.externalApplication failed: $e');
          launched = false;
        }
      }

      // Method 3: Try with webViewConfiguration for Android compatibility
      if (!launched) {
        try {
          print('Trying LaunchMode.inAppWebView...');
          launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );
          print('LaunchMode.inAppWebView result: $launched');
        } catch (e) {
          print('LaunchMode.inAppWebView failed: $e');
          launched = false;
        }
      }

      // Method 4: Try basic launchUrl without mode specification
      if (!launched) {
        try {
          print('Trying basic launchUrl...');
          launched = await launchUrl(uri);
          print('Basic launchUrl result: $launched');
        } catch (e) {
          print('Basic launchUrl failed: $e');
          launched = false;
        }
      }

      if (launched) {
        print('URL launched successfully!');
      } else {
        throw Exception('All launch methods failed');
      }
    } catch (e) {
      print('Error launching URL: $e');

      // Final fallback: copy URL to clipboard with better user experience
      await Clipboard.setData(ClipboardData(text: url));

      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text(
        //           AppLocalizations.of(context)!.unableToOpenBrowser,
        //           style: const TextStyle(fontWeight: FontWeight.bold),
        //         ),
        //         const SizedBox(height: 4),
        //         Text(AppLocalizations.of(context)!.urlCopiedToClipboard(url)),
        //         const SizedBox(height: 4),
        //         Text(
        //           AppLocalizations.of(context)!.pleasePasteInBrowser,
        //           style: const TextStyle(fontSize: 12),
        //         ),
        //       ],
        //     ),
        //     backgroundColor: Colors.orange,
        //     duration: const Duration(seconds: 6),
        //     action: SnackBarAction(
        //       label: AppLocalizations.of(context)!.retry,
        //       textColor: Colors.white,
        //       onPressed: () async {
        //         // Final retry attempt with different approach
        //         try {
        //           final Uri uri = Uri.parse(url);
        //           // Try with canLaunchUrl check first
        //           if (await canLaunchUrl(uri)) {
        //             await launchUrl(uri);
        //           } else {
        //             // Force launch anyway
        //             await launchUrl(
        //               uri,
        //               mode: LaunchMode.externalApplication,
        //             );
        //           }
        //         } catch (e) {
        //           print('Final retry failed: $e');
        //           if (mounted) {
        //             // ScaffoldMessenger.of(context).showSnackBar(
        //             //   SnackBar(
        //             //     content: Text(AppLocalizations.of(context)!
        //             //         .pleaseOpenUrlManually),
        //             //     backgroundColor: Theme.of(context).colorScheme.error,
        //             //   ),
        //             // );
        //           }
        //         }
        //       },
        //     ),
        //   ),
        // );
      }
    }
  }

  Widget _buildInfoSection(String title, String content, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getSectionTitle(context, title),
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            content,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildKeyBenefitsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.keyBenefits,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          ...widget.product.keyBenefits
              .map((benefit) => Padding(
                    padding: EdgeInsets.only(bottom: screenWidth * 0.015),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: screenWidth * 0.015,
                          height: screenWidth * 0.015,
                          margin: EdgeInsets.only(
                            right: screenWidth * 0.025,
                            top: screenWidth * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            benefit,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildProductDetailsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;

    final details = [
      {'title': localizations.sku, 'value': widget.product.sku},
      {'title': localizations.shelfLife, 'value': widget.product.shelfLife},
      {
        'title': localizations.manufacturedBy,
        'value': widget.product.manufacturedBy
      },
      {'title': localizations.marketedBy, 'value': widget.product.marketedBy},
    ];

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.productDetails,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: screenWidth * 0.03,
              mainAxisSpacing: screenWidth * 0.03,
            ),
            itemCount: details.length,
            itemBuilder: (context, index) {
              final detail = details[index];
              return Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      detail['title']!,
                      style: TextStyle(
                        fontSize: screenWidth * 0.028,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenWidth * 0.008),
                    Flexible(
                      child: Text(
                        detail['value']!,
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
            size: screenWidth * 0.055,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: screenWidth *
              0.2, // Add bottom padding to account for bottom nav bar
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: double.infinity,
              height: screenHeight * 0.4,
              color: Theme.of(context).colorScheme.surface,
              child: _buildProductImage(
                widget.product,
                width: double.infinity,
                height: screenHeight * 0.4,
              ),
            ),

            SizedBox(height: screenWidth * 0.04),

            // Product Info Container
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Text(
                          '₹${widget.product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenWidth * 0.04),

                  // Overview
                  _buildInfoSection('Overview', widget.product.overview, context),

                  // Key Benefits
                  _buildKeyBenefitsSection(context),

                  // Fast Facts
                  _buildInfoSection('Fast Facts', widget.product.fastFacts, context),

                  // Usage
                  _buildInfoSection('Usage', widget.product.usage, context),

                  // Storage
                  _buildInfoSection('Storage', widget.product.storage, context),

                  // Product Details Grid
                  _buildProductDetailsGrid(context),

                  // Disclaimer
                  _buildInfoSection('Disclaimer', widget.product.disclaimer, context),

                  SizedBox(height: screenWidth * 0.02),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color:
                    Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    final cart = context.read<CartProvider>();
                    final success = await cart.addToCart(widget.product.id);
                    if (mounted) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text(
                      //       success
                      //           ? AppLocalizations.of(context)!.addedToCart
                      //           : (cart.error ??
                      //               AppLocalizations.of(context)!
                      //                   .failedToAddToCart),
                      //     ),
                      //     backgroundColor: success
                      //         ? Theme.of(context).colorScheme.primary
                      //         : Theme.of(context).colorScheme.error,
                      //     duration: const Duration(seconds: 2),
                      //   ),
                      // );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_shopping_cart,
                        size: screenWidth * 0.045,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        AppLocalizations.of(context)!.addToCart,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          product: widget.product,
                          quantity: 1,
                          fromCart: false,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        size: screenWidth * 0.045,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        AppLocalizations.of(context)!.buyNow,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
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
}
