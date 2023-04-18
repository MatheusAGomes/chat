import 'package:chat/screens/VerificacaoScreen.dart';
import 'package:chat/screens/telefoneCadastroScreen.dart';
import 'package:chat/screens/welcomeScreen.dart';
import 'package:flutter/widgets.dart';

import '../screens/PerfilScreen.dart';



class Routes {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String INICIAL = "/inicio";
  static const String CADASTROTELEFONE = "/cadastroTelefone";
  static const String VERIFICACAOTELEFONE = "/cadastroVerficacao";
  static const String NOME = "/cadastroNomeFoto";










  final routes = <String, WidgetBuilder>{
    Routes.INICIAL: (BuildContext context) => WelcomeScreen(),
    Routes.CADASTROTELEFONE: (BuildContext context) => telefoneCadastroScreen(),
    //Routes.VERIFICACAOTELEFONE:(BuildContext context) => VerificacaoScreen(),
    Routes.NOME: (BuildContext context) => PerfilScreen(),



  };
}
