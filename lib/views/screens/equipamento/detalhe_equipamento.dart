// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../barcode/view_code.dart';
import '../../../controllers/equipamento_controller.dart';
import '../../../models/equipamento_model.dart';
import '../../widgets/autocomplete_usuario.dart';
import '../../widgets/combo_box_empresa.dart';
import '../../widgets/combo_box_setor.dart';

class DetalhesEquipamentoPage extends StatefulWidget {
  final String equipamento;

  const DetalhesEquipamentoPage({super.key, required this.equipamento});

  @override
  DetalhesEquipamentoPageState createState() => DetalhesEquipamentoPageState();
}

class DetalhesEquipamentoPageState extends State<DetalhesEquipamentoPage> {
  final GlobalKey<AutocompleteUsuarioExampleState> _autocompleteKey =
      GlobalKey();
  late Equipamento _equipamento = Equipamento(
    id: '',
    marca: '',
    modelo: '',
    qrcode: '',
    empresa: '',
    setor: '',
    usuario: '',
    criador: '',
    status: '',
  );
  // Variáveis para armazenar o estado dos campos editáveis
  late String _marca = '';
  late String _modelo = '';
  late String _qrcode = '';
  late String _usuario = '';
  late String _criador = '';
  bool _status = true;
  bool waiting = false;

  String _empresaSelecionada = '';
  String _setorSelecionado = '';
  String _usuarioSelecionado = '';
  bool _setorEncontrado = true;
  double _statusBarHeight = 0;

  @override
  void initState() {
    super.initState();
    // Inicialize os campos editáveis com os valores do usuário
    _fetchEquipamento();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statusBarHeight = MediaQuery.of(context).padding.top;
  }

  void _fetchEquipamento() async {
    try {
      // Use o método estático da classe EmpresaController para buscar a empresa
      Equipamento equipamento =
          await EquipamentoController.getEquip(widget.equipamento);
      setState(() {
        _equipamento = equipamento;

        initializeFields();
        fetchCriador();
        fetchUsuario();
      });
    } catch (e) {
      // Trate qualquer erro que possa ocorrer durante a busca da empresa
      print('Erro ao buscar usuario: $e');
    }
  }

  void initializeFields() {
    _marca = _equipamento.marca;
    _modelo = _equipamento.modelo;
    _qrcode = _equipamento.qrcode;
    _status = _equipamento.status == 'Ativo';

    _empresaSelecionada = _equipamento.empresa;
    _usuarioSelecionado = _equipamento.usuario;
    _setorSelecionado = _equipamento.setor;
    if (_setorSelecionado.isEmpty) {
      _setorEncontrado = false;
    } else {
      _setorEncontrado = true;
    }

    marcaController.text = _marca;
    modeloController.text = _modelo;
  }

  void fetchCriador() async {
    DocumentSnapshot usuarioSnapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(_equipamento.criador)
        .get();
    if (usuarioSnapshot.exists) {
      setState(() {
        _criador = usuarioSnapshot['Usuario'];
      });
    }
  }

  void fetchUsuario() async {
    if (_equipamento.usuario.isEmpty) {
      return;
    }
    DocumentSnapshot usuarioSnapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(_equipamento.usuario)
        .get();
    if (usuarioSnapshot.exists) {
      setState(() {
        _usuario = usuarioSnapshot['Nome'];
        waiting = true;
      });
    }
  }

  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
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
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, _statusBarHeight + 16.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'QRcode: $_qrcode',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 18.0),
                IconButton(
                  icon: const Icon(
                    Icons.qr_code,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Visualização do QR Code'),
                          content: const Text('Deseja salvar o QR Code?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Fechar o AlertDialog
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return QRImage(
                                        _qrcode,
                                        _equipamento.empresa,
                                        sourceRoute: ModalRoute.of(context)
                                            ?.settings
                                            .name,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: const Text('Sim'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancelar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18.0),

            // Campos editáveis
            _buildEditableField(
              'Marca',
              _marca,
              marcaController,
              (value) => setState(() => _marca = value),
            ),
            const SizedBox(
              height: 8.0,
            ),

            _buildEditableField(
              'Modelo',
              _modelo,
              modeloController,
              (value) => setState(() => _modelo = value),
            ),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.business,
                  color: Colors.white,
                ), // Ícone que você quer adicionar
                const SizedBox(
                    width: 8), // Espaçamento entre o ícone e o ComboBoxEmpresa
                Expanded(
                  child: ComboBoxEmpresa(
                    empresa: _empresaSelecionada,
                    onEmpresaSelected: (empresa) {
                      setState(() {
                        _empresaSelecionada = empresa;
                      });
                    },
                  ),
                ),
              ],
            ),

            ComboBoxSetor(
              encontrado: _setorEncontrado,
              setor: _setorSelecionado,
              onSetorSelected: (empresa) {
                setState(() {
                  _setorSelecionado = empresa;
                });
              },
            ),
            //Chamar novamente esse componente para atualizar o nome do usuário
            const SizedBox(
              height: 8.0,
            ),

            if (_usuarioSelecionado.isEmpty && waiting)
              const Text('Deseja anexar um usuário ao equipamento?'),
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
            const SizedBox(
              height: 8.0,
            ),
            Row(
              children: [
                Switch(
                  thumbIcon: thumbIcon,
                  value: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  },
                ),
                Text(_status ? 'Ativo' : 'Inativo'),
                const SizedBox(width: 20), // Espaço entre os widgets (opcional)
              ],
            ),
            Text(
              'Criador: $_criador',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 211, 211, 211)),
            ),
            Row(
              children: [
                // Botão Salvar (visível apenas se houver alterações)
                if (_isDataChanged()) _buildSaveButton(),
                if (_isDataChanged()) _buildCancelButton(),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blue,
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
                  if (_isDataChanged()) {
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
                                // Resetar os campos para os valores originais
                                setState(() {
                                  // Resetar os campos para os valores originais
                                  initializeFields();
                                });
                                Navigator.pop(context); // Fechar o AlertDialog
                                Navigator.pushNamed(
                                    context, '/view_equipamentos');
                              },
                              child: const Text('Sim'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Fechar o AlertDialog
                              },
                              child: const Text('Não'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.pushNamed(context, '/view_equipamentos');
                  }
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

  // Constrói um campo de texto editável
  Widget _buildEditableField(String label, String value,
      TextEditingController controller, ValueChanged<String> onChanged) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color.fromARGB(134, 255, 255, 255),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10.0), // Raio da borda arredondada
          borderSide: const BorderSide(color: Colors.white), // Cor da borda
        ),
      ),
      onChanged: onChanged,
    );
  }

  // Verifica se houve alterações nos dados
  bool _isDataChanged() {
    String marca = marcaController.text.trim();
    String modelo = modeloController.text.trim();
    return marca != _equipamento.marca ||
        modelo != _equipamento.modelo ||
        _status != (_equipamento.status == 'Ativo') ||
        _empresaSelecionada != _equipamento.empresa ||
        _setorSelecionado != _equipamento.setor ||
        _usuarioSelecionado != _equipamento.usuario;
  }

  // Constrói o botão "Salvar"
  Widget _buildSaveButton() {
    String status = _status ? 'Ativo' : 'Inativo';
    return ElevatedButton(
      onPressed: () async {
        try {
          // Atualizar os dados no banco de dados
          await FirebaseFirestore.instance
              .collection('Equipamento')
              .doc(_equipamento.id)
              .update({
            'Status': status,
            'IDempresa': _empresaSelecionada,
            'IDsetor': _setorSelecionado,
            'IDusuario': _usuarioSelecionado,
          });

          _fetchEquipamento();

          await FirebaseFirestore.instance
              .collection('DetalheEquipamento')
              .doc(_equipamento.id)
              .update({
            'Marca': _marca,
            'Modelo': _modelo,
          });

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
          _fetchEquipamento();
          _autocompleteKey.currentState?.reconstruirWidget();
        });
      },
      child: const Text('Cancelar'),
    );
  }

  @override
  void dispose() {
    // Limpe os controladores quando a página for descartada
    marcaController.dispose();
    modeloController.dispose();
    super.dispose();
  }
}
