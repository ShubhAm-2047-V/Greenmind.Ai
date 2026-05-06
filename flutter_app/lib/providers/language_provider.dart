import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class LanguageProvider with ChangeNotifier {
  String _languageCode = 'en';
  final _translator = GoogleTranslator();

  bool get isHindi => _languageCode == 'hi';
  bool get isMarathi => _languageCode == 'mr';
  String get languageCode => _languageCode;

  LanguageProvider() {
    _loadLanguage();
  }

  void _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString('languageCode') ?? (prefs.getBool('isHindi') == true ? 'hi' : 'en');
    notifyListeners();
  }

  void toggleLanguage() async {
    if (_languageCode == 'en') {
      _languageCode = 'hi';
    } else if (_languageCode == 'hi') {
      _languageCode = 'mr';
    } else {
      _languageCode = 'en';
    }
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', _languageCode);
    // Keep isHindi for legacy if needed by other components not using this provider
    await prefs.setBool('isHindi', _languageCode == 'hi');
    notifyListeners();
  }

  void setLanguage(String code) async {
    _languageCode = code;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', _languageCode);
    await prefs.setBool('isHindi', _languageCode == 'hi');
    notifyListeners();
  }

  // Translates dynamic text (AI results) using Google Translate
  Future<String> translateDynamic(String text) async {
    if (text.isEmpty) return text;
    
    // Target language: 'hi' for Hindi, 'mr' for Marathi, 'en' for English
    String targetLang = _languageCode;
    
    try {
      var translation = await _translator.translate(text, to: targetLang);
      return translation.text;
    } catch (e) {
      print("Translation error: $e");
      return text; // Fallback to original
    }
  }

  String translate(String englishText) {
    if (_languageCode == 'en') return englishText;
    
    // Simple mock translation map for the app's static texts
    Map<String, Map<String, String>> _allTranslations = {
      'hi': {
        "GreenMind AI": "ग्रीनमाइंड एआई",
        "GreenMind": "ग्रीनमाइंड",
        "AI Detector": "एआई डिटेक्टर",
        "Capture Image": "छवि कैप्चर करें",
        "Analyze": "विश्लेषण करें",
        "Analyze Now": "अभी विश्लेषण करें",
        "Analyze Image": "छवि का विश्लेषण करें",
        "Select from Gallery": "गैलरी से चुनें",
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
        "Create Account": "खाता बनाएं",
        "Join our green community": "हमारे हरित समुदाय में शामिल हों",
        "Login": "लॉगिन",
        "Logout": "लॉगआउट",
        "Sign Up": "साइन अप करें",
        "Already have an account? Login": "पहले से ही एक खाता है? लॉगिन करें",
        "Don't have an account? Sign Up": "खाता नहीं है? साइन अप करें",
        "Email": "ईमेल",
        "Password": "पासवर्ड",
        "Please fill all fields": "कृपया सभी फ़ील्ड भरें",
        "Registration successful! Please login.": "पंजीकरण सफल! कृपया लॉगिन करें।",
        "Language: English": "भाषा: हिंदी",
        "Language": "भाषा",
        "GreenMind AI is typing...": "ग्रीनमाइंड एआई टाइप कर रहा है...",
        "Ask about this disease...": "इस बीमारी के बारे में पूछें...",
        "Type a message...": "एक संदेश लिखें...",
        "Listening...": "सुन रहा है...",
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
        "Voice Read": "आवाज से पढ़ें",
        "Stop": "रोकें",
        "Scan saved to Gallery": "स्कॅन गॅलरीमध्ये सेव्ह केले",
        "This is not a plant. Please upload a plant image.": "यह एक पौधा नहीं है। कृपया एक पौधे की छवि अपलोड करें।",
        "It's hot and dry. Ensure your plants are watered frequently and consider misting indoor plants.": "गर्मी और सूखा है। सुनिश्चित करें कि आपके पौधों को बार-बार पानी दिया जाए।",
        "Hot and humid conditions favor rapid growth but also fungal diseases. Ensure good airflow.": "गर्म और आर्द्र स्थितियाँ तीव्र वृद्धि का पक्ष लेती हैं लेकिन फंगल रोगों का भी। अच्छी हवा सुनिश्चित करें।",
        "It's getting cold. Reduce watering frequency and protect sensitive plants from frost.": "ठंड हो रही है। पानी देने की आवृत्ति कम करें और संवेदनशील पौधों को पाले से बचाएं।",
        "Conditions are mild. Maintain standard watering and care routines.": "स्थितियाँ सामान्य हैं। मानक पानी और देखभाल दिनचर्या बनाए रखें।",
        "No scans yet": "अभी तक कोई स्कैन नहीं",
        // Weather conditions
        "Clear": "साफ",
        "Clouds": "बादल",
        "Rain": "बारिश",
        "Drizzle": "बूंदाबांदी",
        "Thunderstorm": "आंधी",
        "Snow": "बर्फ",
        "Mist": "धुंध",
        "Smoke": "धुआं",
        "Haze": "धुंध",
        "Dust": "धूल",
        "Fog": "कोहरा",
        "Sand": "रेत",
        "Ash": "राख",
        "Squall": "आंधी",
        "Tornado": "बवंडर",
        "Network error. Check your connection.": "नेटवर्क त्रुटि। अपना कनेक्शन जांचें।",
        "Sorry, I'm having trouble connecting to my brain.": "क्षमा करें, मुझे जुड़ने में समस्या हो रही है।",
      },
      'mr': {
        "GreenMind AI": "ग्रीनमाइंड एआई",
        "GreenMind": "ग्रीनमाइंड",
        "AI Detector": "एआय डिटेक्टर",
        "Capture Image": "प्रतिमा टिपका",
        "Analyze": "विश्लेषण करा",
        "Analyze Now": "आत्ता विश्लेषण करा",
        "Analyze Image": "प्रतिमेचे विश्लेषण करा",
        "Select from Gallery": "गॅलरीतून निवडा",
        "Gallery": "गॅलरी",
        "Chat": "चॅट",
        "Profile": "प्रोफाइल",
        "Home": "मुख्यपृष्ठ",
        "History": "इतिहास",
        "Analysis Result": "विश्लेषण निकाल",
        "Plant": "रोप",
        "Disease": "रोग",
        "Confidence": "आत्मविश्वास",
        "Description": "वर्णन",
        "Cause": "कारण",
        "Solution": "उपाय",
        "View Graph": "आलेख पहा",
        "Download PDF": "पीडीएफ डाउनलोड करा",
        "Context Chat": "संदर्भ चॅट",
        "Environmental Insight": "पर्यावरणीय माहिती",
        "No image selected": "कोणतीही प्रतिमा निवडलेली नाही",
        "Welcome Back!": "पुन्हा स्वागत आहे!",
        "Login to continue": "पुढे जाण्यासाठी लॉगिन करा",
        "Create Account": "खाते तयार करा",
        "Join our green community": "आमच्या हरित समुदायात सामील व्हा",
        "Login": "लॉगिन",
        "Logout": "लॉगआउट",
        "Sign Up": "साइन अप करा",
        "Already have an account? Login": "आधीच खाते आहे? लॉगिन करा",
        "Don't have an account? Sign Up": "खाते नाही? साइन अप करा",
        "Email": "ईमेल",
        "Password": "पासवर्ड",
        "Please fill all fields": "कृपया सर्व माहिती भरा",
        "Registration successful! Please login.": "नोंदणी यशस्वी! कृपया लॉगिन करा.",
        "Language: English": "भाषा: मराठी",
        "Language": "भाषा",
        "GreenMind AI is typing...": "ग्रीनमाइंड एआई टाइप करत आहे...",
        "Ask about this disease...": "या रोगाबद्दल विचारा...",
        "Type a message...": "संदेश टाइप करा...",
        "Listening...": "ऐकत आहे...",
        "Disease Expert": "रोग तज्ञ",
        "I see you analyzed a": "मी पाहिले की तुम्ही विश्लेषण केले",
        "with": "सह",
        "What specific questions do you have about treating or managing this?": "यावर उपचार किंवा व्यवस्थापनाबद्दल तुमचे काय विशेष प्रश्न आहेत?",
        "Weather unavailable": "हवामान उपलब्ध नाही",
        "Humidity": "आर्द्रता",
        "Detect Plant Disease": "वनस्पतींचे रोग ओळखा",
        "Take a picture of the affected leaf to get instant analysis.": "त्वरित विश्लेषणासाठी बाधित पानाचा फोटो घ्या।",
        "Weather Details": "हवामानाचा तपशील",
        "Could not load weather data.": "हवामान डेटा लोड झाला नाही.",
        "Feels Like": "जाणवते",
        "General Plant Care": "सामान्य वनस्पती काळजी",
        "Voice Read": "आवाजाने वाचा",
        "Stop": "थांबवा",
        "Scan saved to Gallery": "स्कॅन गॅलरीमध्ये सेव्ह केले",
        "This is not a plant. Please upload a plant image.": "हे रोप नाही. कृपया रोपाची प्रतिमा अपलोड करा.",
        "It's hot and dry. Ensure your plants are watered frequently and consider misting indoor plants.": "हवामान उष्ण आणि कोरडे आहे. तुमच्या वनस्पतींना वारंवार पाणी दिल्याची खात्री करा.",
        "Hot and humid conditions favor rapid growth but also fungal diseases. Ensure good airflow.": "उष्ण आणि दमट हवामान जलद वाढीसाठी अनुकूल आहे परंतु बुरशीजन्य रोगांसाठी देखील. खेळती हवा सुनिश्चित करा.",
        "It's getting cold. Reduce watering frequency and protect sensitive plants from frost.": "थंडी वाढत आहे. पाणी देण्याचे प्रमाण कमी करा आणि संवेदनशील वनस्पतींचे थंडीपासून रक्षण करा.",
        "Conditions are mild. Maintain standard watering and care routines.": "हवामान सौम्य आहे. पाणी देण्याची आणि काळजी घेण्याची नेहमीची पद्धत सुरू ठेवा.",
        "No scans yet": "अद्याप कोणतेही स्कॅन नाहीत",
        // Weather conditions
        "Clear": "स्वच्छ",
        "Clouds": "ढग",
        "Rain": "पाऊस",
        "Drizzle": "रिमझिम",
        "Thunderstorm": "वादळ",
        "Snow": "बर्फ",
        "Mist": "धुके",
        "Smoke": "धूर",
        "Haze": "धुके",
        "Dust": "धुळ",
        "Fog": "धुके",
        "Sand": "वाळू",
        "Ash": "राख",
        "Squall": "वादळ",
        "Tornado": "चक्रीवादळ",
        "Network error. Check your connection.": "नेटवर्क त्रुटी. तुमचे कनेक्शन तपासा.",
        "Sorry, I'm having trouble connecting to my brain.": "क्षमस्व, मला कनेक्ट करण्यात अडचण येत आहे.",
      }
    };


    return _allTranslations[_languageCode]?[englishText] ?? englishText;
  }
}
