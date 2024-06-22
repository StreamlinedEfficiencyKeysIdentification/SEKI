import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/empresa_controller.dart';
import '../../../controllers/equipamento_controller.dart';
import '../../../controllers/usuario_controller.dart';
import '../../../main.dart';
import '../../../models/empresa_model.dart';
import '../../../models/equipamento_model.dart';
import '../../../models/usuario_model.dart';
import '../../widgets/skeleton.dart';
import 'detalhe_equipamento.dart';

class VisualizarEquipamentos extends StatefulWidget {
  const VisualizarEquipamentos({super.key});

  @override
  State<VisualizarEquipamentos> createState() => _VisualizarEquipamentosState();
}

class _VisualizarEquipamentosState extends State<VisualizarEquipamentos> {
  late Future<List<Empresa>> _empresasFuture;
  late Future<List<Equipamento>> _equipamentosFuture;
  late Future<Usuario> _usuario;
  String _statusFiltro = 'Ativo';
  String _searchText = "";
  double _statusBarHeight = 0;

  Map<String, bool> selectedMap = {};

  @override
  void initState() {
    super.initState();
    _empresasFuture = EmpresaController.getEmpresas();
    _equipamentosFuture = EquipamentoController.getEquipamentos();
    _usuario = UsuarioController.getUsuarioLogado();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statusBarHeight = MediaQuery.of(context).padding.top;
  }

  @override
  Widget build(BuildContext context) {
    final hasConnection = ConnectionNotifer.of(context).value;

    return Scaffold(
      body: hasConnection
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      EdgeInsets.fromLTRB(16.0, _statusBarHeight, 16.0, 16.0),
                  child: Column(
                    children: [
                      const Column(
                        children: [
                          Icon(
                            Icons.computer, // Ícone de usuário
                            color: Color(0xFF0073BC),
                            size: 100, // Tamanho do ícone
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Equipamentos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchText = value.toLowerCase();
                                });
                              },
                              style: const TextStyle(
                                color: Color(0xFF0076BC),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Buscar por Marca, Modelo, QRCode',
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 255, 255, 255),
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
                                    color: Colors
                                        .red, // Cor da borda quando há um erro
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
                                suffixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF0076BC),
                                  size: 32.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _statusFiltro = 'Ativo';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _statusFiltro == 'Ativo'
                            ? const Color(0xFF0076BC)
                            : Colors.white,
                      ),
                      child: Text(
                        'Ativo',
                        style: TextStyle(
                          color: _statusFiltro == 'Ativo'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _statusFiltro = 'Inativo';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _statusFiltro == 'Inativo'
                            ? const Color(0xFF0076BC)
                            : Colors.white,
                      ),
                      child: Text(
                        'Inativo',
                        style: TextStyle(
                          color: _statusFiltro == 'Inativo'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _statusFiltro = 'Ambos';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _statusFiltro == 'Ambos'
                            ? const Color(0xFF0076BC)
                            : Colors.white,
                      ),
                      child: Text(
                        'Ambos',
                        style: TextStyle(
                          color: _statusFiltro == 'Ambos'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
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
                          final empresas = snapshot.data!;
                          return FutureBuilder<List<Equipamento>>(
                            future: _equipamentosFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SkeletonLoader();
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Erro: ${snapshot.error}'));
                              } else {
                                final equipamentos =
                                    snapshot.data!.where((equipamento) {
                                  return (_statusFiltro == 'Ambos' ||
                                          equipamento.status ==
                                              _statusFiltro) &&
                                      (equipamento.marca
                                              .toLowerCase()
                                              .contains(_searchText) ||
                                          equipamento.modelo
                                              .toLowerCase()
                                              .contains(_searchText) ||
                                          equipamento.qrcode
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
                                            return _buildMatrizTile(
                                                empresa,
                                                empresas,
                                                equipamentos,
                                                usuario);
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
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF0076BC),
                  size: 32,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.home,
                  color: Color(0xFF0076BC),
                  size: 32,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.person,
                  color: Color(0xFF0076BC),
                  size: 32,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatrizTile(Empresa matriz, List<Empresa> todasEmpresas,
      List<Equipamento> equipamentos, Usuario usuario) {
    int nivel = int.parse(usuario.nivel);
    final filiais = todasEmpresas
        .where((e) => e.matriz == matriz.id && e.id != matriz.id)
        .toList();
    final equipamentosMatriz = equipamentos
        .where((equipamento) => equipamento.empresa == matriz.id)
        .toList();

    // Filtrar filiais com base nos equipamentos
    final filiaisComEquipamentos = filiais.where((filial) {
      final equipsInFilial = equipamentos
          .where((equipamento) =>
              equipamento.empresa == filial.id &&
              (_statusFiltro == 'Ambos' || equipamento.status == _statusFiltro))
          .toList();
      return equipsInFilial.isNotEmpty;
    }).toList();

    final showExpansionArrow =
        filiaisComEquipamentos.isNotEmpty || equipamentosMatriz.isNotEmpty;

    if (!selectedMap.containsKey(matriz.id)) {
      selectedMap[matriz.id] = false;
    }

    final totalEquipamentosFiliais = filiaisComEquipamentos.fold<int>(
        0,
        (total, filial) =>
            total +
            equipamentos
                .where((equipamento) =>
                    equipamento.empresa == filial.id &&
                    (_statusFiltro == 'Ambos' ||
                        equipamento.status == _statusFiltro))
                .length);

    // Incluir contagem de usuários da matriz se o nível do usuário for <= 1
    final totalEquipamentosMatriz = nivel <= 1
        ? equipamentosMatriz
            .where((equipamento) => (_statusFiltro == 'Ambos' ||
                equipamento.status == _statusFiltro))
            .length
        : 0;

    final totalEquipamentos =
        totalEquipamentosFiliais + totalEquipamentosMatriz;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              '${matriz.razaoSocial} ($totalEquipamentos)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
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
              if (nivel <= 2)
                ...equipamentosMatriz.map((equipamento) => ListTile(
                      title: Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              child: Text(
                                '${equipamento.qrcode} \n ${equipamento.empresa}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_red_eye,
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(8),
                              backgroundColor: const Color(0xFF0076BC),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetalhesEquipamentoPage(
                                    equipamento: equipamento.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )),
              ...filiaisComEquipamentos
                  .map((filial) => _buildFilialTile(filial, equipamentos)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilialTile(Empresa filial, List<Equipamento> equipamentos) {
    final equipsInFilial = equipamentos
        .where((equipamento) =>
            equipamento.empresa == filial.id &&
            (_statusFiltro == 'Ambos' || equipamento.status == _statusFiltro))
        .toList();
    final showExpansionArrow = equipsInFilial.isNotEmpty;

    if (!selectedMap.containsKey(filial.id)) {
      selectedMap[filial.id] = false;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExpansionTile(
          title: Row(
            children: [
              const SizedBox(width: 4),
              Text(
                '${filial.razaoSocial} (${equipsInFilial.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
            ...equipsInFilial.map(
              (equipamento) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Fundo cinza
                    borderRadius:
                        BorderRadius.circular(8), // Borda arredondada opcional
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            child: Text(
                              '${equipamento.qrcode} \n ${equipamento.marca} ${equipamento.modelo}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_red_eye,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(8),
                            backgroundColor: const Color(0xFF0076BC),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalhesEquipamentoPage(
                                  equipamento: equipamento.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
