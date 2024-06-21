// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchEmpresa();
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
      return const Icon(Icons.close);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text('Detalhes da Empresa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color.fromARGB(255, 142, 200, 236),
              ),
              child: _buildEditableField(
                'Razão Social',
                _razaoSocial,
                razaoSocialController,
                (value) => setState(() => _razaoSocial = value),
              ),
            ),

            const SizedBox(height: 16.0), // Espaçamento

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color.fromARGB(255, 142, 200, 236),
              ),
              child: _buildEditableField(
                'CNPJ',
                _cnpj,
                cnpjController,
                (value) => setState(() => _cnpj = value),
              ),
            ),

            // Campos editáveis

            Text(
              'Matriz: $_matriz',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0)),
            ),
            Text(
              'Criador: $_criador',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0)),
            ),
            Row(
              children: [
                Switch(
                  thumbIcon: thumbIcon,
                  value: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = !_status;
                    });
                  },
                ),
                Text(
                  _status ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _status
                        ? Color.fromARGB(255, 45, 104, 47)
                        : Color.fromARGB(255, 171, 46, 37),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (widget.setorVisibility)
                  ElevatedButton(
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
                                    Navigator.pop(
                                        context); // Fechar o AlertDialog
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SetorPage(empresa: _empresa),
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
                            builder: (context) => SetorPage(empresa: _empresa),
                          ),
                        );
                      }
                    },
                    child: const Text('Editar Setores'),
                  ),

                // Botão Salvar (visível apenas se houver alterações)
                if (_isDataChanged()) _buildSaveButton(),
                if (_isDataChanged()) _buildCancelButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Constrói um campo de texto editável
  Widget _buildEditableField(String label, String value,
      TextEditingController controller, ValueChanged<String> onChanged) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
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
    razaoSocialController.dispose();
    cnpjController.dispose();
    super.dispose();
  }
}
