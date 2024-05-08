// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/empresa_model.dart';
import '../models/usuario_model.dart';
import 'usuario_controller.dart';

class EmpresaController {
  static Future<Empresa> getEmpresa(String id) async {
    final empresaSnapshot =
        await FirebaseFirestore.instance.collection('Empresa').doc(id).get();

    return Empresa(
      id: empresaSnapshot.id,
      cnpj: empresaSnapshot['CNPJ'],
      matriz: empresaSnapshot['EmpresaPai'],
      razaoSocial: empresaSnapshot['RazaoSocial'],
      criador: empresaSnapshot['QuemCriou'],
      status: empresaSnapshot['Status'],
    );
  }

  static Future<List<Empresa>> getEmpresas() async {
    Usuario usuario = await UsuarioController.getUsuarioLogado();

    int nivelInt = int.parse(usuario.nivel);

    if (nivelInt == 1) {
      final empresasSnapshot =
          await FirebaseFirestore.instance.collection('Empresa').get();
      final List<Empresa> empresas = [];

      for (var doc in empresasSnapshot.docs) {
        final empresa = Empresa(
          id: doc.id,
          cnpj: doc['CNPJ'],
          matriz: doc['EmpresaPai'],
          razaoSocial: doc['RazaoSocial'],
          criador: doc['QuemCriou'],
          status: doc['Status'],
        );
        empresas.add(empresa);
      }
      return empresas;
    } else if (nivelInt == 2) {
      final empresasSnapshot =
          await FirebaseFirestore.instance.collection('Empresa').get();
      final List<Empresa> empresas = [];

      for (var doc in empresasSnapshot.docs) {
        final empresa = Empresa(
          id: doc.id,
          cnpj: doc['CNPJ'],
          matriz: doc['EmpresaPai'],
          razaoSocial: doc['RazaoSocial'],
          criador: doc['QuemCriou'],
          status: doc['Status'],
        );
        if (empresa.matriz == usuario.empresa) {
          empresas.add(empresa);
        }
      }

      return empresas;
    }

    return [];
  }
}
