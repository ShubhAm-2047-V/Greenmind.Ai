import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

import 'home/home_screen.dart';
import 'gallery/gallery_screen.dart';
import 'analyze/analyze_screen.dart';
import 'chat/chat_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // Default to Analyze or Home

  final List<Widget> _screens = [
    const HomeScreen(),
    const GalleryScreen(),
    const AnalyzeScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildNavBar(lang),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(LanguageProvider lang) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 15, left: 16, right: 16),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home, lang.translate("Home"), Colors.green),
              _navItem(1, Icons.image, lang.translate("Gallery"), Colors.blue),
              const SizedBox(width: 60), // Space for FAB
              _navItem(3, Icons.chat, lang.translate("Chat"), Colors.orange),
              _navItem(4, Icons.person, lang.translate("Profile"), Colors.purple),
            ],
          ),
        ),
        Positioned(
          bottom: 30,
          child: GestureDetector(
            onTap: () => setState(() => _selectedIndex = 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _selectedIndex == 2 ? 70 : 60,
              width: _selectedIndex == 2 ? 70 : 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: const Icon(Icons.document_scanner, color: Colors.white, size: 30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _navItem(int index, IconData icon, String label, Color color) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isSelected ? 1.15 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey.shade400, size: 28),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade400, 
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              )
            ),
          ],
        ),
      ),
    );
  }
}
