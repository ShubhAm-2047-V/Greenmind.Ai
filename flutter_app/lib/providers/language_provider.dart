import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  bool _isHindi = false;

  bool get isHindi => _isHindi;

  LanguageProvider() {
    _loadLanguage();
  }

  void _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isHindi = prefs.getBool('isHindi') ?? false;
    notifyListeners();
  }

  void toggleLanguage() async {
    _isHindi = !_isHindi;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHindi', _isHindi);
    notifyListeners();
  }

  String translate(String englishText) {
    if (!_isHindi) return englishText;
    
    // Simple mock translation map for the app's static texts
    Map<String, String> _translations = {
      "GreenMind AI": "ग्रीनमाइंड एआई",
      "Capture Image": "छवि कैप्चर करें",
      "Analyze": "विश्लेषण करें",
      "Gallery": "गैलरी",
      "Chat": "चैट",
      "Profile": "प्रोफ़ाइल",
      "Home": "होम",
      "History": "इतिहास",
      "Analysis Result": "विश्लेषण परिणाम",
      "Plant": "पौधा",
      "Disease": "बीमारी",
      "Confidence": "आत्मविश्वास",
      "Description": "विवरण",
      "Cause": "कारण",
      "Solution": "समाधान",
      "View Graph": "ग्राफ़ देखें",
      "Download PDF": "पीडीएफ डाउनलोड करें",
      "Context Chat": "संदर्भ चैट",
      "No image selected": "कोई छवि चयनित नहीं",
      "Welcome Back!": "वापसी पर स्वागत है!",
      "Login to continue": "जारी रखने के लिए लॉगिन करें",
      "Login": "लॉगिन",
      "Logout": "लॉगआउट",
      "Language: English": "भाषा: हिंदी",
      "Language": "भाषा",
    };

    return _translations[englishText] ?? englishText;
  }
}
