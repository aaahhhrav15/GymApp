import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/payment_service.dart';
import '../services/api_service.dart';

class PaymentProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _lastPaymentResult;
  String? _currentOrderId;
  String? _lastPaymentId;
  String? _lastOrderId;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get lastPaymentResult => _lastPaymentResult;
  String? get currentOrderId => _currentOrderId;
  String? get lastPaymentId => _lastPaymentId;
  String? get lastOrderId => _lastOrderId;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear payment result
  void clearPaymentResult() {
    _lastPaymentResult = null;
    _currentOrderId = null;
    _lastPaymentId = null;
    _lastOrderId = null;
    notifyListeners();
  }

  /// Process payment for a product
  Future<bool> processPaymentForProduct({
    required String productId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      log('Starting payment process for product: $productId');

      final result = await PaymentService.processPayment(
        productId: productId,
        onPaymentSuccess: _handlePaymentSuccess,
        onPaymentFailure: _handlePaymentFailure,
        onExternalWallet: _handleExternalWallet,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
      );

      log('Payment process result: $result');

      if (result['success']) {
        _currentOrderId = result['order_id'];
        log('Payment initiated successfully for product: $productId');
        return true;
      } else {
        final errorMsg = result['error'] ?? 'Unknown payment error';
        _setError(errorMsg);
        log('Failed to initiate payment: $errorMsg');
        return false;
      }
    } catch (e) {
      final errorMsg = 'Failed to process payment: ${e.toString()}';
      _setError(errorMsg);
      log('Error processing payment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Handle payment success callback
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    log('Payment Success: ${response.paymentId}');

    try {
      _setLoading(true);

      // Store the payment and order IDs
      _lastPaymentId = response.paymentId;
      _lastOrderId = response.orderId;

      final result = await PaymentService.handlePaymentSuccess(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      _lastPaymentResult = {
        'success': result['success'],
        'message': result['message'] ?? 'Payment completed successfully!',
        'payment_id': response.paymentId,
        'order_id': response.orderId,
        'signature': response.signature,
        'type': 'success'
      };

      if (!result['success']) {
        _setError(result['error']);
        // Override the type to 'failure' if verification failed
        _lastPaymentResult!['type'] = 'failure';
      } else {
        // Payment was successful - clear cart from backend
        // Note: This will be handled by individual screens, but we can also do it here
        // for centralized cart management
        log('Payment successful - cart will be cleared by UI screens');
      }
    } catch (e) {
      _setError('Error processing payment success: ${e.toString()}');
      _lastPaymentResult = {
        'success': false,
        'error': e.toString(),
        'type': 'error'
      };
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Handle payment failure callback
  void _handlePaymentFailure(PaymentFailureResponse response) {
    log('Payment Failed: ${response.code} - ${response.message}');

    final result = PaymentService.handlePaymentFailure(
      code: response.code.toString(),
      description: response.message ?? 'Payment failed',
      source: 'razorpay',
      orderId: _currentOrderId,
    );

    _lastPaymentResult = {
      'success': false,
      'error': result['error'],
      'error_code': response.code,
      'error_description': response.message,
      'order_id': _currentOrderId,
      'type': 'failure'
    };

    // Mark payment as failed in backend
    _markPaymentAsFailed(response);

    _setError(PaymentService.getPaymentErrorMessage(response.code.toString()));
    notifyListeners();
  }

  /// Handle external wallet callback
  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External Wallet: ${response.walletName}');

    final result = PaymentService.handleExternalWallet(
      walletName: response.walletName ?? '',
    );

    _lastPaymentResult = {
      'success': true,
      'message': result['message'],
      'wallet_name': response.walletName,
      'type': 'external_wallet'
    };

    // Note: External wallet doesn't automatically mean payment success
    // The actual payment completion will be handled by the wallet app
    // and may trigger success/failure callbacks later
    notifyListeners();
  }

  /// Check if payment is successful
  bool get isPaymentSuccessful {
    return _lastPaymentResult != null &&
        _lastPaymentResult!['success'] == true &&
        _lastPaymentResult!['type'] == 'success';
  }

  /// Check if payment failed
  bool get isPaymentFailed {
    return _lastPaymentResult != null &&
        _lastPaymentResult!['success'] == false;
  }

  /// Get payment success message
  String get paymentSuccessMessage {
    if (isPaymentSuccessful) {
      return _lastPaymentResult!['message'] ??
          'Payment completed successfully!';
    }
    return '';
  }

  /// Get payment failure message
  String get paymentFailureMessage {
    if (isPaymentFailed) {
      return _lastPaymentResult!['error'] ??
          'Payment failed. Please try again.';
    }
    return '';
  }

  /// Process cart checkout payment
  Future<bool> processCartCheckout({
    String? customerName,
    String? customerEmail,
    String? customerPhone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      log('Starting cart checkout process');

      final result = await PaymentService.processCartCheckout(
        onPaymentSuccess: _handlePaymentSuccess,
        onPaymentFailure: _handlePaymentFailure,
        onExternalWallet: _handleExternalWallet,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
      );

      log('Cart checkout result: $result');

      if (result['success']) {
        _currentOrderId = result['order_id'];
        log('Cart checkout initiated successfully');
        return true;
      } else {
        final errorMsg = result['error'] ?? 'Unknown cart checkout error';
        _setError(errorMsg);
        log('Failed to initiate cart checkout: $errorMsg');
        return false;
      }
    } catch (e) {
      final errorMsg = 'Failed to process cart checkout: ${e.toString()}';
      _setError(errorMsg);
      log('Error processing cart checkout: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get user orders/payment history
  Future<Map<String, dynamic>> getUserOrders() async {
    try {
      final result = await PaymentService.getUserOrders();
      return result;
    } catch (e) {
      log('Error fetching user orders: $e');
      return {
        'success': false,
        'error': 'Failed to fetch orders: ${e.toString()}'
      };
    }
  }

  Future<bool> isPaymentMethodAvailable() async {
    return await PaymentService.isPaymentMethodAvailable();
  }

  /// Mark payment as failed in backend database
  Future<void> _markPaymentAsFailed(PaymentFailureResponse response) async {
    if (_currentOrderId == null) return;

    try {
      final result = await http.post(
        Uri.parse('${ApiService.baseUrl}payment-razorpay/mark-failed'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'orderId': _currentOrderId,
          'error_code': response.code,
          'error_description': response.message,
        }),
      );

      if (result.statusCode == 200) {
        log('Successfully marked payment as failed in backend: $_currentOrderId');
      } else {
        log('Failed to mark payment as failed: ${result.statusCode} - ${result.body}');
      }
    } catch (e) {
      log('Error marking payment as failed: $e');
    }
  }

  @override
  void dispose() {
    PaymentService.dispose();
    super.dispose();
  }
}
