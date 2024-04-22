import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/usuario_controller.dart';
import '../models/usuario_model.dart';

class ComboBoxEmpresa extends StatefulWidget {
  final void Function(String) onEmpresaSelected;

  const ComboBoxEmpresa({
    required this.onEmpresaSelected,
    super.key,
  });

  @override
  ComboBoxEmpresaState createState() => ComboBoxEmpresaState();
}

class ComboBoxEmpresaState extends State<ComboBoxEmpresa> {
  String _empresaSelecionada = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario>(
      future: UsuarioController.getUsuarioLogado(),
      builder: (context, snapshot) {
        Usuario usuario =
            snapshot.data ?? Usuario(uid: '', nivel: '', empresa: '');

        Query empresasQuery = FirebaseFirestore.instance.collection('Empresa');
        if (usuario.nivel == '2') {
          empresasQuery = empresasQuery
              .where('EmpresaPai', isEqualTo: usuario.empresa)
              .where(FieldPath.documentId, isNotEqualTo: usuario.empresa);
        } else if (usuario.nivel == '3') {
          empresasQuery = empresasQuery.where(FieldPath.documentId,
              isEqualTo: usuario.empresa);
        }

        return StreamBuilder<QuerySnapshot>(
          stream: empresasQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final empresas = snapshot.data?.docs.map((doc) {
                  return {
                    'RazaoSocial': doc['RazaoSocial'] as String,
                    'ID': doc.id,
                  };
                }).toList() ??
                [];

            return DropdownButton<String>(
              hint: const Text('Selecione uma empresa'),
              value:
                  _empresaSelecionada.isNotEmpty ? _empresaSelecionada : null,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _empresaSelecionada = newValue;
                  });
                  widget.onEmpresaSelected(newValue);
                }
              },
              items: empresas.map<DropdownMenuItem<String>>(
                  (Map<String, dynamic> empresa) {
                return DropdownMenuItem<String>(
                  value: empresa['ID'] as String,
                  child: Text(empresa['RazaoSocial'] as String),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
