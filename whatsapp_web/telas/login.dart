import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/uteis/paleta_cores.dart';
import '../modelos/usuario.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerNome = TextEditingController(); //text: 'Adriano Henrique'
  TextEditingController _controllerEmail = TextEditingController();//text: 'adriano.henrique@gmail.com'
  TextEditingController _controllerSenha = TextEditingController(); //text: '1234567'flutter
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Uint8List? _imagemSelecionada;

  bool _cadastroUsuario = false;

  // _verificarUsuarioLogado(){
  //
  //   User? usuarioLogado =  _auth.currentUser;
  //
  //   if(usuarioLogado != null){
  //     Navigator.pushReplacementNamed(context, '/home');
  //   }
  //
  // }

  _selecionarImagem() async {

    //Selecionar Arquivo
    FilePickerResult? resultado = await FilePicker.platform.pickFiles(
      type: FileType.image
    );

    //Recuperar arquivo

    setState(() {
      _imagemSelecionada = resultado?.files.single.bytes;
    });
  }

  _uploadImagem(Usuario usuario){

    Uint8List? arquivoSelecionado = _imagemSelecionada;
    if(arquivoSelecionado != null){

      Reference imagemPerfilRef = _storage.ref('imagens/perfil/${usuario.idUsuario}.jpg');
      UploadTask uploadTask = imagemPerfilRef.putData(arquivoSelecionado);

      uploadTask.whenComplete(() async {

        String urlImagem = await uploadTask.snapshot.ref.getDownloadURL();
        usuario.urlImagem = urlImagem;

        // Atualiza url e nome nos dados do usuário

        await _auth.currentUser?.updateDisplayName(usuario.nome);
        await _auth.currentUser?.updatePhotoURL(usuario.urlImagem);

        final usuariosRef = _firestore.collection('usuarios');
        usuariosRef.doc(usuario.idUsuario)
            .set(usuario.toMap())
            .then((value){

              //tela principal
            Navigator.pushReplacementNamed(context, '/home');

            });
        //print('link Imagem: $linkImagem');
      });
    }

  }

  _validacaoCampos() async {

    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(email.isNotEmpty && email.contains('@')){
      if(senha.isNotEmpty && senha.length > 6){

        if( _cadastroUsuario){

          if(_imagemSelecionada != null){

            //cadastro
            if(nome.isNotEmpty && nome.length > 2){

              _auth.createUserWithEmailAndPassword(
                  email: email,
                  password: senha
              ).then((auth){

                //Upload imagem
                String? idUsuario = auth.user?.uid;
                //print('Usuario cadastrado: $idUsuario');
                if(idUsuario != null){

                  Usuario usuario = Usuario(idUsuario,
                      nome,
                      email
                  );
                  _uploadImagem(usuario);
                }

              });

            } else {
              print('Nome Inválido, digite pelomenos 3 caracteres');
            }
          } else{
            print('Selecione uma imagem');
          }

        } else {
          //Login
          await _auth.signInWithEmailAndPassword(
              email: email,
              password: senha
          ).then((auth){

            //tela principal
            Navigator.pushReplacementNamed(context, '/home');

          });

        }

      } else {
        print('Senha Inválida');
      }

    } else {
      print('Email Inválido');
    }

  }

  // @override
  // void initState() {
  //   super.initState();
  //   _verificarUsuarioLogado();
  // }

  @override
  Widget build(BuildContext context) {

    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: PaletaCores.corFundo,
        width: larguraTela,
        height: alturaTela,
        child: Stack(
          children: [

            Positioned(
                child: Container(
                    width: larguraTela,
                    height: alturaTela * 0.4,
                    color: PaletaCores.corPrimaria
                ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10)
                        )
                    ),
                    child: Container(
                      padding: EdgeInsets.all(40),
                      width: 500,
                      child: Column(
                        children: [

                          //Imagem perfil

                         Visibility(
                            visible: _cadastroUsuario,
                             child:  ClipOval(
                                 child: _imagemSelecionada != null
                                     ? Image.memory(
                                        _imagemSelecionada!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        )
                                     : Image.asset(
                                     'imagens/perfil.png',
                                     width: 120,
                                     height: 120,
                                     fit: BoxFit.cover,
                                  )
                             ),
                         ),

                          SizedBox(
                          height: 8,
                          ),

                          Visibility(
                              visible: _cadastroUsuario,
                              child: OutlinedButton(
                                  onPressed: _selecionarImagem,
                                  child: Text('Selecionar foto')
                              ),
                          ),

                          SizedBox(
                            height: 8,
                          ),

                          //Caixa de texto nome
                          Visibility(
                              visible: _cadastroUsuario,
                              child: TextField(
                                keyboardType: TextInputType.text,
                                controller: _controllerNome,
                                decoration: InputDecoration(
                                    suffixIcon: Icon(Icons.person_outline),
                                    hintText: 'Nome',
                                    labelText: 'Nome'
                                ),
                              ),
                          ),

                          TextField(
                            keyboardType: TextInputType.emailAddress,
                            controller: _controllerEmail,
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.mail_outline),
                              hintText: 'Email',
                              labelText: 'Email'
                            ),
                          ),
                          TextField(
                            keyboardType: TextInputType.visiblePassword,
                            controller: _controllerSenha,
                            obscureText: true,
                            decoration: InputDecoration(
                                suffixIcon: Icon(Icons.lock_outline),
                                hintText: 'Senha',
                                labelText: 'Senha'
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: _validacaoCampos,
                                style: ElevatedButton.styleFrom(
                                  primary: PaletaCores.corPrimaria
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                      _cadastroUsuario ? 'Cadastro' : 'Login',
                                      style: TextStyle(
                                        fontSize: 18
                                      ),
                                  ),
                                )
                            ),
                          ),
                          Row(
                            children: [
                              Text('Login'),
                              Switch(
                                  value: _cadastroUsuario,
                                  activeColor: PaletaCores.corPrimaria,
                                  onChanged: (bool valor){
                                    setState(() {
                                      _cadastroUsuario = valor;
                                    });
                                  }
                              ),
                              Text('Cadastro'),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
