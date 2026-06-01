import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/language_provider.dart';
import '../../widgets/translated_text.dart';
import '../../widgets/background_wrapper.dart';
import '../../utils/tts_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic> resultData;

  const ChatDetailScreen({super.key, required this.resultData});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late List<Map<String, String>> _messages;
  final _controller = TextEditingController();
  bool _isTyping = false;
  
  // Voice variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TtsService _ttsService = TtsService();
  bool _isListening = false;
  bool _isVoiceMode = true; // Default to voice mode
  String _lastWords = "";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    String plant = widget.resultData['plant'] ?? "Plant";
    String disease = widget.resultData['disease'] ?? "Disease";
    
    String greeting = lang.languageCode == 'hi' 
      ? "मैंने देखा कि आपने $disease के साथ $plant का विश्लेषण किया। इसे ठीक करने के बारे में आपके क्या प्रश्न हैं?"
      : (lang.languageCode == 'mr'
        ? "मी पाहिले की तुम्ही $disease सह $plant चे विश्लेषण केले. यावर उपाय करण्याबद्दल तुमचे काय प्रश्न आहेत?"
        : (lang.languageCode == 'kn'
          ? "ನಾನು ನೀವು $disease ರೊಂದಿಗೆ $plant ಅನ್ನು ವಿಶ್ಲೇಷಿಸಿದ್ದನ್ನು ನೋಡಿದೆ. ಇದನ್ನು ಚಿಕಿತ್ಸೆ ಅಥವಾ ನಿರ್ವಹಿಸುವ ಬಗ್ಗೆ ನಿಮಗೆ ಯಾವ ನಿರ್ದಿಷ್ಟ ಪ್ರಶ್ನೆಗಳಿವೆ?"
          : (lang.languageCode == 'te'
            ? "మీరు $disease తో $plant ని విశ్లేషించడాన్ని నేను చూశాను. దీనికి చికిత్స లేదా నిర్వహణ గురించి మీకు ఏవైనా నిర్దిష్ట ప్రశ్నలు ఉన్నాయా?"
            : (lang.languageCode == 'gu'
              ? "મેં જોયું કે તમે $disease સાથે $plant નું વિશ્લેષણ કર્યું છે. આની સારવાર અથવા સંચાલન વિશે તમને કયા વિશિષ્ટ પ્રશ્નો છે?"
              : "I see you analyzed a $plant with $disease. What specific questions do you have about treating or managing this?"))));

    _messages = [
      {"role": "bot", "text": greeting}
    ];
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        final lang = Provider.of<LanguageProvider>(context, listen: false);
        setState(() => _isListening = true);
        _speech.listen(
          localeId: lang.languageCode == 'hi' ? 'hi_IN' : 
                    (lang.languageCode == 'mr' ? 'mr_IN' : 
                    (lang.languageCode == 'kn' ? 'kn_IN' : 
                    (lang.languageCode == 'te' ? 'te_IN' : 
                    (lang.languageCode == 'gu' ? 'gu_IN' : 'en_US')))),
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3), // Stop after 3s of silence
          onResult: (val) {
            setState(() {
              _lastWords = val.recognizedWords;
              if (val.recognizedWords.isNotEmpty) {
                _controller.text = val.recognizedWords;
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final String language = langProvider.languageCode == 'hi' ? "hindi" : 
                            (langProvider.languageCode == 'mr' ? "marathi" : 
                            (langProvider.languageCode == 'kn' ? "kannada" : 
                            (langProvider.languageCode == 'te' ? "telugu" : 
                            (langProvider.languageCode == 'gu' ? "gujarati" : "english"))));

    String userInput = _controller.text;
    setState(() {
      _messages.add({"role": "user", "text": userInput});
      _isTyping = true;
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse("https://greenmindaibackend.vercel.app/chat"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "message": userInput,
          "context": "Plant: ${widget.resultData['plant']}, Disease: ${widget.resultData['disease']}, Solution: ${widget.resultData['solution']}",
          "language": language
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        String botResponse = data["response"];
        setState(() {
          _messages.add({"role": "bot", "text": botResponse});
        });
        
        // Auto-read bot response only if voice mode is on
        if (_isVoiceMode) {
          _ttsService.speak(
            botResponse, 
            langProvider.languageCode == 'hi' ? 'hi-IN' : 
            (langProvider.languageCode == 'mr' ? 'mr-IN' : 
            (langProvider.languageCode == 'kn' ? 'kn-IN' : 
            (langProvider.languageCode == 'te' ? 'te-IN' : 
            (langProvider.languageCode == 'gu' ? 'gu-IN' : 'en-US'))))
          );
        }

      } else {
        setState(() {
          _messages.add({"role": "bot", "text": "Sorry, I'm having trouble connecting to my brain."});
        });
      }
    } catch (e) {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      setState(() {
        _messages.add({"role": "bot", "text": lang.translate("Network error. Check your connection.")});
      });
    } finally {
      setState(() => _isTyping = false);
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(lang.translate("Disease Expert")),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green.shade900,
        actions: [
          // Voice Mode Toggle
          Row(
            children: [
              Icon(_isVoiceMode ? Icons.headset : Icons.keyboard, size: 18, color: Colors.green.shade700),
              Switch(
                value: _isVoiceMode, 
                onChanged: (val) {
                  setState(() => _isVoiceMode = val);
                  if (!val) _ttsService.stop();
                },
                activeColor: Colors.green.shade700,
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: BackgroundWrapper(
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 20), // Spacer for AppBar
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(lang.translate("GreenMind AI is typing..."), style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
                    ),
                  ).animate().fadeIn().slideX(begin: -0.1, end: 0);
                }
                final msg = _messages[index];
                bool isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 20, color: Colors.green),
                          onPressed: () {
                            final lang = Provider.of<LanguageProvider>(context, listen: false);
                            _ttsService.speak(
                              msg["text"]!, 
                              lang.languageCode == 'hi' ? 'hi-IN' : 
                              (lang.languageCode == 'mr' ? 'mr-IN' : 
                              (lang.languageCode == 'kn' ? 'kn-IN' : 
                              (lang.languageCode == 'te' ? 'te-IN' : 
                              (lang.languageCode == 'gu' ? 'gu-IN' : 'en-US'))))
                            );
                          },
                        ),
                      ],
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.green.shade700 : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20).copyWith(
                              bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                              bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: TranslatedText(
                            msg["text"]!,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.green.shade900,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: isUser ? 0.2 : -0.2, end: 0, curve: Curves.easeOutBack);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.transparent, // Removed the white box
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.green.shade900),
                      decoration: InputDecoration(
                        hintText: _isListening ? lang.translate("Listening...") : lang.translate("Ask about this disease..."),
                        hintStyle: TextStyle(color: Colors.green.shade700.withOpacity(0.5)),
                        prefixIcon: _isVoiceMode ? IconButton(
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.green.shade700),
                          onPressed: _listen,
                        ) : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.6), // Subtle glass effect for the field itself
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.green.shade700,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    ),
    );
  }
}
