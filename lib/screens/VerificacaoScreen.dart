import 'dart:convert';

import 'package:chat/Utils/constants.dart';
import 'package:chat/Utils/toastService.dart';
import 'package:chat/models/Usuario.dart';
import 'package:chat/screens/telefoneCadastroScreen.dart';
import 'package:chat/widgets/buttonAlternativo.dart';
import 'package:chat/widgets/buttonPadrao.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';


import '../Utils/Routes.dart';
import '../Utils/Store.dart';
import '../models/Auth.dart';

class VerificacaoScreen extends StatefulWidget {
  String verificationId = "";
  String numero = "";

   VerificacaoScreen({required this.verificationId, required this.numero});

  @override
  State<VerificacaoScreen> createState() => _VerificacaoScreenState();
}

class _VerificacaoScreenState extends State<VerificacaoScreen> {

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context, listen: false);
    Future<List<Usuario>?> readData() async {
      final response = await http.get(Uri.parse('${constants.banco}/users.json'));

      if (response.statusCode == 200) {
        // dados foram obtidos com sucesso
        List<Usuario> items = [];

        Map<String, dynamic> data = json.decode(response.body);
      data.forEach((userId, userData) {
      items.add(
        Usuario(idUser: userId, telefoneUsuario: userData['telefoneUsuario'],nomeUsuario: userData['nomeUsuario']),
      );
      });
        print(items);
        return items;
      } else {
        // houve um erro ao obter os dados
        print('Erro ao obter dados: ${response.statusCode}');
      }
      return null;
    }

    bool idExistsInList(List<Usuario> lista, String id) {
      for (var usuario in lista) {
        if (usuario.idUser == id) {
          return true;
        }
      }
      return false;
    }

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
                          FirebaseAuth authFire = FirebaseAuth.instance;
                                      try{
                                      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId:widget.verificationId, smsCode: verificationCode);

                                    final result =  await authFire.signInWithCredential(credential).then((value) async {
                                      print(value.user!.uid);

                                      auth.tokenFake(value.user!.uid);
                                      List<Usuario>? users =await readData();
                                      
                                      if(idExistsInList(users!,auth.token!))
                                        {
                                          Navigator.pushReplacementNamed(context, Routes.MENU);
                                        }
                                      else
                                        {

                                        final response =   await http.put(
                                        Uri.parse('${constants.banco}/users/${value.user!.uid}.json'),
                                        body: jsonEncode({
                                        'idUser': value.user!.uid,
                                        'nomeUsuario': null,
                                        'telefoneUsuario': widget.numero,
                                        })).then((a) {
                                        Store.save("objeto",Usuario(idUser: value.user!.uid, telefoneUsuario: widget.numero).toJson());
                                        Navigator.pushReplacementNamed(context, Routes.NOME);
                                        }).onError((error, stackTrace) => ToastService.showToastError(error.toString()));
                                        print(response);

                                        }}
                                      );}
    catch(error)
    {
    ToastService.showToastError(error.toString());
    }


                                    }




                                      // String idUser;
                                      // String? nomeUsuario;
                                      // String telefoneUsuario;





                         // end onSubmit
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
