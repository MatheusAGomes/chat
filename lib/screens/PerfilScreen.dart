import 'dart:convert';
import 'dart:io';

import 'package:chat/Utils/constants.dart';
import 'package:chat/Utils/toastService.dart';
import 'package:chat/screens/EdicaoFotoScreen.dart';
import 'package:chat/screens/telefoneCadastroScreen.dart';
import 'package:chat/widgets/buttonAlternativo.dart';
import 'package:chat/widgets/buttonPadrao.dart';
import 'package:chat/widgets/textfieldpadrao.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../Utils/ColorsService.dart';
import '../Utils/Routes.dart';
import '../Utils/Store.dart';
import '../Utils/utils.dart';
import '../models/Auth.dart';
import '../models/Usuario.dart';

class PerfilScreen extends StatefulWidget {
  PerfilScreen();

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  void updateUserData(String uid, Usuario user) async {
    final url = '${constants.banco}/users/$uid.json';
    final response = await http.patch(Uri.parse(url), body: json.encode({
      'idUser': user.idUser,
      'nomeUsuario': user.nomeUsuario,
      'telefoneUsuario': user.telefoneUsuario,
    }));
    if (response.statusCode == 200) {
      ToastService.showToastInfo('Usuario cadastrado com sucesso !');
    } else {
      ToastService.showToastError('Erro ao cadastrar usuário: ${response.reasonPhrase}');
    }
  }
  File? _storedImage;
  final nome =  TextEditingController();
  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context, listen: false);

    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Insira o seu nome e sua foto para que as pessoas te reconhecam"),
                InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  EdicaoFotoScreen(_storedImage,nome.text),));
                      },
                  child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                             _storedImage != null
                            ? CircleAvatar(
                          radius: 45,
                          backgroundImage:
                          FileImage(
                              _storedImage!),
                        )
                            : CircleAvatar(
                          backgroundColor:
                          ColorService
                              .azulClaro,
                          radius: 90,
                          child: Text(
                            abreviacao(
                                nome
                                    .text),
                            style: const TextStyle(
                                color: Colors
                                    .white),
                          ),
                        ),
                        const Positioned(
                          top: 130,
                          left: 100,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor:
                            Colors.white,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ]),
                ),



          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                Text('Nome: '),
                SizedBox(width:200,child: TextFieldPadrao(click: (){},hintText: 'Digite seu nome',controller: nome,onchange: (value){
                  setState(() {

                  });
                },)),
            ],
                ),
                    ButtonPadrao(btnName: 'Iniciar', click: () async {
                      Usuario user = Usuario.fromJson(
                          await Store.read("objeto"));
                      user.nomeUsuario = nome.text;
                      updateUserData(auth.token!,user);
                      Navigator.pushReplacementNamed(context, Routes.MENU);

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
