// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<StatefulWidget> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? barcode;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() async {
    super.reassemble();

    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _buildQrView(context),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                size: 30,
                color: Colors.blue,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            bottom: 10,
            child: barcode != null ? buildResult() : Container(),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            child: buildControlButtons(),
          ),
        ],
      ),
    );
  }

  Widget buildControlButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white24,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: FutureBuilder<bool?>(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Icon(
                    color:
                        snapshot.data! ? Colors.lightBlueAccent : Colors.blue,
                    snapshot.data! ? Icons.flash_on : Icons.flash_off,
                  );
                } else {
                  return Container();
                }
              },
            ),
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {});
            },
          ),
          IconButton(
            icon: FutureBuilder(
              future: controller?.getCameraInfo(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return const Icon(
                    color: Colors.blue,
                    Icons.flip_camera_ios,
                  );
                } else {
                  return Container();
                }
              },
            ),
            onPressed: () async {
              await controller?.flipCamera();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget buildResult() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        barcode != null ? 'Barcode: ${barcode!.code}' : 'Scan a code',
        style: const TextStyle(
          color: Colors.blue,
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        barcode = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
