import 'dart:async';
import 'dart:convert';
import 'package:cc_resume_app/env_config.dart';
import 'package:cc_resume_app/widgets/message.dart';
import 'package:cc_resume_app/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../api_config.dart';
import 'chat_page.dart';

class DraggableChatWidget extends StatefulWidget {
  const DraggableChatWidget({super.key});

  @override
  _DraggableChatWidgetState createState() => _DraggableChatWidgetState();
}

class _DraggableChatWidgetState extends State<DraggableChatWidget> {
  double top = 100;
  double left = 20;

  List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _waitingResponse = false;
  String _selectedModel = "Sug";
  final List<String> _modelOptions = ["Sug", "Pep", "MLC"];
  final String apiKey = EnvConfig.apiKey;
  bool _isModelChanging = false;
  Timer? _modelChangeTimer;
  String _currentModelMessages = "";
  bool _chatWaiting = false;
  Timer? _chatWaitTimer;
  String _currentFunnyChatMessage = "";

  void _startChatWaitTimer() {
    _currentFunnyChatMessage = EnvConfig.randomChatMessage();
    setState(() {
      _chatWaiting = true;
    });

    _chatWaitTimer ??= Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentFunnyChatMessage = EnvConfig.randomChatMessage();
      });
    });
  }

  void _stopChatWaitTimer() {
    _chatWaitTimer?.cancel();
    _chatWaitTimer = null;
    setState(() {
      _chatWaiting = false;
    });
  }

  void _startModelChangeTimer(String modelType) {
    _currentModelMessages = EnvConfig.randomModelChangeMessage();
    setState(() {
      _isModelChanging = true;
    });

    _modelChangeTimer ??= Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentModelMessages = EnvConfig.randomModelChangeMessage();
      });
    });
  }

  void _stopModelTimer() {
    _modelChangeTimer?.cancel();
    _modelChangeTimer = null;
  }

  /// Utility to get cat icon path
  String getCatIconPath() {
    final int day = DateTime.now().day;
    return (day % 2 == 0)
        ? 'assets/images/seker_icon.png'
        : 'assets/images/biber_icon.png';
  }

  /// Utility for dynamic chat header
  String getChatHeader() {
    final int day = DateTime.now().day;
    return (day % 2 == 0) ? 'Talk with Sug' : 'Talk with Pep';
  }

  /// Parse answer from piperag
  String _parseAnswer(String answer) {
    try {
      final Map<String, dynamic> data = jsonDecode(answer);
      if (data.containsKey("result")) {
        return data["result"] as String;
      }
    } catch (_) {}
    if (answer.contains("User:")) {
      return answer.split("User:")[0].trim();
    }
    return answer;
  }

  /// Actually call GET /ask?...
  Future<void> _getMessage(String userMessage) async {
    setState(() {
      _waitingResponse = true;
    });
    _startChatWaitTimer();
    final uri = Uri.parse(ApiConfig.askEndpoint(userMessage, _selectedModel));
    try {
      final response = await http.get(
        uri,
        headers: ApiConfig.defaultHeaders(isJson: false),
      );
      if (response.statusCode == 200) {
        final rawBody = response.body.trim();
        final parsedAnswer = _parseAnswer(rawBody);
        setState(() {
          messages.add(Message(sender: 'bot', text: parsedAnswer));
        });
      } else if (response.statusCode == 403) {
        setState(() {
          messages.add(Message(
            sender: 'bot',
            text: 'Authentication error: Check your API key config.',
          ));
        });
      } else {
        final errorDetail = ApiConfig.extractErrorDetail(response.body);
        setState(() {
          messages.add(Message(
            sender: 'bot',
            text: 'Error ${response.statusCode}: $errorDetail',
          ));
        });
      }
    } catch (e) {
      setState(() {
        messages.add(Message(
          sender: 'bot',
          text: 'Error connecting to server: $e',
        ));
      });
    } finally {
      setState(() {
        _waitingResponse = false;
      });
      _stopChatWaitTimer();
      _scrollToBottom();
    }
  }

  /// Called after user typed a message
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    setState(() {
      messages.add(Message(sender: 'user', text: message));
    });
    _controller.clear();
    _scrollToBottom();
    await _getMessage(message);
    _scrollToBottom();
  }

  /// Resets the conversation
  void _resetConversation() {
    setState(() {
      messages.clear();
    });
  }

  /// Move the scroll to the bottom
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

  /// Actually calls POST /update_model to switch models
  Future<void> _updateModel(String modelType) async {
    _startModelChangeTimer(modelType);
    final uri = Uri.parse(ApiConfig.updateModelEndpoint());
    try {
      final response = await http.post(
        uri,
        headers: ApiConfig.defaultHeaders(),
        body: jsonEncode({
          "new_model": "",
          "new_model_type": modelType,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Model changed to $modelType')),
        );
      } else {
        final errorMessage = ApiConfig.extractErrorDetail(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error. Check if server is running.')),
      );
    } finally {
      setState(() {
        _isModelChanging = false;
      });
      _stopModelTimer();
    }
  }

  /// Image logic: shows a dialog to choose a task.
  Future<String?> _showImageTaskDialog() async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.shield),
                title: const Text('Deepfake Detection'),
                onTap: () => Navigator.pop(context, 'deepfake_detection'),
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Object Recognition'),
                onTap: () => Navigator.pop(context, 'object_recognition'),
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Image Classification'),
                onTap: () => Navigator.pop(context, 'image_classification'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Actually do a POST /recognize?task=...
  Future<void> _sendImageWithTask(XFile image, String task) async {
    setState(() {
      messages.add(Message(sender: 'user', text: 'Sent an image for $task'));
      _waitingResponse = true;
    });
    final uri = Uri.parse(ApiConfig.recognizeEndpoint(task));
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(ApiConfig.defaultHeaders(isJson: false));
    try {
      final bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: image.name,
        contentType: MediaType.parse('image/jpeg'),
      ));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final body = response.body;
        try {
          final data = jsonDecode(body);
          String parsedResult = '';
          if (data.containsKey('result')) {
            parsedResult = data['result'].toString();
          } else {
            parsedResult = body;
          }
          setState(() {
            messages.add(Message(sender: 'bot', text: parsedResult));
          });
        } catch (_) {
          setState(() {
            messages.add(Message(sender: 'bot', text: body));
          });
        }
      } else if (response.statusCode == 403) {
        setState(() {
          messages.add(Message(
            sender: 'bot',
            text: 'Authentication error: Check your API key configuration.',
          ));
        });
      } else {
        final errorDetail = ApiConfig.extractErrorDetail(response.body);
        setState(() {
          messages.add(Message(
            sender: 'bot',
            text: 'Image processing error (${response.statusCode}): $errorDetail',
          ));
        });
      }
    } catch (e) {
      setState(() {
        messages.add(Message(sender: 'bot', text: 'Error uploading image: $e'));
      });
    } finally {
      setState(() {
        _waitingResponse = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final task = await _showImageTaskDialog();
      if (task != null) {
        await _sendImageWithTask(image, task);
      }
    }
  }

  @override
  void dispose() {
    _modelChangeTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> messageWidgets = messages.map((msg) {
      // For example, you could replace plain text with parsed widgets if needed:
      return OptimizedMessageBubble(
        text: msg.text, // Alternatively, you might use ApiConfig.parseResult(msg.text)
        isUser: msg.sender == 'user',
      );
    }).toList();

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
                // Header with cat icon, expand button, model refresh
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cat icon + dynamic title
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Image.asset(getCatIconPath()),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            getChatHeader(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.open_in_full, color: Colors.white),
                            tooltip: 'Open Full Chat',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    initialMessages: messages,
                                    selectedModel: _selectedModel,
                                  ),
                                ),
                              ).then((updatedMessages) {
                                if (updatedMessages != null) {
                                  setState(() {
                                    messages = updatedMessages;
                                  });
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            tooltip: 'Reset Conversation',
                            onPressed: _resetConversation,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Model selection row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: Colors.indigo.shade100,
                  child: Row(
                    children: [
                      const Text(
                        'Model:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _selectedModel,
                        items: _modelOptions.map((model) {
                          return DropdownMenuItem(
                            value: model,
                            child: Text(model.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (_waitingResponse || _isModelChanging)
                            ? null
                            : (newValue) {
                                if (newValue != null) {
                                  setState(() => _selectedModel = newValue);
                                  _updateModel(newValue);
                                }
                              },
                      ),
                    ],
                  ),
                ),

                // Banner when model is changing
                if (_isModelChanging)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.blue.shade50,
                    child: Center(
                      child: Text(
                        _currentModelMessages,
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ),

                // Banner when waiting for a response
                if (_waitingResponse)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.blue.shade50,
                    child: Center(
                      child: Text(
                        _currentFunnyChatMessage,
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ),

                // Chat messages list
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    children: messageWidgets,
                  ),
                ),

                // Input row for text
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image, color: Colors.indigo),
                        onPressed: (_waitingResponse || _isModelChanging)
                            ? null
                            : _pickAndSendImage,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Type your message…',
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_waitingResponse || _isModelChanging)
                              ? null
                              : _sendMessage,
                          enabled: !_waitingResponse && !_isModelChanging,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: (_waitingResponse || _isModelChanging)
                            ? null
                            : () {
                                if (_controller.text.trim().isNotEmpty) {
                                  _sendMessage(_controller.text);
                                }
                              },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (_waitingResponse || _isModelChanging)
                                ? Colors.grey
                                : Colors.indigo,
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
