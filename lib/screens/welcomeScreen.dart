import 'package:chat/widgets/buttonAlternativo.dart';
import 'package:chat/widgets/buttonPadrao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../Utils/ImagesConst.dart';
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
        padding:  EdgeInsets.only(top: 250,bottom: 20,left: 25,right: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Image.asset(
              ImagesConst.logo,
              height: 50,
            ),

            Padding(
              padding: const EdgeInsets.only(top:200),
              child: SizedBox(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonPadrao(btnName: "Já sou cadastrado", click: (){
                      Navigator.pushNamed(context, Routes.CADASTROTELEFONE);

                    }),
                    Column(children: [

                    ],),
                    ButtonAlternativo(btnName: "Quero me cadastrar", click: (){
                      Navigator.pushNamed(context, Routes.CADASTROTELEFONE);
                    }),


                  ],
                ),
              ),
            ),
            Text('© Copyright - Messagio 2023'),
          ],
        ),
      )
    );
  }
}
