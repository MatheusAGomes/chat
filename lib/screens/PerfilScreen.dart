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
      'nomeUsuario': user.nomeUsuario,
      'telefoneUsuario': user.telefoneUsuario,
    }));
    if (response.statusCode == 200) {
      ToastService.showToastInfo('Usuario cadastrado com sucesso !');
    } else {
      ToastService.showToastError('Erro ao cadastrar usuário: ${response.reasonPhrase}');
    }
  }
  final nome =  TextEditingController();
  File? _storedImage;
  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context, listen: false);


    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 70,horizontal: 25),
            child: Column(
              children: [
                Column(
                  children: [

                    Center(
                        child: Text("Insira seus dados",
                            style: TextStyle(
                                color: ColorService.azulEscuro,
                                fontSize: 30,
                                fontWeight: FontWeight.bold))),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Text("Insira o seu nome e sua foto para que as pessoas te reconhecam"),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),

                    _storedImage != null ? InkWell(
                      onTap: () async {
                        File? file =
                        await Navigator.of(context)
                            .push(MaterialPageRoute(
                            builder: (context) =>
                                EdicaoFotoScreen(
                                    _storedImage ,
                                    nome
                                        .text)));
                        setState(() {
                          _storedImage = file;
                        });},
                  child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                             _storedImage != null
                            ? CircleAvatar(
                          radius: 90,
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
                      ]),
                ) : InkWell(
                      onTap: () async {
                        File? file =
                            await Navigator.of(context)
                            .push(MaterialPageRoute(
                            builder: (context) =>
                                EdicaoFotoScreen(
                                    _storedImage ,
                                    nome
                                        .text)));
                        setState(() {
                          _storedImage = file;



                        });},
                      child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _storedImage != null
                                ? CircleAvatar(
                              radius: 90,
                              backgroundImage:
                              FileImage(
                                  _storedImage!),
                            )
                                : CircleAvatar(
                              backgroundColor:
                              ColorService
                                  .cinza,
                              radius: 90,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,color: ColorService.azulEscuro,size: 60),
                                  Text('Foto')
                                ],
                              ),
                            ),
                            // const Positioned(
                            //   top: 130,
                            //   left: 100,
                            //   child: CircleAvatar(
                            //     radius: 40,
                            //     backgroundColor:
                            //     Colors.white,
                            //     child: Icon(
                            //       Icons.camera_alt,
                            //       color: Colors.black,
                            //     ),
                            //   ),
                            // )
                          ]),
                    ),


                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
            SizedBox( width: MediaQuery.of(context).size.width * 0.8,child: TextFieldPadrao(click: (){},hintText: 'Digite seu nome',controller: nome,onchange: (value){
              setState(() {

              });
            },)),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,

                      child: ButtonPadrao(btnName: 'Avançar', click: () async {
                        Usuario user = Usuario.fromJson(
                            await Store.read("objeto"));
                        user.nomeUsuario = nome.text;
                        updateUserData(auth.token!,user);
                        Navigator.pushReplacementNamed(context, Routes.Auth);

                      }),
                    )
  ],
                ),
              ],
            ),
          ),
        )
    );
  }
}
