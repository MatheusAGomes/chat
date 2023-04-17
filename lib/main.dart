import 'package:chat/screens/loading_page.dart';
import 'package:chat/screens/welcomeScreen.dart';
import 'package:flutter/material.dart';

import 'Utils/Routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Routes route = Routes();
    return MaterialApp(
      navigatorKey: Routes.navigatorKey,
      home: WelcomeScreen(),
      debugShowCheckedModeBanner: false,
      title: "Chat",

      routes: route.routes,
    );
  }
}
