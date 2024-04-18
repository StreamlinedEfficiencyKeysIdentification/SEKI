import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupPage extends StatefulWidget {
  GroupPage({Key? key}) : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
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

  Future<String?> _getUsuarioLogado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuarioLogado = prefs.getString('usuarioLogado');

    if (usuarioLogado != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('Usuarios')
          .doc(usuarioLogado)
          .get();

      if (userDoc.exists) {
        return usuarioLogado; // Retorna o ID do usuário logado se o documento existir
      } else {
        print('Documento do usuário não encontrado no Firestore.');
        return null; // Retorna null se o documento do usuário não for encontrado
      }
    } else {
      print('Usuário não logado.');
      return null; // Retorna null se o usuário não estiver logado
    }
  }

  Future<String> _getIDnivel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuarioLogado = prefs.getString('usuarioLogado');

    if (usuarioLogado != null) {
      DocumentSnapshot<Map<String, dynamic>> userIDnivel =
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(usuarioLogado)
              .get();

      if (userIDnivel.exists) {
        String? idNivel = userIDnivel.data()?['IDnivel'];
        if (idNivel != null) {
          return idNivel; // Retorna o ID do nível se existir
        } else {
          print('ID do nível não encontrado para o usuário.');
          return ''; // Retorna uma string vazia se o ID do nível não for encontrado
        }
      } else {
        print('Documento do usuário não encontrado no Firestore.');
        return ''; // Retorna uma string vazia se o documento do usuário não for encontrado
      }
    } else {
      print('Usuário não logado.');
      return ''; // Retorna uma string vazia se o usuário não estiver logado
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _getUsuarioEmpresa(
      String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('Usuarios').doc(uid).get();
    if (userDoc.exists) {
      String idEmpresa = userDoc['IDempresa'];
      return FirebaseFirestore.instance
          .collection('Empresa')
          .doc(idEmpresa)
          .get();
    } else {
      return null;
    }
  }

  Future<void> cadastrarEmpresa() async {
    // Obtenha os valores dos campos de texto
    String cnpj = _cnpjController.text.trim();
    String razaoSocial = _razaosocialController.text.trim();
    bool switchValue = _switchValue;
    String status;

    if (switchValue) {
      status = 'Ativo';
    } else {
      status = 'Inativo';
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuarioLogado = prefs.getString('usuarioLogado');

    DocumentSnapshot<Map<String, dynamic>>? empresaDoc =
        await _getUsuarioEmpresa(usuarioLogado!);

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
          usuarioLogado, // Adicione o valor do Switch aos dados da empresa
    };

    String? nivel = await _getIDnivel();
    int idNivel = int.tryParse(nivel) ?? 0;

    String? empresaPai = empresaDoc?['EmpresaPai'];

    // Adiciona o campo EmpresaPai se existir
    if (idNivel == 1) {
      if (empresaPai != null) {
        dadosEmpresa['EmpresaPai'] = proximoId.toString();
      } else {
        dadosEmpresa['EmpresaPai'] = empresaPai;
      }
    } else {
      dadosEmpresa['EmpresaPai'] = empresaPai;
    }

    // Adiciona os dados do documento na coleção 'Empresa'
    await novoDocumento.set(dadosEmpresa);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Grupo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Criação de Empresa'),
            TextFormField(
              controller: _cnpjController,
              decoration: const InputDecoration(labelText: 'CNPJ'),
            ),
            TextFormField(
              controller: _razaosocialController,
              decoration: const InputDecoration(labelText: 'Razao Social'),
            ),
            FutureBuilder<String?>(
              future: _getUsuarioLogado(),
              builder: (context, snapshot) {
                if (snapshot.hasError || snapshot.data == null) {
                  return const Text('Erro: Usuário não logado.');
                } else {
                  String usuarioLogado = snapshot.data!;
                  return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                    future: _getUsuarioEmpresa(usuarioLogado),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                            'Erro ao carregar os dados do usuário.');
                      } else {
                        DocumentSnapshot<Map<String, dynamic>>? empresaDoc =
                            snapshot.data;
                        return FutureBuilder<String?>(
                          future: _getIDnivel(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text(
                                  'Erro ao carregar o nível do usuário.');
                            } else {
                              int nivel =
                                  int.tryParse(snapshot.data ?? '') ?? 0;
                              String? empresaPai = empresaDoc?['RazaoSocial'];

                              if (nivel == 1) {
                                return const SizedBox(); // Retorna um widget vazio se o nível for 1
                              } else {
                                return TextFormField(
                                  initialValue: empresaPai,
                                  decoration: const InputDecoration(
                                    labelText: 'EmpresaPai',
                                  ),
                                  readOnly: true,
                                );
                              }
                            }
                          },
                        );
                      }
                    },
                  );
                }
              },
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
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class SwitchExample extends StatefulWidget {
  final void Function(bool) onValueChanged;

  const SwitchExample({Key? key, required this.onValueChanged})
      : super(key: key);

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
