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
        bool redefinirSenha = userDoc.data()!['RedefinirSenha'] ?? false;

        await FirebaseFirestore.instance
            .collection('DetalheUsuario')
            .doc(usuarioLogado)
            .update({
          'DataAcesso': FieldValue
              .serverTimestamp(), // Use FieldValue.serverTimestamp() para obter a hora atual no servidor
        });

        if (primeiroAcesso || redefinirSenha) {
          // Se for o primeiro acesso, redirecione para a tela de alteração de senha
          Navigator.pushReplacementNamed(context, '/alterar_senha',
              arguments:
                  primeiroAcesso ? 'Primeiro Acesso' : 'Redefina sua Senha');
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1,
                  ),
                  child: Image.asset(
                    'images/userlogin.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Login',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color.fromRGBO(0, 115, 188, 0.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
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
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Senha',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/reset_password');
                        },
                        child: const Text(
                          'Esqueci a senha',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 19, 74, 119),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _login(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 19, 74, 119),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const SizedBox(
                          width: double.infinity,
                          height: 35,
                          child: Center(
                            child: Text(
                              'Login',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
