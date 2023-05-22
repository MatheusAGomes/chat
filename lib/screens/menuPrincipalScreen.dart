import 'dart:convert';

import 'package:chat/widgets/buttonAlternativo.dart';
import 'package:chat/widgets/buttonPadrao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import '../Utils/ColorsService.dart';
import '../Utils/Routes.dart';
import '../models/Auth.dart';
import '../models/Usuario.dart';
import 'package:http/http.dart' as http;
import 'package:chat/Utils/constants.dart';
import 'package:intl/intl.dart';
import 'ConversaScreen.dart';

class MenuPrincipalScreen extends StatefulWidget {
  const MenuPrincipalScreen({super.key});

  @override
  State<MenuPrincipalScreen> createState() => _MenuPrincipalScreenState();
}

class _MenuPrincipalScreenState extends State<MenuPrincipalScreen> {
  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context, listen: false);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Future<List<DocumentSnapshot>> getCollectionData() async {
      QuerySnapshot querySnapshot  = await firestore.collection('conversations').get();
      return querySnapshot.docs;
    }

    Future<Usuario> getUsuario(idUser)async {
      final response =
      await http.get(Uri.parse('${constants.banco}/users/${idUser}.json'));
      Usuario usuario;


      if (response.statusCode == 200) {
        // dados foram obtidos com sucesso

        Map<String, dynamic>? data = json.decode(response.body);
        if(data != null){

          usuario = Usuario(
                  imagemUrl: data['imagemUrl'],
                  telefoneUsuario: data['telefoneUsuario'],
                  nomeUsuario: data['nomeUsuario']);
          return usuario;
        }

      } else {
        // houve um erro ao obter os dados
        print('Erro ao obter dados: ${response.statusCode}');
      }
      return Usuario(telefoneUsuario: 'default');

    }

    String conversao(timestamp){
      DateTime dateTime = timestamp.toDate();
      DateTime now = DateTime.now();
      DateTime messageTime = timestamp.toDate();

      String time;
      if (now.difference(messageTime).inHours < 24) {
        // Exibir apenas a hora se a diferença for menor que 24 horas
        time = DateFormat.Hm().format(messageTime);
      } else {
        // Exibir dia e mês completos se a diferença for maior que 24 horas
        time = DateFormat('dd/MM').format(messageTime);
      }
      return time;
    }

    Future<Map<String, dynamic>?> getLastMessage(String idConversation) async {
      // Obtenha a referência da coleção de mensagens
      CollectionReference messagesRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(idConversation)
          .collection('messages');

      // Consulte as mensagens ordenando por data de envio em ordem decrescente
      QuerySnapshot querySnapshot = await messagesRef
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      // Verifique se há resultados
      if (querySnapshot.docs.isNotEmpty) {
        // Obtenha a última mensagem da lista de documentos retornados
        DocumentSnapshot lastMessage = querySnapshot.docs.first;

        Map<String, dynamic>? lastMessageData = lastMessage.data() as Map<String, dynamic>?;

        // Retorna os dados da última mensagem
        return lastMessageData ?? {};
        return lastMessageData;
      } else {
        // Caso não haja nenhuma mensagem na conversa, retorne null ou um valor indicativo de ausência
        return null;
      }
    }    return Scaffold(appBar: AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      bottomOpacity: 0.0,
      elevation: 0.0,
      leading: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.01),
      ),
      title: Text(
        //auth.authDecoded!['name'],
        'Conversas',
        style: TextStyle(
            color: ColorService.azulEscuro,
            fontWeight: FontWeight.bold),
      ),

    ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                FutureBuilder<dynamic>(
                  future:
                    getCollectionData(), //Future that returns bool

                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(width: MediaQuery.of(context).size.width *0.1,
                            child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Erro: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      List<DocumentSnapshot> documents = snapshot.data!;
                      // Aqui você pode usar os dados para popular a sua interface gráfica
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 1,
                        width: MediaQuery.of(context).size.width * 1,
                        child: ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot document = documents[index];
                            // Faça algo com cada documento, por exemplo:

                            if(document['user1'] == auth.token)
                              {
                                return FutureBuilder<List<dynamic>>(
                                 // future: getLastMessage(document['user1']+document['user2']),
                                    future: Future.wait([ getLastMessage(document['user1']+document['user2']),getUsuario(document['user2'])]),
                                  builder: (context,   AsyncSnapshot<dynamic> snapshot,) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return SizedBox();
                              // return Center(
                              //   child: SizedBox(
                              //       width: MediaQuery.of(context).size.width *0.1,
                              //         child: CircularProgressIndicator()),
                              // );
                              } else if (snapshot.hasError) {
                              return Text('Erro: ${snapshot.error}');
                              } else if (snapshot.hasData)  {
                                      Usuario usuario = snapshot.data![1];
                                      dynamic data =  snapshot.data![0];
                                      if(data != null && usuario !=null) {
                                        return SizedBox(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ConversasScreen(
                                                          usuarioDestinatario:
                                                              usuario,
                                                          idConversa: document[
                                                                  'user1'] +
                                                              document[
                                                                  'user2']!,
                                                        )),
                                              );
                                            },
                                            child: ListTile(
                                              leading: usuario.imagemUrl != null
                                                  ? CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(usuario
                                                              .imagemUrl!),
                                                    )
                                                  : CircleAvatar(
                                                      child: Text(
                                                        usuario.nomeUsuario!
                                                            .split(' ')
                                                            .map((word) =>
                                                                word[0])
                                                            .join(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.blue,
                                                    ),
                                              title: Text(usuario.nomeUsuario
                                                  .toString()),
                                              subtitle: Text(data['text']),
                                              trailing: Text(
                                                  conversao(data['timestamp'])),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                    return SizedBox();
                                  }
                              );
                              }
                            if(document['user2'] == auth.token)
                            {
                              return FutureBuilder<List<dynamic>>(
                                // future: getLastMessage(document['user1']+document['user2']),
                                  future: Future.wait([ getLastMessage(document['user1']+document['user2']),getUsuario(document['user1'])]),
                                  builder: (context,   AsyncSnapshot<dynamic> snapshot,) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return SizedBox();

                                      // return Center(
                                      //   child: SizedBox(
                                      //       width: MediaQuery.of(context).size.width *0.1,
                                      //
                                      //       child: CircularProgressIndicator()),
                                      // );
                                    } else if (snapshot.hasError) {
                                      return Text('Erro: ${snapshot.error}');
                                    } else if (snapshot.hasData)  {
                                      Usuario usuario = snapshot.data![1];
                                      dynamic data =  snapshot.data![0];
                                      if(data != null && usuario !=null) {
                                        return SizedBox(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ConversasScreen(
                                                          usuarioDestinatario:
                                                              usuario,
                                                          idConversa: document[
                                                                  'user1'] +
                                                              document[
                                                                  'user2']!,
                                                        )),
                                              );
                                            },
                                            child: ListTile(
                                              leading: usuario.imagemUrl != null
                                                  ? CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(usuario
                                                              .imagemUrl!),
                                                    )
                                                  : CircleAvatar(
                                                      child: Text(
                                                        usuario.nomeUsuario!
                                                            .split(' ')
                                                            .map((word) =>
                                                                word[0])
                                                            .join(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.blue,
                                                    ),
                                              title: Text(usuario.nomeUsuario
                                                  .toString()),
                                              subtitle: Text(data['text']),
                                              trailing: Text(
                                                  conversao(data['timestamp'])),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                    return SizedBox();
                                  }
                              );
                            }
                            return SizedBox();

                          },
                        ),
                      );
                    } else {
                      return Text('Nenhum dado encontrado.');
                    }
                  },
                ),

              ],
            ),
          ),
        )
    );
  }
}
