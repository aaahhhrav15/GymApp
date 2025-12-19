import 'package:flutter/material.dart';

class EnhancedPaymentSuccessDialog extends StatelessWidget {
  final String paymentId;
  final String orderId;
  final double amount;
  final int itemCount;
  final bool isCartOrder;
  final List<String> productNames;

  const EnhancedPaymentSuccessDialog({
    super.key,
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.itemCount,
    this.isCartOrder = false,
    this.productNames = const [],
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(screenWidth * 0.06),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Animation
              Container(
                width: screenWidth * 0.25,
                height: screenWidth * 0.25,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: screenWidth * 0.15,
                ),
              ),

              SizedBox(height: screenWidth * 0.05),

              // Success Title
              Text(
                'Payment Successful!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: screenWidth * 0.03),

              // Order Details
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      'Order ID',
                      '#${orderId.length > 12 ? orderId.substring(0, 12) : orderId}...',
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    _buildDetailRow(
                      context,
                      'Payment ID',
                      paymentId,
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    _buildDetailRow(
                      context,
                      'Amount Paid',
                      '₹${amount.toStringAsFixed(2)}',
                      valueColor: Colors.green,
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    _buildDetailRow(
                      context,
                      isCartOrder ? 'Total Items' : 'Product',
                      isCartOrder
                          ? '$itemCount item${itemCount > 1 ? 's' : ''}'
                          : productNames.isNotEmpty
                              ? productNames.first
                              : 'Product',
                    ),
                  ],
                ),
              ),

              // Success Message
              if (isCartOrder) ...[
                SizedBox(height: screenWidth * 0.04),
                Text(
                  '🎉 Your cart items have been purchased successfully!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                SizedBox(height: screenWidth * 0.04),
                Text(
                  '✨ Thank you for your purchase!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],

              SizedBox(height: screenWidth * 0.06),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class EnhancedPaymentFailureDialog extends StatelessWidget {
  final String? orderId;
  final String errorMessage;
  final double amount;
  final int itemCount;
  final bool isCartOrder;
  final VoidCallback? onRetry;

  const EnhancedPaymentFailureDialog({
    super.key,
    this.orderId,
    required this.errorMessage,
    required this.amount,
    required this.itemCount,
    this.isCartOrder = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(screenWidth * 0.06),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Animation
              Container(
                width: screenWidth * 0.25,
                height: screenWidth * 0.25,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error,
                  color: Colors.red,
                  size: screenWidth * 0.15,
                ),
              ),

              SizedBox(height: screenWidth * 0.05),

              // Error Title
              Text(
                'Payment Failed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: screenWidth * 0.03),

              // Error Details
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                child: Column(
                  children: [
                    if (orderId != null) ...[
                      _buildDetailRow(
                        context,
                        'Order ID',
                        '#${orderId!.length > 12 ? orderId!.substring(0, 12) : orderId}...',
                      ),
                      SizedBox(height: screenWidth * 0.02),
                    ],
                    _buildDetailRow(
                      context,
                      'Amount',
                      '₹${amount.toStringAsFixed(2)}',
                      valueColor: Colors.red,
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    _buildDetailRow(
                      context,
                      isCartOrder ? 'Items' : 'Product',
                      isCartOrder
                          ? '$itemCount item${itemCount > 1 ? 's' : ''}'
                          : 'Single item',
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenWidth * 0.04),

              // Error Message
              Container(
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenWidth * 0.06),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (onRetry != null) ...[
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onRetry!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.03),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                          ),
                        ),
                        child: const Text(
                          'Retry Payment',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.03),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                          ),
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// Helper functions to show the dialogs
void showEnhancedPaymentSuccessDialog({
  required BuildContext context,
  required String paymentId,
  required String orderId,
  required double amount,
  required int itemCount,
  bool isCartOrder = false,
  List<String> productNames = const [],
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => EnhancedPaymentSuccessDialog(
      paymentId: paymentId,
      orderId: orderId,
      amount: amount,
      itemCount: itemCount,
      isCartOrder: isCartOrder,
      productNames: productNames,
    ),
  );
}

void showEnhancedPaymentFailureDialog({
  required BuildContext context,
  String? orderId,
  required String errorMessage,
  required double amount,
  required int itemCount,
  bool isCartOrder = false,
  VoidCallback? onRetry,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => EnhancedPaymentFailureDialog(
      orderId: orderId,
      errorMessage: errorMessage,
      amount: amount,
      itemCount: itemCount,
      isCartOrder: isCartOrder,
      onRetry: onRetry,
    ),
  );
}
