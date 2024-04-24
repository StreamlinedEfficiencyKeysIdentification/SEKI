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
        title: const Text('Redefinir Senha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              child: const Text('Enviar E-mail de Redefinição'),
            ),
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
    );
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String email = _emailController.text.trim();

    try {
      // Enviar e-mail de redefinição de senha
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Obter UID do usuário correspondente ao e-mail
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();

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
