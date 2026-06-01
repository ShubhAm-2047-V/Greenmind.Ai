import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

import 'home/home_screen.dart';
import 'gallery/gallery_screen.dart';
import 'chat/chat_screen.dart';
import 'profile/profile_screen.dart';
import 'home/camera_capture_screen.dart';
import '../widgets/background_wrapper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default to Home

  final List<Widget> _screens = [
    const HomeScreen(),
    const GalleryScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent the FAB from jumping
      body: BackgroundWrapper(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: 400.ms,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey<int>(_selectedIndex),
                child: _screens[_selectedIndex],
              ),
            ),
            if (!isKeyboardVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildNavBar(lang),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(LanguageProvider lang) {
    return Container(
      height: 120,
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // The Navigation Bar Background
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _navItem(0, Icons.home_rounded, lang.translate("Home"), Colors.green.shade800)),
                Expanded(child: _navItem(1, Icons.image_rounded, lang.translate("Gallery"), Colors.blue.shade700)),
                const SizedBox(width: 80), // Space for FAB
                Expanded(child: _navItem(2, Icons.chat_bubble_rounded, lang.translate("Chat"), Colors.orange.shade800)),
                Expanded(child: _navItem(3, Icons.person_rounded, lang.translate("Profile"), Colors.purple.shade700)),
              ],
            ),
          ),
          
          // Floating Camera Button
          Positioned(
            bottom: 25,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraCaptureScreen()));
              },
              child: Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.5.seconds, curve: Curves.easeInOut)
                .boxShadow(begin: BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15), end: BoxShadow(color: Colors.blue.withOpacity(0.6), blurRadius: 30), duration: 1.5.seconds),
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, Color color) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            color: isSelected ? color : Colors.grey.shade400, 
            size: 30
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              color: isSelected ? color : Colors.grey.shade400, 
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            )
          ),
        ],
      ),
    ).animate(target: isSelected ? 1 : 0)
     .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 200.ms)
     .shimmer(duration: 1.seconds, color: color.withOpacity(0.2));
  }
}
