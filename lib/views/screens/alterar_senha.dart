// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirstAccessPage extends StatefulWidget {
  final String title;

  const FirstAccessPage({super.key, required this.title});

  @override
  FirstAccessPageState createState() => FirstAccessPageState();
}

class FirstAccessPageState extends State<FirstAccessPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordValid = false;
  bool _isLengthValid = false;
  bool _hasSpecialChar = false;
  bool _hasUppercaseChar = false;
  bool _hasLowercaseChar = false;
  bool _hasDigit = false;
  bool _passwordsMatch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
              ),
              child: Image.asset(
                'images/redefinir_senha.png',
                width: 100,
                height: 100,
              ),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Nova Senha'),
              obscureText: true,
              onChanged: (_) => _validatePassword(),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirmar Senha'),
              obscureText: true,
              onChanged: (_) => _validatePassword(),
            ),
            const SizedBox(height: 8.0),
            _buildPasswordRequirements(),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed:
                  _isPasswordValid ? () => _changePassword(context) : null,
              child: const Text('Alterar Senha'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requisitos de Senha:',
          style: TextStyle(
            color: _isPasswordValid ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '- Pelo menos 8 caracteres',
          style: TextStyle(color: _isLengthValid ? Colors.green : Colors.red),
        ),
        Text(
          '- Pelo menos 1 caractere especial',
          style: TextStyle(color: _hasSpecialChar ? Colors.green : Colors.red),
        ),
        Text(
          '- Pelo menos 1 letra maiúscula',
          style:
              TextStyle(color: _hasUppercaseChar ? Colors.green : Colors.red),
        ),
        Text(
          '- Pelo menos 1 letra minúscula',
          style:
              TextStyle(color: _hasLowercaseChar ? Colors.green : Colors.red),
        ),
        Text(
          '- Pelo menos 1 número',
          style: TextStyle(color: _hasDigit ? Colors.green : Colors.red),
        ),
        Text(
          '- Senhas coincidem',
          style: TextStyle(color: _passwordsMatch ? Colors.green : Colors.red),
        ),
      ],
    );
  }

  void _validatePassword() {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    _isLengthValid = password.length >= 8;
    _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    _hasUppercaseChar = password.contains(RegExp(r'[A-Z]'));
    _hasLowercaseChar = password.contains(RegExp(r'[a-z]'));
    _hasDigit = password.contains(RegExp(r'[0-9]'));
    _passwordsMatch = password == confirmPassword && confirmPassword.isNotEmpty;

    setState(() {
      _isPasswordValid = _isLengthValid &&
          _hasSpecialChar &&
          _hasUppercaseChar &&
          _hasLowercaseChar &&
          _hasDigit &&
          _passwordsMatch;
    });
  }

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
          'RedefinirSenha': false,
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
}
