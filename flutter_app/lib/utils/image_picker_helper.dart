import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/language_provider.dart';
import '../screens/analyze/analyze_screen.dart';
import '../screens/home/camera_capture_screen.dart';

class ImagePickerHelper {
  static Future<void> pickGalleryImage(BuildContext parentContext, {BuildContext? sheetContext}) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      
      if (pickedFile == null) {
        debugPrint("pickGalleryImage: User cancelled or no image selected");
        final dialogContext = (sheetContext != null && sheetContext.mounted) ? sheetContext : (parentContext.mounted ? parentContext : null);
        if (dialogContext != null) {
          showDialog(
            context: dialogContext,
            builder: (context) => AlertDialog(
              title: const Text("Picker Debug"),
              content: const Text("Image picker returned NULL (no image was received by the app)."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
              ],
            ),
          );
        }
        return;
      }
      
      if (sheetContext != null && sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }
      
      if (!parentContext.mounted) {
        debugPrint("pickGalleryImage: Parent context is not mounted after picker returned");
        final dialogContext = (sheetContext != null && sheetContext.mounted) ? sheetContext : null;
        if (dialogContext != null) {
          showDialog(
            context: dialogContext,
            builder: (context) => AlertDialog(
              title: const Text("Picker Debug"),
              content: const Text("Parent context is NOT mounted. Cannot navigate to Analyze Screen."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
              ],
            ),
          );
        }
        return;
      }

      Navigator.push(
        parentContext,
        MaterialPageRoute(
          builder: (_) => AnalyzeScreen(image: File(pickedFile.path)),
        ),
      );
    } catch (e) {
      debugPrint("Error picking gallery image: $e");
      final dialogContext = (sheetContext != null && sheetContext.mounted) ? sheetContext : (parentContext.mounted ? parentContext : null);
      if (dialogContext != null) {
        showDialog(
          context: dialogContext,
          builder: (context) => AlertDialog(
            title: const Text("Picker Error"),
            content: Text("An error occurred: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    }
  }

  static void showImageSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        final lang = Provider.of<LanguageProvider>(sheetContext, listen: false);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.95),
                  const Color(0xFFE8F5E9).withOpacity(0.95), // Soft green tint
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pull-down handle bar
                Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  lang.translate("Scan Plant"),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 6),
                
                // Subtitle
                Text(
                  lang.translate("Select an option to proceed"),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 24),
                
                // Camera Option Button
                _buildOptionTile(
                  context: sheetContext,
                  title: lang.translate("Take a Photo"),
                  subtitle: lang.translate("Use camera to scan leaf"),
                  icon: Icons.camera_alt_rounded,
                  iconGradientColors: [const Color(0xFF2196F3), const Color(0xFF4CAF50)], // Blue to Green
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
                    );
                  },
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 16),
                
                // Gallery Option Button
                _buildOptionTile(
                  context: sheetContext,
                  title: lang.translate("Choose from Gallery"),
                  subtitle: lang.translate("Select an existing photo"),
                  icon: Icons.photo_library_rounded,
                  iconGradientColors: [const Color(0xFFFF9800), const Color(0xFF2196F3)], // Amber to Blue
                  onTap: () {
                    pickGalleryImage(context, sheetContext: sheetContext);
                  },
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: 0.1, end: 0),
                
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildOptionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> iconGradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Gradient Icon Container
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: iconGradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconGradientColors.first.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 18),
                
                // Label & Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.green.shade700,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
