import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'result_screen.dart';

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
  static const String _apiUrl = "https://greenmindaibackend.vercel.app/predict";

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

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest("POST", Uri.parse(_apiUrl));
      request.files.add(await http.MultipartFile.fromPath("file", _currentImage!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> resultData = json.decode(response.body);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ResultScreen(resultData: resultData, image: _currentImage)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Failed to get prediction from Vercel")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot connect to Vercel server. Check internet.")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyze'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green.shade900,
        automaticallyImplyLeading: widget.image != null, // Show back only if came from camera
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _currentImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(_currentImage!, height: 300, width: 300, fit: BoxFit.cover),
                    )
                  : Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
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
                  label: const Text("Select from Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
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
                      : const Text(
                          "Analyze Image",
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
