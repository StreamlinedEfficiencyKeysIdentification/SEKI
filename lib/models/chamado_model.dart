// ignore_for_file: non_constant_identifier_names

class Chamado {
  final String IDdoc;
  final String IDchamado;
  final String QRcode;
  final String Titulo;
  final String Usuario;
  final String Descricao;
  final String Empresa;
  final String Status;
  final String Responsavel;
  final String DataCriacao;
  final String DataAtualizacao;
  final bool Lido;

  Chamado({
    required this.IDdoc,
    required this.IDchamado,
    required this.QRcode,
    required this.Titulo,
    required this.Usuario,
    required this.Descricao,
    required this.Empresa,
    required this.Status,
    required this.Responsavel,
    required this.DataCriacao,
    required this.DataAtualizacao,
    required this.Lido,
  });
}
