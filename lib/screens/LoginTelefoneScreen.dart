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

class LoginTelefoneScreen extends StatefulWidget {
  LoginTelefoneScreen({super.key});

  @override
  State<LoginTelefoneScreen> createState() => _LoginTelefoneScreenState();
}

class _LoginTelefoneScreenState extends State<LoginTelefoneScreen> {
  final _telefoneController = TextEditingController();
  String nomeDaEmpresa = "Messageio";
  String verify = "";
  void checkPhoneNumber(String phoneNumber) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Opcionalmente, você pode fazer algo aqui se a verificação for concluída automaticamente.
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Erro ao verificar o número de telefone: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          // Opcionalmente, você pode armazenar o verificationId para uso posterior.
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Opcionalmente, você pode fazer algo aqui quando o tempo limite de recuperação automática expirar.
        },
      );
      print('O número de telefone ainda não foi cadastrado.');
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'invalid-phone-number') {
        print('O número de telefone é inválido.');
      } else if (e is FirebaseAuthException && e.code == 'too-many-requests') {
        print('Muitas solicitações foram feitas para verificar este número de telefone. Tente novamente mais tarde.');
      } else if (e is FirebaseAuthException) {
        print('Erro ao verificar o número de telefone: ${e.message}');
      } else {
        print('Erro ao verificar o número de telefone: $e');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 100),
          child: Center(
            child: Column(

              mainAxisAlignment:MainAxisAlignment.spaceBetween,
              children: [
                Text("Verifique seu número",style: TextStyle(color: ColorService.azulEscuro,fontSize: 20)),
                Text("O ${nomeDaEmpresa} te enviara um sms para verificar seu número de telefone. Insira o seu telefone: ",style: TextStyle(fontSize: 15)),
                TextFieldPadrao(click: (){},inputFormatter: [FilteringTextInputFormatter.digitsOnly,
                  TelefoneInputFormatter()],hintText: 'Digite seu Telefone',controller: _telefoneController),
                ButtonPadrao(btnName: 'Avancar', click: () async {
                  checkPhoneNumber('+55 ${UtilBrasilFields.obterTelefone(_telefoneController.text,mascara:false)}');
                })
              ],
            ),
          ),
        )
    );
  }
}
