// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/empresa_model.dart';

class SetorModel {
  final String id;
  final String descricao;

  SetorModel({required this.id, required this.descricao});
}

class SetorEditingController {
  final String id;
  final TextEditingController controller;

  SetorEditingController({required this.id, required this.controller});

  String getText() {
    return controller.text;
  }
}

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
  late List<SetorEditingController> _controllers = [];
  bool _saving = false;
  late List<SetorModel> _existingSetores = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    initializeSelection();
    _initializeControllers();
    _loadExistingSetores();
  }

  void initializeSelection() {
    _selected = List<bool>.generate(listLength, (_) => false);
  }

  _initializeControllers() {
    _controllers = List.generate(
      listLength,
      (index) => SetorEditingController(
        id: _existingSetores.isNotEmpty && index < _existingSetores.length
            ? _existingSetores[index].id
            : '', // Definir o ID vazio para novos setores
        controller: TextEditingController(),
      ),
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
    _existingSetores = querySnapshot.docs.map((doc) {
      return SetorModel(
        id: doc.id,
        descricao: doc['Descricao'] as String,
      );
    }).toList();

    // Se houver setores existentes, atualize os controladores
    if (_existingSetores.isNotEmpty) {
      setState(() {
        _controllers = _existingSetores.map((setor) {
          return SetorEditingController(
            id: setor.id,
            controller: TextEditingController(text: setor.descricao),
          );
        }).toList();
        listLength = _existingSetores.length;
        _selected = List<bool>.generate(listLength, (_) => false);
      });
    }
  }

  // Restaurar os controladores para os valores originais
  void _restoreControllers() {
    if (!_checkForChanges(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Não houve alterações dentro dos campos. Nenhum dado foi salvo.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _saving = false;
      });
      return;
    }
    if (_existingSetores.isEmpty) return;
    // Limpar os controladores existentes
    _controllers.clear();

    // Se houver setores existentes, recuperá-los da coleção separada
    if (_existingSetores.isNotEmpty) {
      setState(() {
        _controllers = _existingSetores.map((setor) {
          return SetorEditingController(
            id: setor.id,
            controller: TextEditingController(text: setor.descricao),
          );
        }).toList();
        listLength = _existingSetores.length;
        _selected = List<bool>.generate(listLength, (_) => false);
      });
    }

    // Atualizar o comprimento da lista e as seleções
    listLength = _controllers.length;
    _selected = List<bool>.generate(listLength, (_) => false);
  }

  bool _checkForChanges(bool checkForEmpty) {
    if (checkForEmpty) {
      if (_controllers.length != _existingSetores.length) {
        return true;
      }
    }

    for (int i = 0; i < _controllers.length; i++) {
      String currentText = _controllers[i].getText();
      String originalText =
          _existingSetores.isNotEmpty && i < _existingSetores.length
              ? _existingSetores[i].descricao
              : '';

      if (currentText != originalText) {
        return true;
      }
    }

    return false;
  }

  Future<void> _saveDataToFirestore(List<SetorModel> setores) async {
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

      // Verifica se houve mudanças
      if (!_checkForChanges(false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Não houve alterações dentro dos campos. Nenhum dado foi salvo.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _saving = false;
        });
        return;
      }

      // Montar a lista de setores excluindo os campos vazios
      List<SetorModel> setoresParaSalvar = [];
      for (int i = 0; i < _controllers.length; i++) {
        String id = '';
        if (_existingSetores.isNotEmpty && i < _existingSetores.length) {
          id = _existingSetores[i].id;
        }

        String descricao = _controllers[i].getText();

        // Verificar se a descrição não está vazia antes de adicionar à lista
        if (descricao.isNotEmpty) {
          setoresParaSalvar.add(SetorModel(id: id, descricao: descricao));
        }
      }

      // Iterar sobre a lista de setores
      for (SetorModel setor in setoresParaSalvar) {
        if (setor.id.isNotEmpty) {
          // Se o ID do documento estiver presente, atualizar o documento correspondente
          await _firestore.collection('Setor').doc(setor.id).update({
            'Descricao': setor.descricao,
          });
        } else {
          // Se o ID do documento não estiver presente, adicionar um novo documento
          await _firestore.collection('Setor').add({
            'Descricao': setor.descricao,
            'IDempresa': widget.empresa.id,
          });
        }
      }
      // Atualizar a lista de setores na tela
      setState(() {
        _existingSetores = setoresParaSalvar;
      });

      // Exibir uma mensagem de sucesso ou atualizar a interface do usuário, se necessário
      setState(() {
        _saving = false;
      });

      String razaoSocial = widget.empresa.razaoSocial;

      String mensagem =
          'Existe os seguintes setores na empresa $razaoSocial:\n\n';
      for (int i = 0; i < setoresParaSalvar.length; i++) {
        mensagem += '- ${setoresParaSalvar[i].descricao}\n';
      }

      initialize();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Setores'),
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

  Future<void> _deleteSelectedSetores() async {
    List<String> selectedIds = [];

    // Identificar os IDs dos setores selecionados
    for (int i = 0; i < _selected.length; i++) {
      if (_selected[i] && _controllers[i].id.isNotEmpty) {
        selectedIds.add(_controllers[i].id);
      }
    }

    if (selectedIds.isEmpty) {
      return; // Não há setores com IDs selecionados para excluir
    }

    bool confirmarExclusao = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
            'Tem certeza de que deseja excluir os setores selecionados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmarExclusao == true) {
      // Excluir os setores do banco de dados
      for (String id in selectedIds) {
        try {
          await _firestore.collection('Setor').doc(id).delete();
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir setor: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      // Remover os setores da lista de setores na tela e os controladores correspondentes
      setState(() {
        _existingSetores.removeWhere((setor) => selectedIds.contains(setor.id));
        _controllers
            .removeWhere((controller) => selectedIds.contains(controller.id));
        listLength = _existingSetores.length;
        _selected = List<bool>.generate(listLength, (_) => false);

        isSelectionMode = false;
      });

      initialize();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setores selecionados excluídos com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1,
            ),
            child: Image.asset(
              'images/setor.png',
              width: 100,
              height: 100,
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
                    onPressed: _deleteSelectedSetores,
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
                  _controllers.add(SetorEditingController(
                      id: '', controller: TextEditingController()));
                });
              },
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _saving
                ? null
                : () {
                    List<SetorModel> setores = [];
                    for (int i = 0; i < _controllers.length; i++) {
                      String id = '';
                      if (_existingSetores.isNotEmpty &&
                          i < _existingSetores.length) {
                        id = _existingSetores[i].id;
                      }
                      setores.add(SetorModel(
                          id: id, descricao: _controllers[i].getText()));
                    }

                    setState(() {
                      _saving = true;
                    });
                    _saveDataToFirestore(setores).then((_) {
                      setState(() {
                        _saving = false;
                      });
                    });
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
          if (!_saving)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _restoreControllers();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 190, 10, 10),
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              isSelectionMode
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF0076BC),
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          isSelectionMode = false;
                        });
                        initializeSelection();
                      },
                    )
                  : IconButton(
                      onPressed: () {
                        if (_checkForChanges(true)) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Descartar Alterações?'),
                                content: const Text(
                                    'Tem certeza que deseja descartar as alterações e sair?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Fechar o AlertDialog
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Sim'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Fechar o AlertDialog
                                    },
                                    child: const Text('Não'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF0076BC),
                        size: 32,
                      ),
                    ),
              IconButton(
                icon: const Icon(
                  Icons.home,
                  color: Color(0xFF0076BC),
                  size: 32,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.person,
                  color: Color(0xFF0076BC),
                  size: 32,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
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
  final List<SetorEditingController> controllers;
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
            controller: widget.controllers[index].controller,
            decoration: InputDecoration(
              labelText: 'Setor ${index + 1}',
            ),
          ),
        );
      },
    );
  }
}
