import 'package:flutter/material.dart';
import '../../../controllers/empresa_controller.dart';
import '../../../controllers/usuario_controller.dart';
import '../../../main.dart';
import '../../../models/empresa_model.dart';
import '../../../models/usuario_model.dart';
import '../../widgets/skeleton.dart';
import 'detalhe_usuario.dart';

class VisualizarUsuarios extends StatefulWidget {
  const VisualizarUsuarios({Key? key});

  @override
  State<VisualizarUsuarios> createState() => _VisualizarUsuariosState();
}

class _VisualizarUsuariosState extends State<VisualizarUsuarios> {
  late Future<List<Empresa>> _empresasFuture;
  late Future<List<Usuario>> _usuariosFuture;
  late Future<Usuario> _usuario;
  late String _statusFiltro = 'Ativo';
  late String _searchText = "";

  Map<String, bool> selectedMap = {};

  @override
  void initState() {
    super.initState();
    _empresasFuture = EmpresaController.getEmpresas();
    _usuariosFuture = UsuarioController.getUsuarios();
    _usuario = UsuarioController.getUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    final hasConnection = ConnectionNotifer.of(context).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar Usuários'),
        leading: hasConnection
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              )
            : Container(),
      ),
      body: hasConnection
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: Icon(
                          Icons.person, // Ícone de usuário
                          color: const Color(0xFF0073BC),
                          size: 140, // Tamanho do ícone
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar por Nome ou Email',
                          hintStyle: const TextStyle(fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFF0073BC).withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: const Icon(Icons.search,
                              color: Colors.black), // Ícone à direita
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchText = value.toLowerCase();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _statusFiltro = 'Ativo';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _statusFiltro == 'Ativo' ? Colors.blue : null,
                        ),
                        child: const Text('Ativo'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _statusFiltro = 'Inativo';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _statusFiltro == 'Inativo' ? Colors.blue : null,
                        ),
                        child: const Text('Inativo'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _statusFiltro = 'Ambos';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _statusFiltro == 'Ambos' ? Colors.blue : null,
                        ),
                        child: const Text('Ambos'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder<List<Empresa>>(
                      future: _empresasFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SkeletonLoader();
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Erro: ${snapshot.error}'));
                        } else {
                          List<Empresa> empresas;
                          empresas = snapshot.data!;
                          return FutureBuilder<List<Usuario>>(
                            future: _usuariosFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SkeletonLoader();
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Erro: ${snapshot.error}'));
                              } else {
                                final usuarios =
                                    snapshot.data!.where((usuario) {
                                  return (_statusFiltro == 'Ambos' ||
                                          usuario.status == _statusFiltro) &&
                                      (usuario.nome
                                              .toLowerCase()
                                              .contains(_searchText) ||
                                          usuario.email
                                              .toLowerCase()
                                              .contains(_searchText));
                                }).toList();

                                return FutureBuilder<Usuario>(
                                  future: _usuario,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SkeletonLoader();
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Erro: ${snapshot.error}'));
                                    } else {
                                      final usuario = snapshot.data!;
                                      return ListView.builder(
                                        itemCount: empresas.length,
                                        itemBuilder: (context, index) {
                                          final empresa = empresas[index];
                                          if (empresa.matriz == empresa.id) {
                                            // É uma empresa matriz
                                            return _buildMatrizTile(empresa,
                                                empresas, usuarios, usuario);
                                          } else {
                                            // É uma empresa filial (será tratada nas empresas matriz)
                                            return Container();
                                          }
                                        },
                                      );
                                    }
                                  },
                                );
                              }
                            },
                          );
                        }
                      },
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
                  const SizedBox(height: 20),
                  const Text(
                    'Sem conexão com a internet.',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Verifique sua conexão e tente novamente.',
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildMatrizTile(Empresa matriz, List<Empresa> todasEmpresas,
      List<Usuario> usuarios, Usuario usuario) {
    int nivel = int.parse(usuario.nivel);
    final filiais = todasEmpresas
        .where((e) => e.matriz == matriz.id && e.id != matriz.id)
        .toList();
    final usuariosMatriz =
        usuarios.where((usuario) => usuario.empresa == matriz.id).toList();

    final filiaisComUsuarios = filiais.where((filial) {
      final usersInFilial = usuarios
          .where((usuario) =>
              usuario.empresa == filial.id &&
              (_statusFiltro == 'Ambos' || usuario.status == _statusFiltro))
          .toList();
      return usersInFilial.isNotEmpty;
    }).toList();

    final showExpansionArrow =
        filiaisComUsuarios.isNotEmpty || usuariosMatriz.isNotEmpty;

    if (!selectedMap.containsKey(matriz.id)) {
      selectedMap[matriz.id] = false;
    }

    final totalUsuariosFiliais = filiaisComUsuarios.fold<int>(
        0,
        (total, filial) =>
            total +
            usuarios
                .where((usuario) =>
                    usuario.empresa == filial.id &&
                    (_statusFiltro == 'Ambos' ||
                        usuario.status == _statusFiltro))
                .length);

    final totalUsuariosMatriz = nivel <= 1
        ? usuariosMatriz
            .where((usuario) =>
                (_statusFiltro == 'Ambos' || usuario.status == _statusFiltro))
            .length
        : 0;

    final totalUsuarios = totalUsuariosFiliais + totalUsuariosMatriz;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExpansionTile(
          title: Text('${matriz.razaoSocial} ($totalUsuarios)'),
          trailing: !showExpansionArrow
              ? const SizedBox()
              : Icon(
                  selectedMap[matriz.id] ?? false
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
          onExpansionChanged: (value) {
            setState(() {
              selectedMap[matriz.id] = value;
            });
          },
          children: [
            if (nivel <= 1)
              ...usuariosMatriz.map(
                (usuario) => ListTile(
                  title: Row(
                    children: [
                      const SizedBox(width: 24),
                      Expanded(
                        child: GestureDetector(
                          child: Text('${usuario.nome} \n ${usuario.usuario}'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalhesUsuarioPage(
                                usuario: usuario.uid,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ...filiaisComUsuarios
                .map((filial) => _buildFilialTile(filial, usuarios)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilialTile(Empresa filial, List<Usuario> usuarios) {
    final usersInFilial = usuarios
        .where((usuario) =>
            usuario.empresa == filial.id &&
            (_statusFiltro == 'Ambos' || usuario.status == _statusFiltro))
        .toList();
    final showExpansionArrow = usersInFilial.isNotEmpty;

    if (!selectedMap.containsKey(filial.id)) {
      selectedMap[filial.id] = false;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExpansionTile(
          title: Row(
            children: [
              const SizedBox(width: 12),
              Text('${filial.razaoSocial} (${usersInFilial.length})'),
            ],
          ),
          trailing: !showExpansionArrow
              ? const SizedBox()
              : Icon(
                  selectedMap[filial.id] ?? false
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
          onExpansionChanged: (value) {
            setState(() {
              selectedMap[filial.id] = value;
            });
          },
          children: [
            ...usersInFilial.map(
              (usuario) => ListTile(
                title: Row(
                  children: [
                    const SizedBox(width: 24),
                    Expanded(
                      child: GestureDetector(
                        child: Text('${usuario.nome} \n ${usuario.usuario}'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalhesUsuarioPage(
                              usuario: usuario.uid,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Adicione mais detalhes do usuário conforme necessário
              ),
            ),
          ],
        ),
      ),
    );
  }
}
