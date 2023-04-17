import 'package:chat/screens/welcomeScreen.dart';
import 'package:flutter/widgets.dart';



class Routes {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String INICIAL = "/inicio";








  final routes = <String, WidgetBuilder>{
    Routes.INICIAL: (BuildContext context) => WelcomeScreen(),



  };
}
