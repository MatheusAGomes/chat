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




  @override
  void initState() {


    _controller = VideoPlayerController.network(widget.videoEnvio!)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
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
    return Scaffold(
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
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height *0.5,

                child: InkWell(onTap: (){
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },child: VideoPlayer(_controller)))
          ]),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: VideoProgressIndicator(_controller, allowScrubbing: true,colors: VideoProgressColors(backgroundColor: Colors.white,playedColor: ColorService.azulEscuro),))
        ],
      ),
    );
  }
}
