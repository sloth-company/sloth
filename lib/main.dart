//import 'dart:html';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'task.dart';
import 'categories.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'home.dart';
import 'Sloth_login_ui.dart';
import 'loading.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new TodoApp());
}

class TodoApp extends StatelessWidget {
  // This widget is the root of your application.
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError){
          return Scaffold(
            appBar: AppBar(
              title: Text("Something went wrong :("),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done){
          return MaterialApp(
            title: 'Things to Get Done',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              primarySwatch: Colors.orange,
              // This makes the visual density adapt to the platform that you run
              // the app on. For desktop platforms, the controls will be smaller and
              // closer together (more dense) than on mobile platforms.
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: '/home',
            routes: {
              '/': (context) => Loading(),  //This doesn't exist yet but will probably be needed later
              '/login': (context) => LoginPage(),
              '/home': (context) => TodoList(),
            },
          );
        }
        return Loading();
      },
    );
  }
}
