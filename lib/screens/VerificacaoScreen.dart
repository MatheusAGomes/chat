import 'package:chat/Utils/toastService.dart';
import 'package:chat/screens/telefoneCadastroScreen.dart';
import 'package:chat/widgets/buttonAlternativo.dart';
import 'package:chat/widgets/buttonPadrao.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';


import '../Utils/Routes.dart';

class VerificacaoScreen extends StatefulWidget {
  String verificationId = "";
   VerificacaoScreen({required this.verificationId});

  @override
  State<VerificacaoScreen> createState() => _VerificacaoScreenState();
}

class _VerificacaoScreenState extends State<VerificacaoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              const Text("Logo"),

              SizedBox(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                //   OTPTextField(
                //   length: 5,
                //   width: MediaQuery.of(context).size.width,
                //   fieldWidth: 50,
                //   style: TextStyle(
                //       fontSize: 17
                //   ),
                //   textFieldAlignment: MainAxisAlignment.spaceAround,
                //   fieldStyle: FieldStyle.underline,
                //   onCompleted: (pin) async {
                //
                //     FirebaseAuth auth = FirebaseAuth.instance;
                //             try{
                //             PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: telefoneCadastroScreen().verify, smsCode: pin);
                //
                //             await auth.signInWithCredential(credential);
                //             ToastService.showToastInfo("Deu bom");
                //
                //           }catch(e)
                //             {
                //                   ToastService.showToastError("Deu merda");
                //             }
                //
                //
                //
                //   },
                // ),

                    Center(
                      child: OtpTextField(
                        numberOfFields: 6,
                        borderColor: Color(0xFF512DA8),

                        onCodeChanged: (String code) {
                        },
                        //runs when every textfield is filled
                        onSubmit: (String verificationCode) async {
                          FirebaseAuth auth = FirebaseAuth.instance;
                                      try{
                                      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId:widget.verificationId, smsCode: verificationCode);

                                      await auth.signInWithCredential(credential);
                                      Navigator.pushReplacementNamed(context, Routes.NOME);
                                    }catch(error)
                                      {
                                            ToastService.showToastError(error.toString());
                                      }

                        }, // end onSubmit
                      ),
                    ),


                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}
