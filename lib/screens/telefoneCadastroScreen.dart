import 'dart:convert';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:chat/Utils/ColorsService.dart';
import 'package:chat/Utils/toastService.dart';
import 'package:chat/screens/VerificacaoScreen.dart';
import 'package:chat/widgets/buttonAlternativo.dart';
import 'package:chat/widgets/buttonPadrao.dart';
import 'package:chat/widgets/textfieldpadrao.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../Utils/Routes.dart';
import '../main.dart';
import 'package:http/http.dart' as http;
import 'package:chat/Utils/constants.dart';


import '../models/Usuario.dart';

class telefoneCadastroScreen extends StatefulWidget {
   telefoneCadastroScreen({super.key});

  @override
  State<telefoneCadastroScreen> createState() => _telefoneCadastroScreenState();
}

class _telefoneCadastroScreenState extends State<telefoneCadastroScreen> {
  final _telefoneController = TextEditingController();
  String nomeDaEmpresa = "Messageio";
  String verify = "";

  Future<List<Usuario>?> readData() async {
    final response =
    await http.get(Uri.parse('${constants.banco}/users.json'));

    if (response.statusCode == 200) {
      // dados foram obtidos com sucesso
      List<Usuario> items = [];

      Map<String, dynamic>? data = json.decode(response.body);
      if(data != null) {
        data.forEach((userId, userData) {
          items.add(
            Usuario(
                telefoneUsuario: userData['telefoneUsuario'],
                nomeUsuario: userData['nomeUsuario']),
          );
        });
      }
      print(items);
      return items;
    } else {
      // houve um erro ao obter os dados
      print('Erro ao obter dados: ${response.statusCode}');
    }
    return null;
  }
  bool idExistsInList(List<Usuario> lista, String telefone) {


    for (var usuario in lista) {
      if (usuario.telefoneUsuario == telefone) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorService.azulEscuro,
        title: Text('Cadastro'),
      ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 25,right: 25,top: 25,bottom: 0),
            child: Center(
              child: Column(
                children: [
                  Text("Verifique seu número",style: TextStyle(color: ColorService.azulEscuro,fontSize: 30,fontWeight: FontWeight.bold)),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                  Text("Digite seu número de celular para enviarmos um SMS com o código de verificação.",style: TextStyle(fontSize: 16)),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                  TextFieldPadrao(click: (){},inputFormatter: [FilteringTextInputFormatter.digitsOnly,
                    TelefoneInputFormatter()],hintText: 'Digite seu Telefone',controller: _telefoneController),
                 SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                  SizedBox(
                    width:MediaQuery.of(context).size.width * 0.6 ,
                    child: ButtonPadrao(btnName: 'Avancar', click: () async {
                      List<Usuario>? users = await readData();
                      if(idExistsInList(users!,UtilBrasilFields.obterTelefone(_telefoneController.text,mascara:false)))
                        {
                          ToastService.showToastError('Telefone já cadastrado você será direcionado para a tela de verificação de telefone para efetuar o login');
                        }
                          await FirebaseAuth.instance.verifyPhoneNumber(
                            phoneNumber: '+55 ${UtilBrasilFields.obterTelefone(_telefoneController.text,mascara:false)}',
                            verificationCompleted: (PhoneAuthCredential credential) {},
                            verificationFailed: (FirebaseAuthException e) {
                              ToastService.showToastError(e.message.toString());
                            },
                            codeSent: (String verificationId, int? resendToken) {
                              verify = verificationId;
                              Navigator.push(context,MaterialPageRoute(builder: (context) => VerificacaoScreen(verificationId: verificationId,numero: UtilBrasilFields.obterTelefone(_telefoneController.text,mascara:false),)), );
                            },
                            codeAutoRetrievalTimeout: (String verificationId) {},
                          );



                    }),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.45,),

                  Text('© Copyright - Messagio 2023'),
                ],
              ),
            ),
          ),
        )
    );
  }
}
