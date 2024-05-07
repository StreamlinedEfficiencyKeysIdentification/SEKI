// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../controllers/equipamento_controller.dart';
import '../../controllers/usuario_controller.dart';
import '../../models/usuario_model.dart';
import '../../barcode/view_code.dart';
import '../widgets/autocomplete_usuario.dart';
import '../widgets/combo_box_empresa.dart';
import '../widgets/combo_box_setor.dart';

class HardwarePage extends StatefulWidget {
  const HardwarePage({super.key});

  @override
  HardwarePageState createState() => HardwarePageState();
}

class HardwarePageState extends State<HardwarePage> {
  final TextEditingController _qrcodeController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  String _empresaSelecionada = '';
  String _setorSelecionado = '';
  String _usuarioSelecionado = '';
  bool _switchValue = false;
  bool usuarioValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Hardware'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qrcodeController,
                      decoration: const InputDecoration(labelText: 'QRcode'),
                      enabled: false, // Desabilita a edição do campo
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      _generateQRCodeHash();
                    },
                  ),
                ],
              ),
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(labelText: 'Marca'),
              ),
              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(labelText: 'Modelo'),
              ),
              ComboBoxEmpresa(
                onEmpresaSelected: (empresa) {
                  setState(() {
                    _empresaSelecionada = empresa;
                  });
                },
              ),
              ComboBoxSetor(
                onSetorSelected: (setor) {
                  setState(() {
                    _setorSelecionado = setor;
                  });
                },
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        usuarioValue
                            ? 'Inserir Usuário'
                            : 'Não Inserir Usuário',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: usuarioValue ? Colors.green : Colors.grey,
                        ),
                      ),
                      Switch(
                        value: usuarioValue,
                        onChanged: (value) {
                          setState(() {
                            usuarioValue = value;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    child: usuarioValue
                        ? AutocompleteUsuarioExample(
                            onUsuarioSelected: (usuario) {
                              setState(() {
                                _usuarioSelecionado = usuario;
                              });
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _switchValue ? 'Equipamento Ativo' : 'Equipamento Inativo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _switchValue ? Colors.green : Colors.grey,
                    ),
                  ),
                  Switch(
                    value: _switchValue,
                    onChanged: (value) {
                      setState(() {
                        _switchValue = value;
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: cadastrarEquipamento,
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateQRCodeHash() async {
    // Buscar a empresa do usuário logado
    Usuario usuario = await UsuarioController.getUsuarioLogado();

    // Identificar a empresa matriz à qual o usuário pertence
    String matriz = '';
    DocumentSnapshot empresaSnapshot = await FirebaseFirestore.instance
        .collection('Empresa')
        .doc(usuario.empresa)
        .get();

    matriz = empresaSnapshot['EmpresaPai'].toString();

    DocumentSnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('QRcode').doc(matriz).get();

    List<String> hashesExistentes = [];

    String novoHash = '';
    bool hashExistente = true;
    int tentativas = 0;
    int maxTentativas = 1000000;

    while (hashExistente && tentativas < maxTentativas) {
      novoHash = _gerarHashUnico();

      if (querySnapshot.exists) {
        Map<String, dynamic>? dados =
            querySnapshot.data() as Map<String, dynamic>?;
        if (dados != null &&
            !dados.containsKey(novoHash) &&
            !hashesExistentes.contains(novoHash)) {
          hashExistente = false;
        }
      } else {
        hashExistente = false;
      }

      hashesExistentes.add(novoHash);

      tentativas++;
    }

    if (tentativas == maxTentativas) {
      print(
          'Não foi possível gerar um hash único após $maxTentativas tentativas.');
    } else {
      setState(() {
        _qrcodeController.text = novoHash;
      });
    }
  }

  String _gerarHashUnico() {
    final Random random = Random();

    String hash = '';

    for (int i = 0; i < 6; i++) {
      int randomNumber = random.nextInt(10);

      hash += randomNumber.toString();
    }

    return hash;
  }

  void cadastrarEquipamento() async {
    if (_qrcodeController.text.isEmpty ||
        _marcaController.text.isEmpty ||
        _modeloController.text.isEmpty ||
        _empresaSelecionada.isEmpty ||
        _setorSelecionado.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Campos obrigatórios'),
            content:
                const Text('Por favor, preencha todos os campos obrigatórios.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    if (usuarioValue && _usuarioSelecionado.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Usuário obrigatório',
            ),
            content: const Text(
              'Por favor, selecione um usuário ou desative a opção de inserir usuário.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    bool waiting = await EquipamentoController.cadastrarEquipamento(
        context,
        _qrcodeController.text,
        _empresaSelecionada,
        _setorSelecionado,
        _usuarioSelecionado,
        _switchValue,
        _marcaController.text,
        _modeloController.text);

    if (waiting) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Cadastrado com sucesso!'),
            content: const Text('Deseja salvar o QR Code?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) {
                        return QRImage(_qrcodeController);
                      }),
                    ),
                  );
                },
                child: const Text('Sim'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/hardware');
                },
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Falha ao cadastrar o equipamento.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class SwitchExample extends StatefulWidget {
  final void Function(bool) onValueChanged;

  const SwitchExample({
    super.key,
    required this.onValueChanged,
  });

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  bool light1 = false;

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Switch(
          thumbIcon: thumbIcon,
          value: light1,
          onChanged: (bool value) {
            setState(() {
              light1 = value;
            });
            widget
                .onValueChanged(value); // Chama a função de retorno de chamada
          },
        ),
      ],
    );
  }
}
