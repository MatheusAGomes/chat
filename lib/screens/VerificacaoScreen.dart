import 'dart:convert';

import 'package:chat/Utils/constants.dart';
import 'package:chat/Utils/toastService.dart';
import 'package:chat/models/Usuario.dart';
import 'package:chat/screens/telefoneCadastroScreen.dart';
import 'package:chat/widgets/buttonAlternativo.dart';
import 'package:chat/widgets/buttonPadrao.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../Utils/ColorsService.dart';
import '../Utils/Routes.dart';
import '../Utils/Store.dart';
import '../models/Auth.dart';
import '../widgets/textfieldpadrao.dart';

class VerificacaoScreen extends StatefulWidget {
  String verificationId = "";
  String numero = "";

  VerificacaoScreen({required this.verificationId, required this.numero});

  @override
  State<VerificacaoScreen> createState() => _VerificacaoScreenState();
}

class _VerificacaoScreenState extends State<VerificacaoScreen> {
  TextEditingController _codigo = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context, listen: false);
    Future<List<Usuario>?> readData() async {
      final response =
          await http.get(Uri.parse('${constants.banco}/users.json'));
      List<Usuario> items = [];


      if (response.statusCode == 200) {
        // dados foram obtidos com sucesso

        Map<String, dynamic>? data = json.decode(response.body);
        if(data != null){
          data.forEach((userId, userData) {
            items.add(
              Usuario(
                  telefoneUsuario: userData['telefoneUsuario'],
                  nomeUsuario: userData['nomeUsuario']),
            );
          });
        }

        print(items);
      } else {
        // houve um erro ao obter os dados
        print('Erro ao obter dados: ${response.statusCode}');
      }
      return items;
    }

    bool idExistsInList(List<Usuario> lista, String telefone) {
      if(lista != []) {
        for (var usuario in lista) {
          if (usuario.telefoneUsuario == telefone) {
            return true;
          }
        }
      }
      return false;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Column(
            children: [
              Center(
                  child: Text("Insira o código",
                      style: TextStyle(
                          color: ColorService.azulEscuro,
                          fontSize: 30,
                          fontWeight: FontWeight.bold))),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
            const  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70),
                child: Center(
                    child: Text(
                        "Assim que receber o código de verificação, digite no campo abaixo.",
                        style: TextStyle(fontSize: 16))),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                    child: TextFieldPadrao(
                    click: () {},
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                        maxlength: 6,
                    hintText: 'Digite seu codigo',
                    controller: _codigo),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70),
                child: Center(
                    child: Text("Reenviar codigo",
                        style: TextStyle(
                            fontSize: 16,
                            color: ColorService.azulClaro,
                            decoration: TextDecoration.underline))),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ButtonPadrao(
                    btnName: 'Avançar',
                    click: () async {
                      FirebaseAuth authFire = FirebaseAuth.instance;
                      try {

                        PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: widget.verificationId,
                                smsCode: _codigo.text);

                        final result = await authFire
                            .signInWithCredential(credential)
                            .then((value) async {
                              //ate aqui ta certo
                          auth.tokenFake(widget.numero);



                          List<Usuario>? users = await readData();

                          if (idExistsInList(users!, auth.token!)) {
                            Navigator.pushReplacementNamed(context, Routes.MENU);
                          } else {
                            final response = await http
                                .put(
                                    Uri.parse(
                                        '${constants.banco}/users/${widget.numero}.json'),
                                    body: jsonEncode({
                                      'nomeUsuario': null,
                                      'telefoneUsuario': widget.numero,
                                    }))
                                .then((a) {
                              Store.save(
                                  "objeto",
                                  Usuario(
                                          telefoneUsuario: widget.numero)
                                      .toJson());
                              Navigator.pushReplacementNamed(context, Routes.NOME);
                            }).onError((error, stackTrace) =>
                                    ToastService.showToastError(error.toString()));
                            print(response);
                          }
                        });

                         print(result);
                         print(credential.token);
                      } catch (error) {
                        ToastService.showToastError(error.toString());
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
