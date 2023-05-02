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
import 'package:validatorless/validatorless.dart';

import '../Utils/ColorsService.dart';
import '../Utils/Routes.dart';
import '../Utils/Store.dart';
import '../Utils/utils.dart';
import '../models/Auth.dart';
import '../models/MyPageIndex.dart';
import '../models/Usuario.dart';

class MeuPerfilScreen extends StatefulWidget {
  MeuPerfilScreen();

  @override
  State<MeuPerfilScreen> createState() => _MeuPerfilScreenState();
}

class _MeuPerfilScreenState extends State<MeuPerfilScreen> {

  GlobalKey<FormFieldState> nomeKey = GlobalKey<FormFieldState>();

  Future<Usuario?>? readData(token) async {
    final response =
        await http.get(Uri.parse('${constants.banco}/users/${token}.json'));

    if (response.statusCode == 200) {
      Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        Usuario user = Usuario(
            telefoneUsuario: data['telefoneUsuario'],
            nomeUsuario: data['nomeUsuario']);
        return user;
      }
    } else {
      print('Erro ao obter dados: ${response.statusCode}');
    }
    return null;
  }

  void updateUserData(String uid, Usuario user) async {
    final url = '${constants.banco}/users/$uid.json';
    final response = await http.patch(Uri.parse(url),
        body: json.encode({
          'nomeUsuario': user.nomeUsuario,
          'telefoneUsuario': user.telefoneUsuario,
        }));
    if (response.statusCode == 200) {
      ToastService.showToastInfo('Usuario alterado com sucesso !');
    } else {
      ToastService.showToastError(
          'Erro ao cadastrar usuário: ${response.reasonPhrase}');
    }
  }

  final nomeController = TextEditingController();
  File? _storedImage;
  bool editable = false;
  Usuario? user;
  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context, listen: false);

    return FutureBuilder(
      future: readData(auth.token),
      builder: (context, snapshot) {

    if(snapshot.hasData)
      {
        if (user == null) {
          user = snapshot.data;
          nomeController.text = user!.nomeUsuario!;
        }


      return  Scaffold(
            appBar: editable == false
                ? AppBar(
              backgroundColor: Colors.transparent,
              bottomOpacity: 0.0,
              elevation: 0.0,
              leading: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.01,
                    horizontal: MediaQuery.of(context).size.height * 0.01),
              ),
              title: Center(
                child: Text(
                  'Meu Perfil',
                  style: TextStyle(
                      color: ColorService.azulEscuro,
                      fontWeight: FontWeight.bold),
                ),
              ),
              actions: [
                PopupMenuButton(
                  color: Colors.white,
                  icon: Icon(
                    Icons.more_vert,
                    color: ColorService.azulEscuro,
                  ),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Text(
                          'Editar',
                          style: TextStyle(color: ColorService.azulEscuro),
                        ),
                        onTap: () async {
                          setState(() {
                            editable = true;
                          });
                        },
                      ),
                      PopupMenuItem<int>(
                        value: 0,
                        child: Text(
                          'Sair',
                          style: TextStyle(color: ColorService.azulEscuro),
                        ),
                        onTap: () async {
                          auth.deslogar();
                        },
                      ),
                    ];
                  },
                )
              ],
            )
                : AppBar(
              backgroundColor: Colors.transparent,
              bottomOpacity: 0.0,
              elevation: 0.0,
              leading: Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.height * 0.01,
                      bottom: MediaQuery.of(context).size.height * 0.01),
                  child: IconButton(
                    color: Colors.black,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        editable = false;
                      });

                      setState(()  {
                        user = snapshot.data;

                        nomeController.text = user!.nomeUsuario!;
                        editable = false;
                      });

                      setState(() {
                        editable = false;
                      });
                    },
                  )),
              title: Center(
                child: Text(
                  //auth.authDecoded!['name'],
                  'Editando meu perfil',
                  style: TextStyle(
                      color: ColorService.azulEscuro,
                      fontWeight: FontWeight.bold),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    if(nomeKey.currentState!.validate()) {
                      setState(() {
                        editable = false;
                      });

                      updateUserData(auth.token!, Usuario(
                          telefoneUsuario: user!.telefoneUsuario,
                          nomeUsuario: nomeController.text));

                      setState(() {
                        editable = false;
                      });
                    }

                  },
                  icon: const Icon(Icons.check),
                  color: Colors.black,
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _storedImage != null
                            ? InkWell(
                          onTap: () async {
                            File? file = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => EdicaoFotoScreen(
                                        _storedImage, nomeController.text)));
                            setState(() {
                              _storedImage = file;
                            });
                          },
                          child: Stack(clipBehavior: Clip.none, children: [
                            _storedImage != null
                                ? CircleAvatar(
                              radius: 90,
                              backgroundImage: FileImage(_storedImage!),
                            )
                                : CircleAvatar(
                              backgroundColor: ColorService.azulClaro,
                              radius: 90,
                              child: Text(
                                abreviacao(nomeController.text),
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                            ),
                          ]),
                        )
                            : InkWell(
                          onTap: () async {
                            File? file = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => EdicaoFotoScreen(
                                        _storedImage, nomeController.text)));
                            setState(() {
                              _storedImage = file;
                            });
                          },
                          child: Stack(clipBehavior: Clip.none, children: [
                            _storedImage != null
                                ? CircleAvatar(
                              radius: 90,
                              backgroundImage: FileImage(_storedImage!),
                            )
                                : CircleAvatar(
                              backgroundColor: ColorService.cinza,
                              radius: 90,
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,
                                      color: ColorService.azulEscuro,
                                      size: 60),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Nome'),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.65,
                                child: TextFieldPadrao(
                                  textFormFildKey: nomeKey,
                                  enable: editable,
                                  click: () {},
                                  hintText: 'Digite seu nome',
                                  controller: nomeController,
                                  validator: Validatorless.multiple([
                                    Validatorless.required('Campo Obrigatorio'),
                                  ]),
                                  onchange: (value) {
                                    setState(() {
                                      nomeKey.currentState!.validate();
                                    });
                                  },
                                )),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
        }
    else if (snapshot.hasError) {
      //   return ;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          bottomOpacity: 0.0,
          elevation: 0.0,
          leading: Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.01,
                horizontal: MediaQuery.of(context).size.height * 0.01),
          ),
          title: Text(
            //auth.authDecoded!['name'],
            'Meu Perfil',
            style: TextStyle(
                color: ColorService.azulEscuro,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            PopupMenuButton(
              color: Colors.white,
              icon: Icon(
                Icons.more_vert,
                color: ColorService.azulEscuro,
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text(
                      'Sair',
                      style: TextStyle(color: ColorService.azulEscuro),
                    ),
                    onTap: () async {
                      Provider.of<MyPageIndexProvider>(context, listen: false).updateIndex(0);
                      auth.deslogar();

                    },
                  ),
                ];
              },
            )
          ],
        ),
        body:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Center(
              child: Text('Estamos com problema'),
            )
            //  Center(child: Text(snapshot.error.toString()),)
          ],
        ),
      );
    } else {
      return Center(
          child: CircularProgressIndicator(
            color: ColorService.azulEscuro,
          ));
    }
      },

      
    );
  }
}
