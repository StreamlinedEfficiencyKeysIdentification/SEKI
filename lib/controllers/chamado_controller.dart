import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/usuario_model.dart';
import '../models/chamado_model.dart';
import 'usuario_controller.dart';
import 'package:intl/date_symbol_data_local.dart';

class ChamadoController {
  static Future<List<Chamado>> getChamados({bool crescente = true}) async {
    initializeDateFormatting();
    Usuario usuario = await UsuarioController.getUsuarioLogado();

    int nivelInt = int.parse(usuario.nivel);

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Chamado> chamados = [];

    // Identificar a empresa matriz à qual o usuário pertence
    DocumentSnapshot empresaSnapshot =
        await firestore.collection('Empresa').doc(usuario.empresa).get();

    String matriz = empresaSnapshot['EmpresaPai'].toString();

    if (nivelInt == 1) {
      // Obtém todos os documentos dentro da coleção 'Chamados'
      QuerySnapshot empresaSnapshots =
          await firestore.collection('Chamados').get();

      // Itera sobre cada documento (empresa matriz)
      for (QueryDocumentSnapshot empresaDoc in empresaSnapshots.docs) {
        String empresaId = empresaDoc.id;

        // Obtém o conteúdo do documento (os mapas de chamados)
        DocumentSnapshot chamadosSnapshot =
            await firestore.collection('Chamados').doc(empresaId).get();

        Map<String, dynamic> chamadosData =
            chamadosSnapshot.data() as Map<String, dynamic>;

        // Itera sobre cada mapa de chamado
        chamadosData.forEach((chamadoId, chamadoData) {
          Map<String, dynamic> data = chamadoData as Map<String, dynamic>;
          Chamado chamado = Chamado(
            IDdoc: empresaId,
            IDchamado: chamadoId,
            QRcode: data['QRcode'] ?? '',
            Titulo: data['Titulo'] ?? '',
            Usuario: data['Usuario'] ?? '',
            Descricao: data['Descricao'] ?? '',
            Empresa: data['Empresa'] ?? '',
            Status: data['Status'] ?? '',
            Responsavel: data['Responsavel'] ?? '',
            EmpresaResponsavel: data['EmpresaResponsavel'] ?? '',
            DataCriacao: data['DataCriacao'] != null
                ? formatarTimeStamp(data['DataCriacao'])
                : '',
            DataAtualizacao: data['DataAtualizacao'] != null
                ? formatarTimeStamp(data['DataAtualizacao'])
                : '',
            Lido: data['Lido'] ?? false,
          );
          chamados.add(chamado);
        });
      }
    } else if (nivelInt == 2) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Chamados')
          .doc(matriz)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        chamados = data.entries.map((entry) {
          return Chamado(
            IDdoc: matriz,
            IDchamado: entry.key,
            QRcode: entry.value['QRcode'] ?? '',
            Titulo: entry.value['Titulo'] ?? '',
            Usuario: entry.value['Usuario'] ?? '',
            Descricao: entry.value['Descricao'] ?? '',
            Empresa: entry.value['Empresa'] ?? '',
            Status: entry.value['Status'] ?? '',
            Responsavel: entry.value['Responsavel'] ?? '',
            EmpresaResponsavel: entry.value['EmpresaResponsavel'] ?? '',
            DataCriacao: entry.value['DataCriacao'] != null
                ? formatarTimeStamp(entry.value['DataCriacao'])
                : '',
            DataAtualizacao: entry.value['DataAtualizacao'] != null
                ? formatarTimeStamp(entry.value['DataAtualizacao'])
                : '',
            Lido: entry.value['Lido'] ?? false,
          );
        }).toList();
      }
    } else if (nivelInt == 3) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Chamados')
          .doc(matriz)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        chamados = data.entries
            .where((entry) =>
                entry.value['Empresa'] == usuario.empresa ||
                entry.value['Responsavel'] == usuario.uid ||
                entry.value['Usuario'] == usuario.uid)
            .map((entry) {
          return Chamado(
            IDdoc: matriz,
            IDchamado: entry.key,
            QRcode: entry.value['QRcode'] ?? '',
            Titulo: entry.value['Titulo'] ?? '',
            Usuario: entry.value['Usuario'] ?? '',
            Descricao: entry.value['Descricao'] ?? '',
            Empresa: entry.value['Empresa'] ?? '',
            Status: entry.value['Status'] ?? '',
            Responsavel: entry.value['Responsavel'] ?? '',
            EmpresaResponsavel: entry.value['EmpresaResponsavel'] ?? '',
            DataCriacao: entry.value['DataCriacao'] != null
                ? formatarTimeStamp(entry.value['DataCriacao'])
                : '',
            DataAtualizacao: entry.value['DataAtualizacao'] != null
                ? formatarTimeStamp(entry.value['DataAtualizacao'])
                : '',
            Lido: entry.value['Lido'] ?? false,
          );
        }).toList();
      }
    } else if (nivelInt == 4) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Chamados')
          .doc(matriz)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        chamados = data.entries
            .where((entry) => entry.value['Usuario'] == usuario.uid)
            .map((entry) {
          return Chamado(
            IDdoc: matriz,
            IDchamado: entry.key,
            QRcode: entry.value['QRcode'] ?? '',
            Titulo: entry.value['Titulo'] ?? '',
            Usuario: entry.value['Usuario'] ?? '',
            Descricao: entry.value['Descricao'] ?? '',
            Empresa: entry.value['Empresa'] ?? '',
            Status: entry.value['Status'] ?? '',
            Responsavel: entry.value['Responsavel'] ?? '',
            EmpresaResponsavel: entry.value['EmpresaResponsavel'] ?? '',
            DataCriacao: entry.value['DataCriacao'] != null
                ? formatarTimeStamp(entry.value['DataCriacao'])
                : '',
            DataAtualizacao: entry.value['DataAtualizacao'] != null
                ? formatarTimeStamp(entry.value['DataAtualizacao'])
                : '',
            Lido: entry.value['Lido'] ?? false,
          );
        }).toList();
      }
    }

    // Ordenar a lista de chamados por data de criação
    // Ordenar a lista de chamados por data de criação
    if (crescente) {
      chamados.sort((a, b) => a.DataCriacao.compareTo(b.DataCriacao));
    } else {
      chamados.sort((a, b) => b.DataCriacao.compareTo(a.DataCriacao));
    }

    return chamados;
  }

  static Future<List<Chamado>> getChamadosHome({bool crescente = true}) async {
    initializeDateFormatting();
    Usuario usuario = await UsuarioController.getUsuarioLogado();

    int nivelInt = int.parse(usuario.nivel);

    if (nivelInt == 4) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      List<Chamado> chamados = [];

      // Identificar a empresa matriz à qual o usuário pertence
      DocumentSnapshot empresaSnapshot =
          await firestore.collection('Empresa').doc(usuario.empresa).get();

      String matriz = empresaSnapshot['EmpresaPai'].toString();
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Chamados')
          .doc(matriz)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        chamados = data.entries
            .where((entry) => entry.value['Usuario'] == usuario.uid)
            .map((entry) {
          return Chamado(
            IDdoc: matriz,
            IDchamado: entry.key,
            QRcode: entry.value['QRcode'] ?? '',
            Titulo: entry.value['Titulo'] ?? '',
            Usuario: entry.value['Usuario'] ?? '',
            Descricao: entry.value['Descricao'] ?? '',
            Empresa: entry.value['Empresa'] ?? '',
            Status: entry.value['Status'] ?? '',
            Responsavel: entry.value['Responsavel'] ?? '',
            EmpresaResponsavel: entry.value['EmpresaResponsavel'] ?? '',
            DataCriacao: entry.value['DataCriacao'] != null
                ? formatarTimeStamp(entry.value['DataCriacao'])
                : '',
            DataAtualizacao: entry.value['DataAtualizacao'] != null
                ? formatarTimeStamp(entry.value['DataAtualizacao'])
                : '',
            Lido: entry.value['Lido'] ?? false,
          );
        }).toList();
      }
      // Ordenar a lista de chamados por data de criação
      // Ordenar a lista de chamados por data de criação
      if (crescente) {
        chamados.sort((a, b) => a.DataCriacao.compareTo(b.DataCriacao));
      } else {
        chamados.sort((a, b) => b.DataCriacao.compareTo(a.DataCriacao));
      }

      return chamados;
    }
    return [];
  }
}

String formatarTimeStamp(Timestamp timestamp) {
  // Converta o timestamp para um objeto DateTime
  DateTime dateTime = timestamp.toDate();

  // Converta para o fuso horário local
  DateTime localDateTime = dateTime.toLocal();

  // Formate a data e hora para exibição
  return DateFormat('dd/MM/yyyy HH:mm:ss').format(localDateTime);
}
