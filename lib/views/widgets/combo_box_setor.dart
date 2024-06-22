import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/usuario_controller.dart';
import '../../models/usuario_model.dart';

class ComboBoxSetor extends StatefulWidget {
  final void Function(String) onSetorSelected;
  final String setor;
  final bool encontrado;

  const ComboBoxSetor({
    required this.encontrado,
    required this.onSetorSelected,
    required this.setor,
    super.key,
  });

  @override
  ComboBoxSetorState createState() => ComboBoxSetorState();
}

class ComboBoxSetorState extends State<ComboBoxSetor> {
  String _setorSelecionada = '';
  bool _setorEncontrado = false;

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

        Query setorQuery = FirebaseFirestore.instance.collection('Setor');
        if (usuario.nivel == '2') {
          setorQuery =
              setorQuery.where('IDempresa', isEqualTo: usuario.empresa);
        }

        if (widget.encontrado == false && _setorSelecionada.isEmpty) {
          _setorEncontrado = false;
        } else {
          _setorSelecionada = widget.setor;
          _setorEncontrado = true;
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

            return SizedBox(
              child: Column(
                children: [
                  if (!_setorEncontrado)
                    const Text(
                      'Setor não encontrado. Por favor, escolha um setor existente.',
                    ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(
                        color: Colors
                            .lightBlueAccent, // Cor da borda quando o campo está habilitado
                        width: 2.0,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text(
                          'Selecione um setor',
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        alignment: Alignment.center,
                        borderRadius: BorderRadius.circular(25.0),
                        iconEnabledColor: Colors.blue,
                        style: const TextStyle(
                          color: Color(0xFF0076BC),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        value: _setorSelecionada.isNotEmpty
                            ? _setorSelecionada
                            : null,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _setorSelecionada = newValue;
                            });
                            widget.onSetorSelected(newValue);
                          }
                        },
                        items: setor.map<DropdownMenuItem<String>>(
                            (Map<String, dynamic> setor) {
                          return DropdownMenuItem<String>(
                            alignment: Alignment.center,
                            value: setor['ID'] as String,
                            child: Text(setor['Descricao'] as String),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
