// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'controllers/equipamento_controller.dart';
import 'views/autocomplete_usuario.dart';
import 'views/combo_box_empresa.dart';
import 'views/combo_box_setor.dart';

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
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _qrcodeController,
                decoration: const InputDecoration(labelText: 'Qrcode'),
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
            title: const Text('Usuário obrigatório'),
            content: const Text(
                'Por favor, selecione um usuário ou desative a opção de inserir usuário.'),
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
    await EquipamentoController.cadastrarEquipamento(
      _qrcodeController.text,
      _empresaSelecionada,
      _setorSelecionado,
      _usuarioSelecionado,
      _switchValue,
      _marcaController.text,
      _modeloController.text,
    );

    _qrcodeController.clear();
    _marcaController.clear();
    _modeloController.clear();
    _empresaSelecionada = '';
    _setorSelecionado = '';
    _usuarioSelecionado = '';
    _switchValue = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usuário registrado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) => const HardwarePage(),
    ));
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
