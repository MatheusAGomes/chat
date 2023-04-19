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
