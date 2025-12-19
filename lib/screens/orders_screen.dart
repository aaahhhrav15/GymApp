import 'package:flutter/material.dart';
import 'dart:developer';

import '../l10n/app_localizations.dart';
import '../services/payment_service.dart';
import '../models/order_model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myOrders),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _loadOrders(refresh: true),
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.refresh,
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
                  label: Text(AppLocalizations.of(context)!.all),
                  selected: _selectedStatus == null,
                  onSelected: (_) => _loadOrders(refresh: true),
                ),
                FilterChip(
                  label: Text(AppLocalizations.of(context)!.paid),
                  selected: _selectedStatus == 'paid',
                  onSelected: (_) => _loadOrders(refresh: true, status: 'paid'),
                ),
                FilterChip(
                  label: Text(AppLocalizations.of(context)!.failed),
                  selected: _selectedStatus == 'failed',
                  onSelected: (_) =>
                      _loadOrders(refresh: true, status: 'failed'),
                ),
                FilterChip(
                  label: Text(AppLocalizations.of(context)!.pending),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.errorLoadingOrders,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadOrders(refresh: true),
              child: Text(AppLocalizations.of(context)!.tryAgain),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noOrdersFound,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.noOrdersYet,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
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
                      child: Text(AppLocalizations.of(context)!.loadMore),
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
                Text(
                    '${AppLocalizations.of(context)!.status}: ${order.statusText}'),
                Text(
                    '${AppLocalizations.of(context)!.items}: ${order.totalItems}'),
                Text(
                    '${AppLocalizations.of(context)!.amount}: ${order.formattedAmount}'),
                if (order.isCartOrder)
                  Text(AppLocalizations.of(context)!.cartOrder,
                      style: const TextStyle(color: Colors.blue)),
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
        return Icons.cancel;
      case OrderStatus.created:
        return Icons.pending;
    }
  }

  void _showOrderDetails(Order order) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.orderDetails),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(localizations.orderId, order.id),
              _buildDetailRow(localizations.status, order.statusText),
              _buildDetailRow(localizations.amount, order.formattedAmount),
              _buildDetailRow(localizations.items, order.totalItems.toString()),
              _buildDetailRow(localizations.gym, order.meta.gym.name),
              _buildDetailRow(localizations.date,
                  '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}'),
              if (order.meta.products.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '${localizations.products}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...order.meta.products.map((product) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Text('• ${product.name} (${product.quantity}x)'),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
