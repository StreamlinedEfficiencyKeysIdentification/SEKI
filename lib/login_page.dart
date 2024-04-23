// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Se algum dos campos estiver vazio, informe ao usuário e não prossiga com o login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Retorna para evitar a execução do código de login
    }

    try {
      // Faça login do usuário com email e senha
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtenha o UID do usuário autenticado
      String usuarioLogado = userCredential.user!.uid;

      // Armazene o UID localmente usando shared_preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuarioLogado', usuarioLogado);

      // Verifique se é o primeiro acesso consultando o Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('DetalheUsuario')
          .doc(usuarioLogado)
          .get();

      if (userDoc.exists) {
        bool primeiroAcesso = userDoc.data()!['PrimeiroAcesso'] ?? false;

        await FirebaseFirestore.instance
            .collection('DetalheUsuario')
            .doc(usuarioLogado)
            .update({
          'DataAcesso': FieldValue
              .serverTimestamp(), // Use FieldValue.serverTimestamp() para obter a hora atual no servidor
        });

        if (primeiroAcesso) {
          // Se for o primeiro acesso, redirecione para a tela de alteração de senha
          Navigator.pushReplacementNamed(context, '/alterar_senha');
        } else {
          // Se não for o primeiro acesso, redirecione para a tela principal
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Se o documento do usuário não existir, trate como desejar
        print('Documento do usuário não encontrado no Firestore.');
      }
    } catch (e) {
      // Trate os erros de autenticação
      print('Erro ao fazer login: $e');
      String errorMessage = '';

      // Mensagens de erro específicas podem ser tratadas aqui
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Email não está no formato correto.';
            break;
          // Adicione mais casos conforme necessário para outros erros
          default:
            errorMessage = 'Usuário e/ou Senha incorretos.';
        }
      } else {
        errorMessage = 'Erro ao fazer login.';
      }

      // Mostra a mensagem de erro na tela
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _login(context),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
