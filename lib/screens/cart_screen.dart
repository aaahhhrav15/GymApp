import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/payment_provider.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../widgets/payment_dialogs.dart';
import 'checkout_screen.dart';
import '../l10n/app_localizations.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isProcessingPayment = false;
  PaymentProvider? _paymentProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCartItems();

      // Set up payment provider listener
      _paymentProvider = context.read<PaymentProvider>();
      _paymentProvider!.addListener(_onPaymentResultChanged);
    });
  }

  @override
  void dispose() {
    _paymentProvider?.removeListener(_onPaymentResultChanged);
    super.dispose();
  }

  void _onPaymentResultChanged() async {
    if (!mounted || _paymentProvider == null) return;

    final result = _paymentProvider!.lastPaymentResult;
    if (result == null) return;

    // Handle payment success
    if (result['success'] == true && result['type'] == 'success') {
      final cartProvider = context.read<CartProvider>();
      final cartItems = cartProvider.cartItems;
      final totalAmount = cartProvider.totalPrice;
      final productNames = cartItems.map((item) => item.name).toList();

      showEnhancedPaymentSuccessDialog(
        context: context,
        paymentId: _paymentProvider!.lastPaymentId ?? 'Unknown',
        orderId: _paymentProvider!.lastOrderId ?? 'Unknown',
        amount: totalAmount,
        itemCount: cartItems.length,
        isCartOrder: true,
        productNames: productNames,
      );

      // Clear cart after successful payment (both local and backend)
      await cartProvider.clearCartAfterPayment();

      // Clear the payment result to prevent duplicate dialogs
      _paymentProvider!.clearPaymentResult();
    }
    // Handle payment failure
    else if (result['success'] == false &&
        (result['type'] == 'failure' || result['type'] == 'error')) {
      final cartProvider = context.read<CartProvider>();

      showEnhancedPaymentFailureDialog(
        context: context,
        orderId: _paymentProvider!.lastOrderId,
        errorMessage: _paymentProvider!.paymentFailureMessage.isNotEmpty
            ? _paymentProvider!.paymentFailureMessage
            : AppLocalizations.of(context)!.paymentFailed,
        amount: cartProvider.totalPrice,
        itemCount: cartProvider.cartItems.length,
        isCartOrder: true,
        onRetry: _processCartCheckout,
      );

      // Clear the payment result to prevent duplicate dialogs
      _paymentProvider!.clearPaymentResult();
    }
    // Handle external wallet (informational only, don't show success dialog yet)
    else if (result['success'] == true && result['type'] == 'external_wallet') {
      // Show a message that user was redirected to external wallet
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(AppLocalizations.of(context)!
      //         .redirectedToWallet(result['wallet_name'])),
      //     duration: const Duration(seconds: 2),
      //   ),
      // );

      // Don't clear the result yet - wait for actual payment completion
    }
  }

  Future<void> _processCartCheckout() async {
    if (_isProcessingPayment) return;

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final paymentProvider = context.read<PaymentProvider>();

      // Clear any previous payment results
      paymentProvider.clearPaymentResult();

      final success = await paymentProvider.processCartCheckout();

      if (success) {
        // Payment initiation successful, Razorpay interface will open
        // Don't show success dialog here - wait for actual payment completion
        log('Cart checkout initiated, waiting for payment result...');
      } else {
        // Show failure dialog for initiation failure
        final cartProvider = context.read<CartProvider>();
        if (mounted) {
          showEnhancedPaymentFailureDialog(
            context: context,
            orderId: paymentProvider.currentOrderId,
            errorMessage: paymentProvider.error ??
                AppLocalizations.of(context)!.failedToInitiateCheckout,
            amount: cartProvider.totalPrice,
            itemCount: cartProvider.cartItems.length,
            isCartOrder: true,
            onRetry: _processCartCheckout,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final cartProvider = context.read<CartProvider>();
        showEnhancedPaymentFailureDialog(
          context: context,
          errorMessage:
              AppLocalizations.of(context)!.cartCheckoutError(e.toString()),
          amount: cartProvider.totalPrice,
          itemCount: cartProvider.cartItems.length,
          isCartOrder: true,
          onRetry: _processCartCheckout,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  Widget _buildCartItemCard(CartItem item) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              child: Container(
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: screenWidth * 0.08,
                          );
                        },
                      )
                    : Icon(
                        Icons.image_not_supported,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: screenWidth * 0.08,
                      ),
              ),
            ),

            SizedBox(width: screenWidth * 0.03),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    '₹${item.price.toStringAsFixed(0)} × ${item.quantity}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  SizedBox(height: screenWidth * 0.005),
                  Text(
                    '₹${item.totalPrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Quantity Controls and Actions
            Column(
              children: [
                // Quantity Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final cartProvider = context.read<CartProvider>();
                        await cartProvider.decrementQuantity(item.productId);
                        // Error handling is done in the provider
                        if (mounted && cartProvider.error != null) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text(cartProvider.error!),
                          //     backgroundColor:
                          //         Theme.of(context).colorScheme.error,
                          //     duration: const Duration(seconds: 2),
                          //   ),
                          // );
                        }
                      },
                      child: Container(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.01),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Icon(
                          Icons.remove,
                          size: screenWidth * 0.04,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      item.quantity.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    GestureDetector(
                      onTap: () async {
                        await context
                            .read<CartProvider>()
                            .incrementQuantity(item.productId);
                      },
                      child: Container(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.01),
                        ),
                        child: Icon(
                          Icons.add,
                          size: screenWidth * 0.04,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.02),

                // Action Buttons Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Buy Now Button for individual item
                    Container(
                      height: screenWidth * 0.08,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Get the product details from the ProductProvider
                          final productProvider =
                              context.read<ProductProvider>();

                          // Find the product or create a basic product object
                          Product? product;
                          try {
                            product = productProvider.products.firstWhere(
                              (p) => p.id == item.productId,
                            );
                          } catch (e) {
                            // If product not found in provider, create a basic product from cart item
                            product = Product(
                              id: item.productId,
                              name: item.name,
                              overview: 'Product from cart',
                              price: item.price,
                              keyBenefits: [],
                              fastFacts: 'N/A',
                              usage: 'N/A',
                              storage: 'N/A',
                              sku: 'N/A',
                              shelfLife: 'N/A',
                              manufacturedBy: 'N/A',
                              marketedBy: 'N/A',
                              disclaimer: 'N/A',
                              url: '',
                              imageUrl: item.imageUrl.isNotEmpty
                                  ? item.imageUrl
                                  : null,
                              imageBase64: null,
                              customerId: '',
                              gymId: '',
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(
                                product: product!,
                                quantity: item.quantity,
                                fromCart: true,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.01),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.buy,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.01),

                    // Remove Button
                    Container(
                      height: screenWidth * 0.08,
                      width: screenWidth * 0.08,
                      child: IconButton(
                        onPressed: () async {
                          final cartProvider = context.read<CartProvider>();
                          final itemName = item.name; // Store name before deletion
                          final success = await cartProvider.removeFromCart(item.productId);
                          if (mounted) {
                            if (success) {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(
                              //     content: Text(AppLocalizations.of(context)!
                              //         .removedFromCart(itemName)),
                              //     backgroundColor:
                              //         Theme.of(context).colorScheme.primary,
                              //     duration: const Duration(seconds: 2),
                              //   ),
                              // );
                            } else if (cartProvider.error != null) {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(
                              //     content: Text(cartProvider.error!),
                              //     backgroundColor:
                              //         Theme.of(context).colorScheme.error,
                              //     duration: const Duration(seconds: 3),
                              //   ),
                              // );
                            }
                          }
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: screenWidth * 0.045,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: screenWidth * 0.2,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            AppLocalizations.of(context)!.yourCartIsEmpty,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            AppLocalizations.of(context)!.addProductsToGetStarted,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
          ),
          SizedBox(height: screenWidth * 0.06),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenWidth * 0.03,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.startShopping),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.cartItems.isEmpty) return const SizedBox.shrink();

        return Container(
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
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.total}:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '₹${cartProvider.totalPrice.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.03),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (cartProvider.cartItems.isEmpty || _isProcessingPayment)
                            ? null
                            : () {
                                _processCartCheckout();
                              },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding:
                          EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                    ),
                    child: _isProcessingPayment
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.proceedToCheckout,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.myCart,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          if (cartProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: screenWidth * 0.15,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  Text(
                    AppLocalizations.of(context)!.errorLoadingCart,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    cartProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  ElevatedButton(
                    onPressed: () => cartProvider.fetchCartItems(),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          if (cartProvider.cartItems.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    return _buildCartItemCard(cartProvider.cartItems[index]);
                  },
                ),
              ),
              _buildCheckoutSection(),
            ],
          );
        },
      ),
    );
  }
}
