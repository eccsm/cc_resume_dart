import 'package:http/http.dart' as http;
import 'package:cc_resume_app/widgets/typing_indicator_bubble.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

/// A simple message model to represent a chat message.
class Message {
  final String sender;
  final String text;
  Message({required this.sender, required this.text});
}

class DraggableChatWidget extends StatefulWidget {
  const DraggableChatWidget({super.key});

  @override
  _DraggableChatWidgetState createState() => _DraggableChatWidgetState();
}

class _DraggableChatWidgetState extends State<DraggableChatWidget> {
  double top = 100;
  double left = 20;
  final List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  /// Returns the cat icon path based on the current day (Pep or Sug).
  String getCatIconPath() {
    final int day = DateTime.now().day;
    return (day % 2 == 0)
        ? 'assets/images/seker_icon.png'
        : 'assets/images/biber_icon.png';
  }

  /// Makes a normal HTTP GET request (no streaming).
  /// While waiting, we show a typing indicator in the chat bubble.
  Future<void> _getMessage(String message) async {
    final uri = Uri.parse('http://127.0.0.1:8000/ask?q=${Uri.encodeComponent(message)}');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Trim or parse the response if needed
        final rawAnswer = response.body;
        final sanitizedAnswer = rawAnswer.trim();

        setState(() {
          messages.add(Message(sender: 'bot', text: sanitizedAnswer));
        });
      } else {
        setState(() {
          messages.add(Message(
            sender: 'bot',
            text: 'Error: ${response.statusCode}',
          ));
        });
      }
    } catch (e) {
      setState(() {
        messages.add(Message(
          sender: 'bot',
          text: 'Error connecting to server.',
        ));
      });
    }
    _scrollToBottom();
  }

  /// Called when user sends a message.
  /// Adds a user message, shows loading indicator, fetches response, hides indicator.
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      messages.add(Message(sender: 'user', text: message));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Make the HTTP request to get the bot's response
    await _getMessage(message);

    setState(() {
      _isLoading = false;
    });
    _scrollToBottom();
  }

  /// Resets the entire conversation
  void _resetConversation() {
    setState(() {
      messages.clear();
    });
  }

  /// Scrolls the ListView to the bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build the list of message widgets
    final List<Widget> messageWidgets = messages.map<Widget>((msg) {
      return MessageBubble(
        text: msg.text,
        isUser: msg.sender == 'user',
      );
    }).toList();

    // Show typing indicator bubble if we are waiting for a response
    if (_isLoading) {
      messageWidgets.add(const TypingIndicatorBubble());
    }

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            top += details.delta.dy;
            left += details.delta.dx;
            top = top.clamp(0.0, MediaQuery.of(context).size.height - 500);
            left = left.clamp(0.0, MediaQuery.of(context).size.width - 350);
          });
        },
        child: Material(
          elevation: 8.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 350,
            height: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Image.asset(getCatIconPath()),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Chat with Sug or Pep',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        tooltip: 'Reset Conversation',
                        onPressed: _resetConversation,
                      ),
                    ],
                  ),
                ),

                // ~~ Removed the LinearProgressIndicator() here ~~

                // Chat messages
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    children: messageWidgets,
                  ),
                ),

                // Input field
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: _sendMessage,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          if (_controller.text.trim().isNotEmpty) {
                            _sendMessage(_controller.text);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.indigo,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
