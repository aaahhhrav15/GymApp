import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/cart_model.dart';
import '../services/token_manager.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  int _cartCount = 0;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get cartCount => _cartCount;

  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get totalItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  // Base URL for API calls
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://65.0.5.24/';

  Future<void> fetchCartItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '${baseUrl}add-to-cart';
      if (kDebugMode) {
        print('Base URL: $baseUrl');
        print('Fetching cart from: $url');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Cart fetch response: ${response.statusCode}');
        print('Cart fetch body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          _cartItems =
              data.map((cartJson) => CartItem.fromJson(cartJson)).toList();
          _cartCount = _cartItems.length;
          if (kDebugMode) {
            print('Cart items loaded: ${_cartItems.length}');
          }
        } else if (data is Map && data['message'] != null) {
          // Empty cart case
          _cartItems = [];
          _cartCount = 0;
          if (kDebugMode) {
            print('Empty cart message received');
          }
        }
        _error = null;
      } else if (response.statusCode == 401) {
        _error = 'Authentication failed. Please login again.';
      } else {
        _error = 'Failed to fetch cart items. Status: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('Error fetching cart items: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(String productId) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        _error = 'No authentication token found';
        notifyListeners();
        return false;
      }

      final url = '${baseUrl}add-to-cart/add/$productId';
      if (kDebugMode) {
        print('Base URL: $baseUrl');
        print('Adding to cart: $url');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Add to cart response: ${response.statusCode}');
        print('Add to cart body: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final newCartItem = CartItem.fromJson(data['cartItem']);
        _cartItems.add(newCartItem);
        _cartCount = _cartItems.length;
        _error = null;
        if (kDebugMode) {
          print('Item added to cart successfully. Total items: $_cartCount');
        }
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['error'] ?? 'Failed to add item to cart';
        if (kDebugMode) {
          print('Add to cart failed: $_error');
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('Error adding to cart: $e');
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromCart(String productId) async {
    CartItem? itemToRestore;
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        _error = 'No authentication token found';
        notifyListeners();
        return false;
      }

      // Find the item to remove (for potential restoration if deletion fails)
      try {
        itemToRestore = _cartItems.firstWhere(
          (item) => item.productId == productId,
        );
      } catch (e) {
        // Item not found in local state - might have been already removed
        // Refresh from backend to get accurate state
        await _refreshCartSilently();
        _error = 'Item not found in cart';
        notifyListeners();
        return false;
      }
      
      // Optimistically remove from local state first for immediate UI update
      _cartItems.removeWhere((item) => item.productId == productId);
      _cartCount = _cartItems.length;
      _error = null;
      notifyListeners(); // Update UI immediately

      final response = await http.delete(
        Uri.parse('${baseUrl}add-to-cart/remove/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Backend confirmed deletion - state is already updated
        // Optionally refresh from backend to ensure complete sync
        // But do it silently without showing loading state
        _refreshCartSilently();
        return true;
      } else {
        // Backend deletion failed - restore the item
        if (itemToRestore != null) {
          _cartItems.add(itemToRestore);
          _cartCount = _cartItems.length;
        }
        final data = json.decode(response.body);
        _error = data['error'] ?? 'Failed to remove item from cart';
        if (kDebugMode) {
          print('Failed to remove item from backend, restored to cart');
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      // If item was optimistically removed, restore it
      if (itemToRestore != null) {
        // Check if item is not already in the list (avoid duplicates)
        if (!_cartItems.any((item) => item.productId == productId)) {
          _cartItems.add(itemToRestore);
          _cartCount = _cartItems.length;
        }
      }
      
      // Refresh from backend to get accurate state
      await _refreshCartSilently();
      
      _error = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('Error removing from cart: $e');
      }
      notifyListeners();
      return false;
    }
  }

  // Silent refresh without showing loading state
  Future<void> _refreshCartSilently() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) return;

      final url = '${baseUrl}add-to-cart';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          _cartItems = data.map((cartJson) => CartItem.fromJson(cartJson)).toList();
          _cartCount = _cartItems.length;
        } else if (data is Map && data['message'] != null) {
          _cartItems = [];
          _cartCount = 0;
        }
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in silent cart refresh: $e');
      }
      // Don't set error for silent refresh to avoid disrupting UI
    }
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.productId == productId);
  }

  CartItem? getCartItem(String productId) {
    try {
      return _cartItems.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  int getQuantity(String productId) {
    final item = getCartItem(productId);
    return item?.quantity ?? 0;
  }

  void updateQuantity(String productId, int newQuantity) {
    final itemIndex =
        _cartItems.indexWhere((item) => item.productId == productId);
    if (itemIndex != -1) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(itemIndex);
        _cartCount = _cartItems.length;
      } else {
        _cartItems[itemIndex].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  // Refresh cart state - useful when returning to screens
  Future<void> refreshCart() async {
    await fetchCartItems();
  }

  Future<bool> incrementQuantity(String productId) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        _error = 'No authentication token found';
        notifyListeners();
        return false;
      }

      final url = '${baseUrl}add-to-cart/$productId/increment';
      if (kDebugMode) {
        print('Incrementing quantity: $url');
      }

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Increment response: ${response.statusCode}');
        print('Increment body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedItem = CartItem.fromJson(data['updatedItem']);
        
        // Update the item in local state
        final itemIndex = _cartItems.indexWhere((item) => item.productId == productId);
        if (itemIndex != -1) {
          _cartItems[itemIndex] = updatedItem;
        }
        
        _error = null;
        if (kDebugMode) {
          print('Quantity incremented successfully');
        }
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['error'] ?? 'Failed to increment quantity';
        if (kDebugMode) {
          print('Increment failed: $_error');
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('Error incrementing quantity: $e');
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> decrementQuantity(String productId) async {
    try {
      final item = getCartItem(productId);
      if (item == null) {
        _error = 'Item not found in cart';
        notifyListeners();
        return false;
      }

      // If quantity is 1, remove the item instead of decrementing
      if (item.quantity <= 1) {
        return await removeFromCart(productId);
      }

      final token = await TokenManager.getToken();
      if (token == null) {
        _error = 'No authentication token found';
        notifyListeners();
        return false;
      }

      final url = '${baseUrl}add-to-cart/$productId/decrement';
      if (kDebugMode) {
        print('Decrementing quantity: $url');
      }

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Decrement response: ${response.statusCode}');
        print('Decrement body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedItem = CartItem.fromJson(data['cartItem']);
        
        // Update the item in local state
        final itemIndex = _cartItems.indexWhere((item) => item.productId == productId);
        if (itemIndex != -1) {
          _cartItems[itemIndex] = updatedItem;
        }
        
        _error = null;
        if (kDebugMode) {
          print('Quantity decremented successfully');
        }
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['error'] ?? 'Failed to decrement quantity';
        if (kDebugMode) {
          print('Decrement failed: $_error');
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('Error decrementing quantity: $e');
      }
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _cartCount = 0;
    notifyListeners();
  }

  // Clear cart after successful payment - also clears from backend
  Future<void> clearCartAfterPayment() async {
    try {
      final token = await TokenManager.getToken();
      if (token != null) {
        // Clear all cart items from backend
        for (final item in _cartItems) {
          try {
            await http.delete(
              Uri.parse('${baseUrl}add-to-cart/remove/${item.productId}'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            );
          } catch (e) {
            if (kDebugMode) {
              print('Error removing item ${item.productId} from backend: $e');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cart from backend: $e');
      }
    }

    // Clear local cart state
    clearCart();
    
    if (kDebugMode) {
      print('Cart cleared after successful payment');
    }
  }
}
