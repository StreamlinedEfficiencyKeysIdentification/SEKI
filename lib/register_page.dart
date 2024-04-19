import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String>> _getUsuarioLogado() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? usuarioLogado = prefs.getString('usuarioLogado');

  if (usuarioLogado != null) {
    // Buscar documento do usuário no Firestore
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(usuarioLogado)
        .get();

    if (userSnapshot.exists) {
      // Retornar o UID, o nível e a empresa do usuário
      return {
        'uid': usuarioLogado,
        'nivel': userSnapshot['IDnivel'] as String? ?? '',
        'empresa': userSnapshot['IDempresa'] as String? ?? '',
      };
    }
  }
  // Se não encontrar o usuário ou houver um erro, retornar um mapa vazio
  return {};
}

class AutocompleteEmpresaExample extends StatelessWidget {
  final void Function(String) onEmpresaSelected;

  const AutocompleteEmpresaExample({
    required this.onEmpresaSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _getUsuarioLogado(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Tratar erros
        }

        // Obter o nível do usuário logado
        String? nivel = snapshot.data?['nivel'];

        // Se o nível for null ou vazio, não há permissões, retornar uma lista vazia
        if (nivel == null || nivel.isEmpty) {
          return const SizedBox();
        }

        // Se o nível for 1, permitir que o usuário selecione qualquer empresa
        // Se o nível for 2, filtrar as empresas com base na empresa associada ao usuário
        // Se o nível for 3, permitir que o usuário selecione qualquer empresa
        String? empresa = snapshot.data?['empresa'];
        Query empresasQuery = FirebaseFirestore.instance.collection('Empresa');
        if (nivel == '2') {
          empresasQuery = empresasQuery.where('EmpresaPai', isEqualTo: empresa);
        }

        return StreamBuilder<QuerySnapshot>(
          stream: empresasQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // Tratar erros
            }

            final empresas = snapshot.data?.docs.map((doc) {
                  return {
                    'RazaoSocial': doc['RazaoSocial'] as String,
                    'ID': doc.id, // Adicione o ID do documento
                  };
                }).toList() ??
                [];

            return Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return empresas
                    .where((empresa) =>
                        empresa['RazaoSocial'] != null &&
                        empresa['RazaoSocial']!
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                    .map((empresa) => empresa['RazaoSocial'] as String);
              },
              onSelected: (String selection) {
                // Encontre o ID correspondente à RazaoSocial selecionada
                final selectedEmpresa = empresas.firstWhere(
                  (empresa) => empresa['RazaoSocial'] == selection,
                );
                onEmpresaSelected(selectedEmpresa['ID'] as String);
              },
            );
          },
        );
      },
    );
  }
}

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _empresaSelecionada = '';
  bool _switchValue = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _nivelController = TextEditingController();

  Future<Map<String, String>> _getUsuarioLogado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuarioLogado = prefs.getString('usuarioLogado');

    if (usuarioLogado != null) {
      // Buscar documento do usuário no Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(usuarioLogado)
          .get();

      if (userSnapshot.exists) {
        // Retornar o UID, o nível e a empresa do usuário
        return {
          'uid': usuarioLogado,
          'nivel': userSnapshot['IDnivel'] as String? ?? '',
          'empresa': userSnapshot['IDempresa'] as String? ?? '',
        };
      }
    }
    // Se não encontrar o usuário ou houver um erro, retornar um mapa vazio
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Register Page'),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            AutocompleteEmpresaExample(
              onEmpresaSelected: (empresa) {
                setState(() {
                  _empresaSelecionada =
                      empresa; // Atualizar o estado do campo 'IDempresa'
                });
              },
            ),
            TextFormField(
              controller: _nivelController,
              decoration: const InputDecoration(labelText: 'Nível de Acesso'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _switchValue ? 'Usuário Ativo' : 'Usuário Inativo',
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
                _register(context,
                    _empresaSelecionada); // Chamar _register passando _empresaSelecionada
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future sendEmail({user_name, user_email, user_subject, message}) async {
    final service_id = 'service_3v4rnsl';
    final template_id = 'template_iecf4gn';
    final user_id = 'vfwarZrM3MChAFVqG';

    var url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      var response = await http.post(url,
          headers: {
            'origin': 'http://localhost',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'service_id': service_id,
            'template_id': template_id,
            'user_id': user_id,
            'template_params': {
              'user_name': user_name,
              'user_email': user_email,
              'user_subject': user_subject,
              'message': message,
            },
          }));

      print('[Enviado] ${response.body}');
    } catch (e) {
      print('[Erro ao enviar email]');
    }
  }

  void _register(BuildContext context, String empresaSelecionadaId) async {
    String email = _emailController.text.trim();
    String password = '123456789';
    String nome = _nomeController.text.trim();
    // String empresa = _empresaController.text.trim();
    String nivel = _nivelController.text.trim();
    bool switchValue = _switchValue;
    String status;
    String user_name = nome;
    String user_email = email;
    String user_subject = 'Criação de Usuário';
    String message =
        'Seu usuário foi criado com sucesso! Para entrar no sistema, acesse com o e-mail: $email e senha: $password .';
    Map<String, String> userInfo = await _getUsuarioLogado();

    if (switchValue) {
      status = 'Ativo';
    } else {
      status = 'Inativo';
    }

    var logger = Logger(
      printer: PrettyPrinter(),
    );

    try {
      // Registrar usuário no Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obter o UID do usuário registrado
      String uid = userCredential.user!.uid;

      // Agora você pode usar o UID para associar documentos no Firestore
      // Por exemplo, você pode criar um documento na coleção 'users' com o UID como identificador
      await FirebaseFirestore.instance.collection('Usuarios').doc(uid).set({
        'Email': email,
        'IDempresa':
            empresaSelecionadaId, // Armazenar a empresa selecionada como IDempresa
        'IDnivel': nivel,
        'Nome': nome,
        'Status': status,
        // Outros campos...
      });

      await FirebaseFirestore.instance
          .collection('DetalheUsuario')
          .doc(uid)
          .set({
        'PrimeiroAcesso': true,
        'QuemCriou': userInfo['uid'], // Armazenar o UID do usuário que criou
        // Outros campos...
      });

      // Se o registro for bem-sucedido, chame a função sendEmail
      await sendEmail(
        user_name: user_name,
        user_email: user_email,
        user_subject: user_subject,
        message: message,
      );

      print('Usuário registrado com sucesso!');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        logger.d('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        logger.d('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        logger.d('The email is invalidl.');
      } else if (e.code == 'email-already-in-use') {
        logger.d('The account already exists for that email.');
      } else {
        logger.d('User and/or password is invalid.');
      }
    } catch (e) {
      logger.e(e.toString());
    }
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
