// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/usuario_controller.dart';
import '../../models/usuario_model.dart';

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
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder<Usuario>(
                    future: UsuarioController.getUsuarioLogado(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text(
                          'Erro ao carregar o nome do usuário.',
                        );
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
                              criador: '',
                              dataCriacao: '',
                              dataAcesso: '',
                              primeiroAcesso: false,
                              redefinirSenha: false,
                            );

                        int nivelUsuario = int.tryParse(usuario.nivel) ?? 0;
                        String user = usuario.usuario;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Bem-vindo,\n$user!',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                              Visibility(
                                visible: nivelUsuario <= 2,
                                child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        131, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(
                                        10), // Adicionando bordas arredondadas
                                  ),
                                  child: Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left:
                                                10), // Adicionando espaço à esquerda do texto
                                        child: Text(
                                          'Empresa',
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                    context, '/view_empresas');
                                              },
                                              child: const Icon(
                                                Icons.remove_red_eye_outlined,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                    context, '/group');
                                              },
                                              child: const Icon(
                                                Icons.add,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Visibility(
                                visible: nivelUsuario <= 3,
                                child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        131, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Usuários'),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Adicione a lógica para o botão de adicionar aqui
                                        },
                                        child: const Icon(
                                          Icons.remove_red_eye_outlined,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/register');
                                        },
                                        child: const Icon(
                                          Icons.add,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Visibility(
                                visible: nivelUsuario <= 3,
                                child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        131, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Equipamento'),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Adicione a lógica para o botão de adicionar aqui
                                        },
                                        child: const Icon(
                                          Icons.remove_red_eye_outlined,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/hardware');
                                        },
                                        child: const Icon(
                                          Icons.add,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Visibility(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/scan');
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_outlined,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
    );
  }
}
