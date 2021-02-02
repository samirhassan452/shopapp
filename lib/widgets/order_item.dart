import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders_provider.dart' as ord;

class OrderItem extends StatelessWidget {
  final ord.OrderItem order;

  const OrderItem({this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text('\$${order.amount}'),
        subtitle:
            Text(DateFormat('EEE, dd/MM/yyyy  hh:mm a').format(order.dateTime)),
        children: order.products
            .map((product) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${product.quantity}x \$${product.price}',
                      style: TextStyle(fontSize: 18.0, color: Colors.grey),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
