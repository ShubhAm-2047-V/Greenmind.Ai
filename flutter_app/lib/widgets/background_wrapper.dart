import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFCEE), // Soft glowing yellow-cream (mockup top-left)
            Color(0xFFE5F6EB), // Pastel mint green (mockup center)
            Color(0xFFE3F2FD), // Soft pastel sky blue (mockup bottom-right)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}
