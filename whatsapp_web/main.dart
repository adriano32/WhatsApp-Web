import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/provider/conversa_provider.dart';
import 'package:whatsappweb/rotas.dart';
import 'package:whatsappweb/uteis/paleta_cores.dart';
import 'package:provider/provider.dart';

final ThemeData temaPadrao = ThemeData(
  primaryColor: PaletaCores.corPrimaria,
  appBarTheme: AppBarTheme(
    foregroundColor: PaletaCores.corSecundaria,
    backgroundColor: PaletaCores.corPrimaria
  )
);

void main() {

  User? usuario = FirebaseAuth.instance.currentUser;
  String urlInicial = '/';

  if(usuario != null){
    urlInicial = '/home';
  }

  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
      create: (context) => ConversaProvider(),
      child: MaterialApp(
        title: 'Whatsapp Web',
        theme: temaPadrao,
        debugShowCheckedModeBanner: false,
        initialRoute: urlInicial,
        onGenerateRoute: Rotas.gerarRota,
      ),
  ));
}


