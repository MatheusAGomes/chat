import 'package:chat/widgets/buttonAlternativo.dart';
import 'package:chat/widgets/buttonPadrao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class telefoneCadastroScreen extends StatefulWidget {
  const telefoneCadastroScreen({super.key});

  @override
  State<telefoneCadastroScreen> createState() => _telefoneCadastroScreenState();
}

class _telefoneCadastroScreenState extends State<telefoneCadastroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Text("Imagem"),
            Text("Insira o número de seu telefone ")
          ],
        )
    );
  }
}
