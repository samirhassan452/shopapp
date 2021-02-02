import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/products_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/product-details';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct = Provider.of<ProductsProvider>(context, listen: false)
        .findProductById(productId);
    return Scaffold(
      //appBar: AppBar(title: Text("ProductDetailsScreen")),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Container(
                color: Colors.black38,
                padding: EdgeInsets.symmetric(vertical: 6),
                width: double.infinity,
                child: Text(
                  loadedProduct.title,
                  textAlign: TextAlign.center,
                ),
              ),
              background: Hero(
                tag: productId,
                // Image.network to not load image again from internet after already downloaded in first time
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: 10.0),
                Text(
                  "\$${loadedProduct.price}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    loadedProduct.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
