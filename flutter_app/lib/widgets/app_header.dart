import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.26,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD4FC79), Color(0xFF96E6A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          // Background Graph Line (Pixel perfect match attempt)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.4,
              child: CustomPaint(
                size: const Size(double.infinity, 40),
                painter: GraphPainter(),
              ),
            ),
          ),
          
          // Leaves decoration (bottom right) - Overlapping cluster for high visibility
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.85,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Lighter background leaf, splayed further left
                  Transform.rotate(
                    angle: -0.6,
                    child: Icon(
                      Icons.eco_rounded, 
                      size: 140, 
                      color: const Color(0xFF4CAF50).withOpacity(0.9),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .rotate(begin: -0.04, end: 0.04, duration: 4.seconds, curve: Curves.easeInOut)
                   .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 4.seconds),

                  // Main dark green foreground leaf
                  Transform.rotate(
                    angle: -0.15,
                    child: const Icon(
                      Icons.eco_rounded, 
                      size: 175, 
                      color: Color(0xFF1B5E20),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .rotate(begin: -0.06, end: 0.06, duration: 3.seconds, curve: Curves.easeInOut)
                   .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 3.seconds),
                ],
              ),
            ),
          ),

          // Identity Pill Card (Left aligned, exactly like screenshot)
          Positioned(
            left: 0,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 35, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9).withOpacity(0.95), // Light Green
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(4, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.eco, size: 40, color: Colors.green),
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                     .shimmer(duration: 2.seconds, color: Colors.green.withOpacity(0.2)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.translate("GreenMind"),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B5E20),
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: lang.languageCode == 'hi' ? "एआई " : 
                                    (lang.languageCode == 'mr' ? "एआय " : 
                                    (lang.languageCode == 'kn' ? "ಎಐ " : 
                                    (lang.languageCode == 'te' ? "ఐ " : 
                                    (lang.languageCode == 'gu' ? "એઆઇ " : "AI ")))),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2196F3), // Vibrant Blue
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: lang.translate("AI Detector")
                                  .replaceAll("एआई ", "")
                                  .replaceAll("एआय ", "")
                                  .replaceAll("ಎಐ ", "")
                                  .replaceAll("ఐ ", "")
                                  .replaceAll("એઆઇ ", "")
                                  .replaceAll("AI ", "")
                                  .trim(),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C5E20), // Dark green
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),
                    ],
                  ),
                ],
              ),
            ).animate().slideX(begin: -1, end: 0, duration: 800.ms, curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1B5E20).withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.4, size.height * 0.9);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.3);

    canvas.drawPath(path, paint);

    // Draw dots
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.6), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.9), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.4), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
