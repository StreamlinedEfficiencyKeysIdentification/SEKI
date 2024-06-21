// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:testeseki/controllers/chamado_controller.dart';
import 'package:testeseki/controllers/usuario_controller.dart';
import 'package:testeseki/models/chamado_model.dart';
import 'package:testeseki/models/usuario_model.dart';
import 'package:testeseki/views/screens/chamado/detalhe_chamado.dart';
import 'package:testeseki/views/widgets/skeleton.dart';

class ViewChamados extends StatefulWidget {
  const ViewChamados({super.key});

  @override
  ViewChamadosState createState() => ViewChamadosState();
}

class ViewChamadosState extends State<ViewChamados> {
  Usuario user = Usuario(
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

  bool ordemCrescente = true; // Variável para controlar a ordem
  IconData iconeOrdem = Icons.sort; // Ícone inicial
  String filtroID = ''; // Filtro para o ID do chamado
  final TextEditingController _filtroController = TextEditingController();
  String selectedFilter = 'none';
  String selectedStatusFilter = 'none';
  String selectedLidoFilter = 'none';

  @override
  void initState() {
    super.initState();
    _carregarUsuarioLogado();
  }

  @override
  void dispose() {
    _filtroController.dispose(); // Descarte o controlador
    super.dispose();
  }

  Future<void> _carregarUsuarioLogado() async {
    try {
      Usuario usuario = await UsuarioController.getUsuarioLogado();
      setState(() {
        user = usuario;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar usuário logado.')),
      );
    }
  }

  // Função para alternar a ordem dos chamados
  void _alternarOrdem() {
    setState(() {
      ordemCrescente = !ordemCrescente; // Alterne entre true e false
      iconeOrdem = ordemCrescente
          ? Icons.keyboard_double_arrow_up
          : Icons.keyboard_double_arrow_down;
    });
  }

  // Função para atualizar o filtro de ID
  void _atualizarFiltro(String value) {
    setState(() {
      filtroID = value;
    });
  }

  void _showStatusFilterMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 80, 0, 0),
      items: [
        const PopupMenuItem<String>(
          value: 'Concluído',
          child: Text('Status: Concluido'),
        ),
        const PopupMenuItem<String>(
          value: 'Aguardando',
          child: Text('Status: Aguardando'),
        ),
        const PopupMenuItem<String>(
          value: 'Em andamento',
          child: Text('Status: Em andamento'),
        ),
        const PopupMenuItem<String>(
          value: 'Não iniciado',
          child: Text('Status: Não iniciado'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedStatusFilter = value;
        });
      }
    });
  }

  void _showLidoFilterMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 80, 0, 0),
      items: [
        const PopupMenuItem<String>(
          value: 'lido_true',
          child: Text('Lido'),
        ),
        const PopupMenuItem<String>(
          value: 'lido_false',
          child: Text('Não lido'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedLidoFilter = value;
        });
      }
    });
  }

  // Função para resetar todos os filtros
  void _resetFilters() {
    setState(() {
      filtroID = '';
      selectedStatusFilter = 'none';
      selectedLidoFilter = 'none';
      _filtroController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Chamados'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _alternarOrdem,
            icon: Icon(iconeOrdem), // Use a variável de ícone
            tooltip:
                ordemCrescente ? 'Ordenar Decrescente' : 'Ordenar Crescente',
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'none') {
                _resetFilters();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'none',
                child: Text('Sem filtro'),
              ),
              PopupMenuItem<String>(
                child: ListTile(
                  title: const Text('Filtrar por Status'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () {
                    Navigator.pop(context); // Fechar o menu principal
                    _showStatusFilterMenu(context);
                  },
                ),
              ),
              PopupMenuItem<String>(
                child: ListTile(
                  title: const Text('Filtrar por Lido'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () {
                    Navigator.pop(context); // Fechar o menu principal
                    _showLidoFilterMenu(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _filtroController, // Defina o controlador
              onChanged: _atualizarFiltro,
              decoration: InputDecoration(
                labelText: 'Filtrar por ID do Chamado',
                filled: true,
                fillColor: const Color.fromARGB(150, 255, 255, 255),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                suffixIcon: filtroID.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _filtroController.clear(); // Limpe o campo de texto
                          _atualizarFiltro(
                              ''); // Atualize o filtro para uma string vazia
                        },
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: const BorderSide(
                      color: Color.fromARGB(253, 255, 255, 255)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Chamado>>(
              future: ChamadoController.getChamados(
                  crescente:
                      ordemCrescente), // Passa a ordem atual para a função
              builder: (BuildContext context,
                  AsyncSnapshot<List<Chamado>> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SkeletonLoader();
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhum chamado encontrado.'));
                } else {
                  // Filtrar chamados com base no ID
                  List<Chamado> chamadosFiltrados = filtroID.isNotEmpty
                      ? snapshot.data!
                          .where(
                              (chamado) => chamado.IDchamado.contains(filtroID))
                          .toList()
                      : snapshot.data!;

                  // Aplicar filtros de status e lido
                  if (selectedStatusFilter != 'none') {
                    chamadosFiltrados = chamadosFiltrados.where((chamado) {
                      return chamado.Status == selectedStatusFilter;
                    }).toList();
                  }
                  if (selectedLidoFilter != 'none') {
                    chamadosFiltrados = chamadosFiltrados.where((chamado) {
                      return selectedLidoFilter == 'lido_true'
                          ? chamado.Lido == true
                          : chamado.Lido == false;
                    }).toList();
                  }

                  return ListView.builder(
                    itemCount: chamadosFiltrados.length,
                    itemBuilder: (context, index) {
                      final chamado = chamadosFiltrados[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: ListTile(
                                tileColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title: Text(chamado.IDchamado),
                                subtitle: Text(
                                    '${chamado.Titulo}\n${chamado.DataCriacao}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(chamado.Status),
                                    Text(
                                      chamado.Lido ? 'Lido' : 'Não lido',
                                      style: TextStyle(
                                        color: chamado.Lido
                                            ? const Color.fromARGB(
                                                255, 170, 241, 173)
                                            : const Color.fromARGB(
                                                255, 77, 75, 75),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Vai para a tela de detalhes chamado
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetalheChamado(
                                        chamado: chamado,
                                        nivel: user.nivel,
                                        uid: user.uid,
                                        empresa: user.empresa,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
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
                icon: const Icon(
                  Icons.arrow_back,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
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
}
