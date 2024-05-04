// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/usuario_controller.dart';
import 'models/usuario_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('usuarioLogado'); // Remova o UID do SharedPreferences

      await FirebaseAuth.instance.signOut();

      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print('Erro ao fazer logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<Usuario>(
              future: UsuarioController.getUsuarioLogado(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Erro ao carregar o nome do usuário.');
                } else {
                  Usuario usuario = snapshot.data ??
                      Usuario(
                        uid: '',
                        nivel: '',
                        empresa: '',
                        nome: '',
                        usuario: '',
                        email: '',
                        status: '',
                        dataCriacao: '',
                        dataAcesso: '',
                        primeiroAcesso: false,
                        redefinirSenha: false,
                      );

                  int nivelUsuario = int.tryParse(usuario.nivel) ?? 0;
                  String user = usuario.usuario;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bem-vindo,\n$user!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      Visibility(
                        visible: nivelUsuario <= 4,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/scan');
                          },
                          child: const Text('Ler QR Code'),
                        ),
                      ),
                      Visibility(
                        visible: nivelUsuario <= 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/setor');
                          },
                          child: const Text('Registrar Novo Setor'),
                        ),
                      ),
                      Visibility(
                        visible: nivelUsuario <= 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/group');
                          },
                          child: const Text('Registrar Nova Empresa'),
                        ),
                      ),
                      Visibility(
                        visible: nivelUsuario <= 3,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text('Registrar Novo Usuário'),
                        ),
                      ),
                      Visibility(
                        visible: nivelUsuario <= 3,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/hardware');
                          },
                          child: const Text('Registrar Novo Equipamento'),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
