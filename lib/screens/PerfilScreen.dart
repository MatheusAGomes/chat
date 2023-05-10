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
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:path/path.dart';
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
      'imagemUrl':user.imagemUrl
    }));
    if (response.statusCode == 200) {
      ToastService.showToastInfo('Usuario cadastrado com sucesso !');
    } else {
      ToastService.showToastError('Erro ao cadastrar usuário: ${response.reasonPhrase}');
    }
  }
  final nome =  TextEditingController();
  File? _storedImage;
  bool loading = false;
  String? linkFoto;

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context, listen: false);
    Future<String> uploadFile(File file) async {
      String fileName = basename(file.path);

      // Criar uma referência ao arquivo que será enviado
      Reference ref = FirebaseStorage.instance.ref().child(fileName);

      // Enviar o arquivo para o Firebase Storage
      UploadTask uploadTask = ref.putFile(file);

      // Aguardar o fim do upload
      await uploadTask;

      // Obter a URL do arquivo enviado
      String fileUrl = await ref.getDownloadURL();

      return fileUrl;
    }
    String? Media;

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

                    InkWell(
                      onTap: () async {
                          File? foto;

                          File? file = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => EdicaoFotoScreen(
                                      foto ?? _storedImage,
                                      nome.text == "" ? "" : nome.text)));

                          if(file != null) {
                            setState(() {
                              _storedImage = file;
                              loading = true;
                            });
                            if (file != null) {
                              Media = await uploadFile(file);

                              setState(() {
                                linkFoto = Media;
                              });
                            }
                          }
                          else
                          {
                            setState(() {
                              _storedImage = null;
                              linkFoto = null;
                            });
                          }
                          setState(() {
                            loading = false;
                          });

                      },
                      child: Stack(clipBehavior: Clip.none, children: [
                        loading ? CircularProgressIndicator() :
                        linkFoto != null ? CircleAvatar(
                          radius: 90,
                          backgroundColor: ColorService.azulEscuro,
                          child: CircleAvatar(
                            radius: 88,
                            backgroundImage: NetworkImage(linkFoto!),
                          ),
                        ):
                        _storedImage != null
                            ? CircleAvatar(
                          radius: 90,
                          backgroundColor: ColorService.azulEscuro,
                              child: CircleAvatar(
                          radius: 88,
                          backgroundImage: FileImage(_storedImage!),
                        ),
                            )
                            : CircleAvatar(
                          radius: 90,
                          backgroundColor: ColorService.azulEscuro,
                              child: CircleAvatar(
                          backgroundColor: ColorService.cinza,
                          radius: 88,
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
                            ),
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
                        user.imagemUrl = linkFoto;
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
