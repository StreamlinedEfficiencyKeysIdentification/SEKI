// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_model.dart';

class UsuarioController {
  static Future<Usuario> getUsuarioLogado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuarioLogado = prefs.getString('usuarioLogado') ?? '';

    if (usuarioLogado.isNotEmpty) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(usuarioLogado)
          .get();

      if (userSnapshot.exists) {
        return Usuario(
          uid: usuarioLogado,
          nivel: userSnapshot['IDnivel'] as String? ?? '',
          empresa: userSnapshot['IDempresa'] as String? ?? '',
        );
      }
    }
    return Usuario(uid: '', nivel: '', empresa: '');
  }
}
