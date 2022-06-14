import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/modelos/usuario.dart';
import 'package:whatsappweb/provider/conversa_provider.dart';
import 'package:whatsappweb/uteis/responsivo.dart';
import 'package:provider/provider.dart';

class ListaConversas extends StatefulWidget {
  @override
  _ListaConversasState createState() => _ListaConversasState();
}

class _ListaConversasState extends State<ListaConversas> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  late Usuario _usuarioRemetente;
  late StreamSubscription _streamConversas;

  StreamController _streamController = StreamController<QuerySnapshot>.broadcast();

  _adicionarListenerConversas(){

    final stream = _firestore.collection('conversas')
        .doc(_usuarioRemetente.idUsuario)
        .collection('ultimas_mensagens')
        .snapshots();

    _streamConversas = stream.listen((dados) {

      _streamController.add(dados);
    });
  }

  _recuperarDadosIniciais(){

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

      _adicionarListenerConversas();
    }

  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosIniciais();
  }

  @override
  void dispose() {
    _streamConversas.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final isMobile = Responsivo.isMobile(context);

    return StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text('Carregando conversas...'),
                    CircularProgressIndicator(
                      color: Theme
                          .of(context)
                          .primaryColor,
                    )
                  ],
                ),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erro ao carregar dados!'),
                );
              } else {

                QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                List<DocumentSnapshot> listaConversas = querySnapshot.docs.toList();

                return ListView.separated(
                  itemCount: listaConversas.length,
                  separatorBuilder: (context, index){
                    return Divider(
                      color: Colors.grey,
                      thickness: 0.2,
                    );
                  },
                  itemBuilder: (context, index){

                    DocumentSnapshot conversa = listaConversas[index];
                    String urlImagemDestinatario = conversa['urlImagemDestinatario'];
                    String nomeDestinatario = conversa['nomeDestinatario'];
                    String emailDestinatario = conversa['emailDestinatario'];
                    String ultimaMensagem = conversa['ultimaMensagem'];
                    String idDestinatario = conversa['idDestinatario'];

                    Usuario usuario = Usuario(
                        idDestinatario,
                        nomeDestinatario,
                        emailDestinatario,
                        urlImagem: urlImagemDestinatario
                    );

                    return ListTile(
                      onTap: (){

                        if(isMobile){
                          Navigator.pushNamed(context, '/mensagens', arguments: usuario);
                        } else {

                          context.read<ConversaProvider>().usuarioDestinatario = usuario;

                        }

                      },
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        backgroundImage: CachedNetworkImageProvider(
                            usuario.urlImagem
                        ),
                      ),
                      title: Text(
                        usuario.nome,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      subtitle: Text(
                        ultimaMensagem,
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      contentPadding: EdgeInsets.all(8),
                    );
                  },

                );
              }
          }
        }
    );
  }
}
