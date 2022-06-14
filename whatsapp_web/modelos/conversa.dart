
class Conversa{

  String idRemetente;
  String idDestinatario;
  String ultimaMensagem;
  String nomeDestinatario;
  String emailDestinatario;
  String urlImagemDestinatario;

  Conversa(
      this.idRemetente,
      this.idDestinatario,
      this.ultimaMensagem,
      this.nomeDestinatario,
      this.emailDestinatario,
      this.urlImagemDestinatario
      );

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      'idRemetente' : idRemetente,
      'idDestinatario' : idDestinatario,
      'ultimaMensagem' : ultimaMensagem,
      'nomeDestinatario' : nomeDestinatario,
      'emailDestinatario' : emailDestinatario,
      'urlImagemDestinatario' : urlImagemDestinatario,
    };

    return map;
  }
}