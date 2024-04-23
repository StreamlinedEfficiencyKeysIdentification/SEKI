// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirstAccessPage extends StatelessWidget {
  FirstAccessPage({super.key});
  final TextEditingController _passwordController = TextEditingController();

  void _changePassword(BuildContext context) async {
    String newPassword = _passwordController.text.trim();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Atualize a senha no Firebase Authentication
        await user.updatePassword(newPassword);

        // Atualize o campo 'primeiro_acesso' no Firestore
        FirebaseFirestore.instance
            .collection('DetalheUsuario')
            .doc(user.uid)
            .update({
          'PrimeiroAcesso': false,
        });

        // Senha atualizada com sucesso
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Senha atualizada com sucesso.')));

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        // Trate os erros ao atualizar a senha
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar a senha: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar Senha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Nova Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _changePassword(context),
              child: const Text('Alterar Senha'),
            ),
          ],
        ),
      ),
    );
  }
}
