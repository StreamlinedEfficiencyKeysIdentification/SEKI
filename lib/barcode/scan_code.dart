import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:testeseki/barcode/found_code.dart';
import 'package:testeseki/barcode/scanner_overlay.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  final MobileScannerController cameraController = MobileScannerController(
    torchEnabled: false,
    useNewCameraSelector: true,
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _screenOpened = false;

  @override
  void initState() {
    super.initState();
    _screenWasClosed();

    unawaited(cameraController.start());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          MobileScanner(
            controller: cameraController,
            onDetect: _foundBarcode,
          ),
          QRScannerOverlay(
            overlayColour: Colors.black.withOpacity(0.5),
          ),
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
            top: MediaQuery.of(context).padding.top,
            child: buildControlButtons(),
          ),
        ],
      ),
    );
  }

  void _foundBarcode(BarcodeCapture capture) {
    if (!_screenOpened && capture.barcodes.isNotEmpty) {
      final Barcode barcode = capture.barcodes.first;
      final String code = barcode.rawValue ?? "___";
      _screenOpened = true;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FoundScreen(value: code, screenClose: _screenWasClosed),
        ),
      );

      cameraController.stop();
    }
  }

  void _screenWasClosed() {
    _screenOpened = false;
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
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                if (state == TorchState.on) {
                  return const Icon(
                    color: Colors.lightBlueAccent,
                    Icons.flash_on,
                  );
                } else {
                  return const Icon(
                    color: Colors.blue,
                    Icons.flash_off,
                  );
                }
              },
            ),
            onPressed: () {
              cameraController.toggleTorch();
            },
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                if (state == CameraFacing.back) {
                  return const Icon(
                    color: Colors.blue,
                    Icons.camera_rear,
                  );
                } else {
                  return const Icon(
                    color: Colors.lightBlueAccent,
                    Icons.camera_front,
                  );
                }
              },
            ),
            onPressed: () {
              cameraController.switchCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }
}
