import 'package:flutter/material.dart';
import 'package:testeseki/controllers/equipamento_controller.dart';
import 'package:testeseki/models/equipamento_model.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Result: ",
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'QRcode: $qrcode',
                          style: const TextStyle(fontSize: 16),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/scan');
                              },
                              child: const Text(
                                'Outro QRcode',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/chamado');
                              },
                              child: const Text(
                                'Abrir Chamado',
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/');
                          },
                          child: const Text(
                            'Sair',
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
    );
  }
}
