import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/language_provider.dart';
import '../../utils/tts_service.dart';
import '../../widgets/translated_text.dart';
import '../../widgets/background_wrapper.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [
    {"role": "bot", "text": "Hello! How can I help you with your plants today?"}
  ];
  final _controller = TextEditingController();
  bool _isTyping = false;
  
  // Voice variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TtsService _ttsService = TtsService();
  bool _isListening = false;
  bool _isVoiceMode = true; // Default to voice mode

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
    setState(() {});
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
          _messages.add({"role": "bot", "text": "I'm sorry, I'm having trouble connecting to my server right now."});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "bot", "text": "Connection error. Please check your internet."});
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(lang.translate("Chat")),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green.shade900,
        automaticallyImplyLeading: false,
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
            const SizedBox(height: kToolbarHeight + 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 100), // Added bottom padding to account for nav bar
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5), // More subtle typing indicator
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(lang.translate("GreenMind AI is typing..."), style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
                      ),
                    );
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
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.transparent, 
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: Colors.green.shade900),
                        decoration: InputDecoration(
                          hintText: _isListening ? lang.translate("Listening...") : lang.translate("Type a message..."),
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
                          fillColor: Colors.white.withOpacity(0.6), 
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
            ),
            if (MediaQuery.of(context).viewInsets.bottom == 0)
              const SizedBox(height: 90), // Space for floating nav bar
          ],
        ),
      ),
    );
  }
}
