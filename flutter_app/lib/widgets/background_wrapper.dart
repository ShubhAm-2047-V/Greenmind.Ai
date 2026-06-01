import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
            Color(0xFFFFF6B3), // Vivid glowing yellow-cream
            Color(0xFFC3F3D2), // Vibrant mint green
            Color(0xFFBBDEFB), // Vivid soft sky blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Floating Leaf 1 (Top Left)
          Positioned(
            left: -30,
            top: 150,
            child: Transform.rotate(
              angle: 0.5,
              child: Icon(
                Icons.eco_rounded,
                size: 90,
                color: const Color(0xFF2E7D32).withOpacity(0.16),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .moveY(begin: -15, end: 15, duration: 4.seconds, curve: Curves.easeInOut)
           ..animate(onPlay: (c) => c.repeat(reverse: true))
           .rotate(begin: -0.08, end: 0.08, duration: 5.seconds, curve: Curves.easeInOut),

          // Floating Leaf 2 (Mid Right)
          Positioned(
            right: -25,
            top: 380,
            child: Transform.rotate(
              angle: -1.2,
              child: Icon(
                Icons.eco_rounded,
                size: 130,
                color: const Color(0xFF1B5E20).withOpacity(0.14),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .moveY(begin: -25, end: 25, duration: 5.seconds, curve: Curves.easeInOut)
           ..animate(onPlay: (c) => c.repeat(reverse: true))
           .rotate(begin: -0.1, end: 0.1, duration: 6.seconds, curve: Curves.easeInOut),

          // Floating Leaf 3 (Bottom Left)
          Positioned(
            left: -40,
            bottom: 120,
            child: Transform.rotate(
              angle: 0.8,
              child: Icon(
                Icons.eco_rounded,
                size: 170,
                color: const Color(0xFF2E7D32).withOpacity(0.12),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .moveY(begin: -20, end: 20, duration: 6.seconds, curve: Curves.easeInOut)
           ..animate(onPlay: (c) => c.repeat(reverse: true))
           .rotate(begin: -0.06, end: 0.06, duration: 7.seconds, curve: Curves.easeInOut),

          // Child content
          child,
        ],
      ),
    );
  }
}

