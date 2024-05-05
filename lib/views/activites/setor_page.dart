// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/combo_box_empresa_setor.dart';

class SetorPage extends StatefulWidget {
  const SetorPage({super.key});

  @override
  SetorPageState createState() => SetorPageState();
}

class SetorPageState extends State<SetorPage> {
  bool isSelectionMode = false;
  int listLength = 1;
  late List<bool> _selected;
  bool _selectAll = false;
  late List<TextEditingController> _controllers;
  String _empresaSelecionada = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    initializeSelection();
    _initializeControllers();
  }

  void initializeSelection() {
    _selected = List<bool>.generate(listLength, (_) => false);
  }

  void _initializeControllers() {
    _controllers = List.generate(
      listLength,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    _selected.clear();
    super.dispose();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para salvar os dados no Firestore
  Future<void> _saveDataToFirestore(
      String empresa, List<String> setores) async {
    setState(() {
      _saving = true;
    });

    try {
      if (empresa.isEmpty || setores.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campos vazios. Nenhum dado foi salvo.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _saving = false;
        });
        return;
      }

      // Obter o ID do último documento na coleção 'Setor'
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('Setor')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get();

      // Verificar se há documentos na coleção
      int ultimoID = 0;
      if (querySnapshot.docs.isNotEmpty) {
        ultimoID = int.parse(querySnapshot.docs.first.id);
      }

      // Incrementar o ID para o próximo documento
      int proximoID = ultimoID + 1;

      // Salvar cada setor em um documento separado
      for (String setorValor in setores) {
        await _firestore.collection('Setor').doc(proximoID.toString()).set({
          'IDempresa': empresa,
          'Descricao': setorValor,
        });

        proximoID++;
      }

      // Buscar a RazaoSocial da empresa com base no ID
      DocumentSnapshot empresaSnapshot =
          await _firestore.collection('Empresa').doc(empresa).get();
      String razaoSocial = empresaSnapshot['RazaoSocial'];

      String mensagem =
          'Você adicionou os seguintes setores na empresa $razaoSocial:\n\n';
      for (int i = 0; i < setores.length; i++) {
        mensagem += '- ${setores[i]}\n';
      }

      setState(() {
        _saving = false;
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Criação de Setores'),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar os dados: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setores'),
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    isSelectionMode = false;
                  });
                  initializeSelection();
                },
              )
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ComboBoxEmpresa(
              onEmpresaSelected: (empresa) {
                setState(() {
                  _empresaSelecionada =
                      empresa; // Atualizar o estado do campo 'IDempresa'
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isSelectionMode)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        for (int i = _selected.length - 1; i >= 0; i--) {
                          if (_selected[i]) {
                            _controllers.removeAt(i); // Remove o controlador
                            _selected.removeAt(i); // Remove a seleção
                            listLength = _selected.length;
                          }
                        }
                      });
                    },
                    iconSize: 32,
                  ),
                if (isSelectionMode)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectAll = !_selectAll;
                        _selected =
                            List<bool>.generate(listLength, (_) => _selectAll);
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _selectAll ? 'Desmarcar Todos' : 'Selecionar Todos',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          Expanded(
            child: ListBuilder(
              isSelectionMode: isSelectionMode,
              selectedList: _selected,
              controllers: _controllers,
              onSelectionChange: (bool x) {
                setState(() {
                  isSelectionMode = x;
                });
              },
              onAddField: () {
                setState(() {
                  listLength++;
                  _selected.add(false);
                  _controllers.add(TextEditingController());
                });
              },
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _saving
                ? null
                : () {
                    String empresa = _empresaSelecionada;
                    List<String> setores = _controllers
                        .map((controller) => controller.text)
                        .where((value) => value.isNotEmpty)
                        .toList();
                    _saveDataToFirestore(empresa, setores);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class ListBuilder extends StatefulWidget {
  const ListBuilder({
    super.key,
    required this.isSelectionMode,
    required this.selectedList,
    required this.controllers,
    required this.onSelectionChange,
    required this.onAddField,
  });

  final bool isSelectionMode;
  final List<bool> selectedList;
  final List<TextEditingController> controllers;
  final ValueChanged<bool>? onSelectionChange;
  final VoidCallback? onAddField;

  @override
  State<ListBuilder> createState() => _ListBuilderState();
}

class _ListBuilderState extends State<ListBuilder> {
  void _toggle(int index) {
    if (widget.isSelectionMode) {
      setState(() {
        widget.selectedList[index] = !widget.selectedList[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.selectedList.length + 1,
      itemBuilder: (_, int index) {
        if (index == widget.selectedList.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              onPressed: widget.onAddField,
              child: const Text('Adicionar Campo'),
            ),
          );
        }

        return ListTile(
          onTap: () => _toggle(index),
          onLongPress: () {
            if (!widget.isSelectionMode) {
              setState(() {
                widget.selectedList[index] = true;
              });
              widget.onSelectionChange!(true);
            }
          },
          trailing: widget.isSelectionMode
              ? Checkbox(
                  value: widget.selectedList[index],
                  onChanged: (bool? x) => _toggle(index),
                )
              : const SizedBox.shrink(),
          title: TextFormField(
            controller: widget.controllers[index],
            decoration: InputDecoration(
              labelText: 'Setor ${index + 1}',
            ),
          ),
        );
      },
    );
  }
}
