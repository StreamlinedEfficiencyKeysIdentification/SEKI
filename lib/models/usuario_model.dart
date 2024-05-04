class Usuario {
  final String uid;
  final String nivel;
  final String empresa;
  final String nome;
  final String usuario;
  final String email;
  final String status;
  final String dataCriacao;
  final String dataAcesso;
  final bool primeiroAcesso;
  final bool redefinirSenha;

  Usuario({
    required this.uid,
    required this.nivel,
    required this.empresa,
    required this.nome,
    required this.usuario,
    required this.email,
    required this.status,
    required this.dataCriacao,
    required this.dataAcesso,
    required this.primeiroAcesso,
    required this.redefinirSenha,
  });
}
