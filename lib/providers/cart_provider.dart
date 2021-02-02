import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};

  Map<String, CartItem> get cartItems {
    // ... means spread operator
    return {..._cartItems};
  }

  int get itemCount {
    return _cartItems.length;
  }

  double get totalAmount {
    var total = 0.0;
    _cartItems.forEach((key, CartItem cartItem) {
      // cause if we buy product and it's price is 10 and need 5 from this product, so we will multiply 5*10
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItemToCart(String productId, String title, double price) {
    // we need to differentiate between 2 scenarios
    // 1. add item which not exist in cart
    // 2. if item already exist and click on this item again, so we will increase it's quntity
    if (_cartItems.containsKey(productId)) {
      _cartItems.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      // add this item if not exist
      _cartItems.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }

    notifyListeners();
  }

  void removeItemFromCart(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  void decreaseItemQuantity(String productId) {
    if (!_cartItems.containsKey(productId)) {
      return;
    }
    if (_cartItems[productId].quantity > 1) {
      _cartItems.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity - 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      _cartItems.remove(productId);
    }

    notifyListeners();
  }

  void clearAllItemsFromCart() {
    //_cartItems.clear();
    _cartItems = {};
    notifyListeners();
  }
}
