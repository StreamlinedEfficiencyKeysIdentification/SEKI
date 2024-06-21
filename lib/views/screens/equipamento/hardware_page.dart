// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../controllers/equipamento_controller.dart';
import '../../../controllers/usuario_controller.dart';
import '../../../models/usuario_model.dart';
import '../barcode/view_code.dart';
import '../../widgets/autocomplete_usuario.dart';
import '../../widgets/combo_box_empresa.dart';
import '../../widgets/combo_box_setor.dart';

class HardwarePage extends StatefulWidget {
  const HardwarePage({super.key});

  @override
  HardwarePageState createState() => HardwarePageState();
}

class HardwarePageState extends State<HardwarePage> {
  final GlobalKey<AutocompleteUsuarioExampleState> _autocompleteKey =
      GlobalKey();
  final TextEditingController _qrcodeController = TextEditingController();
  final TextEditingController _patrimonioController = TextEditingController();
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
      body: Center(
        // Centraliza o conteúdo na tela
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Centraliza horizontalmente
              mainAxisSize: MainAxisSize
                  .min, // Ajusta a altura da coluna para seu conteúdo
              children: [
                const Column(
                  children: [
                    Icon(
                      Icons.computer,
                      color: Color(0xFF0076BC),
                      size: 140,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Equipamento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
               Row(
  children: [
    Expanded(
      flex: 2,
      child: TextField(
        controller: _qrcodeController,
        readOnly: true, 
        enableInteractiveSelection: false, 
        decoration: InputDecoration(
          labelText: 'QR Code',
          filled: true,
          fillColor: const Color(0xFF0076BC).withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF0076BC),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateQRCodeHash,
          ),
        ),
        
      ),
    ),
  
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _patrimonioController,
                        decoration: InputDecoration(
                          labelText: 'Patrimônio',
                          filled: true,
                          fillColor: const Color(0xFF0076BC).withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          labelStyle: const TextStyle(
                            color: Color(0xFF0076BC),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _marcaController,
                        decoration: InputDecoration(
                          labelText: 'Marca',
                          filled: true,
                          fillColor: const Color(0xFF0076BC).withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          labelStyle: const TextStyle(
                            color: Color(0xFF0076BC),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _modeloController,
                        decoration: InputDecoration(
                          labelText: 'Modelo',
                          filled: true,
                          fillColor: const Color(0xFF0076BC).withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          labelStyle: const TextStyle(
                            color: Color(0xFF0076BC),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
               Padding(
  padding: const EdgeInsets.only(top: 16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
     Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(50.0),
    color: const Color(0xFF0076BC).withOpacity(0.3),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Center(
    child: ComboBoxEmpresa(
      empresa: _empresaSelecionada,
      onEmpresaSelected: (empresa) {
        setState(() {
          _empresaSelecionada = empresa;
        });
      },
    ),
  ),
),

      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: const Color(0xFF0076BC).withOpacity(0.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: ComboBoxSetor(
          encontrado: true,
          setor: _setorSelecionado,
          onSetorSelected: (setor) {
            setState(() {
              _setorSelecionado = setor;
            });
          },
        ),
      ),
    ],
  ),
),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      usuarioValue ? 'Com Usuário' : 'Sem Usuário',
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
                const SizedBox(height: 5),
                usuarioValue
                    ? AutocompleteUsuarioExample(
                        user: _usuarioSelecionado,
                        key: _autocompleteKey,
                        onUsuarioSelected: (usuario) {
                          setState(() {
                            _usuarioSelecionado = usuario;
                          });
                        },
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      _switchValue
                          ? 'Equipamento Ativo'
                          : 'Equipamento Inativo',
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cadastrarEquipamento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0076BC),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    child: const Text(
                      'Registrar',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
        _patrimonioController.text.isEmpty ||
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
      _modeloController.text,
    );

    if (waiting) {
      showDialog(
        context: context,
        barrierDismissible: false,
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
                      builder: (context) {
                        return QRImage(
                          _qrcodeController.text,
                          _empresaSelecionada,
                          sourceRoute: '/hardware',
                        );
                      },
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
