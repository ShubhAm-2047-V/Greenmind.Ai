import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PlantDiseaseApp(),
  ));
}

class PlantDiseaseApp extends StatefulWidget {
  const PlantDiseaseApp({super.key});

  @override
  State<PlantDiseaseApp> createState() => _PlantDiseaseAppState();
}

class _PlantDiseaseAppState extends State<PlantDiseaseApp> {
  File? _image;
  final _picker = ImagePicker();
  bool _loading = false;
  Map<String, dynamic>? _result;
  
  // State for Navbar Animation
  int _selectedIndex = 2; // Default to Home

  // --- BACKEND CONNECTIVITY CONFIG ---
  // 10.0.2.2 is ONLY for Android Emulator.
  // For a real device, you MUST use your computer's local IP address (e.g., 192.168.1.X).
  // IMPORTANT: Your phone and PC must be connected to the SAME WiFi network.
  // On your PC, find your IP by running 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux).
  // Backend must be started with: uvicorn main:app --host 0.0.0.0 --port 8000
  
  // ignore: unused_field
  static const String _baseUrl = "http://10.39.116.188:8000"; // <--- UPDATED WITH DETECTED IP
  final String _apiUrl = "$_baseUrl/predict";

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = null; 
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      var request = http.MultipartRequest("POST", Uri.parse(_apiUrl));
      request.files.add(await http.MultipartFile.fromPath("file", _image!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        setState(() {
          _result = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error occurred: Failed to get prediction")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot connect to server. Check WiFi and IP.")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: Stack(
        children: [
          // 1. MAIN CONTENT
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    child: const SafeArea(
                      child: Center(
                        child: Text(
                          "GreenMind AI Detector",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    child: Column(
                      children: [
                        // Main Card
                        Container(
                          width: double.infinity,
                          height: 400,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF1F2),
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(35),
                            child: _image != null
                                ? Image.file(_image!, fit: BoxFit.cover)
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.cloud_upload_outlined,
                                          size: 80, color: Color(0xFFB0BEC5)),
                                      const SizedBox(height: 15),
                                      const Text(
                                        "No image selected",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF455A64)),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Use the Navbar to select an image",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14, color: Color(0xFF90A4AE)),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Result Card
                        if (_result != null) _buildResultSection(),
                        
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. CUSTOM BOTTOM NAV BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCustomNavBar(),
          ),

          // 3. FLOATING CENTER HOME BUTTON (Animated)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: _selectedIndex == 2 ? 40 : 45,
            left: MediaQuery.of(context).size.width / 2 - (_selectedIndex == 2 ? 35 : 27.5),
            child: _buildFloatingHomeButton(),
          ),
          
          // 4. GLOBAL LOADING INDICATOR
          if (_loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Analysis Result",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          _infoRow("Plant", _result!['plant']),
          _infoRow("Disease", _result!['disease']),
          _infoRow("Confidence", _result!['confidence']),
          const SizedBox(height: 15),
          _detail("Description", _result!['description'], Colors.green[700]!),
          _detail("Cause", _result!['cause'], Colors.redAccent),
          _detail("Solution", _result!['solution'], Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _detail(String title, String? text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(text ?? "N/A", style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      height: 95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(0, Icons.person_outline, "Profile", Colors.purple, () {}),
          _navItem(1, Icons.history_outlined, "History", Colors.grey, () {}),
          const SizedBox(width: 70), // Space for home button
          _navItem(3, Icons.photo_library_outlined, "Gallery", Colors.blue, _pickImage),
          _navItem(4, Icons.search_rounded, "Analyze", Colors.green, _analyzeImage),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, Color color, VoidCallback action) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedIndex = index);
          action();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedScale(
          scale: isSelected ? 1.2 : 0.95,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, 
                color: isSelected ? color : color.withOpacity(0.4), 
                size: isSelected ? 30 : 26
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isSelected ? color : color.withOpacity(0.4), 
                  fontSize: isSelected ? 12 : 11, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHomeButton() {
    bool isSelected = _selectedIndex == 2;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = 2);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 72 : 55,
        height: isSelected ? 72 : 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2E7D32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.4),
              blurRadius: isSelected ? 15 : 10,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
          ],
        ),
        child: Icon(Icons.home_rounded, 
          color: Colors.white, 
          size: isSelected ? 38 : 28
        ),
      ),
    );
  }
}
