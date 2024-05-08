// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/empresa_model.dart';

class SetorPage extends StatefulWidget {
  final Empresa empresa;

  const SetorPage({
    super.key,
    required this.empresa,
  });

  @override
  SetorPageState createState() => SetorPageState();
}

class SetorPageState extends State<SetorPage> {
  bool isSelectionMode = false;
  int listLength = 1;
  late List<bool> _selected;
  bool _selectAll = false;
  late List<TextEditingController> _controllers = [];
  bool _saving = false;
  late List<String> _existingSetores = [];

  @override
  void initState() {
    super.initState();
    initializeSelection();
    _initializeControllers();
    _loadExistingSetores();
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

  // Carregar setores existentes da empresa do Firestore
  Future<void> _loadExistingSetores() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('Setor')
        .where('IDempresa', isEqualTo: widget.empresa.id)
        .get();

    // Extrair os setores da consulta
    _existingSetores =
        querySnapshot.docs.map((doc) => doc['Descricao'] as String).toList();

    // Se houver setores existentes, atualize os controladores
    if (_existingSetores.isNotEmpty) {
      setState(() {
        _controllers = _existingSetores
            .map((setor) => TextEditingController(text: setor))
            .toList();
        listLength = _existingSetores.length;
        _selected = List<bool>.generate(listLength, (_) => false);
      });
    }
  }

  // Restaurar os controladores para os valores originais
  void _restoreControllers() {
    // Limpar os controladores existentes
    _controllers.clear();

    // Se houver setores existentes, recuperá-los da coleção separada
    if (_existingSetores.isNotEmpty) {
      _controllers = _existingSetores
          .map((setor) => TextEditingController(text: setor))
          .toList();
    }

    // Atualizar o comprimento da lista e as seleções
    listLength = _controllers.length;
    _selected = List<bool>.generate(listLength, (_) => false);
  }

  bool _compareSetores(
      List<String> currentSetores, List<String> originalSetores) {
    // Se o número de setores for diferente, houve alterações
    if (currentSetores.length != originalSetores.length) {
      return true;
    }

    // Ordenar as listas para garantir uma comparação precisa
    currentSetores.sort();
    originalSetores.sort();

    // Comparar os setores um por um
    for (int i = 0; i < currentSetores.length; i++) {
      if (currentSetores[i] != originalSetores[i]) {
        return true;
      }
    }

    // Se nenhum setor foi diferente, não houve alterações
    return false;
  }

  Future<void> _saveDataToFirestore(List<String> setores) async {
    setState(() {
      _saving = true;
    });

    try {
      if (widget.empresa.id.isEmpty || setores.isEmpty) {
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

      bool hasChanges = _compareSetores(setores, _existingSetores);

      if (!hasChanges) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não houve alterações. Nenhum dado foi salvo.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _saving = false;
        });
        return;
      }

      // Obter os setores existentes da empresa atual
      final QuerySnapshot<Map<String, dynamic>> existingSetoresSnapshot =
          await FirebaseFirestore.instance
              .collection('Setor')
              .where('IDempresa', isEqualTo: widget.empresa.id)
              .get();

      final List<String> existingSetores = existingSetoresSnapshot.docs
          .map((doc) => doc['Descricao'].toString())
          .toList();

      // Salvar novos setores
      for (final setor in setores) {
        if (!existingSetores.contains(setor)) {
          await FirebaseFirestore.instance.collection('Setor').add({
            'IDempresa': widget.empresa.id,
            'Descricao': setor,
          });
        }
      }

      // Atualizar setores existentes
      for (final setor in existingSetores) {
        if (!setores.contains(setor)) {
          final QuerySnapshot<Map<String, dynamic>> setorSnapshot =
              await FirebaseFirestore.instance
                  .collection('Setor')
                  .where('IDempresa', isEqualTo: widget.empresa.id)
                  .where('Descricao', isEqualTo: setor)
                  .get();

          final docId = setorSnapshot.docs.first.id;
          await FirebaseFirestore.instance
              .collection('Setor')
              .doc(docId)
              .update({'Descricao': setor});
        }
      }

      // Excluir setores removidos
      for (final setor in existingSetores) {
        if (!setores.contains(setor)) {
          final QuerySnapshot<Map<String, dynamic>> setorSnapshot =
              await FirebaseFirestore.instance
                  .collection('Setor')
                  .where('IDempresa', isEqualTo: widget.empresa.id)
                  .where('Descricao', isEqualTo: setor)
                  .get();

          final docId = setorSnapshot.docs.first.id;
          await FirebaseFirestore.instance
              .collection('Setor')
              .doc(docId)
              .delete();
        }
      }

      // Atualizar a lista de setores na tela
      setState(() {
        _existingSetores = setores;
      });

      // Exibir uma mensagem de sucesso ou atualizar a interface do usuário, se necessário
      setState(() {
        _saving = false;
      });

      String razaoSocial = widget.empresa.razaoSocial;

      String mensagem =
          'Você adicionou os seguintes setores na empresa $razaoSocial:\n\n';
      for (int i = 0; i < setores.length; i++) {
        mensagem += '- ${setores[i]}\n';
      }

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
                    List<String> setores = _controllers
                        .map((controller) => controller.text)
                        .where((value) => value.isNotEmpty)
                        .toList();
                    _saveDataToFirestore(setores);
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
          if (!_saving && _existingSetores.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _restoreControllers();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cancelar',
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
