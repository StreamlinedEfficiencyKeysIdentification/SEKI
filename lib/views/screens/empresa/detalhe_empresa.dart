// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/empresa_controller.dart';
import '../../../models/empresa_model.dart';
import 'setor_page.dart';

class DetalhesEmpresaPage extends StatefulWidget {
  final String empresaID;
  final bool setorVisibility;

  const DetalhesEmpresaPage({
    super.key,
    required this.empresaID,
    required this.setorVisibility,
  });

  @override
  DetalhesEmpresaPageState createState() => DetalhesEmpresaPageState();
}

class DetalhesEmpresaPageState extends State<DetalhesEmpresaPage> {
  late Empresa _empresa = Empresa(
    id: '',
    cnpj: '',
    matriz: '',
    razaoSocial: '',
    criador: '',
    status: '',
  );
  late String _razaoSocial = '';
  late String _cnpj = '';
  late String _matriz = '';
  late String _criador = '';
  bool _status = true;
  double _statusBarHeight = 0;

  @override
  void initState() {
    super.initState();
    _fetchEmpresa();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statusBarHeight = MediaQuery.of(context).padding.top;
  }

  void _fetchEmpresa() async {
    try {
      // Use o método estático da classe EmpresaController para buscar a empresa
      Empresa empresa = await EmpresaController.getEmpresa(widget.empresaID);
      setState(() {
        _empresa = empresa;
        initializeFields();

        fetchMatriz();
        fetchCriador();
      });
    } catch (e) {
      // Trate qualquer erro que possa ocorrer durante a busca da empresa
      print('Erro ao buscar empresa: $e');
    }
  }

  void initializeFields() {
    _razaoSocial = _empresa.razaoSocial;
    _cnpj = _empresa.cnpj;
    _status = _empresa.status == 'Ativo';

    razaoSocialController.text = _razaoSocial;
    cnpjController.text = _cnpj;
  }

  void fetchMatriz() async {
    DocumentSnapshot empresaSnapshot = await FirebaseFirestore.instance
        .collection('Empresa')
        .doc(_empresa.matriz)
        .get();
    if (empresaSnapshot.exists) {
      setState(() {
        _matriz = empresaSnapshot['RazaoSocial'];
      });
    }
  }

  void fetchCriador() async {
    DocumentSnapshot usuarioSnapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(_empresa.criador)
        .get();
    if (usuarioSnapshot.exists) {
      setState(() {
        _criador = usuarioSnapshot['Usuario'];
      });
    }
  }

  final TextEditingController razaoSocialController = TextEditingController();
  final TextEditingController cnpjController = TextEditingController();
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
                const Column(
                  children: [
                    Icon(
                      Icons.domain,
                      color: Color(0xFF0076BC),
                      size: 100,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Empresa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: razaoSocialController,
                  onChanged: (value) => setState(() {
                    _razaoSocial = value;
                  }),
                  style: const TextStyle(
                    color: Color(0xFF0076BC),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Razão Social',
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
                TextField(
                  controller: cnpjController,
                  onChanged: (value) => setState(() {
                    _cnpj = value;
                  }),
                  style: const TextStyle(
                    color: Color(0xFF0076BC),
                  ),
                  decoration: InputDecoration(
                    labelText: 'CNPJ',
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
                Text(
                  'Matriz: $_matriz',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Criador: $_criador',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                      activeColor: const Color(0xff0076BC),
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
                const SizedBox(height: 16.0),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.setorVisibility)
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.white,
                              ),
                            ),
                            onPressed: () {
                              if (_isDataChanged()) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title:
                                          const Text('Descartar Alterações?'),
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
                                            Navigator.pop(
                                                context); // Fechar o AlertDialog
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SetorPage(
                                                    empresa: _empresa),
                                              ),
                                            );
                                          },
                                          child: const Text('Sim'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(
                                                context); // Fechar o AlertDialog
                                          },
                                          child: const Text('Não'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SetorPage(empresa: _empresa),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Editar Setores',
                              style: TextStyle(
                                color: Color(0xFF0076BC),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (_isDataChanged()) _buildSaveButton(),
                        if (_isDataChanged()) _buildCancelButton(),
                      ],
                    ),
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
                                Navigator.pushNamed(context, '/view_empresas');
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
                    Navigator.pushNamed(context, '/view_empresas');
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
    String razaoSocial = razaoSocialController.text.trim();
    String cnpj = cnpjController.text.trim();
    return razaoSocial != _empresa.razaoSocial ||
        cnpj != _empresa.cnpj ||
        _status != (_empresa.status == 'Ativo');
  }

  // Constrói o botão "Salvar"
  Widget _buildSaveButton() {
    String status = _status ? 'Ativo' : 'Inativo';
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          Colors.white,
        ),
      ),
      onPressed: () async {
        try {
          // Atualizar os dados no banco de dados
          await FirebaseFirestore.instance
              .collection('Empresa')
              .doc(_empresa.id)
              .update({
            'CNPJ': _cnpj,
            'Status': status,
          });

          _fetchEmpresa();
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
        backgroundColor: MaterialStateProperty.all<Color>(
          Colors.white,
        ),
      ),
      onPressed: () {
        setState(() {
          // Resetar os campos para os valores originais
          initializeFields();
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

  @override
  void dispose() {
    // Limpe os controladores quando a página for descartada
    razaoSocialController.dispose();
    cnpjController.dispose();
    super.dispose();
  }
}
