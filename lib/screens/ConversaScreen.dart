import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat/Utils/constants.dart';

import 'package:chat/screens/VerificacaoImagemScreen.dart';
import 'package:chat/screens/VerificacaoVideoScreen.dart';
import 'package:chat/screens/playerVideoScreen.dart';
import 'package:just_audio/just_audio.dart' as gabiarra;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers_platform_interface/src/api/player_state.dart' as playerstate;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path/path.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../Utils/ColorsService.dart';
import '../Utils/Routes.dart';
import '../Utils/Store.dart';
import '../Utils/utils.dart';
import '../models/Auth.dart';
import '../models/Usuario.dart';

import 'package:brasil_fields/brasil_fields.dart';
class ConversasScreen extends StatefulWidget {
  final Usuario usuarioDestinatario;
  final String idConversa;

  ConversasScreen({required this.usuarioDestinatario,required this.idConversa});

  @override
  State<ConversasScreen> createState() => _ConversasScreenState();
}

class _ConversasScreenState extends State<ConversasScreen> {
  bool tocandoAudio =false;
  bool tocando =false;
  final player = AudioPlayer();
  Duration position = Duration.zero;
  Duration max = Duration.zero;
  int quantidadeDeAudios = 0;
  @override
  void initState(){
    super.initState();
    initRecorder();
    player.onPlayerStateChanged.listen((event) {
      print(event);
      if(event == playerstate.PlayerState.playing)
        {
            tocando = true;
        }
      else
        {
            tocando = false;
        }

      if(event == playerstate.PlayerState.completed)
        {
          setState(() {
            position = Duration.zero;
          });
        }
    });

    player.onPositionChanged.listen((valor) {

        setState(() {
          position = valor;
        });

    });

    player.onDurationChanged.listen((event) {
      setState(() {
       max = event;
      });
    });
  }
  @override
  void dispose(){
    recorder.closeRecorder();
    player.dispose();
    super.dispose();
  }

  bool isRercorderReady = false;
  bool recording = false;


  Future initRecorder() async{
    final status = await Permission.microphone.request();
    if(status != PermissionStatus.granted){
      throw 'Microphone permission not granted';
    }
    await recorder.openRecorder();
    isRercorderReady = true;
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  File? _storedImage;
  final recorder = FlutterSoundRecorder();

  bool urlContainsMp3(String url) {
    return url.toLowerCase().contains('audio');
  }
  bool urlContainVideo(String url) {
    return url.toLowerCase().contains('video');
  }
  final _controller = StreamController<dynamic>();
  final _messageController =  TextEditingController();







  // Future<void> enviarMensagem(String idConversa, String idRemetente, String mensagem) async {
  //
  //   final responseCon= await http.get(Uri.parse("${constants.banco}/conversas/$idConversa.json"));
  //   final conversaData = jsonDecode(responseCon.body);
  //
  //   int contadorMensagens = conversaData['mensagens'] != null ? conversaData['mensagens'].length : 0;
  //
  //
  //   final url = '${constants.banco}/conversas/$idConversa/mensagens/$contadorMensagens.json';
  //
  //   final response = await http.put(
  //     Uri.parse(url),
  //     body: json.encode({
  //       'remetente': idRemetente,
  //       'mensagem': mensagem,
  //     }),
  //   );
  //   if (response.statusCode != 200) {
  //     throw Exception('Erro ao enviar mensagem');
  //   }
  // }

  Future<void> addMessageToConversation(String conversationId, Map<String, dynamic> messageData) async {
    final store = FirebaseFirestore.instance;
    final messagesRef = store.collection('conversations').doc(conversationId).collection('messages');

    await messagesRef.add(messageData);
  }





  StreamController<List<Map<String, dynamic>>> _streamController =
  StreamController<List<Map<String, dynamic>>>();




  Stream<dynamic> getConversaDataStream(String idConversa) {
    final stream = http.get(
      Uri.parse("${constants.banco}/conversas/$idConversa.json"),
    ).asStream().map((response) {
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Falha ao carregar dados da conversa");
      }
    });

    return stream;
  }


  bool isLink(String text) {
    // Expressão regular para verificar se o texto é um link
    final RegExp regex = RegExp(
      r"^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$",
      caseSensitive: false,
      multiLine: false,
    );

    // Verifica se o texto corresponde à expressão regular
    return regex.hasMatch(text);
  }
  Future<File?> downloadAudio(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDocumentsDir.path}/audio.mp4';
      quantidadeDeAudios++;
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      print('Áudio baixado e salvo em: $filePath');
      return file;

    } else {
      print('Falha ao baixar o áudio. Código de status: ${response.statusCode}');
    }
  }


  @override
  Widget build(BuildContext context) {

    String gerarNumeroAleatorio() {
      Random random = Random();
      int numero = random.nextInt(100); // Define o limite superior como 100 (exclusivo)

      return numero.toString();
    }

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
    Auth auth = Provider.of<Auth>(context, listen: false);
    Stream<dynamic> conversas = getConversaDataStream(widget.idConversa);
    _takePicture() async {

      final ImagePicker _picker = ImagePicker();
      XFile? imageFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      );


      if (imageFile != null) {
        setState(() {
          _storedImage = File(imageFile.path);
        });
      }
    }

    _getImage() async {

      final ImagePicker _picker = ImagePicker();
      XFile? imageFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      );
      if (imageFile != null) {
        setState(() {
          _storedImage = File(imageFile.path);
        });
      }
    }
    _takeVideo() async {

      final ImagePicker _picker = ImagePicker();
      XFile? imageFile = await _picker.pickVideo(
        source: ImageSource.camera,
      );


      if (imageFile != null) {
        setState(() {
          _storedImage = File(imageFile.path);
        });
      }
    }

    _getVideo() async {

      final ImagePicker _picker = ImagePicker();
      XFile? imageFile = await _picker.pickVideo(
        source: ImageSource.gallery,

      );
      if (imageFile != null) {
        setState(() {
          _storedImage = File(imageFile.path);
        });
      }
    }


    Future record() async{
      if(!isRercorderReady) return;
      String fileName = gerarNumeroAleatorio() + 'audio.mp4';

      await recorder.startRecorder(toFile: fileName,);
    }
  String formatTime(Duration duration){
      String twoDigts(int i) => i.toString().padLeft(2,'0');
      final hours = twoDigts(duration.inHours);
      final minutes = twoDigts(duration.inMinutes.remainder(60));
      final seconds = twoDigts(duration.inSeconds.remainder(60));

      return [if(duration.inHours > 0)hours,minutes,seconds ].join(':');
  }
    Future stop() async{
      if(!isRercorderReady) return;
      final path = await recorder.stopRecorder();
      Directory appDocDirectory = await getApplicationDocumentsDirectory();

      final audioFile = File(path!);

      print('recorded audio : ${audioFile}');

      String a = await uploadFile(audioFile);

      Map<String, dynamic> messageData = {
        'sender': auth.token,
        'text': a,
        'timestamp': DateTime.now(),
      };
      addMessageToConversation(widget.idConversa, messageData);

    }

    Future<void> downloadFile(String url, String savePath) async {
      final response = await http.get(Uri.parse(url));
      final file = File(savePath);

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print('Arquivo baixado e salvo em: $savePath');
      } else {
        print('Falha ao baixar o arquivo. Código de status: ${response.statusCode}');
      }
    }


    return Scaffold(
        appBar:AppBar(

          centerTitle: true,
          backgroundColor: Colors.transparent,
          bottomOpacity: 0.0,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: ColorService.azulEscuro,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            //auth.authDecoded!['name'],
            widget.usuarioDestinatario.nomeUsuario ?? "Contato",
            style: TextStyle(
                color: ColorService.azulEscuro,
                fontWeight: FontWeight.bold),
          ),


        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children:  [
            SizedBox(
              height: MediaQuery.of(context).size.height *0.80,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(widget.idConversa)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (BuildContext context, int index)  {
                        dynamic data =
                        snapshot.data!.docs[index].data();
                        bool isCurrentUser = data['sender'] == auth.token;

                        final  _controllerVideo = VideoPlayerController.network(data['text']);

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: isCurrentUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              isLink(data['text']) == false ?
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? ColorService.azulEscuro
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: isCurrentUser
                                        ? Radius.circular(20)
                                        : Radius.circular(0),
                                    bottomRight: isCurrentUser
                                        ? Radius.circular(0)
                                        : Radius.circular(20),
                                  ),
                                ),
                                child:  data['text'].length > 40 ? SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.55 ,
                                  child: Text(
                                    data['text'],
                                    style: TextStyle(
                                      color: isCurrentUser ? Colors.white : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ):Text(
                                  data['text'],
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ) :
                              urlContainsMp3(data['text']) == false ?
                              urlContainVideo(data['text']) == false ?
                              Container(
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? ColorService.azulEscuro
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: isCurrentUser
                                        ? const Radius.circular(20)
                                        : const Radius.circular(0),
                                    bottomRight: isCurrentUser
                                        ? const Radius.circular(0)
                                        : const Radius.circular(20),
                                  ),
                                ),
                                child:  Image.network(data['text'],width: MediaQuery.of(context).size.width * 0.65,height: MediaQuery.of(context).size.height * 0.3,),
                              ) :

                              Container(
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? ColorService.azulEscuro
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: isCurrentUser
                                        ? const Radius.circular(20)
                                        : const Radius.circular(0),
                                    bottomRight: isCurrentUser
                                        ? const Radius.circular(0)
                                        : const Radius.circular(20),
                                  ),
                                ),
                                child:  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.65,
                                    height: MediaQuery.of(context).size.height * 0.3,
                                    child: Center(
                                      child: FutureBuilder(builder:(context, snapshot) {
                                        if(snapshot.connectionState != ConnectionState.waiting ) {
                                          return   Stack(children: [Center(child: Image.file(File(snapshot.data!))),  Align(alignment: Alignment.center,child: IconButton(icon: Icon(Icons.play_arrow,size: 50,color: Colors.white,),onPressed: () async{
                                            await Navigator.push(
                                                context,MaterialPageRoute(builder: (context) => playerVideoScreen(videoEnvio: data['text'])) );
                                          },))],);
                                        }
                                        else
                                        {
                                          return CircularProgressIndicator();
                                        }
                                      },future: VideoThumbnail.thumbnailFile(video: data['text']),),
                                    )),
                                )

                               :Container(
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? ColorService.azulEscuro
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: isCurrentUser
                                        ? const Radius.circular(20)
                                        : const Radius.circular(0),
                                    bottomRight: isCurrentUser
                                        ? const Radius.circular(0)
                                        : const Radius.circular(20),
                                  ),
                                ),
                                child:  SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: Row(
                                    children: [
                                      tocando ? IconButton(icon: Icon(Icons.pause,color: Colors.white,),onPressed: () async {
                                        File? teste = await  downloadAudio(data['text']);
                                        setState(() {
                                          tocando = false;
                                        });
                                        await player.pause();

                                      }) :  IconButton(icon: Icon(Icons.play_arrow,color: Colors.white,),onPressed: () async {

                                        if(player.state == playerstate.PlayerState.stopped || player.state == playerstate.PlayerState.completed) {

                                          File?
                                          teste =
                                          await downloadAudio(data['text']);;

                                          await player
                                              .play(DeviceFileSource(teste!
                                              .path))
                                          ;


                                        }
                                        else
                                        {
                                          player.resume();
                                        }
                                      }),
                                      SizedBox(
                                        width:MediaQuery.of(context).size.width * 0.37,
                                        child: Slider(activeColor: Colors.white,thumbColor: Colors.white,inactiveColor: Colors.white,min: 0,max: max.inSeconds.toDouble(),value: position.inSeconds.toDouble(),
                                          onChanged: (value) async {
                                            final position = Duration(seconds: value.toInt());
                                            await player.seek(position);
                                            await player.resume();
                                          },),
                                      )
                                      //   Text(formatTime(position),style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              )
                              // FutureBuilder<File?>(
                              //   future: downloadAudio(data['text']),
                              //     builder: (context, snapshot) {
                              //
                              //
                              //
                              //
                              //               return ;
                              //
                              //
                              //
                              //     },
                              //   )

                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
                recording ? StreamBuilder(
                  stream: recorder.onProgress,
                  builder: (context, snapshot) {
              final duration = snapshot.hasData ? snapshot.data!.duration:Duration.zero;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:  [
                        Expanded(
                          child: Center(child: Text(formatTime(duration))),
                        ),
                        IconButton(onPressed: ()async{
                          if(recorder.isRecording)
                          {
                            setState(() {
                              recording = false;
                            });
                            await stop();
                          }
                          else{
                            setState(() {
                              recording = true;
                            });
                            await record();
                          }

                        }, icon: Icon(Icons.mic_rounded),color: recording ? Colors.red: Colors.black),
                      ],
                    );
                  }
                ) : Row(
        children:  [
             Expanded(
              child: TextField(

                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Enviar mensagem...',
                ),

              ),
            ),
            IconButton(onPressed: ()async{
              if(recorder.isRecording)
                {
                  setState(() {
                    recording = false;
                  });
                  await stop();
                }
              else{
                setState(() {
                  recording = true;
                });
                await record();
              }

            }, icon: Icon(Icons.mic_rounded),color: recording ? Colors.red: Colors.black),
            IconButton(onPressed: (){
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height *0.76, 0, 0),
                items: [
                  PopupMenuItem(
                    onTap: ()async{
                      await _takePicture();
                      await Navigator.push(
                          context,MaterialPageRoute(builder: (context) =>VerificacaoImagemScreen(imagePerfil: _storedImage,conversationid: widget.idConversa,)) );
                    },
                    value: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tirar foto'),
                        Icon(Icons.camera_alt),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () async{
                     await _getImage();
                    await Navigator.push(
                       context,MaterialPageRoute(builder: (context) => VerificacaoImagemScreen(imagePerfil: _storedImage,conversationid: widget.idConversa,)) );
                      
                    },
                    value: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Galeria'),
                        Icon(Icons.image),
                      ],
                    ),
                  ),

                  PopupMenuItem(
                    onTap: () async{
                      await _takeVideo();
                      await Navigator.push(
                          context,MaterialPageRoute(builder: (context) => VerificacaoVideoScreen(videoEnvio: _storedImage,conversationid: widget.idConversa,)) );

                    },
                    value: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Grave um vídeo'),
                        Icon(Icons.emergency_recording),
                      ],
                    ),
                  ),

                  PopupMenuItem(
                    onTap: () async{
                      await _getVideo();
                      await Navigator.push(
                          context,MaterialPageRoute(builder: (context) => VerificacaoVideoScreen(videoEnvio: _storedImage,conversationid: widget.idConversa,)) );

                    },
                    value: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Video da galeria'),
                        Icon(Icons.image),
                      ],
                    ),
                  ),

                ],
                elevation: 0.0,
              );
            }, icon: Icon(Icons.attach_file)),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if(_messageController.text.isNotEmpty)
                  {
                    Map<String, dynamic> messageData = {
                      'sender': auth.token,
                      'text': _messageController.text,
                      'timestamp': DateTime.now(),
                    };
                    addMessageToConversation(widget.idConversa, messageData);
                    _messageController.text = '';
                  }
                setState(() {
                  conversas = getConversaDataStream(widget.idConversa);
                });
            },

            ),
        ],
      ),
              ],
            ),
          ),
        ));

  }
}
