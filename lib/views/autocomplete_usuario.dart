import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testeseki/models/usuario_model.dart';
import '../controllers/usuario_controller.dart';

class AutocompleteUsuarioExample extends StatelessWidget {
  final void Function(String) onUsuarioSelected;

  const AutocompleteUsuarioExample({
    required this.onUsuarioSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario>(
      future: UsuarioController.getUsuarioLogado(),
      builder: (context, snapshot) {
        Usuario usuario = snapshot.data ??
            Usuario(
              uid: '',
              nivel: '',
              empresa: '',
              nome: '',
              usuario: '',
              email: '',
              status: '',
              dataCriacao: '',
              dataAcesso: '',
              primeiroAcesso: false,
              redefinirSenha: false,
            );

        return FutureBuilder<QuerySnapshot>(
          future: _getUsuariosQuery(usuario),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // Tratar erros
            }
            final usuarios = snapshot.data?.docs
                    .map((doc) => doc['Nome'] as String)
                    .toList() ??
                []; // Obter os nomes das empresas

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SizedBox(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return usuarios.where((String option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) async {
                      // Buscar o UID do usuário selecionado
                      QuerySnapshot querySnapshot = await FirebaseFirestore
                          .instance
                          .collection('Usuarios')
                          .where('Nome', isEqualTo: selection)
                          .get();
                      if (querySnapshot.docs.isNotEmpty) {
                        // Obter o UID do usuário
                        String usuarioUid = querySnapshot.docs.first.id;
                        // Chamar a função onUsuarioSelected passando o UID do usuário
                        onUsuarioSelected(usuarioUid);
                      }
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<QuerySnapshot> _getUsuariosQuery(Usuario usuario) async {
    Query usuariosQuery = FirebaseFirestore.instance.collection('Usuarios');

    if (usuario.nivel == '2') {
      QuerySnapshot empresasSnapshot = await FirebaseFirestore.instance
          .collection('Empresa')
          .where('EmpresaPai', isEqualTo: usuario.empresa)
          .get();

      List<String> empresasIds =
          empresasSnapshot.docs.map((doc) => doc.id).toList();

      return FirebaseFirestore.instance
          .collection('Usuarios')
          .where('IDempresa', whereIn: empresasIds)
          .get();
    } else if (usuario.nivel == '3') {
      return usuariosQuery.where('IDempresa', isEqualTo: usuario.empresa).get();
    }

    return usuariosQuery.get();
  }
}
