import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import 'result_screen.dart';
import '../../widgets/background_wrapper.dart';

class AnalyzeScreen extends StatefulWidget {
  final File? image;
  const AnalyzeScreen({super.key, this.image});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  File? _currentImage;
  bool _isLoading = false;

  // --- BACKEND API CONFIG ---
  static const String _apiUrl = "https://greenmindaibackend.vercel.app/analyze";

  @override
  void initState() {
    super.initState();
    _currentImage = widget.image;
  }

  Future<void> _pickGalleryImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _currentImage = File(pickedFile.path);
      });
    }
  }

  void _analyze() async {
    if (_currentImage == null) return;

    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String language = langProvider.languageCode == 'hi' ? "hindi" : 
                            (langProvider.languageCode == 'mr' ? "marathi" : 
                            (langProvider.languageCode == 'kn' ? "kannada" : 
                            (langProvider.languageCode == 'te' ? "telugu" : 
                            (langProvider.languageCode == 'gu' ? "gujarati" : "english"))));
    final String? email = authProvider.userEmail;

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest("POST", Uri.parse(_apiUrl));
      request.files.add(await http.MultipartFile.fromPath("image", _currentImage!.path));
      request.fields['language'] = language;
      if (email != null) request.fields['email'] = email;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        
        // Check if it's actually a plant
        if (data.containsKey('is_plant') && data['is_plant'] == false) {
          setState(() => _isLoading = false);
          _showError(langProvider.translate("This is not a plant. Please upload a plant image."));
          return;
        }

        setState(() => _isLoading = false);
        if (mounted) {
          final String emailStatus = data['email_status'] ?? "";
          final String historyStatus = data['history_status'] ?? "";

          if (email != null && historyStatus == "Saved successfully") {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(langProvider.translate("Scan saved to Gallery")),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(resultData: data, image: _currentImage),
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Error is handled by finally for loading state
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('Analyze')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green.shade900,
        automaticallyImplyLeading: widget.image != null, // Show back only if came from camera
      ),
      body: BackgroundWrapper(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _currentImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(_currentImage!, height: 300, width: 300, fit: BoxFit.cover),
                          ),
                          if (_isLoading)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.green.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ).animate(onPlay: (c) => c.repeat())
                               .moveY(begin: -300, end: 300, duration: 1.5.seconds, curve: Curves.linear),
                            ),
                          if (_isLoading)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 4,
                                color: Colors.greenAccent.shade400,
                              ).animate(onPlay: (c) => c.repeat())
                               .moveY(begin: 0, end: 300, duration: 1.5.seconds, curve: Curves.linear),
                            ),
                        ],
                      )
                    : Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade300, width: 2),
                        ),
                        child: Center(
                          child: Icon(Icons.image, size: 80, color: Colors.green.shade300),
                        ),
                      ),
                const SizedBox(height: 30),
                if (_currentImage == null)
                  ElevatedButton.icon(
                    onPressed: _pickGalleryImage,
                    icon: const Icon(Icons.photo_library),
                    label: Text(lang.translate("Select from Gallery")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100.withOpacity(0.8),
                      foregroundColor: Colors.green.shade900,
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _currentImage == null || _isLoading ? null : _analyze,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            lang.translate("Analyze Image"),
                            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
