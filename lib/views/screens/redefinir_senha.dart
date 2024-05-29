// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ResetPasswordPageState createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1,
                  ),
                  child: Image.asset(
                    'images/cadeado.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Recuperar Senha',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 60),

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

                const SizedBox(height: 26.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 19, 74, 119),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    height: 35,
                    child: Center(
                      child: Text(
                        'Enviar E-mail de Redefinição',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // ElevatedButton(
                //   onPressed: _isLoading ? null : _resetPassword,
                //   child: const Text('Enviar E-mail de Redefinição'),
                // ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ));
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Por favor, insira um e-mail.';
      });
      return;
    }

    // Adiciona validação para verificar se o email está formatado corretamente
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Por favor, insira um e-mail válido.';
      });
      return;
    }

    try {
      // Obter UID do usuário correspondente ao e-mail
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'E-mail não registrado.';
        });
        return;
      }

      // Enviar e-mail de redefinição de senha
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      String userId = querySnapshot.docs.first.id;

      // Atualizar o campo 'RedefinirSenha' na coleção 'DetalheUsuario' para true
      await FirebaseFirestore.instance
          .collection('DetalheUsuario')
          .doc(userId)
          .update({'RedefinirSenha': true});

      setState(() {
        _isLoading = false;
      });

      // Mostrar mensagem de sucesso
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('E-mail de Redefinição Enviado'),
          content: Text(
              'Um e-mail para redefinição de senha foi enviado para $email.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao enviar e-mail de redefinição: $e';
      });
    }
  }
}
