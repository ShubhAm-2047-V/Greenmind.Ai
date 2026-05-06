import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate("Profile")),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green.shade900,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 60, color: Colors.grey),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),
            const SizedBox(height: 15),
            Text(
              auth.userEmail?.split('@')[0] ?? "User",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade900),
            ),
            const SizedBox(height: 5),
            Text(
              auth.userEmail ?? "user@example.com",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),
            
            // Language Selector
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.language, color: Colors.green.shade700),
                    title: Text(lang.translate("Language"), style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(
                      lang.languageCode == 'en' ? "English" : 
                      lang.languageCode == 'hi' ? "हिंदी" : "मराठी",
                      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLangOption(context, lang, "EN", "en"),
                      _buildLangOption(context, lang, "HI", "hi"),
                      _buildLangOption(context, lang, "MR", "mr"),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
            
            const SizedBox(height: 20),
            
            // Logout Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(lang.translate("Logout"), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                onTap: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                },
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildLangOption(BuildContext context, LanguageProvider lang, String label, String code) {
    bool isSelected = lang.languageCode == code;
    return GestureDetector(
      onTap: () => lang.setLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade700 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
