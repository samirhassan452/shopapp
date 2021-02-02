import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/seperated_widgets/order_button.dart';

// in Dart we can show only somethings in file and hide others
import '../providers/cart_provider.dart' show CartProvider hide CartItem;
//import '../providers/orders_provider.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(title: Text("Your Cart")),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Total", style: TextStyle(fontSize: 20)),
                  // give us all space after above widget to make all other widgets in another side
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.headline6.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.cartItems.length,
              itemBuilder: (ctx, index) => CartItemWidget(
                id: cart.cartItems.values.toList()[index].id,
                productId: cart.cartItems.keys.toList()[index],
                price: cart.cartItems.values.toList()[index].price,
                quantity: cart.cartItems.values.toList()[index].quantity,
                title: cart.cartItems.values.toList()[index].title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
