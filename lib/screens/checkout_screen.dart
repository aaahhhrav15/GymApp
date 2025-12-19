import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:developer';
import '../models/product_model.dart';
import '../providers/payment_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../debug/auth_debug.dart';
import '../widgets/payment_dialogs.dart';

class CheckoutScreen extends StatefulWidget {
  final Product product;
  final int quantity;
  final bool fromCart;

  const CheckoutScreen({
    super.key,
    required this.product,
    this.quantity = 1,
    this.fromCart = false,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await ApiService.getUserData();
    setState(() {
      _userData = userData;
    });
  }

  Widget _buildProductImage(Product product, {required double size}) {
    if (product.hasImageUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage(size: size);
          },
        ),
      );
    } else if (product.hasImageBase64) {
      try {
        String cleanBase64 = product.imageBase64!;
        if (product.imageBase64!.contains(',')) {
          cleanBase64 = product.imageBase64!.split(',').last;
        }
        final bytes = base64Decode(cleanBase64);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderImage(size: size);
            },
          ),
        );
      } catch (e) {
        return _buildPlaceholderImage(size: size);
      }
    } else {
      return _buildPlaceholderImage(size: size);
    }
  }

  Widget _buildPlaceholderImage({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_not_supported,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        size: size * 0.4,
      ),
    );
  }

  Widget _buildOrderSummary() {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalPrice = widget.product.price * widget.quantity;

    return Card(
      elevation: 2,
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Row(
              children: [
                _buildProductImage(widget.product, size: screenWidth * 0.15),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenWidth * 0.01),
                      Text(
                        'Quantity: ${widget.quantity}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                      Text(
                        '₹${widget.product.price.toStringAsFixed(0)} each',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${totalPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Divider(height: screenWidth * 0.08),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '₹${totalPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_userData == null) {
      return Card(
        elevation: 2,
        margin: EdgeInsets.all(screenWidth * 0.04),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: screenWidth * 0.04),
              Text('Loading customer information...'),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: screenWidth * 0.05,
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    _userData!['name'] ?? 'Guest User',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            if (_userData!['phone'] != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: screenWidth * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Text(
                      _userData!['phone'],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.02),
            ],
            if (_userData!['email'] != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: screenWidth * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Text(
                      _userData!['email'],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 2,
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.payment,
                      color: Theme.of(context).colorScheme.primary,
                      size: screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Razorpay',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          'Credit Card, Debit Card, UPI, Net Banking, Wallet',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: screenWidth * 0.05,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    // Add debug information
    await AuthDebug.debugTokenStatus();
    await AuthDebug.testConnection();
    await AuthDebug.testHeaders();

    final paymentProvider = context.read<PaymentProvider>();

    final success = await paymentProvider.processPaymentForProduct(
      productId: widget.product.id,
      customerName: _userData?['name'],
      customerEmail: _userData?['email'],
      customerPhone: _userData?['phone'],
    );

    if (!success && mounted) {
      log('Payment failed with error: ${paymentProvider.error}');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(paymentProvider.error ?? 'Failed to initiate payment'),
      //     backgroundColor: Theme.of(context).colorScheme.error,
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          // Handle payment result
          if (paymentProvider.isPaymentSuccessful) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showEnhancedPaymentSuccessDialog();
            });
          } else if (paymentProvider.isPaymentFailed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showEnhancedPaymentFailureDialog(
                  paymentProvider.paymentFailureMessage);
            });
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummary(),
                _buildCustomerInfo(),
                _buildPaymentMethods(),
                SizedBox(height: screenWidth * 0.02),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
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
          child: Consumer<PaymentProvider>(
            builder: (context, paymentProvider, child) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: paymentProvider.isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                  ),
                  child: paymentProvider.isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: screenWidth * 0.05,
                              height: screenWidth * 0.05,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Text(
                              'Processing...',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        )
                      : Text(
                          'Pay ₹${(widget.product.price * widget.quantity).toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showEnhancedPaymentSuccessDialog() async {
    final paymentProvider = context.read<PaymentProvider>();

    showEnhancedPaymentSuccessDialog(
      context: context,
      paymentId: paymentProvider.lastPaymentId ?? 'Unknown',
      orderId: paymentProvider.lastOrderId ?? 'Unknown',
      amount: widget.product.price * widget.quantity,
      itemCount: widget.quantity,
      isCartOrder: widget.fromCart,
      productNames: [widget.product.name],
    );

    // Clear payment result and handle navigation
    paymentProvider.clearPaymentResult();

    // Clear cart after successful payment
    if (widget.fromCart) {
      // If purchased from cart, just remove this specific item
      await context.read<CartProvider>().removeFromCart(widget.product.id);
    } else {
      // If purchased directly (not from cart), clear entire cart
      // This ensures any other items in cart are also cleared after successful payment
      await context.read<CartProvider>().clearCartAfterPayment();
    }
  }

  void _showEnhancedPaymentFailureDialog(String message) {
    final paymentProvider = context.read<PaymentProvider>();

    showEnhancedPaymentFailureDialog(
      context: context,
      orderId: paymentProvider.lastOrderId,
      errorMessage: message,
      amount: widget.product.price * widget.quantity,
      itemCount: widget.quantity,
      isCartOrder: widget.fromCart,
      onRetry: () {
        // Retry payment logic here if needed
        _processPayment();
      },
    );

    paymentProvider.clearPaymentResult();
  }
}
