import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../utils/image_picker_helper.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});



  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(55),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: Colors.green.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(55),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(10),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Stack(
            children: [
              // Logo Watermark
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.06,
                  child: Image.asset('assets/logo.png', width: 180),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => ImagePickerHelper.pickGalleryImage(context),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.blue.withOpacity(0.12), width: 1.5),
                        ),
                        child: Center(
                          child: Icon(Icons.image_search_outlined, size: 55, color: Colors.blue.shade300)
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(begin: const Offset(1, 1), end: const Offset(1.25, 1.25), duration: 1.5.seconds, curve: Curves.easeInOut)
                            .rotate(begin: -0.05, end: 0.05, duration: 2.seconds, curve: Curves.easeInOut),
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                     .shimmer(duration: 3.seconds, color: Colors.blue.withOpacity(0.05))
                     .animate(onPlay: (c) => c.repeat(reverse: true))
                     .tint(color: Colors.blue.withOpacity(0.02), duration: 2.seconds),
                    const SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          "GreenMind",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F4E36), // Forest green
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          lang.languageCode == 'hi' ? "एआई" : 
                          (lang.languageCode == 'mr' ? "एआय" : 
                          (lang.languageCode == 'kn' ? "ಎಐ" : 
                          (lang.languageCode == 'te' ? "ಐ" : 
                          (lang.languageCode == 'gu' ? "એઆઇ" : "AI")))),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3B82F6), // Vibrant blue
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ).animate().slideX(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOut),
                    const SizedBox(height: 10),
                    Text(
                      lang.translate("Take a picture of the affected leaf to get instant analysis."),
                      style: TextStyle(color: Colors.grey.shade700, height: 1.5, fontSize: 15),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF673AB7)], // Blue to Purple gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF673AB7).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ImagePickerHelper.showImageSourceBottomSheet(context);
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  lang.translate("Analyze Now"),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .shimmer(delay: 4.seconds, duration: 2.seconds, color: Colors.white24)
                     .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 2.seconds),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
