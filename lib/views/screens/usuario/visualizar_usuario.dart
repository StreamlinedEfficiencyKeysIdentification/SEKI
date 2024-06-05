import 'package:flutter/material.dart';
import '../../../controllers/empresa_controller.dart';
import '../../../controllers/usuario_controller.dart';
import '../../../main.dart';
import '../../../models/empresa_model.dart';
import '../../../models/usuario_model.dart';
import '../../widgets/skeleton.dart';
import 'detalhe_usuario.dart';

class VisualizarUsuarios extends StatefulWidget {
  const VisualizarUsuarios({super.key});

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
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Buscar por Nome ou Email',
                            labelStyle: TextStyle(
                                fontSize: 12), // Ajuste o tamanho da fonte aqui
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchText = value.toLowerCase();
                            });
                          },
                        ),
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

    // Filtrar filiais com base nos usuários
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

    // Contar usuários das filiais associadas à matriz
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

    // Incluir contagem de usuários da matriz se o nível do usuário for <= 1
    final totalUsuariosMatriz = nivel <= 1
        ? usuariosMatriz
            .where((usuario) =>
                (_statusFiltro == 'Ambos' || usuario.status == _statusFiltro))
            .length
        : 0;

    final totalUsuarios = totalUsuariosFiliais + totalUsuariosMatriz;

    return ExpansionTile(
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

    return ExpansionTile(
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
    );
  }
}
