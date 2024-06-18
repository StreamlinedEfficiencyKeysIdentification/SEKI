import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/empresa_controller.dart';
import '../../../main.dart';
import '../../../models/empresa_model.dart';
import '../../widgets/skeleton.dart';
import 'detalhe_empresa.dart';

class VisualizarEmpresas extends StatefulWidget {
  const VisualizarEmpresas({super.key});

  @override
  State<VisualizarEmpresas> createState() => _VisualizarEmpresasState();
}

class _VisualizarEmpresasState extends State<VisualizarEmpresas> {
  late Future<List<Empresa>> _empresasFuture;
  late String _statusFiltro = 'Ativo';
  String _searchText = "";
  bool _searchInMatriz = false;
  double _statusBarHeight = 0;

  Map<String, bool> selectedMap = {};

  @override
  void initState() {
    super.initState();
    _empresasFuture = EmpresaController.getEmpresas();

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
                      EdgeInsets.fromLTRB(12.0, _statusBarHeight, 12.0, 12.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 10),
                        child: Icon(
                          Icons.location_city, // Ícone de prédio
                          color: Color(0xFF0073BC),
                          size: 140, // Ajustando o tamanho do ícone
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF0073BC).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: TextField(
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Buscar por CNPJ ou Razão Social',
                                    hintStyle: TextStyle(fontSize: 14),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 10),
                                    suffixIcon: Icon(Icons.search,
                                        color: Colors.black), // Ícone à direita
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchText = value.toLowerCase();
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                Text(_searchInMatriz ? 'Matriz' : 'Filial'),
                                Switch(
                                  value: _searchInMatriz,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchInMatriz = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
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
                          if (_searchInMatriz) {
                            // Busca nas matrizes
                            empresas = snapshot.data!.where((empresa) {
                              return (_statusFiltro == 'Ambos' ||
                                      empresa.status == _statusFiltro) &&
                                  (empresa.cnpj
                                          .toLowerCase()
                                          .contains(_searchText) ||
                                      empresa.razaoSocial
                                          .toLowerCase()
                                          .contains(_searchText));
                            }).toList();
                          } else {
                            // Busca nas filiais
                            empresas = snapshot.data!;
                          }
                          return ListView.builder(
                            itemCount: empresas.length,
                            itemBuilder: (context, index) {
                              final empresa = empresas[index];
                              if (empresa.matriz == empresa.id) {
                                // É uma empresa matriz
                                return _buildMatrizTile(empresa, empresas);
                              } else {
                                // É uma empresa filial (será tratada nas empresas matriz)
                                return Container();
                              }
                            },
                          );
                        }
                      },
                    ),
                  ),
                )
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
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
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

  Widget _buildMatrizTile(Empresa matriz, List<Empresa> todasEmpresas) {
    final filiais = todasEmpresas
        .where((e) => e.matriz == matriz.id && e.id != matriz.id)
        .where(
            (e) => _statusFiltro == 'Ambos' ? true : e.status == _statusFiltro)
        .where((e) =>
            e.razaoSocial.toLowerCase().contains(_searchText) ||
            e.cnpj.toLowerCase().contains(_searchText))
        .toList();

    final showExpansionArrow = filiais.isNotEmpty;

    if (!selectedMap.containsKey(matriz.id)) {
      // Se não existir, adiciona o ID da matriz ao mapa com o valor inicial como false
      selectedMap[matriz.id] = false;
    }

    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(10), // Arredondado
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: GestureDetector(
                child: Text('${matriz.razaoSocial} (${filiais.length})'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalhesEmpresaPage(
                        empresaID: matriz.id, setorVisibility: true),
                  ),
                );
              },
            ),
          ],
        ),
        trailing: !_searchInMatriz &&
                showExpansionArrow // Se _searchInMatriz for verdadeiro, trailing fica null
            ? SizedBox(
                width: 30,
                child: Icon(
                  selectedMap[matriz.id] ?? false
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              )
            : const SizedBox(
                width: 30,
              ),
        onExpansionChanged:
            !_searchInMatriz // Só permite expandir se _searchInMatriz for falso
                ? (value) {
                    setState(() {
                      selectedMap[matriz.id] = value;
                    });
                  }
                : null,
        children: !_searchInMatriz
            ? filiais
                .map(
                  (filial) => ListTile(
                    title: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            child:
                                Text('${filial.razaoSocial} \n ${filial.cnpj}'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalhesEmpresaPage(
                                    empresaID: filial.id,
                                    setorVisibility: false),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalhesEmpresaPage(
                              empresaID: filial.id, setorVisibility: false),
                        ),
                      );
                    },
                  ),
                )
                .toList()
            : [],
      ),
    );
  }
}
