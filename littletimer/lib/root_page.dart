import 'package:flutter/material.dart';
import 'package:best_flutter_ui_templates/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'auth.dart';
import 'navigation_home_screen.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
  }

enum AuthStatus {
  notSignedIn,
  signedIn
}
class _RootPageState extends State<RootPage> {

  AuthStatus authStatus = AuthStatus.notSignedIn;


  initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
    });
    });
  }

void _signedIn() {
  setState(() {
    authStatus = AuthStatus.signedIn;
  });
}

void _signedOut() {
  setState(() {
    authStatus = AuthStatus.notSignedIn;
  });
}
  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(
          auth: widget.auth,
          onSignedIn: _signedIn
          );
      case AuthStatus.signedIn:
        return new NavigationHomeScreen(
    );
    }
  }
}