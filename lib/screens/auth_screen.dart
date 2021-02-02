import 'dart:math';
import 'package:flutter/material.dart';

import '../widgets/seperated_widgets/auth_card.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          buildBackgroundFromContainer(),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildAuthTitle(deviceSize, context),
                  Flexible(
                    child: AuthCard(),
                    flex: deviceSize.width > 600 ? 3 : 2,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Flexible buildAuthTitle(Size deviceSize, BuildContext context) {
    return Flexible(
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding:
            EdgeInsets.symmetric(vertical: 8, horizontal: deviceSize.width / 4),
        transform: Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.deepOrange.shade900,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black45,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          "Rivo Shop",
          style: TextStyle(
            color: Theme.of(context).accentTextTheme.headline6.color,
            fontSize: deviceSize.width * 0.1,
            fontFamily: 'Anton',
          ),
        ),
      ),
    );
  }

  Container buildBackgroundFromContainer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
            Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, 1],
        ),
      ),
    );
  }
}
