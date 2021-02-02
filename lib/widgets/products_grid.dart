import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/products_provider.dart';
import 'package:real_shop/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavorites;

  const ProductsGrid(this.showFavorites);

  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context, listen: true);
    final products =
        showFavorites ? productsData.favoritesProducts : productsData.products;
    return products.isEmpty
        ? Center(child: Text("There is no products!"))
        : GridView.builder(
            itemCount: products.length,
            padding: EdgeInsets.all(10.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5 / 3,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            // use provider here to listen to any change in product, so re-draw ProductItem() which any change happens
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
              value: products[index],
              child: ProductItem(),
            ),
          );
  }
}
