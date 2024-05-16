import 'package:flutter/material.dart';
import '../../../controllers/empresa_controller.dart';
import '../../../models/empresa_model.dart';
import 'detalhe_empresa.dart';

class VisualizarEmpresas extends StatefulWidget {
  const VisualizarEmpresas({super.key});

  @override
  State<VisualizarEmpresas> createState() => _VisualizarEmpresasState();
}

class _VisualizarEmpresasState extends State<VisualizarEmpresas> {
  late Future<List<Empresa>> _empresasFuture;
  late String _statusFiltro = 'Ativo';

  Map<String, bool> selectedMap = {};

  @override
  void initState() {
    super.initState();
    _empresasFuture = EmpresaController.getEmpresas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Visualizar Empresas'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else {
                    final empresas = snapshot.data!;
                    return ListView.builder(
                      itemCount: empresas.length,
                      itemBuilder: (context, index) {
                        final empresa = empresas[index];
                        if (empresa.matriz == empresa.id) {
                          // É uma empresa matriz
                          return _buildMatrizTile(empresa, empresas);
                        } else {
                          // É uma empresa filial (será tratada nas empresas matriz)
                          return null;
                        }
                      },
                    );
                  }
                },
              ),
            ),
          )
        ]));
  }

  Widget _buildMatrizTile(Empresa matriz, List<Empresa> todasEmpresas) {
    final filiais = todasEmpresas
        .where((e) => e.matriz == matriz.id && e.id != matriz.id)
        .where(
            (e) => _statusFiltro == 'Ambos' ? true : e.status == _statusFiltro)
        .toList();

    final showExpansionArrow = filiais.isNotEmpty;

    if (!selectedMap.containsKey(matriz.id)) {
      // Se não existir, adiciona o ID da matriz ao mapa com o valor inicial como false
      selectedMap[matriz.id] = false;
    }

    return ExpansionTile(
      title: Row(
        children: [
          Expanded(
            child: GestureDetector(
              child: Text(matriz.razaoSocial),
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
      trailing: !showExpansionArrow
          ? const SizedBox(
              width: 30,
            )
          : SizedBox(
              width: 30,
              child: Icon(
                selectedMap[matriz.id] ?? false
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ),
      onExpansionChanged: (value) {
        setState(() {
          selectedMap[matriz.id] = value;
        });
      },
      children: filiais
          .map((filial) => ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: Text('${filial.razaoSocial} \n ${filial.cnpj}'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalhesEmpresaPage(
                                empresaID: filial.id, setorVisibility: false),
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
              ))
          .toList(),
    );
  }
}
