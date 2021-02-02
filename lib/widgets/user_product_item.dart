import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/products_provider.dart';
import 'package:real_shop/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem({this.id, this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);

    return ListTile(
      title: Text(title),
      leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName, arguments: id),
            ),
            IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(context).errorColor,
                onPressed: () async {
                  try {
                    await Provider.of<ProductsProvider>(context, listen: false)
                        .deleteProduct(id);
                    scaffold.showSnackBar(
                      SnackBar(
                          content: Text(
                        "Deleted Succuffuly!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.green.shade600),
                      )),
                    );
                  } catch (err) {
                    scaffold.showSnackBar(
                      SnackBar(
                          content: Text(
                        "Deleting failed!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).errorColor),
                      )),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
