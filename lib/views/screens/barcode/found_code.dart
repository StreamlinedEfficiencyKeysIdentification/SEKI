import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testeseki/controllers/equipamento_controller.dart';
import 'package:testeseki/models/equipamento_model.dart';
import 'package:testeseki/views/screens/chamado/chamado.dart';

class FoundScreen extends StatefulWidget {
  final String value;
  const FoundScreen({
    super.key,
    required this.value,
  });

  @override
  State<FoundScreen> createState() => _FoundScreenState();
}

class _FoundScreenState extends State<FoundScreen> {
  double _statusBarHeight = 0;

  @override
  void initState() {
    super.initState();

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
    return Scaffold(
      body: Center(
        // Centraliza o conteúdo na tela
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, _statusBarHeight, 16.0, 16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Centraliza horizontalmente
              mainAxisSize: MainAxisSize
                  .min, // Ajusta a altura da coluna para seu conteúdo
              children: [
                FutureBuilder<Equipamento>(
                  future: EquipamentoController.getEquipamento(widget.value),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Erro ao carregar o equipamento.');
                    } else {
                      Equipamento equipamento = snapshot.data ??
                          Equipamento(
                            id: '',
                            marca: '',
                            modelo: '',
                            qrcode: '',
                            empresa: '',
                            setor: '',
                            usuario: '',
                            criador: '',
                            status: '',
                          );

                      String qrcode = equipamento.qrcode;
                      String marca = equipamento.marca;
                      String modelo = equipamento.modelo;
                      String empresa = equipamento.empresa;
                      String setor = equipamento.setor;
                      String usuario = equipamento.usuario;
                      String criador = equipamento.criador;
                      String status = equipamento.status;

                      return Column(
                        children: [
                          Text(
                            'QRcode: $qrcode',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Marca: $marca',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Modelo: $modelo',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Empresa: $empresa',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Setor: $setor',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Usuário: $usuario',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Criador: $criador',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Status: $status',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/scan');
                                },
                                child: const Text(
                                  'Outro QRcode',
                                  style: TextStyle(
                                    color: Color(0xFF0076BC),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Chamado(qrcode: widget.value),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Abrir Chamado',
                                  style: TextStyle(
                                    color: Color(0xFF0076BC),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.white,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/');
                            },
                            child: const Text(
                              'Sair',
                              style: TextStyle(
                                color: Color(0xFF0076BC),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
