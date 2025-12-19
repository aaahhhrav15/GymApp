import 'dart:developer';
import '../services/payment_service.dart';
import '../models/order_model.dart';

class PaymentTestUtility {
  /// Test the backend /orders endpoint
  static Future<void> testOrdersEndpoint() async {
    log('=== Testing Orders Endpoint ===');

    try {
      // Test 1: Get all orders
      log('Test 1: Getting all user orders...');
      final result = await PaymentService.getUserOrders();

      if (result['success']) {
        log('✅ Orders endpoint working!');
        final data = result['data'];
        log('Orders data structure: $data');

        if (data != null && data['orders'] != null) {
          final orders = data['orders'] as List;
          log('Total orders found: ${orders.length}');

          // Test Order model parsing
          if (orders.isNotEmpty) {
            log('Test 2: Parsing orders with Order model...');
            try {
              final parsedOrders =
                  orders.map((orderJson) => Order.fromJson(orderJson)).toList();
              log('✅ Successfully parsed ${parsedOrders.length} orders');

              // Log some order details
              for (int i = 0; i < parsedOrders.take(3).length; i++) {
                final order = parsedOrders[i];
                log('Order ${i + 1}:');
                log('  - ID: ${order.id}');
                log('  - Status: ${order.statusText}');
                log('  - Amount: ${order.formattedAmount}');
                log('  - Items: ${order.totalItems}');
                log('  - Is Cart Order: ${order.isCartOrder}');
                log('  - Gym: ${order.meta.gym.name}');
              }
            } catch (e) {
              log('❌ Error parsing orders: $e');
            }
          } else {
            log('No orders found to test parsing');
          }
        } else {
          log('Orders data structure is missing');
        }

        // Test pagination info
        if (data != null && data['pagination'] != null) {
          final pagination = data['pagination'];
          log('Pagination info:');
          log('  - Current Page: ${pagination['currentPage']}');
          log('  - Total Pages: ${pagination['totalPages']}');
          log('  - Total Count: ${pagination['totalCount']}');
          log('  - Has Next: ${pagination['hasNext']}');
          log('  - Has Previous: ${pagination['hasPrev']}');
        }
      } else {
        log('❌ Orders endpoint failed: ${result['error']}');
      }

      // Test 3: Get failed orders specifically
      log('Test 3: Getting failed orders...');
      final failedResult = await PaymentService.getFailedOrders();
      if (failedResult['success']) {
        log('✅ Failed orders endpoint working!');
        final failedOrders = failedResult['data']?['orders'] as List? ?? [];
        log('Failed orders count: ${failedOrders.length}');
      } else {
        log('❌ Failed orders test failed: ${failedResult['error']}');
      }

      // Test 4: Get successful orders specifically
      log('Test 4: Getting successful orders...');
      final successResult = await PaymentService.getSuccessfulOrders();
      if (successResult['success']) {
        log('✅ Successful orders endpoint working!');
        final successOrders = successResult['data']?['orders'] as List? ?? [];
        log('Successful orders count: ${successOrders.length}');
      } else {
        log('❌ Successful orders test failed: ${successResult['error']}');
      }

      // Test 5: Get pending orders specifically
      log('Test 5: Getting pending orders...');
      final pendingResult = await PaymentService.getPendingOrders();
      if (pendingResult['success']) {
        log('✅ Pending orders endpoint working!');
        final pendingOrders = pendingResult['data']?['orders'] as List? ?? [];
        log('Pending orders count: ${pendingOrders.length}');
      } else {
        log('❌ Pending orders test failed: ${pendingResult['error']}');
      }
    } catch (e) {
      log('❌ Test failed with exception: $e');
    }

    log('=== Orders Endpoint Test Complete ===');
  }

  /// Test payment availability
  static Future<void> testPaymentAvailability() async {
    log('=== Testing Payment Availability ===');

    final isAvailable = await PaymentService.isPaymentMethodAvailable();
    if (isAvailable) {
      log('✅ Payment methods are available');
    } else {
      log('❌ Payment methods are not available');
    }

    log('=== Payment Availability Test Complete ===');
  }

  /// Test error message generation
  static void testErrorMessages() {
    log('=== Testing Error Messages ===');

    final errorCodes = [
      'PAYMENT_CANCELLED',
      'TXN_FAILURE',
      'TXN_ERROR',
      'NETWORK_ERROR',
      'INVALID_VPA',
      'INSUFFICIENT_FUNDS',
      'BANK_ERROR',
      'UNKNOWN_ERROR'
    ];

    for (final code in errorCodes) {
      final message = PaymentService.getPaymentErrorMessage(code);
      log('$code: $message');
    }

    log('=== Error Messages Test Complete ===');
  }

  /// Run all tests
  static Future<void> runAllTests() async {
    log('🔧 Starting Payment System Tests...');

    await testPaymentAvailability();
    testErrorMessages();
    await testOrdersEndpoint();

    log('🎉 All Payment System Tests Complete!');
  }
}
