import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/modelos/usuario.dart';

class ListaContatos extends StatefulWidget {
  @override
  _ListaContatosState createState() => _ListaContatosState();
}

class _ListaContatosState extends State<ListaContatos> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _idUsuarioLogado;

  Future<List<Usuario>> _recuperarContatos() async {

    final usuariosRef = _firestore.collection('usuarios');
    QuerySnapshot querySnapshot = await usuariosRef.get();
    List<Usuario> listaUsuarios = [];

    for(DocumentSnapshot item in querySnapshot.docs){

      String idUsuario = item['idUsuario'];
      if(idUsuario == _idUsuarioLogado) continue;
      String nome = item['nome'];
      String email = item['email'];
      String urlImagem = item['urlImagem'];

      Usuario usuario = Usuario(
          idUsuario,
          nome,
          email,
          urlImagem: urlImagem
      );

      listaUsuarios.add(usuario);
    }

    print('Lista de usuarios: ${listaUsuarios.toString()}');
    return listaUsuarios;
  }

  _recuperarDadosUsuarioLogado() async {

    User? usuarioAtual = await _auth.currentUser;

    if(usuarioAtual != null){
      _idUsuarioLogado = usuarioAtual.uid;
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
        future: _recuperarContatos(),
        builder: (context, snapshot){

          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text('Carregando dados...'),
                    CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    )
                  ],
                ),
              );
            case ConnectionState.active:
            case ConnectionState.done:

              if(snapshot.hasError){
                return Center(
                  child: Text('Erro ao carregar dados!'),
                );
              } else {
                List<Usuario>? listaUsuarios = snapshot.data;

                if(listaUsuarios != null){
                  return ListView.separated(
                      itemCount: listaUsuarios.length,
                      separatorBuilder: (context, index){
                        return Divider(
                          color: Colors.grey,
                          thickness: 0.2,
                        );
                      },
                      itemBuilder: (context, index){

                        Usuario usuario = listaUsuarios[index];

                        return ListTile(
                          onTap: (){
                            Navigator.pushNamed(context, '/mensagens', arguments: usuario);
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
                          contentPadding: EdgeInsets.all(8),
                        );
                      },

                  );
                }
                return Center(
                    child: Text('Erro ao carregar dados!')
                );
              }
          }
        }
    );
  }
}
