// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  String _empresaSelecionada = '';
  String _setorSelecionado = '';
  String _usuarioSelecionado = '';
  bool _switchValue = false;
  bool usuarioValue = false;
  double _statusBarHeight = 0;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statusBarHeight = MediaQuery.of(context).padding.top;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Centraliza o conteúdo na tela
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, _statusBarHeight, 16.0, 16.0),
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
                      size: 100,
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
                TextField(
                  controller: _qrcodeController,
                  readOnly: true,
                  enableInteractiveSelection: false,
                  style: const TextStyle(
                    color: Color(0xFF0076BC),
                  ),
                  decoration: InputDecoration(
                    labelText: 'QR Code',
                    labelStyle: const TextStyle(
                      color: Colors.lightBlueAccent,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 1.0,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Colors
                            .lightBlueAccent, // Cor da borda quando o campo está habilitado
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Color(0xFF0076BC),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 1.0,
                        color: Colors.red, // Cor da borda quando há um erro
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Colors
                            .red, // Cor da borda quando o campo está focado e há um erro
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Color(0xFF0076BC),
                        size: 32.0,
                      ),
                      onPressed: _generateQRCodeHash,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _marcaController,
                        style: const TextStyle(
                          color: Color(0xFF0076BC),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Marca',
                          labelStyle: const TextStyle(
                            color: Colors.lightBlueAccent,
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: const BorderSide(
                              width: 1.0,
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: const BorderSide(
                              width: 2.0,
                              color: Colors
                                  .lightBlueAccent, // Cor da borda quando o campo está habilitado
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: const BorderSide(
                              width: 2.0,
                              color: Color(0xFF0076BC),
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: const BorderSide(
                              width: 1.0,
                              color:
                                  Colors.red, // Cor da borda quando há um erro
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: const BorderSide(
                              width: 2.0,
                              color: Colors
                                  .red, // Cor da borda quando o campo está focado e há um erro
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _modeloController,
                        style: const TextStyle(
                          color: Color(0xFF0076BC),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Modelo',
                          labelStyle: const TextStyle(
                            color: Colors.lightBlueAccent,
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: const BorderSide(
                              width: 1.0,
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: const BorderSide(
                              width: 2.0,
                              color: Colors
                                  .lightBlueAccent, // Cor da borda quando o campo está habilitado
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: const BorderSide(
                              width: 2.0,
                              color: Color(0xFF0076BC),
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: const BorderSide(
                              width: 1.0,
                              color:
                                  Colors.red, // Cor da borda quando há um erro
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: const BorderSide(
                              width: 2.0,
                              color: Colors
                                  .red, // Cor da borda quando o campo está focado e há um erro
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      child: ComboBoxEmpresa(
                        empresa: _empresaSelecionada,
                        onEmpresaSelected: (empresa) {
                          setState(() {
                            _empresaSelecionada = empresa;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      usuarioValue ? 'Com Usuário' : 'Sem Usuário',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: usuarioValue
                            ? const Color(0xFF0076BC)
                            : Colors.grey,
                      ),
                    ),
                    SwitchExample(
                      onValueChanged: (value) {
                        setState(() {
                          usuarioValue = value;
                          _usuarioSelecionado = '';
                        });
                      },
                    ),
                  ],
                ),
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
                const SizedBox(height: 8),
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
                        color: _switchValue
                            ? const Color(0xFF0076BC)
                            : Colors.grey,
                      ),
                    ),
                    SwitchExample(
                      onValueChanged: (value) {
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
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
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {},
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
    if (_marcaController.text.isEmpty ||
        _modeloController.text.isEmpty ||
        _empresaSelecionada.isEmpty ||
        _setorSelecionado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_qrcodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, gere um QR Code.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (usuarioValue && _usuarioSelecionado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, selecione um usuário ou desative a opção de inserir usuário.'),
          backgroundColor: Colors.red,
        ),
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
      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Switch(
          activeColor: const Color(0xFF0076BC),
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
