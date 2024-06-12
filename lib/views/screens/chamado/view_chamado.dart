// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:testeseki/controllers/chamado_controller.dart';
import 'package:testeseki/controllers/usuario_controller.dart';
import 'package:testeseki/models/chamado_model.dart';
import 'package:testeseki/models/usuario_model.dart';

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

  @override
  void initState() {
    super.initState();
    _carregarUsuarioLogado();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar Chamados'),
        actions: [
          IconButton(
            onPressed: _alternarOrdem,
            icon: Icon(iconeOrdem), // Use a variável de ícone
            tooltip:
                ordemCrescente ? 'Ordenar Decrescente' : 'Ordenar Crescente',
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
                border: const OutlineInputBorder(),
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
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhum chamado encontrado.'));
                } else {
                  // Filtrar chamados com base no ID
                  final List<Chamado> chamadosFiltrados = filtroID.isNotEmpty
                      ? snapshot.data!
                          .where(
                              (chamado) => chamado.IDchamado.contains(filtroID))
                          .toList()
                      : snapshot.data!;

                  return ListView.builder(
                    itemCount: chamadosFiltrados.length,
                    itemBuilder: (context, index) {
                      final chamado = chamadosFiltrados[index];
                      return ListTile(
                        title: Text(chamado.IDchamado),
                        subtitle: Text(chamado.Titulo),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(chamado.Status),
                            Text(chamado.Lido ? 'Lido' : 'Não lido'),
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
    );
  }
}
