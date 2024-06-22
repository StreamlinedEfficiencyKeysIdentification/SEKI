// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:testeseki/controllers/usuario_controller.dart';
import 'package:testeseki/models/equipamento_model.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _equipamentoController = TextEditingController();
  final GlobalKey<AutocompleteUsuarioExampleState> _autocompleteKey =
      GlobalKey();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  bool _isValid = false;
  bool waiting = false;
  String _usuario = '';
  Usuario user = Usuario(
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
  Equipamento equip = Equipamento(
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
  String _usuarioSelecionado = '';
  double _statusBarHeight = 0;

  @override
  void initState() {
    super.initState();
    _equipamentoController.addListener(_onTextChanged);
    _carregarUsuarioLogado();

    if (widget.qrcode.isNotEmpty) {
      _equipamentoController.text = widget.qrcode;
      _searchFirestore(widget.qrcode);
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statusBarHeight = MediaQuery.of(context).padding.top;
  }

  @override
  void dispose() {
    _equipamentoController.dispose();
    super.dispose();
  }

  Future<void> _carregarUsuarioLogado() async {
    try {
      waiting = false;
      Usuario usuario = await UsuarioController.getUsuarioLogado();
      setState(() {
        user = usuario;
        _usuario = usuario.nome;
        _usuarioSelecionado = usuario.uid;
        waiting = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar usuário logado.')),
      );
    }
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
    try {
      final equipamentoSnapshot = await FirebaseFirestore.instance
          .collection('Equipamento')
          .where('IDqrcode', isEqualTo: code)
          .get();

      if (equipamentoSnapshot.docs.isNotEmpty) {
        final equipamentoDoc = equipamentoSnapshot.docs.first;
        final equipamentoData = equipamentoDoc.data();

        // Usar o ID do documento do equipamento para buscar detalhes na coleção DetalheEquipamento
        final detalheEquipamentoSnapshot = await FirebaseFirestore.instance
            .collection('DetalheEquipamento')
            .doc(equipamentoDoc.id)
            .get();

        if (detalheEquipamentoSnapshot.exists) {
          final detalheEquipamentoData =
              detalheEquipamentoSnapshot.data() as Map<String, dynamic>;

          setState(() {
            _isValid = true;
            equip = Equipamento(
              id: equipamentoDoc.id,
              marca: detalheEquipamentoData['Maraa'] ?? '',
              modelo: detalheEquipamentoData['Modelo'] ?? '',
              qrcode: equipamentoData['IDqrcode'] ?? '',
              empresa: equipamentoData['IDempresa'] ?? '',
              setor: equipamentoData['IDsetor'] ?? '',
              usuario: equipamentoData['IDusuario'] ?? '',
              criador: equipamentoData['QuemCriou'] ?? '',
              status: equipamentoData['Status'] ?? '',
            );
          });
        } else {
          setState(() {
            _isValid = false;
          });
        }
      } else {
        setState(() {
          _isValid = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erro ao buscar equipamento no Firestore.')),
      );
    }
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

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      int nivelUsuario = int.tryParse(user.nivel) ?? 0;
      if (!_isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipamento não existe.')),
        );
        return;
      } else if (user.empresa != equip.empresa && nivelUsuario == 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Você não tem permissão para essa empresa.')),
        );
        return;
      } else if (_usuarioSelecionado.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um usuário')),
        );
      } else {
        // Lógica para enviar o formulário
        try {
          // Referência para a coleção "Chamados"
          final chamadosRef = FirebaseFirestore.instance.collection('Chamados');

          // Buscar o ID da EmpresaPai na coleção "Empresa"
          final empresaDoc = await FirebaseFirestore.instance
              .collection('Empresa')
              .doc(user.empresa)
              .get();
          final empresaData = empresaDoc.data();
          final empresaPaiId = empresaData?['EmpresaPai'];

          // Buscar o último ID de chamado na coleção "Chamados"
          int ultimoChamado = 0;
          final ultimoChamadoDoc = await chamadosRef.doc(empresaPaiId).get();
          if (ultimoChamadoDoc.exists) {
            final chamadosData = ultimoChamadoDoc.data();
            chamadosData?.forEach((key, value) {
              if (int.tryParse(key) != null) {
                final chamadoId = int.parse(key);
                if (chamadoId > ultimoChamado) {
                  ultimoChamado = chamadoId;
                }
              }
            });
          }

          // Incrementar o ID do chamado
          final novoChamadoId = (ultimoChamado + 1).toString().padLeft(6, '0');

          // Dados do chamado
          final chamadoData = {
            'QRcode': equip.qrcode,
            'Titulo': _tituloController.text,
            'Usuario': _usuarioSelecionado,
            'Descricao': _descricaoController.text,
            'Empresa': equip.empresa,
            'Status': 'Não iniciado',
            'Responsavel': '',
            'DataCriacao': Timestamp.now(),
            'DataAtualizacao': Timestamp.now(),
            'Lido': false,
          };

          // Adicionar os dados do chamado ao documento na coleção "Chamados"
          await chamadosRef
              .doc(empresaPaiId)
              .set({novoChamadoId: chamadoData}, SetOptions(merge: true));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chamado enviado com sucesso')),
          );

          // Limpar o formulário após envio
          _formKey.currentState?.reset();
          setState(() {
            _equipamentoController.clear();
            _tituloController.clear();
            _descricaoController.clear();
            _carregarUsuarioLogado();
            _isValid = false;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Erro ao enviar chamado para o Firestore.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
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
                        Icons.quick_contacts_mail_outlined,
                        color: Color(0xFF0076BC),
                        size: 100,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Abertura de chamado',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _equipamentoController,
                    style: const TextStyle(
                      color: Color(0xFF0076BC),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.laptop,
                        color: Colors.blue,
                      ),
                      labelText: 'Insira um equipamento',
                      labelStyle: TextStyle(
                        color: _isValid ? Colors.green : Colors.black,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: _isValid ? Colors.green : Colors.red,
                          width: 2,
                          style: BorderStyle.solid,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tituloController,
                    style: const TextStyle(
                      color: Color(0xFF0076BC),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Insira um Titulo',
                      labelStyle: const TextStyle(
                        color: Colors.black,
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                  Text(user.nivel == '4' ? 'Usuario: ${user.usuario}' : ''),
                  if (waiting && user.nivel != '4')
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
                  TextFormField(
                    controller: _descricaoController,
                    maxLines: 5,
                    style: const TextStyle(
                      color: Color(0xFF0076BC),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Insira a descrição',
                      alignLabelWithHint: true,
                      labelStyle: const TextStyle(
                        color: Colors.black,
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0076BC),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      child: const Text(
                        'Enviar chamado',
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
                  color: Color(0xFF0076BC),
                  size: 32,
                ),
                onPressed: () {
                  Navigator.pop(context);
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
}
