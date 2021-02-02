import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/auth_provider.dart';
import 'package:real_shop/providers/cart_provider.dart';
import 'package:real_shop/providers/single_product_provider.dart';
import 'package:real_shop/screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<SingleProductProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final authData = Provider.of<AuthProvider>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: SizedBox(
        child: GridTile(
          child: GestureDetector(
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder:
                    AssetImage('assets/images/product-placeholder.png'),
                //NetworkImage to load image from internet
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            onTap: () => Navigator.of(context).pushNamed(
              ProductDetailsScreen.routeName,
              arguments: product.id,
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: Consumer<SingleProductProvider>(
              builder: (ctx, product, child) => IconButton(
                  icon: Icon(
                    product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: Theme.of(context).accentColor,
                  onPressed: () => product.toggleFavoriteStatus(
                      authData.token, authData.userId)),
            ),
            title: Text(product.title, textAlign: TextAlign.center),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              color: Theme.of(context).accentColor,
              onPressed: () {
                cart.addItemToCart(product.id, product.title, product.price);
                // if user click on add to cart on multiple items in same time, we will hide old snackbar to show new one
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("${product.title} Added to cart"),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: "UNDO!",
                    onPressed: () {
                      cart.decreaseItemQuantity(product.id);
                    },
                  ),
                ));
              },
            ),
          ),
        ),
      ),
    );
  }
}
