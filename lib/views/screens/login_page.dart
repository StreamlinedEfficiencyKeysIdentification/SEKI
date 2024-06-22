// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  double _statusBarHeight = 0;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statusBarHeight = MediaQuery.of(context).padding.top;
  }

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
    final hasConnection = ConnectionNotifer.of(context).value;

    return Scaffold(
      body: Center(
        // Centraliza o conteúdo na tela
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, _statusBarHeight, 16.0, 16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Centraliza horizontalmente
              mainAxisSize: MainAxisSize
                  .min, // Ajusta a altura da coluna para seu conteúdo
              children: [
                Column(
                  children: [
                    Image.asset(
                      'images/userlogin.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(
                    color: Color(0xFF0076BC),
                  ),
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: const TextStyle(
                      color: Colors.lightBlueAccent,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 1.0,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Colors
                            .lightBlueAccent, // Cor da borda quando o campo está habilitado
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Color(0xFF0076BC),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 1.0,
                        color: Colors.red, // Cor da borda quando há um erro
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Colors
                            .red, // Cor da borda quando o campo está focado e há um erro
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  style: const TextStyle(
                    color: Color(0xFF0076BC),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: const TextStyle(
                      color: Colors.lightBlueAccent,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 1.0,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Colors
                            .lightBlueAccent, // Cor da borda quando o campo está habilitado
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Color(0xFF0076BC),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 1.0,
                        color: Colors.red, // Cor da borda quando há um erro
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Colors
                            .red, // Cor da borda quando o campo está focado e há um erro
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF0076BC),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
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
                            color: Color(0xFF0076BC),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              hasConnection ? () => _login(context) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0076BC),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                          child: Text(
                            hasConnection ? 'Login' : 'Sem Conexão',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
