import 'package:chat/screens/menuPrincipalScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../Utils/ColorsService.dart';
import '../models/MyPageIndex.dart';
import 'ContatosScreen.dart';
import 'MeuPerfilScreen.dart';



class EstruturasScreen extends StatefulWidget {
  int pagina;
  int? paginaAtual;
  EstruturasScreen({this.pagina = 1});
  @override
  _EstruturasScreenState createState() => _EstruturasScreenState();
}

class _EstruturasScreenState extends State<EstruturasScreen> {

  late int paginaAtual;
  late PageController pc;
  @override
  initState()  {
    paginaAtual = widget.pagina;
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  setPaginaAtual(pagina) {
    setState(() {
      paginaAtual = pagina;
    });
  }


  @override
  Widget build(BuildContext context) {
    var myPageController = Provider.of<MyPageIndexProvider>(context);
    pc = PageController(initialPage: myPageController.pageIndex);
    return Scaffold(
      body: PageView(
        physics: ClampingScrollPhysics(),
        controller: pc,
        onPageChanged: Provider.of<MyPageIndexProvider>(context).updateIndex,
        children: [MenuPrincipalScreen(),
          ContatosScreen(),
          MeuPerfilScreen(),
         ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: ColorService.azulEscuro,
        type: BottomNavigationBarType.fixed,
        currentIndex: myPageController.pageIndex,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(
                Icons.chat_bubble,
              ),
              label: "Conversas"),
          BottomNavigationBarItem(
              icon: const Icon(Icons.group),
              label: 'Contatos'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'Perfil'),
        ],
        onTap: (pagina)  {
          pc.animateToPage(
            pagina,
            duration: const Duration(milliseconds: 400),
            curve: Curves.ease,
          );
        },
        // backgroundColor: Colors.grey[100],
      ),
    );
  }
}
