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
              const SizedBox(height: 10),
              const Text(
                'Criação de Empresa',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color.fromRGBO(0, 115, 188, 0.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _cnpjController,
                    decoration: const InputDecoration(
                      hintText: 'CNPJ',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color.fromRGBO(0, 115, 188, 0.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _razaosocialController,
                    decoration: const InputDecoration(
                      hintText: 'Razao Social',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              //////////////////////
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color.fromRGBO(0, 115, 188, 0.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FutureBuilder<Usuario>(
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

                            return TextFormField(
                              initialValue: razaoSocial,
                              decoration: const InputDecoration(
                                  labelText: 'Empresa Pai'),
                              readOnly: true,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _switchValue ? 'Empresa ativa' : 'Empresa inativa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _switchValue ? Colors.green : Colors.red,
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
              ElevatedButton(
                onPressed: () {
                  cadastrarEmpresa();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 19, 74, 119),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: Center(
                    child: Text(
                      'Cadastrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
