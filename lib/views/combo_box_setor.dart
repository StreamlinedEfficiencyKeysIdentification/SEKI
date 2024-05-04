import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/usuario_controller.dart';
import '../models/usuario_model.dart';

class ComboBoxSetor extends StatefulWidget {
  final void Function(String) onSetorSelected;

  const ComboBoxSetor({
    required this.onSetorSelected,
    super.key,
  });

  @override
  ComboBoxSetorState createState() => ComboBoxSetorState();
}

class ComboBoxSetorState extends State<ComboBoxSetor> {
  String _setorSelecionada = '';

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

        Query setorQuery = FirebaseFirestore.instance.collection('Setor');
        if (usuario.nivel == '2') {
          setorQuery =
              setorQuery.where('IDempresa', isEqualTo: usuario.empresa);
        }

        return StreamBuilder<QuerySnapshot>(
          stream: setorQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final setor = snapshot.data?.docs.map((doc) {
                  return {
                    'Descricao': doc['Descricao'] as String,
                    'ID': doc.id,
                  };
                }).toList() ??
                [];

            return DropdownButton<String>(
              hint: const Text('Selecione um setor'),
              value: _setorSelecionada.isNotEmpty ? _setorSelecionada : null,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _setorSelecionada = newValue;
                  });
                  widget.onSetorSelected(newValue);
                }
              },
              items: setor
                  .map<DropdownMenuItem<String>>((Map<String, dynamic> setor) {
                return DropdownMenuItem<String>(
                  value: setor['ID'] as String,
                  child: Text(setor['Descricao'] as String),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
