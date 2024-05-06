import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';

class DetalhesUsuarioPage extends StatefulWidget {
  final Usuario usuario;

  const DetalhesUsuarioPage({super.key, required this.usuario});

  @override
  DetalhesUsuarioPageState createState() => DetalhesUsuarioPageState();
}

class DetalhesUsuarioPageState extends State<DetalhesUsuarioPage> {
  // Variáveis para armazenar o estado dos campos editáveis
  late String _nome;
  late String _email;
  late String _empresa;
  late String _nivel;
  late String _status;
  late String _dataAcesso;
  late String _dataCriacao;
  late bool _primeiroAcesso;
  late bool _redefinirSenha;
  late String _quemCriou;

  @override
  void initState() {
    super.initState();
    // Inicialize os campos editáveis com os valores do usuário
    _nome = widget.usuario.nome;
    _email = widget.usuario.email;
    _empresa = widget.usuario.empresa;
    _nivel = widget.usuario.nivel;
    _status = widget.usuario.status;
    _dataAcesso = widget.usuario.dataAcesso;
    _dataCriacao = widget.usuario.dataCriacao;
    _primeiroAcesso = widget.usuario.primeiroAcesso;
    _redefinirSenha = widget.usuario.redefinirSenha;
    _quemCriou = widget.usuario.criador;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Usuário'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo 'usuario' do usuário
            Text('Usuário: ${widget.usuario.usuario}'),
            const SizedBox(height: 16.0), // Espaçamento

            // Campos editáveis
            _buildEditableField(
                'Nome', _nome, (value) => setState(() => _nome = value)),
            _buildEditableField(
                'Email', _email, (value) => setState(() => _email = value)),
            _buildEditableField('Empresa', _empresa,
                (value) => setState(() => _empresa = value)),
            _buildEditableField(
                'Nível', _nivel, (value) => setState(() => _nivel = value)),
            _buildEditableField(
                'Status', _status, (value) => setState(() => _status = value)),
            _buildEditableField('Data de Acesso', _dataAcesso,
                (value) => setState(() => _dataAcesso = value)),
            _buildEditableField('Data de Criação', _dataCriacao,
                (value) => setState(() => _dataCriacao = value)),
            _buildEditableField('Primeiro Acesso', _primeiroAcesso.toString(),
                (value) => setState(() => _primeiroAcesso = value == 'true')),
            _buildEditableField('Redefinir Senha', _redefinirSenha.toString(),
                (value) => setState(() => _redefinirSenha = value == 'true')),
            _buildEditableField('Quem Criou', _quemCriou,
                (value) => setState(() => _quemCriou = value)),

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
    return _nome != widget.usuario.nome ||
        _email != widget.usuario.email ||
        _empresa != widget.usuario.empresa ||
        _nivel != widget.usuario.nivel ||
        _status != widget.usuario.status ||
        _dataAcesso != widget.usuario.dataAcesso ||
        _dataCriacao != widget.usuario.dataCriacao ||
        _primeiroAcesso != widget.usuario.primeiroAcesso ||
        _redefinirSenha != widget.usuario.redefinirSenha ||
        _quemCriou != widget.usuario.criador;
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
