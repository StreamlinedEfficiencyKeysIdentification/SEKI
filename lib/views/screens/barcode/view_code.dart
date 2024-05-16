import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRImage extends StatefulWidget {
  final String qrcodeController;
  final String? sourceRoute; // Adicionando o parâmetro para a rota de origem

  const QRImage(
    this.qrcodeController, {
    super.key,
    this.sourceRoute, // Atualizando o construtor para aceitar o parâmetro
  });

  @override
  State<QRImage> createState() => QRImageState();
}

class QRImageState extends State<QRImage> {
  late final String text;

  @override
  void initState() {
    super.initState();
    text = widget.qrcodeController;
  }

  final GlobalKey globalKey = GlobalKey();
  bool dirExists = false;
  dynamic externalDir = './storage/emulated/0/Download/QR_Code/';

  Future<void> _captureAndSavePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);

      final whitePaint = Paint()..color = Colors.white;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
      canvas.drawRect(
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          whitePaint);
      canvas.drawImage(image, Offset.zero, Paint());
      final picture = recorder.endRecording();
      final img = await picture.toImage(image.width, image.height);
      ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      String fileName = text;
      int i = 1;
      while (await File('$externalDir/$fileName').exists()) {
        fileName = '$text-$i';
        i++;
      }

      dirExists = await Directory(externalDir).exists();
      if (!dirExists) {
        await Directory(externalDir).create(recursive: true);
        dirExists = true;
      }

      final file = await File('$externalDir/$fileName.png').create();
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      const snackBar = SnackBar(content: Text('QR Code salvo na galeira'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      if (!mounted) return;
      const snackBar =
          SnackBar(content: Text('QR Code não foi salvo na galeira'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Image'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            const SizedBox(height: 20),
            RepaintBoundary(
              key: globalKey,
              child: QrImageView(
                data: text,
                version: QrVersions.auto,
                size: 200.0,
                gapless: true,
                errorStateBuilder: (ctx, err) {
                  return const Center(
                    child: Text(
                      'Ocorreu um erro ao gerar o QR Code',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Voltar para a rota de origem
                    if (widget.sourceRoute != null) {
                      Navigator.pushNamed(context, widget.sourceRoute!);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Sair'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _captureAndSavePng();
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
