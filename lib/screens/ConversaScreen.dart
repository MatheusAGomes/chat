import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chat/Utils/constants.dart';
import 'package:chat/Utils/toastService.dart';
import 'package:chat/screens/EdicaoFotoScreen.dart';
import 'package:chat/screens/VerificacaoImagemScreen.dart';
import 'package:chat/screens/VerificacaoScreen.dart';
import 'package:chat/screens/telefoneCadastroScreen.dart';
import 'package:chat/widgets/buttonAlternativo.dart';
import 'package:chat/widgets/buttonPadrao.dart';
import 'package:chat/widgets/textfieldpadrao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path/path.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState(){
    super.initState();
    initRecorder();
  }
  @override
  void dispose(){
    recorder.closeRecorder();
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

    Future record() async{
      if(!isRercorderReady) return;
      await recorder.startRecorder(toFile: gerarNumeroAleatorio());
    }

    Future stop() async{
      if(!isRercorderReady) return;
      final path = await recorder.stopRecorder();
      final audioFile = File(path!);

      print('recorded audio : ${audioFile}');

     String a = await uploadFile(audioFile);
     print(a);
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
                      itemBuilder: (BuildContext context, int index) {
                        dynamic data =
                        snapshot.data!.docs[index].data();
                        bool isCurrentUser = data['sender'] == auth.token;
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: isCurrentUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              isLink(data['text']) ?  Container(
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
                              ):
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
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
                recording ? Row(
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
                              await Navigator.pushReplacement(
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
                              await Navigator.pushReplacement(
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
                      await Navigator.pushReplacement(
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
                    await Navigator.pushReplacement(
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
