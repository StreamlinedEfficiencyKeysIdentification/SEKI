// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class UsuarioController {
  static Future<Usuario> getUsuarioLogado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuarioLogado = prefs.getString('usuarioLogado') ?? '';

    if (usuarioLogado.isNotEmpty) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(usuarioLogado)
          .get();

      DocumentSnapshot detailSnapshot = await FirebaseFirestore.instance
          .collection('DetalheUsuario')
          .doc(usuarioLogado)
          .get();

      if (userSnapshot.exists && detailSnapshot.exists) {
        // Inicialize os formatos de data/hora locais
        initializeDateFormatting();

        String dataCriacaoFormatada =
            formatarTimeStamp(detailSnapshot['DataCriacao']);
        String dataAcessoFormatada =
            formatarTimeStamp(detailSnapshot['DataAcesso']);

        return Usuario(
          uid: usuarioLogado,
          nivel: userSnapshot['IDnivel'] as String? ?? '',
          empresa: userSnapshot['IDempresa'] as String? ?? '',
          nome: userSnapshot['Nome'] as String? ?? '',
          usuario: userSnapshot['Usuario'] as String? ?? '',
          email: userSnapshot['Email'] as String? ?? '',
          status: userSnapshot['Status'] as String? ?? '',
          criador: detailSnapshot['QuemCriou'] as String? ?? '',
          dataCriacao: dataCriacaoFormatada as String? ?? '',
          dataAcesso: dataAcessoFormatada as String? ?? '',
          primeiroAcesso: detailSnapshot['PrimeiroAcesso'] as bool? ?? false,
          redefinirSenha: detailSnapshot['RedefinirSenha'] as bool? ?? false,
        );
      }
    }
    return Usuario(
      uid: '',
      nivel: '',
      empresa: '',
      nome: '',
      usuario: '',
      email: '',
      status: '',
      criador: '',
      dataCriacao: '',
      dataAcesso: '',
      primeiroAcesso: false,
      redefinirSenha: false,
    );
  }

  static Future<Usuario> getUsuario(String uid) async {
    final DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('Usuarios').doc(uid).get();

    final DocumentSnapshot detailSnapshot = await FirebaseFirestore.instance
        .collection('DetalheUsuario')
        .doc(uid)
        .get();

    if (userSnapshot.exists && detailSnapshot.exists) {
      initializeDateFormatting();

      String dataCriacaoFormatada =
          formatarTimeStamp(detailSnapshot['DataCriacao']);
      String dataAcessoFormatada =
          formatarTimeStamp(detailSnapshot['DataAcesso']);

      return Usuario(
        uid: uid,
        nivel: userSnapshot['IDnivel'] as String? ?? '',
        empresa: userSnapshot['IDempresa'] as String? ?? '',
        nome: userSnapshot['Nome'] as String? ?? '',
        usuario: userSnapshot['Usuario'] as String? ?? '',
        email: userSnapshot['Email'] as String? ?? '',
        status: userSnapshot['Status'] as String? ?? '',
        criador: detailSnapshot['QuemCriou'] as String? ?? '',
        dataCriacao: dataCriacaoFormatada,
        dataAcesso: dataAcessoFormatada,
        primeiroAcesso: detailSnapshot['PrimeiroAcesso'] as bool? ?? false,
        redefinirSenha: detailSnapshot['RedefinirSenha'] as bool? ?? false,
      );
    }

    return Usuario(
      uid: '',
      nivel: '',
      empresa: '',
      nome: '',
      usuario: '',
      email: '',
      status: '',
      criador: '',
      dataCriacao: '',
      dataAcesso: '',
      primeiroAcesso: false,
      redefinirSenha: false,
    );
  }

  static Future<List<Usuario>> getUsuarios() async {
    final usuariosSnapshot =
        await FirebaseFirestore.instance.collection('Usuarios').get();
    final List<Usuario> usuarios = [];

    for (var doc in usuariosSnapshot.docs) {
      final usuario = Usuario(
        uid: doc.id,
        nivel: doc['IDnivel'] as String? ?? '',
        empresa: doc['IDempresa'] as String? ?? '',
        nome: doc['Nome'] as String? ?? '',
        usuario: doc['Usuario'] as String? ?? '',
        email: doc['Email'] as String? ?? '',
        status: doc['Status'] as String? ?? '',
        criador: '',
        dataCriacao: '',
        dataAcesso: '',
        primeiroAcesso: false,
        redefinirSenha: false,
      );
      usuarios.add(usuario);
    }
    return usuarios;
  }
}

String formatarTimeStamp(Timestamp timestamp) {
  // Converta o timestamp para um objeto DateTime
  DateTime dateTime = timestamp.toDate();

  // Converta para o fuso horário local
  DateTime localDateTime = dateTime.toLocal();

  // Formate a data e hora para exibição
  return DateFormat('dd/MM/yyyy HH:mm:ss').format(localDateTime);
}
