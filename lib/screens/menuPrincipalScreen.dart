import 'package:chat/widgets/buttonAlternativo.dart';
import 'package:chat/widgets/buttonPadrao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../Utils/ColorsService.dart';
import '../Utils/Routes.dart';
import '../models/Auth.dart';

class MenuPrincipalScreen extends StatefulWidget {
  const MenuPrincipalScreen({super.key});

  @override
  State<MenuPrincipalScreen> createState() => _MenuPrincipalScreenState();
}

class _MenuPrincipalScreenState extends State<MenuPrincipalScreen> {
  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context, listen: false);

    return Scaffold(appBar: AppBar(
      bottomOpacity: 0.0,
      elevation: 0.0,
      leading: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.01,
            horizontal:
            MediaQuery.of(context).size.height * 0.01),
      ),
      title: Center(
        child: Text(
          'Conversas',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        PopupMenuButton(
          color: Colors.white,
          icon: Icon(
            Icons.more_vert,
            color: ColorService.azulEscuro,
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 0,
                child: Text(
                  'Sair',
                  style:
                  TextStyle(color: ColorService.azulEscuro),
                ),
                onTap: ()  {


                auth.deslogar();

                },
              ),
            ];
          },
        )
      ],
    ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100,horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              const Text("TELA PRINCIPAL"),


            ],
          ),
        )
    );
  }
}
