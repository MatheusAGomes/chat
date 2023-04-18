import 'package:chat/screens/loading_page.dart';
import 'package:chat/screens/welcomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Utils/Routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

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
