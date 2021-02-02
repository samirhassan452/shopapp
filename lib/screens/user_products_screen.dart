import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Products"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () =>
                  Navigator.of(context).pushNamed(EditProductScreen.routeName),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, AsyncSnapshot snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                child: Consumer<ProductsProvider>(
                  builder: (ctx, productsData, child) =>
                      productsData.products.isEmpty
                          ? Center(
                              child: Text(
                                "There is no products for you, you can add new one!",
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.all(8.0),
                              child: ListView.builder(
                                itemCount: productsData.products.length,
                                itemBuilder: (ctx, index) => Column(
                                  children: [
                                    UserProductItem(
                                      id: productsData.products[index].id,
                                      title: productsData.products[index].title,
                                      imageUrl:
                                          productsData.products[index].imageUrl,
                                    ),
                                    Divider(),
                                  ],
                                ),
                              ),
                            ),
                ),
                onRefresh: () => _refreshProducts(context),
              ),
      ),
      drawer: AppDrawer(),
    );
  }
}
