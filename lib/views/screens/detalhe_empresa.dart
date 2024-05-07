import 'package:flutter/material.dart';
import '../../models/empresa_model.dart';
import 'setor_page.dart';

class DetalhesEmpresaPage extends StatefulWidget {
  final Empresa empresa;

  const DetalhesEmpresaPage({
    super.key,
    required this.empresa,
  });

  @override
  DetalhesEmpresaPageState createState() => DetalhesEmpresaPageState();
}

class DetalhesEmpresaPageState extends State<DetalhesEmpresaPage> {
  // Variáveis para armazenar o estado dos campos editáveis
  late String _razaoSocial;
  late String _cnpj;
  late String _matriz;
  late String _criador;
  late String _status;

  @override
  void initState() {
    super.initState();
    // Inicialize os campos editáveis com os valores da empresa
    _razaoSocial = widget.empresa.razaoSocial;
    _cnpj = widget.empresa.cnpj;
    _matriz = widget.empresa.matriz;
    _criador = widget.empresa.criador;
    _status = widget.empresa.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Empresa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo 'Razão Social' da empresa
            Text(
              'Razão Social: $_razaoSocial',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0), // Espaçamento

            // Campos editáveis
            _buildEditableField(
              'CNPJ',
              _cnpj,
              (value) => setState(() => _cnpj = value),
            ),
            _buildEditableField(
              'Matriz',
              _matriz,
              (value) => setState(() => _matriz = value),
            ),
            _buildEditableField(
              'Criador',
              _criador,
              (value) => setState(() => _criador = value),
            ),
            _buildEditableField(
              'Status',
              _status,
              (value) => setState(() => _status = value),
            ),
            ElevatedButton(
              onPressed: () {
                // Navegue para a página de setores quando o usuário quiser editar os setores
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SetorPage(empresa: widget.empresa),
                  ),
                );
              },
              child: const Text('Editar Setores'),
            ),

            // Botão Salvar (visível apenas se houver alterações)
            if (_isDataChanged()) _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // Constrói um campo de texto editável
  Widget _buildEditableField(
      String label, String value, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }

  // Verifica se houve alterações nos dados
  bool _isDataChanged() {
    return _razaoSocial != widget.empresa.razaoSocial ||
        _cnpj != widget.empresa.cnpj ||
        _matriz != widget.empresa.matriz ||
        _criador != widget.empresa.criador ||
        _status != widget.empresa.status;
  }

  // Constrói o botão "Salvar"
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        // Implemente a lógica para salvar as alterações no banco de dados
        // Você pode chamar uma função no controlador para atualizar os dados
      },
      child: const Text('Salvar'),
    );
  }
}
