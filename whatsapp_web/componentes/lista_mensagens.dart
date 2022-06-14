import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsappweb/modelos/conversa.dart';
import 'package:whatsappweb/modelos/mensagem.dart';
import 'package:whatsappweb/modelos/usuario.dart';
import 'package:whatsappweb/uteis/paleta_cores.dart';

import '../provider/conversa_provider.dart';

class ListaMensagens extends StatefulWidget {

  final Usuario usuarioRemetente;
  final Usuario usuarioDestinatario;

  ListaMensagens({
    required this.usuarioDestinatario,
    required this.usuarioRemetente
});

  @override
  _ListaMensagensState createState() => _ListaMensagensState();
}

class _ListaMensagensState extends State<ListaMensagens> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _mensagemController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  late Usuario _usuarioDestinatario;
  late Usuario _usuarioRemetente;

  StreamController _streamController = StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamMensagens;

  _enviarMensagem(){

    String textoMensagem = _mensagemController.text;
    String idUsuarioRemetente = _usuarioRemetente.idUsuario;

    if(textoMensagem.isNotEmpty){

      Mensagem mensagem = Mensagem(
        textoMensagem,
        idUsuarioRemetente,
        Timestamp.now().toString()
      );

      //Salvar Mensagem para o remetente
      String idUsuarioDestinatario = _usuarioDestinatario.idUsuario;
      _salvarMensagem(
          idUsuarioRemetente,
          idUsuarioDestinatario,
          mensagem
      );

      Conversa conversaRemetente = Conversa(
          idUsuarioRemetente,
          idUsuarioDestinatario,
          mensagem.texto,
          _usuarioDestinatario.nome,
          _usuarioDestinatario.email,
          _usuarioDestinatario.urlImagem
      );

      _salvarCoversa(conversaRemetente);

      //Salvar Mensagem para o destinatário

      _salvarMensagem(
          idUsuarioDestinatario,
          idUsuarioRemetente,
          mensagem
      );

      Conversa conversaDestinatario = Conversa(
          idUsuarioDestinatario,
          idUsuarioRemetente,
          mensagem.texto,
          _usuarioRemetente.nome,
          _usuarioRemetente.email,
          _usuarioRemetente.urlImagem
      );

      _salvarCoversa(conversaDestinatario);

    }

  }

  _salvarCoversa(Conversa conversa){

    _firestore.collection('conversas')
        .doc(conversa.idRemetente)
          .collection('ultimas_mensagens')
        .doc(conversa.idDestinatario)
        .set(conversa.toMap());
  }

  _salvarMensagem(String idRemetente, String idDestinatario, Mensagem mensagem){

    _firestore.collection('mensagens')
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(mensagem.toMap());

    _mensagemController.clear();
  }

  _recuperarDadosIniciais(){

    _usuarioRemetente = widget.usuarioRemetente;
    _usuarioDestinatario = widget.usuarioDestinatario;

    _adicionarListenerMensagens();

  }

  _atualizarListenersMensagens(){

    Usuario? usuarioDestinatario = context.watch<ConversaProvider>().usuarioDestinatario;

    if(usuarioDestinatario != null){
      _usuarioDestinatario = usuarioDestinatario;
      _recuperarDadosIniciais();
    }
  }

  _adicionarListenerMensagens(){

    final stream = _firestore.collection('mensagens')
        .doc(_usuarioRemetente.idUsuario)
        .collection(_usuarioDestinatario.idUsuario)
        .orderBy('data', descending: false)
        .snapshots();

    _streamMensagens = stream.listen((dados) {

      _streamController.add(dados);
      Timer(Duration(seconds: 1), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _streamMensagens.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosIniciais();
  }

  @override
  void didChangeDependencies() {
    _atualizarListenersMensagens();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    double largura = MediaQuery.of(context).size.width;
    double altura = MediaQuery.of(context).size.height;

    return Container(
      width: largura,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('imagens/bg.png'),
          fit: BoxFit.cover
        ),
      ),
      child: Column(
        children: [

          //Lista de Mensagens
          StreamBuilder(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Expanded(child: Center(
                      child: Column(
                        children: [
                          Text('Carregando dados...'),
                          CircularProgressIndicator(
                            color: Theme
                                .of(context)
                                .primaryColor,
                          )
                        ],
                      ),
                    )
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Erro ao carregar dados!'),
                      );
                    } else {

                      QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                      List<DocumentSnapshot> listaMensagens = querySnapshot.docs.toList();

                      return Expanded(
                          child: ListView.builder(
                              controller: _scrollController,
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, index){

                                DocumentSnapshot mensagem = listaMensagens[index];

                                Alignment alinhamento = Alignment.bottomLeft;
                                Color cor = Colors.white;

                                if(_usuarioRemetente.idUsuario == mensagem['idUsuario']){

                                  alinhamento = Alignment.topRight;
                                  cor = Color(0xffd2ffa5);
                                }

                                Size largura = MediaQuery.of(context).size * 0.8;

                                return Align(
                                  alignment: alinhamento,
                                  child: Container(
                                    constraints: BoxConstraints.loose(largura),
                                    decoration: BoxDecoration(
                                      color: cor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10)
                                      )
                                    ),
                                    padding: EdgeInsets.all(8),
                                    margin: EdgeInsets.all(6),
                                    child: Text(mensagem['texto']),
                                  ),
                                );

                              }
                          )
                      );
                    }
                }
              }
          ),
          //Caixa de texto
          Container(
            padding: EdgeInsets.all(8),
            color: PaletaCores.corFundoBarra,
            child: Row(
              children: [

                //Caixa de texto arredondada
                Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.insert_emoticon),
                          SizedBox(
                            width: 4,
                          ),
                          Expanded(child: TextField(
                            controller: _mensagemController,
                            decoration: InputDecoration(
                                hintText: 'Digite uma Mensagem',
                                border: InputBorder.none
                            ),
                          ),
                          ),
                          Icon(Icons.attach_file),
                          Icon(Icons.camera_alt),
                        ],
                      ),
                    )
                ),
                //Botão enviar
                FloatingActionButton(
                    mini: true,
                    onPressed: (){
                      _enviarMensagem();
                    },
                    child: Icon(Icons.send),
                    backgroundColor: PaletaCores.corPrimaria,
                    foregroundColor: PaletaCores.corSecundaria,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
