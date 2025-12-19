class Order {
  final String id;
  final String razorpayOrderId;
  final String keyId;
  final double amount;
  final String currency;
  final OrderCustomer customer;
  final String gymId;
  final OrderStatus status;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final OrderMeta meta;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.razorpayOrderId,
    required this.keyId,
    required this.amount,
    required this.currency,
    required this.customer,
    required this.gymId,
    required this.status,
    this.razorpayPaymentId,
    this.razorpaySignature,
    required this.meta,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      razorpayOrderId: json['razorpay_order_id'] ?? '',
      keyId: json['key_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble() /
          100, // Convert from paise to rupees
      currency: json['currency'] ?? 'INR',
      customer: OrderCustomer.fromJson(json['customer'] ?? {}),
      gymId: json['gymId'] ?? '',
      status: OrderStatus.fromString(json['status'] ?? 'created'),
      razorpayPaymentId: json['razorpay_payment_id'],
      razorpaySignature: json['razorpay_signature'],
      meta: OrderMeta.fromJson(json['meta'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'razorpay_order_id': razorpayOrderId,
      'key_id': keyId,
      'amount': (amount * 100).round(), // Convert to paise
      'currency': currency,
      'customer': customer.toJson(),
      'gymId': gymId,
      'status': status.toString(),
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'meta': meta.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Getters for convenience
  bool get isPaid => status == OrderStatus.paid;
  bool get isFailed => status == OrderStatus.failed;
  bool get isCreated => status == OrderStatus.created;

  String get statusText {
    switch (status) {
      case OrderStatus.paid:
        return 'Completed';
      case OrderStatus.failed:
        return 'Failed';
      case OrderStatus.created:
        return 'Pending';
    }
  }

  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';

  int get totalItems => meta.products.length;

  bool get isCartOrder => meta.isCartCheckout;
}

class OrderCustomer {
  final String name;
  final String phone;

  OrderCustomer({
    required this.name,
    required this.phone,
  });

  factory OrderCustomer.fromJson(Map<String, dynamic> json) {
    return OrderCustomer(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}

class OrderMeta {
  final List<OrderProduct> products;
  final OrderGym gym;
  final bool isCartCheckout;
  final Map<String, dynamic> rawOrder;

  OrderMeta({
    required this.products,
    required this.gym,
    required this.isCartCheckout,
    required this.rawOrder,
  });

  factory OrderMeta.fromJson(Map<String, dynamic> json) {
    final productsList = json['products'] as List? ?? [];

    return OrderMeta(
      products: productsList.map((p) => OrderProduct.fromJson(p)).toList(),
      gym: OrderGym.fromJson(json['gym'] ?? {}),
      isCartCheckout: json['isCartCheckout'] ?? false,
      rawOrder: json['order'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((p) => p.toJson()).toList(),
      'gym': gym.toJson(),
      'isCartCheckout': isCartCheckout,
      'order': rawOrder,
    };
  }

  double get totalAmount =>
      products.fold(0.0, (sum, product) => sum + product.total);
}

class OrderProduct {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final double total;

  OrderProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'] ?? 1;
    final price = (json['price'] ?? 0).toDouble();

    return OrderProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: price,
      quantity: quantity,
      total: json['total']?.toDouble() ?? (price * quantity),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  String get formattedPrice => '₹${price.toStringAsFixed(0)}';
  String get formattedTotal => '₹${total.toStringAsFixed(0)}';
}

class OrderGym {
  final String id;
  final String name;

  OrderGym({
    required this.id,
    required this.name,
  });

  factory OrderGym.fromJson(Map<String, dynamic> json) {
    return OrderGym(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

enum OrderStatus {
  created,
  paid,
  failed;

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return OrderStatus.paid;
      case 'failed':
        return OrderStatus.failed;
      case 'created':
      default:
        return OrderStatus.created;
    }
  }

  @override
  String toString() {
    switch (this) {
      case OrderStatus.paid:
        return 'paid';
      case OrderStatus.failed:
        return 'failed';
      case OrderStatus.created:
        return 'created';
    }
  }
}
