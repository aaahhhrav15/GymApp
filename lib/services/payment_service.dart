import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'api_service.dart';

class PaymentService {
  static Razorpay? _razorpay;

  // Initialize Razorpay
  static Razorpay getRazorpayInstance() {
    _razorpay ??= Razorpay();
    return _razorpay!;
  }

  // Dispose Razorpay
  static void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }

  /// Create order for cart checkout (multiple products)
  static Future<Map<String, dynamic>> createCartCheckoutOrders() async {
    try {
      log('Creating cart checkout orders');
      log('API Base URL: ${ApiService.baseUrl}');

      final headers = await ApiService.getHeaders();
      log('Request headers: $headers');

      final requestUrl = '${ApiService.baseUrl}payment-razorpay/cart-checkout';
      log('Request URL: $requestUrl');

      final response = await http.post(
        Uri.parse(requestUrl),
        headers: headers,
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        log('Parsed response: $responseBody');

        return {
          'success': true,
          'data': responseBody,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        log('Error response: $errorBody');

        return {
          'success': false,
          'error': errorBody['error'] ?? 'Failed to create cart orders',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      log('Error creating cart orders: $e');
      return {
        'success': false,
        'error': 'Failed to create cart orders: ${e.toString()}'
      };
    }
  }

  /// Get user's payment history/orders with optional filtering
  static Future<Map<String, dynamic>> getUserOrders({
    int page = 1,
    int limit = 50,
    String? status,
  }) async {
    try {
      log('Fetching user orders - Page: $page, Limit: $limit, Status: $status');

      final headers = await ApiService.getHeaders();

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('${ApiService.baseUrl}payment-razorpay/orders')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      log('Orders response status: ${response.statusCode}');
      log('Orders response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseBody,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['error'] ?? 'Failed to fetch orders',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      log('Error fetching orders: $e');
      return {
        'success': false,
        'error': 'Failed to fetch orders: ${e.toString()}'
      };
    }
  }

  /// Get failed orders specifically
  static Future<Map<String, dynamic>> getFailedOrders({
    int page = 1,
    int limit = 20,
  }) async {
    return getUserOrders(page: page, limit: limit, status: 'failed');
  }

  /// Get successful orders specifically
  static Future<Map<String, dynamic>> getSuccessfulOrders({
    int page = 1,
    int limit = 20,
  }) async {
    return getUserOrders(page: page, limit: limit, status: 'paid');
  }

  /// Get pending orders specifically
  static Future<Map<String, dynamic>> getPendingOrders({
    int page = 1,
    int limit = 20,
  }) async {
    return getUserOrders(page: page, limit: limit, status: 'created');
  }

  static Future<Map<String, dynamic>> createOrderForProduct(
      String productId) async {
    try {
      log('Creating order for product: $productId');
      log('API Base URL: ${ApiService.baseUrl}');

      final headers = await ApiService.getHeaders();
      log('Request headers: $headers');

      final requestUrl =
          '${ApiService.baseUrl}payment-razorpay/order/$productId';
      log('Request URL: $requestUrl');

      final response = await http.post(
        Uri.parse(requestUrl),
        headers: headers,
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        log('Parsed response: $responseBody');

        return {
          'success': true,
          'data': responseBody,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        log('Error response: $errorBody');

        return {
          'success': false,
          'error': errorBody['error'] ?? 'Failed to create order',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      log('Error creating order: $e');
      return {
        'success': false,
        'error': 'Failed to create order: ${e.toString()}'
      };
    }
  }

  /// Verify payment signature
  static Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final headers = await ApiService.getHeaders();
      final body = jsonEncode({
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      });

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}payment-razorpay/verify'),
        headers: headers,
        body: body,
      );

      final result = await ApiService.handleResponse(response);

      if (result['success']) {
        log('Payment verified successfully');
        return result;
      } else {
        log('Payment verification failed: ${result['error']}');
        return result;
      }
    } catch (e) {
      log('Error verifying payment: $e');
      return {
        'success': false,
        'error': 'Failed to verify payment: ${e.toString()}'
      };
    }
  }

  /// Process cart checkout payment (multiple products)
  static Future<Map<String, dynamic>> processCartCheckout({
    required Function(PaymentSuccessResponse) onPaymentSuccess,
    required Function(PaymentFailureResponse) onPaymentFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
  }) async {
    try {
      // Step 1: Create cart checkout orders
      final orderResult = await createCartCheckoutOrders();
      if (!orderResult['success']) {
        return orderResult;
      }

      final checkoutData = orderResult['data'];

      if (checkoutData == null || checkoutData['orders'] == null) {
        return {'success': false, 'error': 'Cart checkout data is invalid'};
      }

      final orders = checkoutData['orders'] as List;
      if (orders.isEmpty) {
        return {'success': false, 'error': 'No orders to process'};
      }

      // For now, process the first order (could be extended to handle multiple gym orders)
      final firstOrder = orders[0];

      log('Cart checkout data received: $checkoutData');

      // Step 2: Setup Razorpay
      final razorpay = getRazorpayInstance();

      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onPaymentFailure);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);

      // Step 3: Open Razorpay checkout for cart
      final options = {
        'key': firstOrder['key_id'] ?? '',
        'amount': firstOrder['amount'] ?? 0,
        'currency': firstOrder['currency'] ?? 'INR',
        'name': 'Gym App',
        'description':
            'Cart Purchase - ${(firstOrder['products'] as List?)?.length ?? 0} items',
        'order_id': firstOrder['razorpay_order_id'] ?? '',
        'prefill': {
          'contact': customerPhone ?? checkoutData['customer']?['phone'] ?? '',
          'email': customerEmail ?? '',
          'name': customerName ?? checkoutData['customer']?['name'] ?? '',
        },
        'theme': {'color': '#2196F3'}
      };

      log('Cart Razorpay options: $options');
      razorpay.open(options);

      return {
        'success': true,
        'message': 'Cart payment process initiated',
        'order_id': firstOrder['razorpay_order_id'] ?? '',
        'total_amount': checkoutData['totalAmount'] ?? 0,
        'products_count': (firstOrder['products'] as List?)?.length ?? 0
      };
    } catch (e) {
      log('Error processing cart checkout: $e');
      return {
        'success': false,
        'error': 'Failed to process cart checkout: ${e.toString()}'
      };
    }
  }

  static Future<Map<String, dynamic>> processPayment({
    required String productId,
    required Function(PaymentSuccessResponse) onPaymentSuccess,
    required Function(PaymentFailureResponse) onPaymentFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
  }) async {
    try {
      // Step 1: Create order
      final orderResult = await createOrderForProduct(productId);
      if (!orderResult['success']) {
        return orderResult;
      }

      final orderData = orderResult['data'];

      // Add null checks and better error handling
      if (orderData == null) {
        return {
          'success': false,
          'error': 'Order data is null - invalid response from server'
        };
      }

      // Log the order data to debug
      log('Order data received: $orderData');

      // Step 2: Setup Razorpay
      final razorpay = getRazorpayInstance();

      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onPaymentFailure);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);

      // Step 3: Open Razorpay checkout with null checks
      final options = {
        'key': orderData['key_id'] ?? '',
        'amount': orderData['amount'] ?? 0,
        'currency': orderData['currency'] ?? 'INR',
        'name': 'Gym App',
        'description': 'Purchase ${orderData['product']?['id'] ?? productId}',
        'order_id': orderData['razorpay_order_id'] ?? '',
        'prefill': {
          'contact': customerPhone ?? orderData['customer']?['phone'] ?? '',
          'email': customerEmail ?? '',
          'name': customerName ?? orderData['customer']?['name'] ?? '',
        },
        'theme': {'color': '#2196F3'}
      };

      log('Razorpay options: $options');
      razorpay.open(options);

      return {
        'success': true,
        'message': 'Payment process initiated',
        'order_id': orderData['razorpay_order_id'] ?? ''
      };
    } catch (e) {
      log('Error processing payment: $e');
      return {
        'success': false,
        'error': 'Failed to process payment: ${e.toString()}'
      };
    }
  }

  /// Handle successful payment
  static Future<Map<String, dynamic>> handlePaymentSuccess({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      // Verify payment
      final verifyResult = await verifyPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      if (verifyResult['success']) {
        log('Payment completed successfully');
        return {
          'success': true,
          'message': 'Payment completed successfully',
          'payment_id': verifyResult['data']['paymentId'],
          'status': verifyResult['data']['status']
        };
      } else {
        log('Payment verification failed');
        return {
          'success': false,
          'error': 'Payment verification failed',
          'details': verifyResult['error']
        };
      }
    } catch (e) {
      log('Error handling payment success: $e');
      return {
        'success': false,
        'error': 'Error processing payment success: ${e.toString()}'
      };
    }
  }

  /// Handle payment failure
  static Map<String, dynamic> handlePaymentFailure({
    required String code,
    required String description,
    String? source,
    String? step,
    String? reason,
    String? orderId,
  }) {
    log('Payment failed: $code - $description');
    return {
      'success': false,
      'error': description,
      'error_code': code,
      'source': source,
      'step': step,
      'reason': reason,
      'order_id': orderId,
    };
  }

  /// Handle external wallet
  static Map<String, dynamic> handleExternalWallet({
    required String walletName,
  }) {
    log('External wallet selected: $walletName');
    return {
      'success': true,
      'message': 'Redirected to $walletName',
      'wallet_name': walletName,
    };
  }

  /// Get payment error message based on error code
  static String getPaymentErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'PAYMENT_CANCELLED':
        return 'Payment was cancelled by user';
      case 'TXN_FAILURE':
        return 'Transaction failed. Please try again.';
      case 'TXN_ERROR':
        return 'Transaction error occurred';
      case 'NETWORK_ERROR':
        return 'Network error. Please check your connection.';
      case 'INVALID_VPA':
        return 'Invalid UPI ID entered';
      case 'INSUFFICIENT_FUNDS':
        return 'Insufficient funds in your account';
      case 'BANK_ERROR':
        return 'Bank server error. Please try again.';
      default:
        return 'Payment failed. Please try again.';
    }
  }

  /// Check if payment method is available
  static Future<bool> isPaymentMethodAvailable() async {
    try {
      // Test if we can create a Razorpay instance
      getRazorpayInstance();
      return true;
    } catch (e) {
      log('Payment method not available: $e');
      return false;
    }
  }
}
