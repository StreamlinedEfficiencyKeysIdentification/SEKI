import 'package:flutter/material.dart';

class Chamado extends StatefulWidget {
  const Chamado({super.key});

  @override
  ChamadoState createState() => ChamadoState();
}

class ChamadoState extends State<Chamado> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamado'),
      ),
      body: const Center(
        child: Text('Chamado'),
      ),
    );
  }
}
