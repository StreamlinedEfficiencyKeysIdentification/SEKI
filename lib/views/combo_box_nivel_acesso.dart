import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controllers/usuario_controller.dart';
import '../models/usuario_model.dart';

class ComboBoxNivelAcesso extends StatefulWidget {
  final void Function(String) onNivelSelected;

  const ComboBoxNivelAcesso({
    required this.onNivelSelected,
    super.key,
  });

  @override
  ComboBoxNivelAcessoState createState() => ComboBoxNivelAcessoState();
}

class ComboBoxNivelAcessoState extends State<ComboBoxNivelAcesso> {
  String _nivelSelecionado = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario>(
      future: UsuarioController.getUsuarioLogado(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Tratar erros
        }

        // Obter o nível do usuário logado
        String? nivel = snapshot.data?.nivel;

        // Se o nível for null ou vazio, não há permissões, retornar uma lista vazia
        if (nivel == null || nivel.isEmpty) {
          return const SizedBox();
        }

        // Se o nível for 1, permitir que o usuário selecione qualquer nível
        // Se o nível for 2, filtrar os níveis com base no nível associado ao usuário
        // Se o nível for 3, permitir que o usuário selecione apenas níveis maiores que 3
        Query niveisQuery = FirebaseFirestore.instance.collection('Nivel');
        if (nivel == '2') {
          niveisQuery =
              niveisQuery.where(FieldPath.documentId, isGreaterThan: '2');
        } else if (nivel == '3') {
          niveisQuery =
              niveisQuery.where(FieldPath.documentId, isGreaterThan: '3');
        }

        return StreamBuilder<QuerySnapshot>(
          stream: niveisQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // Tratar erros
            }

            final niveis = snapshot.data?.docs.map((doc) {
                  return {
                    'nivel': doc.id, // O ID do documento representa o nível
                    'descricao': doc['Descricao']
                        as String, // Extrai a descrição do nível
                  };
                }).toList() ??
                [];

            return DropdownButton<String>(
              hint: const Text('Selecione um nível de acesso'),
              value: _nivelSelecionado.isNotEmpty
                  ? _nivelSelecionado
                  : null, // Define o valor inicial do ComboBox
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _nivelSelecionado = newValue;
                  });
                  widget.onNivelSelected(newValue);
                }
              },
              items: niveis
                  .map<DropdownMenuItem<String>>((Map<String, dynamic> nivel) {
                return DropdownMenuItem<String>(
                  value: nivel['nivel'] as String,
                  child: Text('${nivel['descricao']}'),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
