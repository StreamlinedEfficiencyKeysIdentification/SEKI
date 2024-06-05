// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testeseki/controllers/usuario_controller.dart';
import 'package:testeseki/models/usuario_model.dart';
import 'package:testeseki/views/screens/barcode/scan_code.dart';

import '../../widgets/autocomplete_usuario.dart';

class Chamado extends StatefulWidget {
  final String qrcode;

  const Chamado({
    super.key,
    required this.qrcode,
  });

  @override
  ChamadoState createState() => ChamadoState();
}

class ChamadoState extends State<Chamado> {
  final TextEditingController _equipamentoController = TextEditingController();
  final GlobalKey<AutocompleteUsuarioExampleState> _autocompleteKey =
      GlobalKey();
  bool _isValid = false;
  bool waiting = false;
  String _usuario = '';
  Usuario usuario = Usuario(
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
  String _usuarioSelecionado = '';

  @override
  void initState() {
    super.initState();
    _equipamentoController.addListener(_onTextChanged);
    _carregarUsuarioLogado();

    if (widget.qrcode.isNotEmpty) {
      _equipamentoController.text = widget.qrcode;
      _searchFirestore(widget.qrcode);
    }
  }

  @override
  void dispose() {
    _equipamentoController.dispose();
    super.dispose();
  }

  Future<void> _carregarUsuarioLogado() async {
    // Obtém as informações do usuário logado
    Usuario usuario = await UsuarioController.getUsuarioLogado();

    // Atualiza os valores das variáveis _usuario e _usuarioSelecionado
    setState(() {
      _usuario = usuario.nome;
      _usuarioSelecionado = usuario.uid;
      waiting = true;
    });
  }

  void _onTextChanged() {
    if (_equipamentoController.text.length == 6) {
      _searchFirestore(_equipamentoController.text);
    } else {
      setState(() {
        _isValid = false;
      });
    }
  }

  Future<void> _searchFirestore(String code) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Equipamento')
        .where('IDqrcode', isEqualTo: code)
        .get();

    setState(() {
      _isValid = snapshot.docs.isNotEmpty;
    });
  }

  Future<void> _openScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const BarcodeScannerWithController(returnImmediately: true),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        _equipamentoController.text = result;
        _searchFirestore(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamado'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _equipamentoController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.laptop,
                        color: Colors.blue,
                      ),
                      hintText: "Insira um equipamento",
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: _isValid ? Colors.green : Colors.red,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(100, 50),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: _openScanner,
                          child: const Text(
                            "Search",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      hintText: "Insira um Titulo",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      hintText: "Descrição: ",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 50),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      "Enviar",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      print(_usuarioSelecionado);
                      if (_usuarioSelecionado.isEmpty) {
                        const SnackBar(
                          content: Text('Selecione um usuário'),
                          duration: Duration(seconds: 2),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
