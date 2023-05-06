import 'dart:convert';
import 'dart:io';

import 'package:chat/Utils/constants.dart';
import 'package:chat/Utils/toastService.dart';
import 'package:chat/screens/ConversaScreen.dart';
import 'package:chat/screens/EdicaoFotoScreen.dart';
import 'package:chat/screens/telefoneCadastroScreen.dart';
import 'package:chat/widgets/buttonAlternativo.dart';
import 'package:chat/widgets/buttonPadrao.dart';
import 'package:chat/widgets/textfieldpadrao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../Utils/ColorsService.dart';
import '../Utils/Routes.dart';
import '../Utils/Store.dart';
import '../Utils/utils.dart';
import '../models/Auth.dart';
import '../models/Usuario.dart';

import 'package:brasil_fields/brasil_fields.dart';
class ContatosScreen extends StatefulWidget {
  ContatosScreen();

  @override
  State<ContatosScreen> createState() => _ContatosScreenState();
}

class _ContatosScreenState extends State<ContatosScreen> {
  String removeMascaraTelefone(String telefone) {
    return telefone.replaceAll(RegExp(r'[()\s-]+'), '');
  }




  Future<bool> conversationExists(String conversationId) async {
    final store = FirebaseFirestore.instance;
    final conversationRef = store.collection('conversations').doc(conversationId);
    final conversationSnapshot = await conversationRef.get();

    return conversationSnapshot.exists;
  }


  Future<dynamic> matchDeUsuarios(String telefoneP) async {
    List<Contact> listaDeContatos = await getContacts();
    List<String> telefones =await getAllPhoneNumbers(listaDeContatos);
    print(telefones);
    dynamic users;
    final response = await http.get(Uri.parse('${constants.banco}/users.json'));
    if (response.statusCode == 200) {
      Map<String, dynamic> dataMap = jsonDecode(response.body);
      users = dataMap.entries.map((entry) => Usuario(
          nomeUsuario: entry.value['nomeUsuario'],
          telefoneUsuario: entry.value['telefoneUsuario']
      )).toList();

    } else {
      print('Failed to load data');
    }
    print(users);
    List<dynamic> telefonesDoBanco = users.map((usuario) => usuario.telefoneUsuario).toList();
    print(telefonesDoBanco);

    List<dynamic> match= [];


    for(int i = telefones.length - 1; i >= 0 ; i --)
    {

      if(telefonesDoBanco.contains(telefones[i]))
      {
        print(telefonesDoBanco.indexOf(telefones[i]));
        print(users[2]);
        match.add(users[telefonesDoBanco.indexOf(telefones[i])]);
      }

    }
    match.sort((a, b) => a.nomeUsuario.compareTo(b.nomeUsuario));
   return match;
  }





  Future<List<String>> getAllPhoneNumbers(List<Contact> contacts) async {
    List<String> phoneNumbers = [];
    for (Contact contact in contacts) {
      if (contact.phones!.isNotEmpty) {
        for (Item phone in contact.phones!) {
          phoneNumbers.add(removeMascaraTelefone(phone.value!));
        }
      }
    }
    return phoneNumbers;
  }

 Future<List<Contact>> getContacts() async {

    List<Contact> contacts = await ContactsService.getContacts();
    print(contacts);
    return contacts;

  }



  Future<void> createConversation(String conversationId, String user1, String user2) async {
    try {
      final conversationRef = FirebaseFirestore.instance.collection('conversations').doc(conversationId);

      await conversationRef.set({
        'user1': user1,
        'user2': user2,

      });
    } catch (e) {
      print('Error creating conversation: $e');
      rethrow;
    }
  }


  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context, listen: false);

    return Scaffold(
        appBar:AppBar(
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
            'Contatos',
            style: TextStyle(
                color: ColorService.azulEscuro,
                fontWeight: FontWeight.bold),
          ),

        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
            child: Column(children: [
              FutureBuilder(
              future: matchDeUsuarios(auth.token!),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if(snapshot.data.length > 0)
                    {
                      return RefreshIndicator(
                        onRefresh: () {
                          return matchDeUsuarios(auth.token!);
                        },
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 1,
                          width: MediaQuery.of(context).size.width * 1,
                          child: ListView.builder(

                            itemCount: snapshot.data.length,

                            itemBuilder: (context, index) {
                              Usuario usuario = snapshot.data[index];

                              return ListTile(
                                onTap:()async{
                                  
                                  bool validacao1 = await conversationExists(auth.token!+usuario.telefoneUsuario);
                                  bool validacao2 = await conversationExists(usuario.telefoneUsuario+auth.token!);
                                  String? idDaConversa;
                                  if(!validacao2 && !validacao1)
                                    {
                                    await createConversation(auth.token!+usuario.telefoneUsuario,auth.token!,usuario.telefoneUsuario);
                                    idDaConversa = auth.token!+usuario.telefoneUsuario;
                                    }
                                  else
                                    {
                                      if(validacao2)
                                        {
                                          idDaConversa = usuario.telefoneUsuario+auth.token!;
                                        }
                                      else
                                        {
                                          idDaConversa = auth.token!+usuario.telefoneUsuario;
                                        }
                                    }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ConversasScreen(
                                                usuarioDestinatario: usuario,idConversa: idDaConversa!,)),
                                  );
                              },
                                leading: usuario.imagemUrl != null
                                    ? CircleAvatar(
                                  backgroundImage: NetworkImage(usuario.nomeUsuario!),
                                )
                                    : CircleAvatar(
                                  child: Text(
                                    usuario.nomeUsuario!
                                        .split(' ')
                                        .map((word) => word[0])
                                        .join(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                                title: Text(snapshot.data[index].nomeUsuario ?? ''),
                                subtitle: Text(UtilBrasilFields.obterTelefone(snapshot.data[index].telefoneUsuario)),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  else
                    {
                      return  RefreshIndicator(
                        onRefresh: (){
                        return  matchDeUsuarios(auth.token!);
                        },
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          width: MediaQuery.of(context).size.width ,
                          child:  Center(child: Text('Você não há contatos em sua agenda'),
                          ),
                        ),
                      );
                    }

                }
              }),
            ]),
          ),
        ));
  }
}
