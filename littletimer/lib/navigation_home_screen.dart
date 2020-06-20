import 'package:best_flutter_ui_templates/app_theme.dart';
import 'package:best_flutter_ui_templates/custom_drawer/drawer_user_controller.dart';
import 'package:best_flutter_ui_templates/custom_drawer/home_drawer.dart';
import 'package:best_flutter_ui_templates/feedback_screen.dart';
import 'package:best_flutter_ui_templates/help_screen.dart';
import 'package:best_flutter_ui_templates/home_page.dart';
import 'package:best_flutter_ui_templates/invite_friend_screen.dart';
import 'package:best_flutter_ui_templates/login_page.dart';
import 'package:flutter/material.dart';

import 'auth.dart';
import 'home_page.dart';

BaseAuth auth;
VoidCallback onSignedOut;
class NavigationHomeScreen extends StatefulWidget {
  NavigationHomeScreen({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
   
  @override
  _NavigationHomeScreen createState() => _NavigationHomeScreen();
}

class _NavigationHomeScreen extends State<NavigationHomeScreen> {

  void _signOut() async {
    try{
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  Widget screenView;
  DrawerIndex drawerIndex;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = new MyHomePage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.nearlyWhite,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      if (drawerIndex == DrawerIndex.HOME) {
        setState(() {
          screenView = new MyHomePage();
        });
      } else if (drawerIndex == DrawerIndex.Help) {
        setState(() {
          screenView = HelpScreen();
        });
      } else if (drawerIndex == DrawerIndex.FeedBack) {
        setState(() {
          screenView = FeedbackScreen();
        });
      } else if (drawerIndex == DrawerIndex.Invite) {
        setState(() {
          screenView = InviteFriend();
        });
      } else if (drawerIndex == DrawerIndex.About){
        //do in your way......
        _signOut();
        setState(() {
          screenView = LoginPage();
        });
      }
    }
  }
}