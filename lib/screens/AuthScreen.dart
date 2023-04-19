import 'package:chat/screens/menuPrincipalScreen.dart';
import 'package:chat/screens/welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../Utils/ColorsService.dart';

import '../models/Auth.dart';


class AuthScreen extends StatefulWidget {

  const AuthScreen();
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {

    Auth auth = Provider.of(context);
    return FutureBuilder(
      future: auth.tentarLoginAutomatico(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: ColorService.azulClaro,),
            ),
          );
        }  else if (snapshot.error != null) {
          return WelcomeScreen();
        } else {
          if (auth.estaAutenticado) {
            return MenuPrincipalScreen();

          } else {
            return WelcomeScreen();
          }
        }
      },
    );
  }
}
