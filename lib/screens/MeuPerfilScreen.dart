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
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:validatorless/validatorless.dart';

import '../Utils/ColorsService.dart';
import '../Utils/Routes.dart';
import '../Utils/Store.dart';
import '../Utils/utils.dart';
import '../models/Auth.dart';
import '../models/MyPageIndex.dart';
import '../models/Usuario.dart';

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class MeuPerfilScreen extends StatefulWidget {
  MeuPerfilScreen();

  @override
  State<MeuPerfilScreen> createState() => _MeuPerfilScreenState();
}

class _MeuPerfilScreenState extends State<MeuPerfilScreen> {

  GlobalKey<FormFieldState> nomeKey = GlobalKey<FormFieldState>();
  String? fotoPerfil;

  Future<Usuario?>? readData(token) async {
    final response =
        await http.get(Uri.parse('${constants.banco}/users/${token}.json'));

    if (response.statusCode == 200) {
      Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        Usuario user = Usuario(
            imagemUrl: data['imagemUrl'],
            telefoneUsuario: data['telefoneUsuario'],
            nomeUsuario: data['nomeUsuario']);

        fotoPerfil = user.imagemUrl;
        if(fotoPerfil != null)
        {
          _storedImage = null;
        }
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
          'imagemUrl':user.imagemUrl,
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
  bool loading = false;
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
  String? linkFoto;

  @override
  Widget build(BuildContext context) {
    String? Media;
    Auth auth = Provider.of<Auth>(context, listen: false);

    return FutureBuilder(
      future: readData(auth.token),
      builder: (context, snapshot) {

    if(snapshot.hasData)
      {
        if (user == null) {
          user = snapshot.data;
          nomeController.text = user!.nomeUsuario ?? "";
          linkFoto = user?.imagemUrl;
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
                        linkFoto = user?.imagemUrl;
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
                          imagemUrl: linkFoto,
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
                       InkWell(
                          onTap: () async {
                            if(editable == true) {


                              File? foto;
                              if(fotoPerfil != null)
                              {
                                final http.Response response = await http.get(Uri.parse(fotoPerfil!));

                                // Get temporary directory
                                var dir = await getTemporaryDirectory();

                                // Create an image name
                                var filename = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png';

                                // Save to filesystem
                                foto = File(filename);
                                await foto.writeAsBytes(response.bodyBytes);

                              }
                                File? file = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => EdicaoFotoScreen(
                                            foto ?? _storedImage,
                                            nomeController.text)));

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
                              }
                            },
                          child: Stack(clipBehavior: Clip.none, children: [
                            loading ? CircularProgressIndicator() :
                                linkFoto != null ? CircleAvatar(
                              radius: 90,
                              backgroundImage: NetworkImage(linkFoto!),
                            ):
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
