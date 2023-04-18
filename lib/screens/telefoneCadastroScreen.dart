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

class telefoneCadastroScreen extends StatefulWidget {
   telefoneCadastroScreen({super.key});

  @override
  State<telefoneCadastroScreen> createState() => _telefoneCadastroScreenState();
}

class _telefoneCadastroScreenState extends State<telefoneCadastroScreen> {
  final _telefoneController = TextEditingController();
  String nomeDaEmpresa = "Messageio";
  String verify = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
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
                  await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: '+55 ${UtilBrasilFields.obterTelefone(_telefoneController.text,mascara:false)}',
                    verificationCompleted: (PhoneAuthCredential credential) {},
                    verificationFailed: (FirebaseAuthException e) {
                      ToastService.showToastError(e.message.toString());
                    },
                    codeSent: (String verificationId, int? resendToken) {
                      verify = verificationId;
                      Navigator.push(context,MaterialPageRoute(builder: (context) => VerificacaoScreen(verificationId: verificationId)), );
                    },
                    codeAutoRetrievalTimeout: (String verificationId) {},
                  );
                })
              ],
            ),
          ),
        )
    );
  }
}
