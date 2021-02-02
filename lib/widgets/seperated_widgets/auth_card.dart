import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/http_exception.dart';
import '../../providers/auth_provider.dart';

enum AuthMode {
  Login,
  SignUp,
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  AuthMode _authMode = AuthMode.Login;
  // in default case, Login is default screen, and then we can switch, in switch change this height
  double _authModeHeight = 0.45;
  bool _isLoading = false;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  AnimationController _animationController;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(begin: Offset(0, -0.15), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.fastOutSlowIn));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    super.dispose();

    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 20.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.SignUp
            ? deviceSize.height * _authModeHeight // 0.55
            : deviceSize.height * _authModeHeight, // 0.45
        width: deviceSize.width * 0.8,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildTextFormField(labelText: 'E-mail', type: 'email'),
                buildTextFormField(labelText: 'Password', type: 'password'),
                buildConfirmPassword(deviceSize),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : buildSubmitBtn(context),
                buildSwitchBtn(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildTextFormField({String labelText, String type}) {
    return TextFormField(
      key: ValueKey(type),
      enabled: _authMode == AuthMode.SignUp
          ? type == 'confirm-password'
              ? true
              : null
          : null,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: type == 'email' ? TextInputType.emailAddress : null,
      obscureText: type == 'email' ? false : true,
      controller: type == 'password' ? _passwordController : null,
      validator: _authMode == AuthMode.SignUp
          ? (val) => _validateInput(val, inputType: type)
          : type == 'confirm-password'
              ? null
              : (val) => _validateInput(val, inputType: type),
      onSaved:
          type == 'confirm-password' ? null : (val) => _authData[type] = val,
    );
  }

  AnimatedContainer buildConfirmPassword(Size deviceSize) {
    return AnimatedContainer(
      constraints: BoxConstraints(
        maxHeight: _authMode == AuthMode.SignUp ? deviceSize.height * 0.2 : 0,
        maxWidth: _authMode == AuthMode.SignUp ? deviceSize.width * 0.71 : 0,
      ),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: buildTextFormField(
              labelText: 'Confirm Password', type: 'confirm-password'),
        ),
      ),
    );
  }

  FlatButton buildSwitchBtn(BuildContext context) {
    return FlatButton(
      child: Text(
          '${_authMode == AuthMode.SignUp ? 'login'.toUpperCase() : 'signup'.toUpperCase()} INSTEAD'),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
      textColor: Theme.of(context).primaryColor,
      onPressed: _switchAuthMode,
    );
  }

  RaisedButton buildSubmitBtn(BuildContext context) {
    return RaisedButton(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      color: Theme.of(context).primaryColor,
      textColor: Theme.of(context).primaryTextTheme.headline6.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Text(_authMode == AuthMode.SignUp
          ? "signup".toUpperCase()
          : 'login'.toUpperCase()),
      onPressed: _submit,
    );
  }

  Future<void> _submit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!_formKey.currentState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        await authProvider.login(_authData['email'], _authData['password']);
      } else {
        await authProvider.signUp(_authData['email'], _authData['password']);
      }
    } on HttpException catch (err) {
      var httpErrorMsg = 'Authentication Falied';
      if (err.toString().contains('EMAIL_EXISTS')) {
        httpErrorMsg = 'The email address is already in use.';
      } else if (err.toString().contains('INVALID_EMAIL')) {
        httpErrorMsg = 'This is not a valid email address.';
      } else if (err.toString().contains('EMAIL_NOT_FOUND')) {
        httpErrorMsg = 'Could not find a user with that email.';
      } else if (err.toString().contains('WEAK_PASSWORD')) {
        httpErrorMsg = 'This password is too weak.';
      } else if (err.toString().contains('INVALID_PASSWORD')) {
        httpErrorMsg = 'Invalid password.';
      }
      _showErrorDialogMessage(httpErrorMsg);
    } catch (err) {
      const errorMessage = 'Could not authenticate you. Please try again later';
      _showErrorDialogMessage(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialogMessage(String errorMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "An Error Occured!",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(errorMessage),
        actions: [
          FlatButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
        _authModeHeight = 0.55;
      });
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
        _authModeHeight = 0.45;
      });
      _animationController.reverse();
    }
  }

  _validateInput(String val, {String inputType}) {
    //String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    String emailPattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    String passwordPattern =
        r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])[a-zA-Z0-9]{8,20}$';
    if (inputType == 'email') {
      RegExp regExp = RegExp(emailPattern);
      //print(val);
      if (val.isEmpty)
        return 'please enter your email';
      else if (!regExp.hasMatch(val))
        return 'please enter valid email';
      else
        return null;
    } else if (inputType == 'password') {
      RegExp regExp = RegExp(passwordPattern);
      //print(val);
      if (val.isEmpty)
        return 'please enter your password';
      else if (!regExp.hasMatch(val))
        return 'please enter at least 8 characters';
      else
        return null;
    } else if (inputType == 'confirm-password') {
      if (val != _passwordController.text)
        return "password doesn't match";
      else if (val.isEmpty)
        return 'please enter your password';
      else
        return null;
    }
  }
}
