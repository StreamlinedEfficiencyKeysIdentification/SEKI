import 'package:flutter/material.dart';
import '../../../controllers/empresa_controller.dart';
import '../../../controllers/equipamento_controller.dart';
import '../../../controllers/usuario_controller.dart';
import '../../../models/empresa_model.dart';
import '../../../models/equipamento_model.dart';
import '../../../models/usuario_model.dart';
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

  Map<String, bool> selectedMap = {};

  @override
  void initState() {
    super.initState();
    _empresasFuture = EmpresaController.getEmpresas();
    _equipamentosFuture = EquipamentoController.getEquipamentos();
    _usuario = UsuarioController.getUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Visualizar Equipamentos'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          )),
      body: Padding(
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
              return FutureBuilder<List<Equipamento>>(
                future: _equipamentosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else {
                    final equipamentos = snapshot.data!;

                    return FutureBuilder<Usuario>(
                        future: _usuario,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Erro: ${snapshot.error}'));
                          } else {
                            final usuario = snapshot.data!;

                            return ListView.builder(
                              itemCount: empresas.length,
                              itemBuilder: (context, index) {
                                final empresa = empresas[index];
                                if (empresa.matriz == empresa.id) {
                                  // É uma empresa matriz
                                  return _buildMatrizTile(
                                      empresa, empresas, equipamentos, usuario);
                                } else {
                                  // É uma empresa filial (será tratada nas empresas matriz)
                                  return null;
                                }
                              },
                            );
                          }
                        });
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMatrizTile(Empresa matriz, List<Empresa> todasEmpresas,
      List<Equipamento> equipamentos, Usuario usuario) {
    final filiais = todasEmpresas
        .where((e) => e.matriz == matriz.id && e.id != matriz.id)
        .toList();

    final showExpansionArrow = filiais.isNotEmpty;

    if (!selectedMap.containsKey(matriz.id)) {
      // Se não existir, adiciona o ID da matriz ao mapa com o valor inicial como false
      selectedMap[matriz.id] = false;
    }

    return ExpansionTile(
      title: Text(matriz.razaoSocial),
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
        ...filiais.map((filial) => _buildFilialTile(filial, equipamentos)),
      ],
    );
  }

  Widget _buildFilialTile(Empresa filial, List<Equipamento> equipamentos) {
    final equipsInFilial = equipamentos
        .where((equipamento) => equipamento.empresa == filial.id)
        .toList();
    final showExpansionArrow = equipsInFilial.isNotEmpty;

    if (!selectedMap.containsKey(filial.id)) {
      // Se não existir, adiciona o ID da filial ao mapa com o valor inicial como false
      selectedMap[filial.id] = false;
    }

    return ExpansionTile(
      title: Text(filial.razaoSocial),
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
          (equipamento) => ListTile(
            title: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    child:
                        Text('${equipamento.qrcode} \n ${equipamento.empresa}'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye),
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
            // Adicione mais detalhes do usuário conforme necessário
          ),
        ),
      ],
    );
  }
}
