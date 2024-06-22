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
                      EdgeInsets.fromLTRB(16.0, _statusBarHeight, 16.0, 16.0),
                  child: Column(
                    children: [
                      const Column(
                        children: [
                          Icon(
                            Icons.location_city,
                            color: Color(0xFF0076BC),
                            size: 100,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Empresas',
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
                                labelText: 'Buscar por CNPJ ou Razão Social',
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
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              Text(
                                _searchInMatriz ? 'Matriz' : 'Filial',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                activeColor: const Color(0xFF0076BC),
                                inactiveTrackColor: Colors.white,
                                inactiveThumbColor: Colors.grey,
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

  String formatCNPJ(String cnpj) {
    // Verifica se o CNPJ possui exatamente 14 caracteres
    if (cnpj.length != 14) {
      return cnpj; // Retorna o CNPJ original se não tiver 14 caracteres
    }
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12, 14)}';
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
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    child: Text(
                      '${matriz.razaoSocial} (${filiais.length})\n${formatCNPJ(matriz.cnpj)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                    backgroundColor:
                        const Color(0xFF0076BC), // Cor de fundo do botão
                  ),
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
                      (filial) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // Fundo cinza
                            borderRadius: BorderRadius.circular(
                                8), // Borda arredondada opcional
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    child: Text(
                                      '${filial.razaoSocial} \n ${formatCNPJ(filial.cnpj)}',
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
                                        builder: (context) =>
                                            DetalhesEmpresaPage(
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
                                      empresaID: filial.id,
                                      setorVisibility: false),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                    .toList()
                : [],
          ),
        ),
      ),
    );
  }
}
