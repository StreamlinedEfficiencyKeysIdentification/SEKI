// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Chamado'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/view_chamados');
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
            const Text('Status: '),
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
            if (waiting)
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
