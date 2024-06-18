import 'package:flutter/material.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset('assets/qrcode.png'),
                    const SizedBox(height: 10.0),
                    Image.asset('assets/SEKI.png'),
                    const SizedBox(height: 10.0),
                    const GradientText(
                      'Streamlined Efficiency with Key Identification',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      gradient: LinearGradient(colors: [
                        Color.fromRGBO(0, 115, 188, 1),
                        Color.fromRGBO(0, 53, 86, 1),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              right: 0,
              left: 0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 115, 188, 1),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
                ),
                child: const Icon(
                  Icons.arrow_right_alt,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
