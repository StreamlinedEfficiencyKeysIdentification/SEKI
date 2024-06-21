import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../controllers/usuario_controller.dart';
import '../../../models/usuario_model.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  GroupPageState createState() => GroupPageState();
}

class GroupPageState extends State<GroupPage> {
  final TextEditingController _cnpjController = TextEditingController();
  final TextEditingController _razaosocialController = TextEditingController();
  bool _switchValue = false;

  Future<int> _getProximoId() async {
    // Consulte todos os documentos na coleção "Empresa"
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Empresa').get();

    // Crie uma lista de IDs existentes
    List<int> existingIds = querySnapshot.docs
        .map((doc) => int.tryParse(doc.id) ?? 0) // Converta o ID para inteiro
        .toList();

    // Encontre o próximo ID disponível
    int nextId = 1;
    while (existingIds.contains(nextId)) {
      nextId++;
    }

    return nextId;
  }

  Future<void> cadastrarEmpresa() async {
    if (_cnpjController.text.isEmpty || _razaosocialController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Obtenha os valores dos campos de texto
    String cnpj = _cnpjController.text.trim();
    String razaoSocial = _razaosocialController.text.trim();
    bool switchValue = _switchValue;
    String status;

    Usuario usuario = await UsuarioController.getUsuarioLogado();

    if (switchValue) {
      status = 'Ativo';
    } else {
      status = 'Inativo';
    }

    // Obtém o próximo ID disponível
    int proximoId = await _getProximoId();

    // Cria uma referência para o novo documento na coleção 'Empresa' com o próximo ID
    DocumentReference novoDocumento =
        FirebaseFirestore.instance.collection('Empresa').doc('$proximoId');

    // Cria um mapa com os dados da empresa
    Map<String, dynamic> dadosEmpresa = {
      'CNPJ': cnpj,
      'RazaoSocial': razaoSocial,
      'Status': status,
      'QuemCriou':
          usuario.uid, // Adicione o valor do Switch aos dados da empresa
    };

    int nivel = int.tryParse(usuario.nivel) ?? 0;

    String empresaPai = usuario.empresa;

    // Adiciona o campo EmpresaPai se existir
    if (nivel == 1) {
      dadosEmpresa['EmpresaPai'] = proximoId.toString();
    } else {
      dadosEmpresa['EmpresaPai'] = empresaPai;
    }

    // Adiciona os dados do documento na coleção 'Empresa'
    await novoDocumento.set(dadosEmpresa);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1,
                ),
                child: Image.asset(
                  'images/empresa.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Criação de Empresa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cnpjController,
                style: const TextStyle(
                  color: Color(0xFF0076BC),
                ),
                decoration: InputDecoration(
                  labelText: 'CNPJ',
                  labelStyle: const TextStyle(
                    color: Colors.lightBlueAccent,
                  ),
                  hintStyle: const TextStyle(
                    color: Colors.lightBlueAccent, // Cor do texto de dica
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
              const SizedBox(height: 16),
              TextField(
                controller: _razaosocialController,
                style: const TextStyle(
                  color: Color(0xFF0076BC),
                ),
                decoration: InputDecoration(
                  labelText: 'Razão Social',
                  labelStyle: const TextStyle(
                    color: Colors.lightBlueAccent,
                  ),
                  hintStyle: const TextStyle(
                    color: Colors.lightBlueAccent, // Cor do texto de dica
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
              const SizedBox(height: 16),
              FutureBuilder<Usuario>(
                future: UsuarioController.getUsuarioLogado(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // Tratar erros
                  }

                  var usuario = snapshot.data;

                  // Você já tem os dados do usuário aqui, não precisa chamar a função getEmpresa
                  String? idEmpresa = usuario?.empresa;
                  String? nivel = usuario?.nivel;

                  // Se o nível for null ou vazio, não há permissões, retornar uma lista vazia
                  if (nivel == null || nivel.isEmpty) {
                    return const SizedBox();
                  } else if (nivel == '1') {
                    return const SizedBox();
                  } else {
                    return FutureBuilder<
                        DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('Empresa')
                          .doc(idEmpresa)
                          .get(),
                      builder: (context, empresaSnapshot) {
                        if (empresaSnapshot.hasError) {
                          return Text(
                              'Erro ao obter dados da empresa: ${empresaSnapshot.error}');
                        }

                        var empresaData = empresaSnapshot.data?.data();
                        if (empresaData == null) {
                          return const Text(
                              'Empresa não encontrada'); // Lidar com o caso em que a empresa não existe
                        }

                        String? razaoSocial = empresaData['RazaoSocial'];

                        return TextField(
                          controller: TextEditingController(text: razaoSocial),
                          readOnly: true,
                          enableInteractiveSelection: false,
                          style: const TextStyle(
                            color: Color(0xFF0076BC),
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Empresa Pai',
                            labelStyle: const TextStyle(
                              color: Colors.lightBlueAccent,
                            ),
                            hintStyle: const TextStyle(
                              color: Colors
                                  .lightBlueAccent, // Cor do texto de dica
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
                                color: Colors
                                    .red, // Cor da borda quando há um erro
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
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _switchValue ? 'Empresa ativa' : 'Empresa inativa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          _switchValue ? const Color(0xFF0076BC) : Colors.grey,
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
                  onPressed: cadastrarEmpresa,
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

class SwitchExample extends StatefulWidget {
  final void Function(bool) onValueChanged;

  const SwitchExample({super.key, required this.onValueChanged});

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
