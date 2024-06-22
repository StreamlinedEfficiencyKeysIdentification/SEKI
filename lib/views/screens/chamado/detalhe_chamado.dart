// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  double _statusBarHeight = 0;

  @override
  void initState() {
    super.initState();
    fetchChamado();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statusBarHeight = MediaQuery.of(context).padding.top;
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
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, _statusBarHeight + 16.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoSection(),
            const SizedBox(height: 16.0),
            _buildDropdownAndResponsavel(),
            const SizedBox(height: 16.0),
            Container(
              alignment: Alignment.centerRight,
              child: Column(
                children: [
                  Text(
                    'Criado em: ${_chamado.DataCriacao}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Atualizado: ${_chamado.DataAtualizacao}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            _buildAssumirButton(),
            const SizedBox(height: 16.0),
            _buildSaveAndCancelButton(),
            const SizedBox(height: 16.0),
            _buildNovaMensagemButton(),
            _buildMensagensList(),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 228, 242, 253),
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
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF0076BC),
                  size: 32,
                ),
                onPressed: () {
                  if (nivelUsuario == 4) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushNamed(context, '/view_chamados');
                  }
                },
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

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBoldText('Chamado: ${_chamado.IDchamado}'),
        _buildTextEmpresa(' $_empresa'),
        const SizedBox(height: 8.0),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.blue[200],
            borderRadius:
                BorderRadius.circular(10.0), // Adicionando borda arredondada
            border: Border.all(
              color: Colors.lightBlueAccent,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                _chamado.Titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 23, 36, 49),
                ),
              ),
              Text(
                'Problema: ${_chamado.Descricao}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 7, 7, 46),
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          child: _chamado.Lido
              ? const Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      color: Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      'Lido',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : const Row(
                  children: [
                    Icon(
                      Icons.visibility_off,
                      color: Colors.red,
                      size: 16,
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      'Não lido',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 8.0),
        Text(
          nivelUsuario == 4 ? 'Status: ${_chamado.Status}' : '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          nivelUsuario == 4 ? 'Responsável: $user' : '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownAndResponsavel() {
    if (nivelUsuario <= 3 && waiting) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(
                  color: Colors.lightBlueAccent,
                  width: 2.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text(
                    'Selecione o status',
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
                  value: dropdownValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                  items: list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      alignment: Alignment.center,
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
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
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        ),
        child: const Text(
          'Assumir',
          style: TextStyle(
            color: Color(0xFF0076BC),
          ),
        ),
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

  Widget _buildSaveButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
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
      child: const Text(
        'Salvar',
        style: TextStyle(
          color: Color(0xFF0076BC),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
      onPressed: () {
        setState(() {
          // Resetar os campos para os valores originais
          fetchChamado();
          _autocompleteKey.currentState?.reconstruirWidget();
        });
      },
      child: const Text(
        'Cancelar',
        style: TextStyle(
          color: Color(0xFF0076BC),
        ),
      ),
    );
  }

  Widget _buildNovaMensagemButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showNovaMensagemDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0076BC),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
        child: const Text(
          'Nova Mensagem',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48.0,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'No momento não há mensagens.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            ),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> mensagemData = snapshot.data![index];
              String usuarioId = mensagemData['IDusuario'];
              bool isResponsavel = usuarioId == _chamado.Responsavel;

              return _buildMessageBubble(
                mensagemData['Mensagem'],
                mensagemData['NomeUsuario'],
                mensagemData['DataMensagem'] as Timestamp,
                isResponsavel,
              );
            },
          );
        }
      },
    );
  }

  Widget _buildMessageBubble(String mensagem, String nomeUsuario,
      Timestamp timestamp, bool isResponsavel) {
    CrossAxisAlignment alignment =
        isResponsavel ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    Color bubbleColor = isResponsavel ? Colors.blue[200]! : Colors.white;

    DateTime dateTime = timestamp.toDate();
    String formattedDate =
        DateFormat('dd/MM/yyyy \'às\' HH:mm:ss').format(dateTime);

    return Align(
      alignment: isResponsavel ? Alignment.centerRight : Alignment.centerLeft,
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
          height: 32,
          width: 32,
          color: Colors.black,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildTextEmpresa(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'images/empresa.png',
          height: 16,
          width: 16,
          color: Colors.black,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  bool _isDataChanged() {
    return dropdownValue != _chamado.Status ||
        _usuarioSelecionado != _chamado.Responsavel;
  }
}
