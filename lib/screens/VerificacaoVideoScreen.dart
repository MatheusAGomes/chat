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
import 'package:video_player/video_player.dart';
import '../Utils/ColorsService.dart';
import '../models/Auth.dart';

class VerificacaoVideoScreen extends StatefulWidget {
  final File? videoEnvio;
  final String conversationid;

  const VerificacaoVideoScreen({required this.videoEnvio,required this.conversationid});

  @override
  State<VerificacaoVideoScreen> createState() => _VerificacaoVideoScreenState();
}

class _VerificacaoVideoScreenState extends State<VerificacaoVideoScreen> {
  File? _storedImage;
  String? nome;
  bool editedImage = false;
  bool _isPlaying = false;
  Duration _videoDuration = Duration.zero;
  Duration _videoPosition = Duration.zero;

  late VideoPlayerController _controller;


  Future<String> uploadFile(File file) async {
    String fileName = basename(file.path+'video');

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


    _controller = VideoPlayerController.file(widget.videoEnvio!);
    _controller.initialize().then((_) {
      setState(() {
        _videoDuration = _controller.value.duration;
      });

      // Adicione um ouvinte para atualizar a posição do vídeo conforme ele é reproduzido
      _controller.addListener(() {
        final bool isPlaying = _controller.value.isPlaying;

        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
        setState(() {
          _videoPosition = _controller.value.position;
        });
      });
    });
  }




  @override
  Widget build(BuildContext context) {

    Auth auth = Provider.of<Auth>(context, listen: false);

    Future<void> addMessageToConversation(String conversationId, Map<String, dynamic> messageData) async {
      final store = FirebaseFirestore.instance;
      final messagesRef = store.collection('conversations').doc(conversationId).collection('messages');
      await messagesRef.add(messageData);
    }

    String videoPosition = _videoPosition != null
        ? _videoPosition.inMinutes.toString() + ':' + (_videoPosition.inSeconds % 60).toString().padLeft(2, '0')
        : '00:00';
    String videoDuration = _videoDuration != null
        ? _videoDuration.inMinutes.toString() + ':' + (_videoDuration.inSeconds % 60).toString().padLeft(2, '0')
        : '00:00';
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic> messageData = {
            'sender': auth.token,
            'text': await uploadFile(widget.videoEnvio!),
            'timestamp': DateTime.now(),
          };
          await   addMessageToConversation(widget.conversationid,messageData).whenComplete(() =>  Navigator.pop(context,null));

        },
        backgroundColor: ColorService.azulEscuro,
        child: const Icon(Icons.send),
      ),
      backgroundColor: Colors.black,

      // IconButton(
      //   onPressed: () {
      //     Navigator.pop(context, null);
      //   },
      //   icon: const Icon(Icons.close),
      //   color: Colors.white,
      // )
      body:
          Stack(
            children: [

              SizedBox(
                width: MediaQuery.of(context).size.width ,
                height: MediaQuery.of(context).size.height,

                child: InkWell(onTap: (){
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },child: VideoPlayer(_controller))),

            Positioned(
              top: 20,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context, null);
                },
                icon: const Icon(Icons.close),
                color: Colors.white,
              ),
            ),
              Positioned(top: 640,left:20,child: Text("${videoPosition}",style: TextStyle(color: Colors.white),)),
              Positioned(top:640,left:340,child: Text("${videoDuration}",style: TextStyle(color: Colors.white),)),

              Positioned(
                left: 40,
                top: 590,
                child: Column(
                  children: [
                    CircleAvatar(radius: 25,child: IconButton(onPressed: (){
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    }, icon:  _isPlaying ? Icon(Icons.pause,size: 30,) :Icon(Icons.play_arrow,size: 30,))),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: VideoProgressIndicator(_controller, allowScrubbing: true,colors: VideoProgressColors(backgroundColor: Colors.white,playedColor: ColorService.azulEscuro),)),
                  ],
                ),
              )
            ],
          ),

    );
  }
}
