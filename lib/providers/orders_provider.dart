import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../providers/cart_provider.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class OrdersProvider with ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken;
  String userId;

  getData(String userAuthToken, String uId, List<OrderItem> orders) {
    authToken = userAuthToken;
    userId = uId;
    _orders = orders;

    notifyListeners();
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = realtimeUrl + "orders/$userId.json?auth=$authToken";

    try {
      final orderRes = await http.get(url);
      final extractedOrderData =
          json.decode(orderRes.body) as Map<String, dynamic>;
      if (extractedOrderData == null) {
        return;
      }

      final List<OrderItem> loadedOrders = [];
      extractedOrderData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (cartItem) => CartItem(
                    id: cartItem['id'],
                    title: cartItem['title'],
                    quantity: cartItem['quantity'],
                    price: cartItem['price'],
                  ),
                )
                .toList(),
          ),
        );
      });

      // we need reverse to set last order in first
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (err) {
      //throw err;
      print(err.toString());
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double totalAmount) async {
    final url = realtimeUrl + "orders/$userId.json?auth=$authToken";

    try {
      // firstly add order to database
      final timestamp = DateTime.now();
      final encodedOrder = json.encode({
        'amount': totalAmount,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map(
              (cartProd) => {
                'id': cartProd.id,
                'title': cartProd.title,
                'price': cartProd.price,
                'quantity': cartProd.quantity,
              },
            )
            .toList(),
      });
      final addDataRes = await http.post(url, body: encodedOrder);

      // secondly add order localy to list
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(addDataRes.body)['name'],
          amount: totalAmount,
          products: cartProducts,
          dateTime: timestamp,
        ),
      );
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }
}
