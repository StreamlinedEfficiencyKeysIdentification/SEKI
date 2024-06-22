// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/usuario_controller.dart';
import '../../../models/usuario_model.dart';
import '../../widgets/combo_box_empresa.dart';
import '../../widgets/combo_box_nivel_acesso.dart';

class DetalhesUsuarioPage extends StatefulWidget {
  final String usuario;

  const DetalhesUsuarioPage({super.key, required this.usuario});

  @override
  DetalhesUsuarioPageState createState() => DetalhesUsuarioPageState();
}

class DetalhesUsuarioPageState extends State<DetalhesUsuarioPage> {
  late Usuario _usuario = Usuario(
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
  // Variáveis para armazenar o estado dos campos editáveis
  late String _nome = '';
  late String _email = '';
  bool _status = true;
  late String _dataAcesso = '';
  late String _dataCriacao = '';
  bool _primeiroAcesso = false;
  bool _redefinirSenha = false;
  late String _criador = '';
  String _empresaSelecionada = '';
  String _nivelSelecionado = '';
  double _statusBarHeight = 0;

  @override
  void initState() {
    super.initState();
    // Inicialize os campos editáveis com os valores do usuário
    _fetchUsuario();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statusBarHeight = MediaQuery.of(context).padding.top;
  }

  void _fetchUsuario() async {
    try {
      // Use o método estático da classe EmpresaController para buscar a empresa
      Usuario usuario = await UsuarioController.getUsuario(widget.usuario);
      setState(() {
        _usuario = usuario;

        initializeFields();
        fetchCriador();
      });
    } catch (e) {
      // Trate qualquer erro que possa ocorrer durante a busca da empresa
      print('Erro ao buscar usuario: $e');
    }
  }

  void initializeFields() {
    _nome = _usuario.nome;
    _status = _usuario.status == 'Ativo';
    _email = _usuario.email;
    _dataAcesso = _usuario.dataAcesso;
    _dataCriacao = _usuario.dataCriacao;
    _primeiroAcesso = _usuario.primeiroAcesso;
    _redefinirSenha = _usuario.redefinirSenha;

    _empresaSelecionada = _usuario.empresa;
    _nivelSelecionado = _usuario.nivel;

    nomeController.text = _nome;
  }

  void fetchCriador() async {
    DocumentSnapshot usuarioSnapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(_usuario.criador)
        .get();
    if (usuarioSnapshot.exists) {
      setState(() {
        _criador = usuarioSnapshot['Usuario'];
      });
    }
  }

  final TextEditingController nomeController = TextEditingController();
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
                Column(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Color(0xFF0076BC),
                      size: 100,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _usuario.usuario,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Text(
                  'E-mail: $_email',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: nomeController,
                  onChanged: (value) => setState(() {
                    _nome = value;
                  }),
                  style: const TextStyle(
                    color: Color(0xFF0076BC),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nome',
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
                  ),
                ),
                const SizedBox(height: 16.0),
                ComboBoxEmpresa(
                  empresa: _empresaSelecionada,
                  onEmpresaSelected: (empresa) {
                    setState(() {
                      _empresaSelecionada = empresa;
                    });
                  },
                ),
                const SizedBox(height: 8.0),
                ComboBoxNivelAcesso(
                  nivel: _nivelSelecionado,
                  onNivelSelected: (nivel) {
                    setState(() {
                      _nivelSelecionado = nivel;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _status ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _status ? const Color(0xFF0076BC) : Colors.grey,
                      ),
                    ),
                    Switch(
                      activeColor: const Color(0xFF0076BC),
                      thumbIcon: thumbIcon,
                      value: _status,
                      onChanged: (value) {
                        setState(() {
                          _status = !_status;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _primeiroAcesso
                          ? 'Primeiro Acesso'
                          : 'Não é o primeiro acesso',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primeiroAcesso
                            ? const Color(0xFF0076BC)
                            : Colors.grey,
                      ),
                    ),
                    Switch(
                      activeColor: const Color(0xFF0076BC),
                      thumbIcon: thumbIcon,
                      value: _primeiroAcesso,
                      onChanged: (value) {
                        setState(() {
                          _primeiroAcesso = !_primeiroAcesso;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _redefinirSenha
                          ? 'Redefinir Senha'
                          : 'Não é necessário redefinir a senha',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _redefinirSenha
                            ? const Color(0xFF0076BC)
                            : Colors.grey,
                      ),
                    ),
                    Switch(
                      activeColor: const Color(0xFF0076BC),
                      thumbIcon: thumbIcon,
                      value: _redefinirSenha,
                      onChanged: (value) {
                        setState(() {
                          _redefinirSenha = !_redefinirSenha;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Container(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Criador: $_criador',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Criado em: $_dataCriacao',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Ultimo acesso em: $_dataAcesso',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
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
                                Navigator.pushNamed(context, '/view_usuarios');
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
                    Navigator.pushNamed(context, '/view_usuarios');
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

  // Verifica se houve alterações nos dados
  bool _isDataChanged() {
    String nome = nomeController.text.trim();
    return nome != _usuario.nome ||
        _status != (_usuario.status == 'Ativo') ||
        _primeiroAcesso != _usuario.primeiroAcesso ||
        _redefinirSenha != _usuario.redefinirSenha ||
        _empresaSelecionada != _usuario.empresa ||
        _nivelSelecionado != _usuario.nivel;
  }

  // Constrói o botão "Salvar"
  Widget _buildSaveButton() {
    String status = _status ? 'Ativo' : 'Inativo';
    return ElevatedButton(
      onPressed: () async {
        try {
          // Atualizar os dados no banco de dados
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(_usuario.uid)
              .update({
            'Nome': _nome,
            'Status': status,
            'IDempresa': _empresaSelecionada,
            'IDnivel': _nivelSelecionado,
          });

          _fetchUsuario();

          await FirebaseFirestore.instance
              .collection('DetalheUsuario')
              .doc(_usuario.uid)
              .update({
            'PrimeiroAcesso': _primeiroAcesso,
            'RedefinirSenha': _redefinirSenha,
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
          initializeFields();
        });
      },
      child: const Text('Cancelar'),
    );
  }

  @override
  void dispose() {
    // Limpe os controladores quando a página for descartada
    nomeController.dispose();
    super.dispose();
  }
}
