import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controllers/usuario_controller.dart';
import '../models/equipamento_model.dart';
import '../models/usuario_model.dart';

class EquipamentoController {
  static Future<bool> cadastrarEquipamento(
    BuildContext context,
    String qrcode,
    String empresaId,
    String setorId,
    String usuarioId,
    bool status,
    String marca,
    String modelo,
  ) async {
    try {
      String statusS = '';
      // Obter o próximo ID disponível na coleção 'Equipamento'
      int proximoId = await _getProximoIdEquipamento();

      Usuario usuario = await UsuarioController.getUsuarioLogado();

      String matriz = '';
      DocumentSnapshot empresaSnapshot = await FirebaseFirestore.instance
          .collection('Empresa')
          .doc(usuario.empresa)
          .get();

      matriz = empresaSnapshot['EmpresaPai'].toString();

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

      await FirebaseFirestore.instance
          .collection('QRcode')
          .doc(
              matriz) // Usar o ID da empresa como ID do documento na coleção QRcode
          .set({
        qrcode: {
          'QuemCriou': usuario.uid,
          'DataCriacao': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      return false;
    }
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

  static Future<Equipamento> getEquipamento(String qrcode) async {
    try {
      String usuario = '';
      // Buscar o equipamento com o IDqrcode na coleção Equipamento
      QuerySnapshot equipSnapshot = await FirebaseFirestore.instance
          .collection('Equipamento')
          .where('IDqrcode', isEqualTo: qrcode)
          .get();

      if (equipSnapshot.docs.isNotEmpty) {
        // Extrair o ID do documento do equipamento
        String equipId = equipSnapshot.docs.first.id;

        Map<String, dynamic> equipData =
            equipSnapshot.docs.first.data() as Map<String, dynamic>;

        String empresaId = equipData['IDempresa'];
        String setorId = equipData['IDsetor'];
        String usuarioId = equipData['IDusuario'];
        String criadorId = equipData['QuemCriou'];
        String statusId = equipData['Status'];

        // Buscar os detalhes do equipamento na coleção DetalheEquipamento usando o ID do equipamento
        DocumentSnapshot detailSnapshot = await FirebaseFirestore.instance
            .collection('DetalheEquipamento')
            .doc(equipId)
            .get();

        DocumentSnapshot empresaSnapshot = await FirebaseFirestore.instance
            .collection('Empresa')
            .doc(empresaId)
            .get();

        DocumentSnapshot setorSnapshot = await FirebaseFirestore.instance
            .collection('Setor')
            .doc(setorId)
            .get();

        if (usuarioId != '') {
          DocumentSnapshot usuarioSnapshot = await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(usuarioId)
              .get();

          if (usuarioSnapshot.exists) {
            Map<String, dynamic> usuarioData =
                usuarioSnapshot.data() as Map<String, dynamic>;

            usuario = usuarioData['Nome'];
          }
        }

        DocumentSnapshot criadorSnapshot = await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(criadorId)
            .get();

        if (detailSnapshot.exists) {
          // Extrair os dados do detalhe do equipamento
          Map<String, dynamic> detailData =
              detailSnapshot.data() as Map<String, dynamic>;
          Map<String, dynamic> empresaData =
              empresaSnapshot.data() as Map<String, dynamic>;
          Map<String, dynamic> setorData =
              setorSnapshot.data() as Map<String, dynamic>;
          Map<String, dynamic> criadorData =
              criadorSnapshot.data() as Map<String, dynamic>;

          String marca = detailData['Marca'];
          String modelo = detailData['Modelo'];
          String qrcode = equipData['IDqrcode'];
          String empresa = empresaData['RazaoSocial'];
          String setor = setorData['Descricao'];
          String criador = criadorData['Nome'];

          return Equipamento(
            id: equipId,
            marca: marca as String? ?? '',
            modelo: modelo as String? ?? '',
            qrcode: qrcode as String? ?? '',
            empresa: empresa as String? ?? '',
            setor: setor as String? ?? '',
            usuario: usuario as String? ?? '',
            criador: criador as String? ?? '',
            status: statusId as String? ?? '',
          );
        }
      }
      return Equipamento(
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
    } catch (e) {
      return Equipamento(
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
    }
  }
}
