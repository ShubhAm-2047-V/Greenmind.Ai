import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService with ChangeNotifier {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  TtsService._internal() {
    _initTts();
  }

  bool get isPlaying => _isPlaying;

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isPlaying = true;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _isPlaying = false;
      notifyListeners();
    });
  }

  Future<void> speak(String text, String languageCode) async {
    if (text.isEmpty) return;
    
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isPlaying = false;
    notifyListeners();
  }
}
