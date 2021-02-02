import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text("Hello Customer!"),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          buildDrawerListTile(context, Icons.shop, "Shop", '/'),
          Divider(),
          buildDrawerListTile(
              context, Icons.payment, "Orders", OrdersScreen.routeName),
          Divider(),
          buildDrawerListTile(context, Icons.edit, "Manage Products",
              UserProductsScreen.routeName),
          Divider(),
          buildDrawerListTile(context, Icons.exit_to_app, "Logout", '/'),
        ],
      ),
    );
  }

  ListTile buildDrawerListTile(
      BuildContext context, IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (title == 'Logout') {
          // close the drawer
          Navigator.of(context).pop();
          // navigate to auth screen
          Navigator.of(context).pushReplacementNamed(routeName);
          // fire logout method
          Provider.of<AuthProvider>(context, listen: false).logout();
        } else {
          Navigator.of(context).pushReplacementNamed(routeName);
        }
      },
    );
  }
}
