import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/cart_provider.dart';
import 'package:real_shop/providers/orders_provider.dart';

class OrderButton extends StatefulWidget {
  final CartProvider cart;

  const OrderButton({@required this.cart});
  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading
          ? CircularProgressIndicator()
          : Text("order now".toUpperCase()),
      textColor: Theme.of(context).primaryColor,
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<OrdersProvider>(context, listen: false)
                  .addOrder(
                widget.cart.cartItems.values.toList(),
                widget.cart.totalAmount,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clearAllItemsFromCart();
            },
    );
  }
}
