import 'package:flutter/material.dart';
import 'dart:developer';

import '../services/payment_service.dart';
import '../models/order_model.dart';
import '../debug/payment_test.dart';

class OrdersTestScreen extends StatefulWidget {
  const OrdersTestScreen({super.key});

  @override
  State<OrdersTestScreen> createState() => _OrdersTestScreenState();
}

class _OrdersTestScreenState extends State<OrdersTestScreen> {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasNext = false;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({bool refresh = false, String? status}) async {
    if (refresh) {
      setState(() {
        _orders.clear();
        _currentPage = 1;
        _selectedStatus = status;
      });
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await PaymentService.getUserOrders(
        page: _currentPage,
        limit: 20,
        status: _selectedStatus,
      );

      if (result['success']) {
        final data = result['data'];
        final ordersData = data['orders'] as List? ?? [];
        final newOrders =
            ordersData.map((json) => Order.fromJson(json)).toList();

        setState(() {
          if (refresh) {
            _orders = newOrders;
          } else {
            _orders.addAll(newOrders);
          }
          _hasNext = data['pagination']?['hasNext'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['error'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading orders: $e';
        _isLoading = false;
      });
      log('Error loading orders: $e');
    }
  }

  Future<void> _loadMore() async {
    if (!_hasNext || _isLoading) return;

    _currentPage++;
    await _loadOrders();
  }

  Future<void> _runTests() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Running tests...'),
          ],
        ),
      ),
    );

    await PaymentTestUtility.runAllTests();

    if (mounted) {
      Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(

      //         const SnackBar(content: Text('Tests completed! Check console logs.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _runTests,
            tooltip: 'Run Tests',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadOrders(refresh: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (_) => _loadOrders(refresh: true),
                ),
                FilterChip(
                  label: const Text('Paid'),
                  selected: _selectedStatus == 'paid',
                  onSelected: (_) => _loadOrders(refresh: true, status: 'paid'),
                ),
                FilterChip(
                  label: const Text('Failed'),
                  selected: _selectedStatus == 'failed',
                  onSelected: (_) =>
                      _loadOrders(refresh: true, status: 'failed'),
                ),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _selectedStatus == 'created',
                  onSelected: (_) =>
                      _loadOrders(refresh: true, status: 'created'),
                ),
              ],
            ),
          ),

          // Orders list
          Expanded(
            child: _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_isLoading && _orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadOrders(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No orders found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _orders.length + (_hasNext ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _orders.length) {
          // Load more button
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _loadMore,
                      child: const Text('Load More'),
                    ),
            ),
          );
        }

        final order = _orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(order.status),
              child: Icon(
                _getStatusIcon(order.status),
                color: Colors.white,
              ),
            ),
            title: Text(
              order.meta.gym.name.isEmpty
                  ? 'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}'
                  : order.meta.gym.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${order.statusText}'),
                Text('Items: ${order.totalItems}'),
                Text('Amount: ${order.formattedAmount}'),
                if (order.isCartOrder)
                  const Text('🛒 Cart Order',
                      style: TextStyle(color: Colors.blue)),
              ],
            ),
            trailing: Text(
              '${order.createdAt.day}/${order.createdAt.month}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            onTap: () => _showOrderDetails(order),
          ),
        );
      },
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.paid:
        return Colors.green;
      case OrderStatus.failed:
        return Colors.red;
      case OrderStatus.created:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.paid:
        return Icons.check_circle;
      case OrderStatus.failed:
        return Icons.error;
      case OrderStatus.created:
        return Icons.pending;
    }
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Order ID', order.id),
              _detailRow('Razorpay Order ID', order.razorpayOrderId),
              _detailRow('Status', order.statusText),
              _detailRow('Amount', order.formattedAmount),
              _detailRow('Currency', order.currency),
              _detailRow('Customer', order.customer.name),
              _detailRow('Phone', order.customer.phone),
              _detailRow('Gym', order.meta.gym.name),
              _detailRow('Cart Order', order.isCartOrder ? 'Yes' : 'No'),
              _detailRow('Items Count', order.totalItems.toString()),
              _detailRow('Created', order.createdAt.toString()),
              if (order.razorpayPaymentId != null)
                _detailRow('Payment ID', order.razorpayPaymentId!),
              const SizedBox(height: 16),
              const Text('Products:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.meta.products.map((product) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ${product.name}'),
                        Text(
                            '  Price: ${product.formattedPrice} x ${product.quantity}'),
                        Text('  Total: ${product.formattedTotal}'),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
