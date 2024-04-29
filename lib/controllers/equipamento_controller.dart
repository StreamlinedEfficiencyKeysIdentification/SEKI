import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/usuario_controller.dart';
import '../models/usuario_model.dart';

class EquipamentoController {
  static Future<void> cadastrarEquipamento(
    String qrcode,
    String empresaId,
    String setorId,
    String usuarioId,
    bool status,
    String marca,
    String modelo,
  ) async {
    String statusS = '';
    // Obter o próximo ID disponível na coleção 'Equipamento'
    int proximoId = await _getProximoIdEquipamento();

    Usuario usuario = await UsuarioController.getUsuarioLogado();

    if (status) {
      statusS = 'Ativo';
    } else {
      statusS = 'Inativo';
    }

    // Inserir os detalhes do equipamento na coleção 'Equipamento'
    await FirebaseFirestore.instance
        .collection('Equipamento')
        .doc(proximoId.toString())
        .set({
      'IDqrcode': qrcode,
      'IDempresa': empresaId,
      'IDsetor': setorId,
      'IDusuario': usuarioId,
      'Status': statusS,
      'QuemCriou': usuario.uid,
    });

    // Inserir os detalhes adicionais (marca e modelo) na coleção 'DetalheEquipamento'
    await FirebaseFirestore.instance
        .collection('DetalheEquipamento')
        .doc(proximoId.toString())
        .set({
      'Marca': marca,
      'Modelo': modelo,
    });
  }

  static Future<int> _getProximoIdEquipamento() async {
    // Consulte todos os documentos na coleção "Empresa"
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Equipamento').get();

    // Crie uma lista de IDs existentes
    List<int> existingIds = querySnapshot.docs
        .map((doc) => int.tryParse(doc.id) ?? 0) // Converta o ID para inteiro
        .toList();

    // Encontre o próximo ID disponível
    int proximoId = 1;
    while (existingIds.contains(proximoId)) {
      proximoId++;
    }

    return proximoId;
  }
}
