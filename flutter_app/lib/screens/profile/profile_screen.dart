import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

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
            ),
            const SizedBox(height: 15),
            Text(
              "Demo User",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade900),
            ),
            const SizedBox(height: 5),
            Text(
              "demo@example.com",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),
            
            // Language Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: SwitchListTile(
                title: Text(lang.translate("Language: English"), style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("English / हिंदी"),
                value: lang.isHindi,
                activeColor: Colors.green.shade700,
                secondary: Icon(Icons.language, color: Colors.green.shade700),
                onChanged: (value) {
                  Provider.of<LanguageProvider>(context, listen: false).toggleLanguage();
                },
              ),
            ),
            
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
            ),
          ],
        ),
      ),
    );
  }
}
