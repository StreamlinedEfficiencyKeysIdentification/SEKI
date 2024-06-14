// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testeseki/controllers/chamado_controller.dart';
import 'package:testeseki/models/chamado_model.dart';
import 'package:testeseki/views/widgets/autocomplete_usuario.dart';

const List<String> list = <String>[
  'Não iniciado',
  'Em andamento',
  'Aguardando',
  'Concluído'
];

class DetalheChamado extends StatefulWidget {
  final Chamado chamado;
  final String nivel;
  final String uid;
  final String empresa;

  const DetalheChamado({
    super.key,
    required this.chamado,
    required this.nivel,
    required this.uid,
    required this.empresa,
  });

  @override
  DetalheChamadoState createState() => DetalheChamadoState();
}

class DetalheChamadoState extends State<DetalheChamado> {
  final GlobalKey<AutocompleteUsuarioExampleState> _autocompleteKey =
      GlobalKey();
  // Declare a GlobalKey para o FutureBuilder
  final GlobalKey<State<DetalheChamado>> _futureBuilderKey = GlobalKey();
  Chamado _chamado = Chamado(
      IDdoc: '',
      IDchamado: '',
      QRcode: '',
      Titulo: '',
      Usuario: '',
      Descricao: '',
      Empresa: '',
      Status: '',
      Responsavel: '',
      DataCriacao: '',
      DataAtualizacao: '',
      Lido: false);
  int nivelUsuario = 0;
  String dropdownValue = '';
  late String _usuario = '';
  late String user = '';
  String _usuarioSelecionado = '';
  bool waiting = false;
  String _empresa = '';

  @override
  void initState() {
    super.initState();
    fetchChamado();
  }

  void fetchChamado() async {
    try {
      Chamado chamado = await ChamadoController.getChamadoById(
        widget.chamado.IDdoc,
        widget.chamado.IDchamado,
      );
      setState(() {
        _chamado = chamado;

        initializeFields();
        fetchUsuario();
        fetchEmpresa();

        _atualizarCampoLidoSeNecessario();
      });
    } catch (e) {
      // Trate qualquer erro que possa ocorrer durante a busca da empresa
      print('Erro ao buscar usuario: $e');
    }
  }

  void initializeFields() {
    _usuarioSelecionado = _chamado.Responsavel;
    dropdownValue = _chamado.Status;
  }

  void fetchUsuario() async {
    if (_chamado.Responsavel.isEmpty) {
      return;
    }
    DocumentSnapshot usuarioSnapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(_chamado.Responsavel)
        .get();
    if (usuarioSnapshot.exists) {
      setState(() {
        _usuario = usuarioSnapshot['Nome'];
        user = usuarioSnapshot['Usuario'];
        waiting = true;
      });
    }
  }

  void fetchEmpresa() async {
    DocumentSnapshot empresaSnapshot = await FirebaseFirestore.instance
        .collection('Empresa')
        .doc(_chamado.Empresa)
        .get();
    if (empresaSnapshot.exists) {
      setState(() {
        _empresa = empresaSnapshot['RazaoSocial'];
      });
    }
  }

  Future<void> _atualizarCampoLidoSeNecessario() async {
    nivelUsuario = int.tryParse(widget.nivel) ?? 0;
    if (_chamado.Lido == false && nivelUsuario <= 3) {
      try {
        await ChamadoController.marcarChamadoComoLido(
          _chamado.IDdoc,
          _chamado.IDchamado,
        );
      } catch (e) {
        print('Erro ao marcar chamado como lido: $e');
      }
    }
  }

  Future<void> _assumirChamado() async {
    if (_chamado.Responsavel != widget.uid &&
        nivelUsuario <= 3 &&
        widget.uid == widget.chamado.Responsavel) {
      try {
        await ChamadoController.assumirChamado(
          _chamado.IDdoc,
          _chamado.IDchamado,
          widget.uid,
        );
      } catch (e) {
        print('Erro ao assumir chamado: $e');
      }
    }
  }

  void _showNovaMensagemDialog() {
    TextEditingController mensagemController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nova Mensagem'),
          content: TextField(
            controller: mensagemController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Digite sua mensagem...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Enviar'),
              onPressed: () async {
                String mensagem = mensagemController.text;
                if (mensagem.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('Tramites').add({
                    'IDchamado': _chamado.IDchamado,
                    'IDusuario': widget.uid,
                    'Mensagem': mensagem,
                    'DataMensagem': FieldValue.serverTimestamp(),
                  });
                  Navigator.of(context).pop();
                  _fetchMensagens();
                  setState(() {
                    _futureBuilderKey == GlobalKey();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchMensagens() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Tramites')
        .where('IDchamado', isEqualTo: _chamado.IDchamado)
        .orderBy('DataMensagem', descending: true)
        .get();

    List<Map<String, dynamic>> mensagensComUsuario = [];

    for (DocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> mensagemData = doc.data() as Map<String, dynamic>;
      String usuarioId = mensagemData['IDusuario'];

      DocumentSnapshot usuarioSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(usuarioId)
          .get();

      if (usuarioSnapshot.exists) {
        mensagemData['NomeUsuario'] = usuarioSnapshot['Usuario'];
      } else {
        mensagemData['NomeUsuario'] = 'Usuário desconhecido';
      }

      mensagensComUsuario.add(mensagemData);
    }
    return mensagensComUsuario;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Chamado'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID do Chamado: ${_chamado.IDchamado}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text('Título: ${_chamado.Titulo}'),
            const SizedBox(height: 8.0),
            Text('Descrição: ${_chamado.Descricao}'),
            const SizedBox(height: 8.0),
            Text('Empresa: $_empresa'),
            const SizedBox(height: 8.0),
            Text('Status: ${nivelUsuario == 4 ? _chamado.Status : ''}'),
            if (nivelUsuario <= 3)
              DropdownMenu<String>(
                initialSelection: dropdownValue,
                onSelected: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                dropdownMenuEntries:
                    list.map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              ),
            const SizedBox(height: 8.0),
            Text(nivelUsuario == 4 ? 'Responsável: $user' : ''),
            if (waiting && nivelUsuario <= 3)
              AutocompleteUsuarioExample(
                user: _usuario,
                key: _autocompleteKey,
                onUsuarioSelected: (usuario) {
                  setState(() {
                    _usuarioSelecionado = usuario;
                  });
                },
              ),
            const SizedBox(height: 8.0),
            Text('Data de Criação: ${_chamado.DataCriacao}'),
            const SizedBox(height: 8.0),
            Text('Data de Atualização: ${_chamado.DataAtualizacao}'),
            const SizedBox(height: 8.0),
            Text('Lido: ${_chamado.Lido ? 'Sim' : 'Não'}'),
            const SizedBox(height: 8.0),
            if (nivelUsuario <= 3 &&
                _chamado.Responsavel.isEmpty &&
                widget.uid != _chamado.Responsavel)
              ElevatedButton(
                onPressed: _assumirChamado,
                child: const Text('Assumir'),
              ),
            const SizedBox(height: 8.0),
            if (_isDataChanged()) _buildSaveButton(),
            if (_isDataChanged()) _buildCancelButton(),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _showNovaMensagemDialog,
              child: const Text('Nova Mensagem'),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchMensagens(),
              key: _futureBuilderKey,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Erro ao carregar mensagens');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhuma mensagem encontrada');
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> mensagemData = snapshot.data![index];
                      String mensagem = mensagemData['Mensagem'];
                      String nomeUsuario = mensagemData['NomeUsuario'];
                      Timestamp timestamp =
                          mensagemData['DataMensagem'] as Timestamp;
                      DateTime dateTime = timestamp.toDate();

                      String formattedDate =
                          DateFormat('dd/MM/yyyy \'às\' HH:mm:ss')
                              .format(dateTime);

                      return ListTile(
                        title:
                            Text('Enviado por: $nomeUsuario em $formattedDate'),
                        subtitle: Text(
                          mensagem,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  bool _isDataChanged() {
    return dropdownValue != _chamado.Status ||
        _usuarioSelecionado != _chamado.Responsavel;
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          // Atualizar os dados no banco de dados
          await ChamadoController.atualizarChamado(
            _chamado.IDdoc,
            _chamado.IDchamado,
            _usuarioSelecionado,
            dropdownValue,
          );

          fetchChamado();

          // Mostrar uma mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('As informações foram salvas com sucesso.'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          print('Erro ao salvar dados: $e');
        }
      },
      child: const Text('Salvar'),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          // Resetar os campos para os valores originais
          fetchChamado();
          _autocompleteKey.currentState?.reconstruirWidget();
        });
      },
      child: const Text('Cancelar'),
    );
  }
}
