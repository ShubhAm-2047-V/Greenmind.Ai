import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../providers/language_provider.dart';

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

  @override
  void initState() {
    super.initState();
    String plant = widget.resultData['plant'];
    String disease = widget.resultData['disease'];
    
    _messages = [
      {"role": "bot", "text": "I see you analyzed a $plant with $disease. What specific questions do you have about treating or managing this?"}
    ];
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final String language = langProvider.isHindi ? "hindi" : "english";

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
        final data = json.decode(response.body);
        setState(() {
          _messages.add({"role": "bot", "text": data["response"]});
        });
      } else {
        setState(() {
          _messages.add({"role": "bot", "text": "Sorry, I'm having trouble connecting to my brain."});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "bot", "text": "Network error. Check your connection."});
      });
    } finally {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disease Expert"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text("GreenMind AI is typing...", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
                    ),
                  );
                }
                final msg = _messages[index];
                bool isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue.shade600 : Colors.white,
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                        bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(20),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Ask about this disease...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade600,
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
    );
  }
}
