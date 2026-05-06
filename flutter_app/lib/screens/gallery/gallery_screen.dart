import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/background_wrapper.dart';
import '../../widgets/translated_text.dart';
import '../analyze/result_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistory,
          )
        ],
      ),
      body: BackgroundWrapper(
        child: _isLoading
            ? _buildShimmerLoading()
            : _errorMessage != null
                ? _buildErrorView()
                : _history.isEmpty
                    ? _buildEmptyView(lang)
                    : _buildGalleryGrid(lang),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: kToolbarHeight + 20),
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
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // This is a bit tricky as we are in a sub-page. 
              // Usually we'd use a callback or change the index in MainScreen.
              // For now, let's just show a tip.
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text("Start Scanning"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid(LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: kToolbarHeight + 20),
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green.shade900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TranslatedText(
                        scan['disease_name'] ?? "Healthy",
                        style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w500),
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
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
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
