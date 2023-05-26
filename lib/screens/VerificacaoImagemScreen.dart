import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import '../Utils/ColorsService.dart';
import '../models/Auth.dart';

class VerificacaoImagemScreen extends StatefulWidget {
  final File? imagePerfil;
  final String conversationid;

  const VerificacaoImagemScreen({required this.imagePerfil,required this.conversationid});

  @override
  State<VerificacaoImagemScreen> createState() => _VerificacaoImagemScreenState();
}

class _VerificacaoImagemScreenState extends State<VerificacaoImagemScreen> {
  File? _storedImage;
  String? nome;
  bool editedImage = false;


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

  @override
  void initState() {
    _storedImage = widget.imagePerfil;
  }




  @override
  Widget build(BuildContext context) {

    Auth auth = Provider.of<Auth>(context, listen: false);

    Future<void> addMessageToConversation(String conversationId, Map<String, dynamic> messageData) async {
      final store = FirebaseFirestore.instance;
      final messagesRef = store.collection('conversations').doc(conversationId).collection('messages');
      await messagesRef.add(messageData);
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic> messageData = {
            'sender': auth.token,
            'text': await uploadFile(_storedImage!),
            'timestamp': DateTime.now(),
          };
       await   addMessageToConversation(widget.conversationid,messageData).whenComplete(() =>  Navigator.pop(context,null));
         
          },
        backgroundColor: ColorService.azulEscuro,
        child: const Icon(Icons.send),
      ),
      appBar: AppBar(

        backgroundColor: Colors.black,
        bottomOpacity: 0.0,
        elevation: 0.0,
        leading: Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.height * 0.01,
                bottom: MediaQuery.of(context).size.height * 0.01),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context, null);
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
            Image.file(_storedImage!,height: MediaQuery.of(context).size.height *0.8,width:MediaQuery.of(context).size.width,),
          ])
        ],
      ),
    );
  }
}
