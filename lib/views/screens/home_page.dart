// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testeseki/controllers/chamado_controller.dart';
import 'package:testeseki/models/chamado_model.dart';
import 'package:testeseki/views/screens/chamado/detalhe_chamado.dart';
import '../../../controllers/usuario_controller.dart';
import '../../main.dart';
import '../../models/usuario_model.dart';
import '../widgets/skeleton.dart';

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
    final hasConnection = ConnectionNotifer.of(context).value;

    return PopScope(
        canPop: false,
        child: Scaffold(
          body: hasConnection
              ? Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder<Usuario>(
                            future: UsuarioController.getUsuarioLogado(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SkeletonItem();
                              } else if (snapshot.hasError) {
                                return Column(
                                  children: [
                                    const Text(
                                        'Erro ao carregar o nome do usuário.'),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                            context, '/');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 19, 74, 119),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                      ),
                                      child: const SizedBox(
                                        width: double.infinity,
                                        height: 35,
                                        child: Center(
                                          child: Text(
                                            'Tentar novamente',
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

                                int nivelUsuario =
                                    int.tryParse(usuario.nivel) ?? 0;
                                String user = usuario.usuario;

                                return FutureBuilder<List<Chamado>>(
                                  future: ChamadoController.getChamadosHome(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SkeletonItem();
                                    } else if (snapshot.hasError) {
                                      return const Center(
                                          child: Text(
                                              "Erro ao carregar chamados"));
                                    } else {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                        BorderRadius.circular(
                                                      30,
                                                    ),
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Icons.logout,
                                                      color: Color(0xFF0076BC),
                                                      size: 32,
                                                    ),
                                                    onPressed: () =>
                                                        _logout(context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '$user!',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'RobotoMono'),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 40,
                                            ),
                                            const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                            LayoutBuilder(
                                              builder: (context, constraints) {
                                                return SizedBox(
                                                  height: constraints
                                                              .maxHeight >
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.5
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.5
                                                      : constraints.maxHeight,
                                                  child: SingleChildScrollView(
                                                    physics: nivelUsuario <= 3
                                                        ? const AlwaysScrollableScrollPhysics()
                                                        : const NeverScrollableScrollPhysics(),
                                                    child: Column(
                                                      children: [
                                                        //Container Empresa e seus botoes...
                                                        Visibility(
                                                          visible:
                                                              nivelUsuario <= 2,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  131,
                                                                  255,
                                                                  255,
                                                                  255),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width:
                                                                      1), // Definindo o raio da borda
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20,
                                                                          5,
                                                                          20,
                                                                          0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
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
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 18,
                                                                              color: Colors.white,
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
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                35,
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
                                                                          20,
                                                                          5,
                                                                          20,
                                                                          20),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              const CircleBorder(),
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              12),
                                                                          backgroundColor:
                                                                              Colors.white, // Cor de fundo do botão
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              '/view_empresas');
                                                                        },
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .remove_red_eye_outlined,
                                                                          color:
                                                                              Color(0xFF0076BC),
                                                                          size:
                                                                              44,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              48),
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              const CircleBorder(),
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              12),
                                                                          backgroundColor:
                                                                              Colors.white, // Cor de fundo do botão
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              '/group');
                                                                        },
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .add,
                                                                          color:
                                                                              Color(0xFF0076BC),
                                                                          size:
                                                                              44,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        if (nivelUsuario <= 2)
                                                          const SizedBox(
                                                              height: 20),
                                                        //Container Usuário e seus botoes...
                                                        Visibility(
                                                          visible:
                                                              nivelUsuario <= 3,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  131,
                                                                  255,
                                                                  255,
                                                                  255),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20,
                                                                          5,
                                                                          20,
                                                                          0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
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
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 18,
                                                                              color: Colors.white,
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
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                35,
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
                                                                          20,
                                                                          5,
                                                                          20,
                                                                          20),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              const CircleBorder(),
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              12),
                                                                          backgroundColor:
                                                                              Colors.white, // Cor de fundo do botão
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              '/view_usuarios');
                                                                        },
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .remove_red_eye_outlined,
                                                                          color:
                                                                              Color(0xFF0076BC),
                                                                          size:
                                                                              44,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              48),
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              const CircleBorder(),
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              12),
                                                                          backgroundColor:
                                                                              Colors.white, // Cor de fundo do botão
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              '/register');
                                                                        },
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .add,
                                                                          color:
                                                                              Color(0xFF0076BC),
                                                                          size:
                                                                              44,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        if (nivelUsuario <= 3)
                                                          const SizedBox(
                                                              height: 20),
                                                        //container equipamentos e seus botoes...
                                                        Visibility(
                                                          visible:
                                                              nivelUsuario <= 3,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  131,
                                                                  255,
                                                                  255,
                                                                  255),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20,
                                                                          5,
                                                                          20,
                                                                          0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
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
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 18,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.computer_sharp,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                35,
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
                                                                          20,
                                                                          5,
                                                                          20,
                                                                          20),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              const CircleBorder(),
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              12),
                                                                          backgroundColor:
                                                                              Colors.white, // Cor de fundo do botão
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              '/view_equipamentos');
                                                                        },
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .remove_red_eye_outlined,
                                                                          color:
                                                                              Color(0xFF0076BC),
                                                                          size:
                                                                              44,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              48),
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              const CircleBorder(),
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              12),
                                                                          backgroundColor:
                                                                              Colors.white, // Cor de fundo do botão
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              '/hardware');
                                                                        },
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .add,
                                                                          color:
                                                                              Color(0xFF0076BC),
                                                                          size:
                                                                              44,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        if (nivelUsuario <= 3)
                                                          const SizedBox(
                                                              height: 20),
                                                        //container equipamentos e seus botoes...
                                                        Visibility(
                                                          visible:
                                                              nivelUsuario <= 4,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  131,
                                                                  255,
                                                                  255,
                                                                  255),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20,
                                                                          5,
                                                                          20,
                                                                          0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
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
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 18,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.document_scanner,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                35,
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
                                                                          20,
                                                                          5,
                                                                          20,
                                                                          20),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      if (nivelUsuario <=
                                                                          3)
                                                                        ElevatedButton(
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            shape:
                                                                                const CircleBorder(),
                                                                            padding:
                                                                                const EdgeInsets.all(12),
                                                                            backgroundColor:
                                                                                Colors.white, // Cor de fundo do botão
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pushNamed(context,
                                                                                '/view_chamados');
                                                                          },
                                                                          child:
                                                                              const Icon(
                                                                            Icons.remove_red_eye_outlined,
                                                                            color:
                                                                                Color(0xFF0076BC),
                                                                            size:
                                                                                44,
                                                                          ),
                                                                        ),
                                                                      if (nivelUsuario <=
                                                                          3)
                                                                        const SizedBox(
                                                                            width:
                                                                                48),
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              const CircleBorder(),
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              12),
                                                                          backgroundColor:
                                                                              Colors.white, // Cor de fundo do botão
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              '/chamado');
                                                                        },
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .add,
                                                                          color:
                                                                              Color(0xFF0076BC),
                                                                          size:
                                                                              44,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        if (nivelUsuario == 4)
                                                          LayoutBuilder(
                                                            builder: (context,
                                                                constraints) {
                                                              return SizedBox(
                                                                height: constraints.maxHeight >
                                                                        MediaQuery.of(context).size.height *
                                                                            0.5
                                                                    ? MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.3
                                                                    : constraints
                                                                        .maxHeight,
                                                                child: ListView
                                                                    .builder(
                                                                  physics:
                                                                      const AlwaysScrollableScrollPhysics(),
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount:
                                                                      snapshot
                                                                          .data!
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    Chamado
                                                                        chamado =
                                                                        snapshot
                                                                            .data![index];
                                                                    Color
                                                                        statusColor;
                                                                    IconData
                                                                        statusIcon;

                                                                    // Defina a cor e o ícone com base no status do chamado
                                                                    switch (chamado
                                                                        .Status) {
                                                                      case "Não iniciado":
                                                                        statusColor =
                                                                            Colors.red; // Cor transparente para o círculo
                                                                        statusIcon =
                                                                            Icons.circle; // Ícone de círculo
                                                                        break;
                                                                      case "Em andamento":
                                                                        statusColor =
                                                                            Colors.lightBlueAccent;
                                                                        statusIcon =
                                                                            Icons.timelapse; // Ícone de marca de seleção
                                                                        break;
                                                                      case "Aguardando":
                                                                        statusColor =
                                                                            Colors.yellow;
                                                                        statusIcon =
                                                                            Icons.timer; // Ícone de relógio
                                                                        break;
                                                                      case "Concluído":
                                                                        statusColor =
                                                                            Colors.green;
                                                                        statusIcon =
                                                                            Icons.check_circle; // Ícone de erro
                                                                        break;
                                                                      default:
                                                                        statusColor =
                                                                            Colors.transparent;
                                                                        statusIcon =
                                                                            Icons.circle;
                                                                    }
                                                                    return Container(
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        border:
                                                                            Border(
                                                                          bottom:
                                                                              BorderSide(color: Colors.grey),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            chamado.Titulo),
                                                                        subtitle:
                                                                            Text("ID: ${chamado.IDchamado}"),
                                                                        trailing:
                                                                            CircleAvatar(
                                                                          backgroundColor:
                                                                              statusColor,
                                                                          child:
                                                                              Icon(
                                                                            statusIcon,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          // Navegação para a tela de detalhes
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => DetalheChamado(
                                                                                chamado: chamado,
                                                                                nivel: usuario.nivel,
                                                                                uid: usuario.uid,
                                                                                empresa: usuario.empresa,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Visibility(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/scan');
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_outlined,
                            color: Color(0xFF0076BC),
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/no_internet.png',
                        color: Colors.red,
                        height: 100,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 10),
                        child: const Text(
                          'Sem conexão com a internet.',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Verifique sua conexão e tente novamente.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),
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
                  const IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 32,
                    ),
                    onPressed: null,
                  ),
                  const IconButton(
                    icon: Icon(
                      Icons.home,
                      size: 32,
                    ),
                    onPressed: null,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.person,
                      color: Color(0xFF0076BC),
                      size: 32,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SkeletonItem(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
