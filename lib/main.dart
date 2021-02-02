//import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/screens/product_overview_screen.dart';
import 'package:real_shop/screens/splash_screen.dart';

import './providers/auth_provider.dart';
import './providers/cart_provider.dart';
import './providers/orders_provider.dart';
import './providers/products_provider.dart';

import './screens/cart_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/orders_screen.dart';
import './screens/product_details_screen.dart';
import './screens/user_products_screen.dart';
import './screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This method should be called before any usage of FlutterFire plugins
  await Firebase.initializeApp();
  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => MyApp(),
    // ),
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthProvider()),
        // use ProxyProvider if we have provider depends on another provider
        // and we have ProductProvider depends on AuthProvider cause it need userId and token
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (_) => ProductsProvider(),
          update: (ctx, authValue, prevProduct) => prevProduct
            ..getData(
              authValue.token,
              authValue.userId,
              prevProduct == null ? null : prevProduct.products,
            ),
        ),
        ChangeNotifierProvider.value(value: CartProvider()),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (_) => OrdersProvider(),
          update: (ctx, authValue, prevOrder) => prevOrder
            ..getData(
              authValue.token,
              authValue.userId,
              prevOrder == null ? null : prevOrder.orders,
            ),
        ),
      ],
      child: Consumer<AuthProvider>(
        // authValue is object from AuthProvider()
        builder: (ctx, authValue, child) => MaterialApp(
          title: 'Rivo Shop',
          debugShowCheckedModeBanner: false,
          // locale: DevicePreview.locale(context),
          // builder: DevicePreview.appBuilder,
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: authValue.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: authValue.tryAutoLogin(),
                  builder: (ctx, AsyncSnapshot authSnapshot) {
                    //print(authSnapshot.data);
                    return authSnapshot.connectionState ==
                            ConnectionState.waiting
                        ? SplashScreen()
                        : AuthScreen();
                  },
                ),
          //initialRoute: ProductDetailsScreen.routeName,
          routes: {
            //ProductOverviewScreen.routeName: (_) => ProductOverviewScreen(),
            AuthScreen.routeName: (_) => AuthScreen(),
            ProductDetailsScreen.routeName: (_) => ProductDetailsScreen(),
            CartScreen.routeName: (_) => CartScreen(),
            OrdersScreen.routeName: (_) => OrdersScreen(),
            EditProductScreen.routeName: (_) => EditProductScreen(),
            UserProductsScreen.routeName: (_) => UserProductsScreen(),
          },
        ),
      ),
    );
  }
}
