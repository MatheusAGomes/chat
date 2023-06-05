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

class playerVideoScreen extends StatefulWidget {
  final String? videoEnvio;

  const playerVideoScreen({required this.videoEnvio});

  @override
  State<playerVideoScreen> createState() => _playerVideoScreenState();
}

class _playerVideoScreenState extends State<playerVideoScreen> {
  File? _storedImage;

  late VideoPlayerController _controller;

  bool _isPlaying = false;
  Duration _videoDuration = Duration.zero;
  Duration _videoPosition = Duration.zero;
  @override
  void initState() {


    _controller = VideoPlayerController.network(widget.videoEnvio!);
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
  void dispose() {
    _controller.dispose(); // Certifique-se de liberar o controlador ao sair da tela
    super.dispose();
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
      backgroundColor: Colors.black,
      body:
          Stack(
            children: [SizedBox(
                width: MediaQuery.of(context).size.width ,
                height: MediaQuery.of(context).size.height,

                child: InkWell(onTap: (){
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },child: VideoPlayer(_controller))),

              Positioned(top: 700,left:20,child: Text("${videoPosition}",style: TextStyle(color: Colors.white),)),
              Positioned(top: 700,left:340,child: Text("${videoDuration}",style: TextStyle(color: Colors.white),)),

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
              Positioned(
        left: 40,
                top: 650,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 25,child: IconButton(onPressed: (){
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    }, icon: _isPlaying ? Icon(Icons.pause,size: 30,) :Icon(Icons.play_arrow,size: 30,))),
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
