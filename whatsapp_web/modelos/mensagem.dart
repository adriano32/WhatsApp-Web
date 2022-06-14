
class Mensagem {

  String idUsuario;
  String texto;
  String data;

  Mensagem(
     this.texto,
     this.idUsuario,
     this.data
);

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      'idUsuario' : idUsuario,
      'texto' : texto,
      'data' : data,
    };

    return map;
  }
}