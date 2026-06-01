import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/background_wrapper.dart';
import '../../widgets/translated_text.dart';
import '../analyze/result_screen.dart';
import '../analyze/analyze_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _history = [];
  
  // Local Stored Images
  int _activeTab = 0; // 0 = Stored Images, 1 = Scan History
  List<String> _localImages = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _loadLocalImages();
  }

  Future<void> _loadLocalImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if we need to copy preloaded images
      final bool alreadyCopied = prefs.getBool('preloaded_images_copied') ?? false;
      
      if (!alreadyCopied) {
        final List<String> copiedPaths = [];
        final tempDir = Directory.systemTemp;
        
        const List<String> preloadedFilenames = [
          "Early_Blight_of_Tomato1687.jpeg",
          "disease-on-pear-tree-leaves-260nw-2686391131.webp",
          "download (2).jpg",
          "download (24).jpg",
          "download (28).jpg",
          "download (29).jpg",
          "download (3).jpg",
          "images (1).jpg",
          "images (2).jpg",
          "images (3).jpg",
          "images (4).jpg",
          "images (5).jpg",
          "images (6).jpg",
          "images (7).jpg",
          "images.jpg",
          "potato-early-blight-leaves.jpg"
        ];
        
        for (final filename in preloadedFilenames) {
          try {
            final byteData = await DefaultAssetBundle.of(context).load("assets/preloaded_images/$filename");
            final file = File("${tempDir.path}/$filename");
            await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
            copiedPaths.add(file.path);
          } catch (assetError) {
            debugPrint("Error loading preloaded asset $filename: $assetError");
          }
        }
        
        // Fetch any existing manual stored images
        final List<String>? existing = prefs.getStringList('local_gallery_images');
        if (existing != null) {
          copiedPaths.addAll(existing);
        }
        
        await prefs.setStringList('local_gallery_images', copiedPaths);
        await prefs.setBool('preloaded_images_copied', true);
        
        setState(() {
          _localImages = copiedPaths;
        });
      } else {
        final List<String>? images = prefs.getStringList('local_gallery_images');
        if (images != null) {
          setState(() {
            _localImages = images;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading local stored images: $e");
    }
  }

  Future<void> _saveLocalImage(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _localImages.insert(0, path); // Add to the front
      });
      await prefs.setStringList('local_gallery_images', _localImages);
    } catch (e) {
      debugPrint("Error saving local image path: $e");
    }
  }

  Future<void> _deleteLocalImage(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _localImages.remove(path);
      });
      await prefs.setStringList('local_gallery_images', _localImages);
      
      // Physically delete from cache directory to optimize space
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint("Error deleting local image: $e");
    }
  }

  Future<void> _addLocalImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null) {
        await _saveLocalImage(pickedFile.path);
      }
    } catch (e) {
      debugPrint("Error selecting gallery image to store: $e");
    }
  }

  Future<void> _fetchHistory() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.userEmail == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "You must be logged in to view your history.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String encodedEmail = Uri.encodeComponent(auth.userEmail!);
      final response = await http.get(
        Uri.parse("https://greenmindaibackend.vercel.app/history?email=$encodedEmail"),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _history = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Unable to load history. Please try again later.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Connection Error: $e";
      });
    }
  }

  void _showQuickScanDialog(String path) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final lang = Provider.of<LanguageProvider>(context, listen: false);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: Colors.white.withOpacity(0.95),
          clipBehavior: Clip.antiAlias,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  color: Colors.green.shade900.withOpacity(0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang.translate("Stored Images"),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F4E36)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
                
                // Image Preview
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(path),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 250,
                        color: Colors.grey.shade100,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                
                // Buttons footer
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                  child: Row(
                    children: [
                      // Delete Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteLocalImage(path);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Quick Scan Button
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF2196F3)], // Green to Blue
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AnalyzeScreen(image: File(path)),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.flash_on, color: Colors.white, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      lang.translate("Quick Scan"),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(lang.translate("Gallery")),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green.shade900,
        automaticallyImplyLeading: false,
        actions: [
          if (_activeTab == 0)
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_rounded, size: 28),
              onPressed: _addLocalImage,
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchHistory,
            )
        ],
      ),
      body: BackgroundWrapper(
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 35),
            _buildSegmentSelector(lang),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _activeTab == 0
                    ? _buildStoredImagesTab(lang)
                    : (_isLoading
                        ? _buildShimmerLoading()
                        : _errorMessage != null
                            ? _buildErrorView()
                            : _history.isEmpty
                                ? _buildEmptyView(lang)
                                : _buildGalleryGrid(lang)),
              ),
            ),
            const SizedBox(height: 120), // Room for bottom navigation bar
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentSelector(LanguageProvider lang) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.green.withOpacity(0.08)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _activeTab == 0 ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = 0),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      lang.translate("Stored Images"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _activeTab == 0 ? Colors.white : Colors.green.shade900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = 1),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      lang.translate("Scan History"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _activeTab == 1 ? Colors.white : Colors.green.shade900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoredImagesTab(LanguageProvider lang) {
    if (_localImages.isEmpty) {
      return _buildStoredImagesEmptyView(lang);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _localImages.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final path = _localImages[index];
          return _buildStoredImageItem(path, index);
        },
      ),
    );
  }

  Widget _buildStoredImagesEmptyView(LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 80, color: Colors.green.shade200)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: -10, end: 10, duration: 2.seconds),
          const SizedBox(height: 15),
          Text(
            lang.translate("No stored images yet"),
            style: TextStyle(color: Colors.green.shade900, fontSize: 18, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 8),
          Text(
            lang.translate("Tap + to add images for a quick scan"),
            style: TextStyle(color: Colors.green.shade700.withOpacity(0.8), fontSize: 13),
          ).animate().fadeIn(delay: 450.ms),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            onPressed: _addLocalImage,
            icon: const Icon(Icons.add_a_photo_rounded),
            label: Text(lang.translate("Add Image")),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildStoredImageItem(String path, int index) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    return InkWell(
      onTap: () => _showQuickScanDialog(path),
      borderRadius: BorderRadius.circular(15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.green.shade50.withOpacity(0.3),
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.broken_image, size: 40, color: Colors.green.shade300),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${lang.translate('Plant')} ${index + 1}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green.shade900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang.translate("Quick Scan"),
                            style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.flash_on, size: 12, color: Colors.orange.shade600),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (index * 80).ms)
     .fadeIn(duration: 500.ms)
     .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad)
     .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: GridView.builder(
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
          ),
        ).animate(onPlay: (c) => c.repeat())
         .shimmer(duration: 1.5.seconds, color: Colors.green.withOpacity(0.1)),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.orange.shade700)
              .animate().shake(duration: 500.ms),
            const SizedBox(height: 15),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade900, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchHistory,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 80, color: Colors.green.shade200)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: -10, end: 10, duration: 2.seconds),
          const SizedBox(height: 15),
          Text(
            lang.translate("No scans yet"),
            style: TextStyle(color: Colors.green.shade900, fontSize: 18),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid(LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: RefreshIndicator(
        onRefresh: _fetchHistory,
        color: Colors.green.shade700,
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _history.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final scan = _history[index];
            return _buildGalleryItem(scan, index);
          },
        ),
      ),
    );
  }

  Widget _buildGalleryItem(dynamic scan, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              resultData: {
                'plant': scan['plant_name'],
                'disease': scan['disease_name'],
                'confidence': scan['confidence'].toString(),
                'description': scan['description'] ?? "No description available.",
                'cause': scan['cause'] ?? "No cause data available.",
                'solution': scan['solution'] ?? "No solution available.",
              },
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Icon(Icons.eco, size: 40, color: Colors.green.shade300)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .rotate(begin: -0.1, end: 0.1, duration: 2.seconds),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatedText(
                        scan['plant_name'] ?? "Unknown Plant",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green.shade900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TranslatedText(
                        scan['disease_name'] ?? "Healthy",
                        style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            scan['created_at'] != null 
                              ? scan['created_at'].toString().split('T')[0]
                              : "",
                            style: const TextStyle(color: Colors.grey, fontSize: 9),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 10, color: Colors.green.shade300),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms)
     .fadeIn(duration: 600.ms)
     .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack)
     .blurXY(begin: 10, end: 0)
     .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}
