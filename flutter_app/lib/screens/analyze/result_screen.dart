import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/weather_provider.dart';
import '../../utils/environmental_insights.dart';
import 'pdf_preview_screen.dart';
import 'graph_screen.dart';
import '../chat/chat_detail_screen.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;
  final File? image;

  const ResultScreen({super.key, required this.resultData, this.image});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final weather = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate("Analysis Result")),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (image != null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(image: FileImage(image!), fit: BoxFit.cover),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(lang.translate("Plant"), resultData['plant'], Colors.green.shade800),
                  const Divider(),
                  _buildHeaderRow(lang.translate("Disease"), resultData['disease'], Colors.red.shade700),
                  const Divider(),
                  _buildHeaderRow(lang.translate("Confidence"), resultData['confidence'], Colors.blue.shade700),
                  const SizedBox(height: 20),
                  _buildDetailSection(lang.translate("Description"), resultData['description'], Icons.info_outline),
                  _buildDetailSection(lang.translate("Cause"), resultData['cause'], Icons.bug_report),
                  _buildDetailSection(lang.translate("Solution"), resultData['solution'], Icons.healing),
                  
                  const SizedBox(height: 25),
                  
                  // Environmental Insight
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.blue.shade100]),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wb_sunny, color: Colors.orange.shade600),
                            const SizedBox(width: 10),
                            Text(
                              lang.translate("Environmental Insight"),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        weather.isLoading 
                          ? const Center(child: CircularProgressIndicator()) 
                          : Text(
                              EnvironmentalInsights.getInsight(
                                resultData['disease'], 
                                weather.temperature, 
                                weather.humidity,
                                isHindi: lang.isHindi
                              ),
                              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.blue.shade900, fontStyle: FontStyle.italic),
                            ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton(
                        context, 
                        Icons.bar_chart, 
                        lang.translate("View Graph"), 
                        Colors.orange, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => GraphScreen(confidence: resultData['confidence'])))
                      ),
                      _actionButton(
                        context, 
                        Icons.picture_as_pdf, 
                        lang.translate("Download PDF"), 
                        Colors.red, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => PdfPreviewScreen(resultData: resultData)))
                      ),
                      _actionButton(
                        context, 
                        Icons.chat, 
                        lang.translate("Context Chat"), 
                        Colors.blue, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(resultData: resultData)))
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green.shade600),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
              ],
            ),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }
}
