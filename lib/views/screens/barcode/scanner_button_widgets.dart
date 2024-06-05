import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:testeseki/views/screens/barcode/found_code.dart';

class AnalyzeImageFromGalleryButton extends StatelessWidget {
  const AnalyzeImageFromGalleryButton(
      {required this.controller, required this.returnImmediately, super.key});

  final MobileScannerController controller;
  final bool returnImmediately;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.image,
        color: Colors.blue,
      ),
      iconSize: 32.0,
      onPressed: () async {
        final ImagePicker picker = ImagePicker();

        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );

        if (image == null) {
          return;
        }

        final BarcodeCapture? barcodes = await controller.analyzeImage(
          image.path,
        );

        if (!context.mounted) {
          return;
        }

        final String barcodeValue = barcodes?.barcodes.first.rawValue ?? '';

        if (barcodes == null && barcodeValue.isEmpty) {
          const SnackBar snackbar = SnackBar(
            content: Text('No barcode found!'),
            backgroundColor: Colors.red,
          );

          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        } else {
          if (returnImmediately) {
            Navigator.pop(context, barcodeValue);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoundScreen(value: barcodeValue),
              ),
            );
          }

          controller.dispose();
        }
      },
    );
  }
}

class StartStopMobileScannerButton extends StatelessWidget {
  const StartStopMobileScannerButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return IconButton(
            icon: const Icon(
              Icons.play_arrow,
              color: Colors.lightBlueAccent,
            ),
            iconSize: 32.0,
            onPressed: () async {
              await controller.start();
            },
          );
        }

        return IconButton(
          icon: const Icon(
            Icons.stop,
            color: Colors.blue,
          ),
          iconSize: 32.0,
          onPressed: () async {
            await controller.stop();
          },
        );
      },
    );
  }
}

class SwitchCameraButton extends StatelessWidget {
  const SwitchCameraButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        final int? availableCameras = state.availableCameras;

        if (availableCameras != null && availableCameras < 2) {
          return const SizedBox.shrink();
        }

        final Widget icon;

        switch (state.cameraDirection) {
          case CameraFacing.front:
            icon = const Icon(
              Icons.camera_front,
              color: Colors.lightBlueAccent,
            );
          case CameraFacing.back:
            icon = const Icon(
              Icons.camera_rear,
              color: Colors.blue,
            );
        }

        return IconButton(
          iconSize: 32.0,
          icon: icon,
          onPressed: () async {
            await controller.switchCamera();
          },
        );
      },
    );
  }
}

class ToggleFlashlightButton extends StatelessWidget {
  const ToggleFlashlightButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        switch (state.torchState) {
          case TorchState.auto:
            return IconButton(
              iconSize: 32.0,
              icon: const Icon(
                Icons.flash_auto,
                color: Colors.blue,
              ),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.off:
            return IconButton(
              iconSize: 32.0,
              icon: const Icon(
                Icons.flash_off,
                color: Colors.blue,
              ),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.on:
            return IconButton(
              iconSize: 32.0,
              icon: const Icon(
                Icons.flash_on,
                color: Colors.lightBlueAccent,
              ),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.unavailable:
            return const Icon(
              Icons.no_flash,
              color: Colors.red,
            );
        }
      },
    );
  }
}
