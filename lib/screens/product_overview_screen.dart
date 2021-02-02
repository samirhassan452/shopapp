import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/cart_provider.dart';
import 'package:real_shop/providers/products_provider.dart';
import 'package:real_shop/screens/cart_screen.dart';
import 'package:real_shop/widgets/badge.dart';
import 'package:real_shop/widgets/products_grid.dart';
import '../widgets/app_drawer.dart';

enum FilterOption { Favorites, All }

class ProductOverviewScreen extends StatefulWidget {
  //static const routeName = '/';
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _isLoading = false;
  var _showOnlyFavorites = false;
  //var _isInit = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts()
        .then(
          (_) => setState(() => _isLoading = false),
        )
        .catchError(
          (err) => setState(() => _isLoading = false),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rivo Shop"),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (FilterOption selectedVal) {
              setState(() {
                if (selectedVal == FilterOption.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("Show All"),
                value: FilterOption.All,
              ),
              PopupMenuItem(
                child: Text("Only Favorites"),
                value: FilterOption.Favorites,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Consumer<CartProvider>(
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () =>
                    Navigator.of(context).pushNamed(CartScreen.routeName),
              ),
              builder: (_, cart, child) => Badge(
                child: child,
                value: cart.itemCount.toString(),
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showOnlyFavorites),
      drawer: AppDrawer(),
    );
  }
}
