// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/usuario_controller.dart';
import '../../models/usuario_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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
      body: 
        Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<Usuario>(
                          future: UsuarioController.getUsuarioLogado(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: 6,
                                itemBuilder: (context, index) {
                                },
                              );
                            } else if (snapshot.hasError) {
                              return const Text(
                                  'Erro ao carregar o nome do usuário.');
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

                              int nivelUsuario =
                                  int.tryParse(usuario.nivel) ?? 0;
                              String user = usuario.usuario;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Bem-vindo,',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: 
                                              IconButton(
                                                  icon:
                                                      const Icon(Icons.logout),
                                                  color: Colors.blue,
                                                  onPressed: () =>
                                                      _logout(context),
                                                )
                                              ,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '$user!',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontFamily: 'RobotoMono'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Ações',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      color: Colors.white,
                                      thickness: 1,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Column(
                                      children: [
                                        //Container Empresa e seus botoes...
                                        Visibility(
                                          visible: nivelUsuario <= 2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  131, 255, 255, 255),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width:
                                                      1), // Definindo o raio da borda
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(20, 5, 20, 0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Text(
                                                            'Empresa',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Icon(
                                                            Icons.domain,
                                                            color: Colors.white,
                                                            size: 35,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          20, 5, 20, 20),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {},
                                                        child: const Icon(
                                                          Icons
                                                              .remove_red_eye_outlined,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/view_empresas');
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
                                        //Container Usuário e seus botoes...
                                        Visibility(
                                          visible: nivelUsuario <= 3,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  131, 255, 255, 255),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(20, 5, 20, 0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Text(
                                                            'Usuários',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Icon(
                                                            Icons.people_alt,
                                                            color: Colors.white,
                                                            size: 35,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          20, 5, 20, 20),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {},
                                                        child: const Icon(
                                                          Icons
                                                              .remove_red_eye_outlined,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/register');
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
                                        //container equipamentos e seus botoes...
                                        Visibility(
                                          visible: nivelUsuario <= 3,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  131, 255, 255, 255),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(20, 5, 20, 0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Text(
                                                            'Equipamento',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .computer_sharp,
                                                            color: Colors.white,
                                                            size: 35,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          20, 5, 20, 20),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/view_equipamentos');
                                                        },
                                                        child: const Icon(
                                                          Icons
                                                              .remove_red_eye_outlined,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/hardware');
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
                                        //container equipamentos e seus botoes...
                                        Visibility(
                                          visible: nivelUsuario <= 3,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  131, 255, 255, 255),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(20, 5, 20, 0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Text(
                                                            'Chamados',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Icon(
                                                            Icons.call_rounded,
                                                            color: Colors.white,
                                                            size: 35,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          20, 5, 20, 20),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          // Navigator.pushNamed(
                                                          //     context,
                                                          //     '/view_equipamentos');
                                                        },
                                                        child: const Icon(
                                                          Icons
                                                              .remove_red_eye_outlined,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          // Navigator.pushNamed(
                                                          //     context,
                                                          //     '/hardware');
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
                                      ],
                                    ),
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
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _logout(context),
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
