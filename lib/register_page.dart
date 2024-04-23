// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, prefer_const_declarations, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import '../controllers/usuario_controller.dart';
import 'models/usuario_model.dart';
import 'views/combo_box_empresa.dart';
import 'views/combo_box_nivel_acesso.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _empresaSelecionada = '';
  String _nivelSelecionado = '';
  bool _switchValue = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();

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
            ComboBoxEmpresa(
              onEmpresaSelected: (empresa) {
                setState(() {
                  _empresaSelecionada =
                      empresa; // Atualizar o estado do campo 'IDempresa'
                });
              },
            ),
            ComboBoxNivelAcesso(
              onNivelSelected: (nivel) {
                setState(() {
                  _nivelSelecionado =
                      nivel; // Atualizar o estado do campo 'IDempresa'
                });
              },
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
                _register(context, _empresaSelecionada,
                    _nivelSelecionado); // Chamar _register passando _empresaSelecionada
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

  void _register(BuildContext context, String empresaSelecionadaId,
      String nivelSelecionado) async {
    String email = _emailController.text.trim();
    String password = '123456789';
    String nome = _nomeController.text.trim();
    bool switchValue = _switchValue;
    String status;
    String user_name = nome;
    String user_email = email;
    String user_subject = 'Criação de Usuário';
    String message =
        'Seu usuário foi criado com sucesso! Para entrar no sistema, acesse com o e-mail: $email e senha: $password .';
    Usuario usuario = await UsuarioController.getUsuarioLogado();

    // Converter os dados do objeto Usuario em um Map<String, String>
    Map<String, String> userInfo = {
      'uid': usuario.uid,
      'nivel': usuario.nivel,
      'empresa': usuario.empresa,
    };

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
        'IDnivel': nivelSelecionado,
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
