import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Utils/ColorsService.dart';

class EdicaoFotoScreen extends StatefulWidget {
  final File? imagePerfil;
  final String? nome;

  const EdicaoFotoScreen(this.imagePerfil, this.nome);

  @override
  State<EdicaoFotoScreen> createState() => _EdicaoFotoScreenState();
}

class _EdicaoFotoScreenState extends State<EdicaoFotoScreen> {
  File? _storedImage;
  File? _oldImage;
  String? nome;
  bool editedImage = false;

  @override
  void initState() {
    _storedImage = widget.imagePerfil;
    _oldImage = widget.imagePerfil;
    nome = widget.nome;
  }

  Future<bool?> _showGeneralDialog() async {
    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black45,
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'Permissão negada',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      decoration: TextDecoration.none),
                ),
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.close_rounded,
                    size: 45,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Não foi possiver acessar a camera ou a galeria',
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      decoration: TextDecoration.none),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 125,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {
                            openAppSettings();
                            Navigator.pop(context);
                            return null;
                          },
                          child: Text('Ir para configurações'),
                        ),
                      ),
                      Container(
                        width: 125,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            return null;
                          },
                          child: Text(
                              'Continue sem foto'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }


  Future<File?> _imagecropper(File image) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Edite sua foto',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _storedImage = File(croppedFile.path);
        editedImage = true;
      });
    }

    return _storedImage;
  }

  _takePicture() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      var result = await Permission.camera.request();

      if (result != PermissionStatus.granted) {
        if (await _showGeneralDialog() == null) {
          return null;
        }
      }
    }
    final ImagePicker _picker = ImagePicker();
    XFile? imageFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 200,
    );


    if (imageFile != null) {
      setState(() {
        _storedImage = File(imageFile.path);
        editedImage = true;
      });
    }
  }

  _getImage() async {
    var status = await Permission.storage.status;

    if (status.isDenied) {
      var result = await Permission.storage.request();
      if (result != PermissionStatus.granted) {
        return _showGeneralDialog();
      }
    }
    final ImagePicker _picker = ImagePicker();
    XFile? imageFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
    );
    if (imageFile != null) {
      setState(() {
        _storedImage = File(imageFile.path);
        editedImage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        fixedColor: Colors.white,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,

        items:  [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              label:  'Editar'),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
            label: 'Adicionar foto',
          ),
        ],
        onTap: (pagina) {
          if (pagina == 1) {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(
                            Icons.photo,
                          ),
                          title:
                          Text('Escolher foto'),
                          onTap: () async {
                            await _getImage();
                            print(_storedImage);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.camera_alt,
                          ),
                          title: Text('Tirar foto'),
                          onTap: () async {
                            await _takePicture();
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.clear,
                            color: Colors.red,
                          ),
                          title: Text('Apagar foto',
                              style: TextStyle(color: Colors.red)),
                          onTap: () {
                            setState(() {
                              if (_storedImage != null) {
                                _storedImage = null;
                                editedImage = true;
                              }
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                });
          } else {
            if (_storedImage == null) {
              Fluttertoast.showToast(
                  msg: 'Nao existe foto para ser editada',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  fontSize: 16.0);
            } else {
              _imagecropper(_storedImage!);
            }
          }
        },
        // backgroundColor: Colors.grey[100],
      ),
      appBar: AppBar(
        title: Text('Foto de perfil'),
        backgroundColor: Colors.black,
        bottomOpacity: 0.0,
        elevation: 0.0,
        actions: [
          if (editedImage)
            IconButton(
                onPressed: () {
                  Navigator.pop(context, _storedImage);
                },
                icon: const Icon(Icons.check))
        ],
        leading: Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.height * 0.01,
                bottom: MediaQuery.of(context).size.height * 0.01),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context, _oldImage);
              },
              icon: const Icon(Icons.close),
              color: Colors.white,
            )),
      ),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _storedImage != null
                ? CircleAvatar(
              radius: 150,
              backgroundImage: FileImage(_storedImage!),
            )
                : ProfilePicture(name: nome!, radius: 150, fontsize: 50)
          ])
        ],
      ),
    );
  }
}
