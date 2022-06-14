import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/componentes/lista_conversas.dart';
import 'package:whatsappweb/componentes/lista_mensagens.dart';
import 'package:whatsappweb/modelos/usuario.dart';
import 'package:whatsappweb/provider/conversa_provider.dart';
import 'package:whatsappweb/uteis/paleta_cores.dart';
import 'package:whatsappweb/uteis/responsivo.dart';
import 'package:provider/provider.dart';

class HomeWeb extends StatefulWidget {
  @override
  _HomeWebState createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  late Usuario _usuarioLogado;

  _recuperarDadosUsuarioLogado(){

    User? usuarioLogado = _auth.currentUser;

    if(usuarioLogado != null){

      String idUsuario = usuarioLogado.uid;
      String? nome = usuarioLogado.displayName ?? '';
      String? email = usuarioLogado.email ?? '';
      String? urlImagem = usuarioLogado.photoURL ?? '';

      _usuarioLogado = Usuario(
          idUsuario,
          nome,
          email,
          urlImagem: urlImagem
      );
    }

  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {

    final largura = MediaQuery.of(context).size.width;
    final altura = MediaQuery.of(context).size.height;
    final isweb = Responsivo.isWeb(context);

    return Scaffold(
      body: Container(
        color: PaletaCores.corFundo,
        child: Stack(
          children: [
            Positioned(
                top: 0,
                child: Container(
                  color: PaletaCores.corPrimaria,
                  width: largura,
                  height: altura * 0.3,
                )
            ),
            Positioned(
                top: Responsivo.isWeb(context) ? altura * 0.05 : 0,
                bottom: Responsivo.isWeb(context) ? altura * 0.05 : 0,
                left: Responsivo.isWeb(context) ? largura * 0.05 : 0,
                right: Responsivo.isWeb(context) ? largura * 0.05 : 0,
                child: Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: AreaLateralConversas(
                          usuarioLogado: _usuarioLogado,
                        )
                    ),
                    Expanded(
                        flex: 10,
                        child: AreaLateralMensagens(
                          usuarioLogado: _usuarioLogado,
                        )
                    )
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}


class AreaLateralConversas extends StatelessWidget {

  final Usuario usuarioLogado;

  AreaLateralConversas({
   required this.usuarioLogado
});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PaletaCores.corFundoBarraClaro,
        border: Border(
          right: BorderSide(
            color: PaletaCores.corFundo,
            width: 1
          )
        ),
      ),
      child: Column(
        children: [

          //Barra Superior
          Container(
            color: PaletaCores.corFundoBarra,
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(
                      usuarioLogado.urlImagem
                  ),
                ),
                Spacer(),
                IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.message)
                ),
                IconButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: Icon(Icons.logout)
                )
              ],
            ),
          ),

          //Barra de Pesquisa

          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100)
            ),
            child: Row(
              children: [

                IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.search)
                ),
                Expanded(
                    child: TextField(
                      decoration: InputDecoration.collapsed(
                        hintText: 'Pesquisar uma conversa'
                      ),
                    )
                )
              ],
            ),
          ),

          //Lista de Coversas

          Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: ListaConversas(),
              )
          )
        ],
      ),
    );
  }
}

class AreaLateralMensagens extends StatelessWidget {

  final usuarioLogado;

  const AreaLateralMensagens ({
    required this.usuarioLogado
});

  @override
  Widget build(BuildContext context) {

    final largura = MediaQuery.of(context).size.width;
    final altura = MediaQuery.of(context).size.height;
    Usuario? usuarioDestinatario = context.watch<ConversaProvider>().usuarioDestinatario;

    return usuarioDestinatario != null
        ? Column(
      children: [

        //Barra superior

        Container(
          color: PaletaCores.corFundoBarra,
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(
                    usuarioDestinatario.urlImagem
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                usuarioDestinatario.nome,
                style: TextStyle(
                  fontSize: 16
                ),
              ),
              Spacer(),
              IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.search)
              ),
              IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.more_vert)
              ),
            ],
          ),
        ),

        //Listagem de Mensagens

        Expanded(
            child: ListaMensagens(
              usuarioRemetente: usuarioLogado,
              usuarioDestinatario: usuarioDestinatario,
            )
        )

      ],
    )
        : Container(
          width: largura,
          height: altura,
          color: PaletaCores.corFundoBarraClaro,
          child: Center(
            child: Text('Nenhum usuario selecionado!'),
          )
        );

  }
}


