// ignore_for_file: overridden_fields, annotate_overrides

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testeseki/models/usuario_model.dart';
import '../../controllers/usuario_controller.dart';

class AutocompleteUsuarioExample extends StatefulWidget {
  final void Function(String) onUsuarioSelected;
  final String user;
  final Key key;

  const AutocompleteUsuarioExample({
    required this.onUsuarioSelected,
    required this.user,
    required this.key,
  }) : super(key: key);

  @override
  AutocompleteUsuarioExampleState createState() =>
      AutocompleteUsuarioExampleState();
}

class AutocompleteUsuarioExampleState
    extends State<AutocompleteUsuarioExample> {
  // Defina uma chave única para o widget
  GlobalKey<AutocompleteUsuarioExampleState> _key = GlobalKey();

  // Método para reconstruir o widget com a chave atualizada
  void reconstruirWidget() {
    setState(() {
      _key = GlobalKey();
    });
  }

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
              criador: '',
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
            late String userInitial = '';

            if (widget.user.isNotEmpty) {
              userInitial = widget.user;
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SizedBox(
                  key: _key,
                  child: Autocomplete<String>(
                    initialValue: TextEditingValue(text: userInitial),
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
                        widget.onUsuarioSelected(usuarioUid);
                      }
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      return TextField(
                        decoration: InputDecoration(
                          hintText: 'Digite o nome do usuário',
                          hintStyle: const TextStyle(
                            color: Color(0xFF0076BC), // Cor do texto de dica
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.3), // Cor de fundo com opacidade
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                50.0), // Borda arredondada
                            borderSide: BorderSide.none, // Sem borda visível
                          ),
                        ),
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                      );
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
