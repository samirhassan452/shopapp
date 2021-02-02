import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartItemWidget extends StatelessWidget {
  final String id;
  final String productId;
  final int quantity;
  final double price;
  final String title;

  const CartItemWidget({
    this.id,
    this.productId,
    this.quantity,
    this.price,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Icon(Icons.delete, color: Colors.white, size: 40),
      ),
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Are you sure?"),
            content: Text("Do you want to remove $title item from the cart?"),
            actions: [
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("no".toUpperCase()),
              ),
              FlatButton(
                // we give true to pop() here cause when dismiss item Dismissible already remove item until make pop() only
                // but if we give true, then we tell Dismissible to confirm to delete this item
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("confirm!".toUpperCase()),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<CartProvider>(context, listen: false)
            .removeItemFromCart(productId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: FittedBox(
                  child: Text("\$$price"),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text("Total \$${price * quantity}"),
            trailing: Text("$quantity x"),
          ),
        ),
      ),
    );
  }
}
