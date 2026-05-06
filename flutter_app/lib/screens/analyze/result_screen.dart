import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/weather_provider.dart';
import '../../utils/environmental_insights.dart';
import '../../utils/tts_service.dart';
import 'pdf_preview_screen.dart';
import 'graph_screen.dart';
import '../chat/chat_detail_screen.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> resultData;
  final File? image;

  const ResultScreen({super.key, required this.resultData, this.image});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TtsService _ttsService = TtsService();
  bool _isSpeaking = false;
  Map<String, dynamic>? _translatedData;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _ttsService.addListener(_onTtsChange);
  }

  void _onTtsChange() {
    if (mounted) {
      setState(() {
        _isSpeaking = _ttsService.isPlaying;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleTranslation();
  }

  Future<void> _handleTranslation() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    
    // Always translate to the current language (English or Hindi)
    // The translator will handle it if the text is already in the target language.
    
    setState(() => _isTranslating = true);

    try {
      final translated = <String, dynamic>{};
      translated['plant'] = await lang.translateDynamic(widget.resultData['plant']);
      translated['disease'] = await lang.translateDynamic(widget.resultData['disease']);
      translated['description'] = await lang.translateDynamic(widget.resultData['description']);
      translated['cause'] = await lang.translateDynamic(widget.resultData['cause']);
      translated['solution'] = await lang.translateDynamic(widget.resultData['solution']);
      translated['confidence'] = widget.resultData['confidence']; // Numbers stay same
      
      if (mounted) {
        setState(() {
          _translatedData = translated;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTranslating = false);
      }
    }
  }

  @override
  void dispose() {
    _ttsService.removeListener(_onTtsChange);
    _ttsService.stop();
    super.dispose();
  }

  void _speakContent(LanguageProvider lang, WeatherProvider weather) async {
    if (_isSpeaking) {
      await _ttsService.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    final data = _translatedData ?? widget.resultData;

    String insight = EnvironmentalInsights.getInsight(
      widget.resultData['disease'],
      weather.temperature,
      weather.humidity,
      languageCode: lang.languageCode
    );

    String textToSpeak = "";
    if (lang.languageCode == 'hi') {
      textToSpeak = "पौधा: ${data['plant']}. "
          "बीमारी: ${data['disease']}. "
          "विवरण: ${data['description']}. "
          "कारण: ${data['cause']}. "
          "समाधान: ${data['solution']}. "
          "पर्यावरण अंतर्दृष्टि: $insight";
    } else if (lang.languageCode == 'mr') {
      textToSpeak = "रोप: ${data['plant']}. "
          "रोग: ${data['disease']}. "
          "वर्णन: ${data['description']}. "
          "कारण: ${data['cause']}. "
          "उपाय: ${data['solution']}. "
          "पर्यावरणीय माहिती: $insight";
    } else {
      textToSpeak = "Plant: ${data['plant']}. "
          "Disease: ${data['disease']}. "
          "Description: ${data['description']}. "
          "Cause: ${data['cause']}. "
          "Solution: ${data['solution']}. "
          "Environmental Insight: $insight";
    }

    _speakContentInternal(textToSpeak, lang.languageCode == 'hi' ? 'hi-IN' : (lang.languageCode == 'mr' ? 'mr-IN' : 'en-US'));
  }

  void _speakContentInternal(String text, String lang) async {
    await _ttsService.speak(text, lang);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final weather = Provider.of<WeatherProvider>(context);
    final displayData = _translatedData ?? widget.resultData;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate("Analysis Result")),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_isTranslating)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.image != null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(image: FileImage(widget.image!), fit: BoxFit.cover),
                ),
              ).animate().scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 800.ms, curve: Curves.easeOut),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(lang.translate("Plant"), displayData['plant'], Colors.green.shade800).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
                  const Divider(),
                  _buildHeaderRow(lang.translate("Disease"), displayData['disease'], Colors.red.shade700).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
                  const Divider(),
                  _buildHeaderRow(lang.translate("Confidence"), displayData['confidence'], Colors.blue.shade700).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 20),
                  _buildDetailSection(lang.translate("Description"), displayData['description'], Icons.info_outline).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                  _buildDetailSection(lang.translate("Cause"), displayData['cause'], Icons.bug_report).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                  _buildDetailSection(lang.translate("Solution"), displayData['solution'], Icons.healing).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                  
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
                                widget.resultData['disease'], 
                                weather.temperature, 
                                weather.humidity,
                                languageCode: lang.languageCode
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
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => GraphScreen(confidence: widget.resultData['confidence'])))
                      ),
                      _actionButton(
                        context, 
                        _isSpeaking ? Icons.stop_circle : Icons.volume_up, 
                        lang.translate(_isSpeaking ? "Stop" : "Voice Read"), 
                        _isSpeaking ? Colors.red : Colors.teal, 
                        () => _speakContent(lang, weather)
                      ).animate().shimmer(duration: 2.seconds, delay: 1.seconds),
                      _actionButton(
                        context, 
                        Icons.picture_as_pdf, 
                        lang.translate("Download PDF"), 
                        Colors.red, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => PdfPreviewScreen(resultData: displayData, languageCode: lang.languageCode)))
                      ),
                      _actionButton(
                        context, 
                        Icons.chat, 
                        lang.translate("Context Chat"), 
                        Colors.blue, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(resultData: displayData)))
                      ).animate().scale(delay: 900.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    ].animate(interval: 100.ms).fadeIn(delay: 700.ms).slideY(begin: 0.5, end: 0),
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
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .tint(color: color.withOpacity(0.2), duration: 1.5.seconds),
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
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, spreadRadius: 1)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
          ),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
       .moveY(begin: 0, end: -5, duration: 2.seconds, curve: Curves.easeInOut)
       .shimmer(delay: 3.seconds, duration: 2.seconds, color: Colors.white24),
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
