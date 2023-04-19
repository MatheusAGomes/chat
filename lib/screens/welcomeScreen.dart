import 'package:chat/widgets/buttonAlternativo.dart';
import 'package:chat/widgets/buttonPadrao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../Utils/Routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100,horizontal: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            const Text("Logo"),

            SizedBox(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ButtonPadrao(btnName: "Já sou cadastrado", click: (){
                    Navigator.pushNamed(context, Routes.CADASTROTELEFONE);

                  }),
                  ButtonAlternativo(btnName: "Quero me cadastrar", click: (){
                    Navigator.pushNamed(context, Routes.CADASTROTELEFONE);
                  })

                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
