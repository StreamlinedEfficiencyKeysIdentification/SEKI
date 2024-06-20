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
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoSection(),
            const SizedBox(height: 16.0),
            _buildDropdownAndResponsavel(),
            const SizedBox(height: 16.0),
            const SizedBox(height: 16.0),
            _buildAssumirButton(),
            const SizedBox(height: 16.0),
            _buildSaveAndCancelButton(),
            const SizedBox(height: 16.0),
            _buildNovaMensagemButton(),
            const SizedBox(height: 16.0),
            _buildMensagensList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBoldText('Chamado: ${_chamado.IDchamado}'),
        _buildTextCausa('${_chamado.Titulo}'),
        _buildTextProblema('Problema: ${_chamado.Descricao}'),
        _buildText(nivelUsuario == 4 ? 'Status: ${_chamado.Status}' : ''),
        _buildText(nivelUsuario == 4 ? 'Responsável: $user' : ''),
        _buildTextEmpresa(' $_empresa'),
        _buildText('Criado em: ${_chamado.DataCriacao}'),
        _buildText('Atualizado: ${_chamado.DataAtualizacao}'),
        _buildText('Lido: ${_chamado.Lido ? 'Sim' : 'Não'}'),
      ],
    );
  }

  Widget _buildDropdownAndResponsavel() {
    if (nivelUsuario <= 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownMenu<String>(
            initialSelection: dropdownValue,
            onSelected: (String? value) {
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
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }


  Widget _buildAssumirButton() {
    if (nivelUsuario <= 3 &&
        _chamado.Responsavel.isEmpty &&
        widget.uid != _chamado.Responsavel) {
      return ElevatedButton(
        onPressed: _assumirChamado,
        child: const Text('Assumir'),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildSaveAndCancelButton() {
    if (_isDataChanged()) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSaveButton(),
          _buildCancelButton(),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildNovaMensagemButton() {
    return ElevatedButton(
      onPressed: _showNovaMensagemDialog,
      child: const Text('Nova Mensagem'),
    );
  }

  Widget _buildMensagensList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchMensagens(),
      key: _futureBuilderKey,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar mensagens'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma mensagem encontrada'));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> mensagemData = snapshot.data![index];
              bool isMinhaMensagem = mensagemData['Remetente'] ==
                  'eu'; // Adaptar conforme sua lógica de remetente

              return _buildMessageBubble(
                mensagemData['Mensagem'],
                mensagemData['NomeUsuario'],
                mensagemData['DataMensagem'] as Timestamp,
                isMinhaMensagem,
              );
            },
          );
        }
      },
    );
  }

  Widget _buildMessageBubble(String mensagem, String nomeUsuario,
      Timestamp timestamp, bool isMinhaMensagem) {
    CrossAxisAlignment alignment =
        isMinhaMensagem ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    Color bubbleColor = isMinhaMensagem ? Colors.blue[200]! : Colors.grey[300]!;

    DateTime dateTime = timestamp.toDate();
    String formattedDate =
        DateFormat('dd/MM/yyyy \'às\' HH:mm:ss').format(dateTime);

    return Align(
      alignment: isMinhaMensagem ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            Text(
              '$nomeUsuario - $formattedDate',
              style: const TextStyle(fontSize: 12.0),
            ),
            const SizedBox(height: 4.0),
            Text(
              mensagem,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoldText(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'images/chatsupport.png',
          height: 24,
          width: 36,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w200, color: Colors.white, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15),
    );
  }

   Widget _buildTextCausa(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 36, 49)),
    );
  }
    Widget _buildTextEmpresa(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'images/empresa.png',
          height: 24,
          width: 36, color: Colors.white,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w200, color: Color.fromARGB(255, 220, 220, 221), fontSize: 18),
        ),
      ],
    );
  }

 Widget _buildTextProblema(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 7, 7, 46)),
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
