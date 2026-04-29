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
      "Environmental Insight": "पर्यावरण अंतर्दृष्टि",
      "No image selected": "कोई छवि चयनित नहीं",
      "Welcome Back!": "वापसी पर स्वागत है!",
      "Login to continue": "जारी रखने के लिए लॉगिन करें",
      "Login": "लॉगिन",
      "Logout": "लॉगआउट",
      "Language: English": "भाषा: हिंदी",
      "Language": "भाषा",
      "GreenMind AI is typing...": "ग्रीनमाइंड एआई टाइप कर रहा है...",
      "Ask about this disease...": "इस बीमारी के बारे में पूछें...",
      "Disease Expert": "रोग विशेषज्ञ",
      "I see you analyzed a": "मैंने देखा कि आपने विश्लेषण किया",
      "with": "के साथ",
      "What specific questions do you have about treating or managing this?": "इस उपचार या प्रबंधन के बारे में आपके पास क्या विशेष प्रश्न हैं?",
      "Weather unavailable": "मौसम अनुपलब्ध",
      "Humidity": "आर्द्रता",
      "Detect Plant Disease": "पौधों के रोग का पता लगाएं",
      "Take a picture of the affected leaf to get instant analysis.": "त्वरित विश्लेषण प्राप्त करने के लिए प्रभावित पत्ती की एक तस्वीर लें।",
      "Weather Details": "मौसम का विवरण",
      "Could not load weather data.": "मौसम डेटा लोड नहीं किया जा सका।",
      "Feels Like": "महसूस होता है",
      "General Plant Care": "सामान्य पौधों की देखभाल",
      "It's hot and dry. Ensure your plants are watered frequently and consider misting indoor plants.": "गर्मी और सूखा है। सुनिश्चित करें कि आपके पौधों को बार-बार पानी दिया जाए।",
      "Hot and humid conditions favor rapid growth but also fungal diseases. Ensure good airflow.": "गर्म और आर्द्र स्थितियाँ तीव्र वृद्धि का पक्ष लेती हैं लेकिन फंगल रोगों का भी। अच्छी हवा सुनिश्चित करें।",
      "It's getting cold. Reduce watering frequency and protect sensitive plants from frost.": "ठंड हो रही है। पानी देने की आवृत्ति कम करें और संवेदनशील पौधों को पाले से बचाएं।",
      "Conditions are mild. Maintain standard watering and care routines.": "स्थितियाँ सामान्य हैं। मानक पानी और देखभाल दिनचर्या बनाए रखें।",
    };

    return _translations[englishText] ?? englishText;
  }
}
