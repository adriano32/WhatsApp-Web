import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/componentes/lista_mensagens.dart';
import 'package:whatsappweb/modelos/usuario.dart';

class Mensagens extends StatefulWidget {

  final Usuario usuarioDestinatario;

  Mensagens(
   this.usuarioDestinatario,
);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {

  late Usuario _usuarioDestinatario;
  late Usuario _usuarioRemetente;
  FirebaseAuth _auth = FirebaseAuth.instance;

  _recuperarDadosIniciais(){

    _usuarioDestinatario = widget.usuarioDestinatario;

    User? usuarioLogado = _auth.currentUser;

    if(usuarioLogado != null){

      String idUsuario = usuarioLogado.uid;
      String? nome = usuarioLogado.displayName ?? '';
      String? email = usuarioLogado.email ?? '';
      String? urlImagem = usuarioLogado.photoURL ?? '';

      _usuarioRemetente = Usuario(
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
    _recuperarDadosIniciais();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(
                  _usuarioDestinatario.urlImagem
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
                _usuarioDestinatario.nome,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  fontSize: 18
                ),
            )
          ],
        ),
        actions: [
          IconButton(
              onPressed: (){},
              icon: Icon(Icons.more_vert)
          )
        ],
      ),
      body: SafeArea(
          child: ListaMensagens(
            usuarioDestinatario: _usuarioDestinatario,
            usuarioRemetente: _usuarioRemetente,
          ),
      ),
    );
  }
}
