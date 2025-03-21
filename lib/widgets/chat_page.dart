import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../config/env_config.dart';
import 'message.dart';
import 'message_bubble.dart';

class ChatPage extends StatefulWidget {
  final List<Message> initialMessages;
  final String selectedModel;
  final Function(String)? onModelChanged;

  const ChatPage({
    super.key,
    required this.initialMessages,
    required this.selectedModel,
    this.onModelChanged,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Message> messages = [];
  late String _selectedModel;
  final String apiKey = EnvConfig.apiKey;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Flags for waiting states
  bool _waitingResponse = false;
  bool _modelChanging = false;

  Timer? _funnyTimer;
  String _currentFunnyMessage = '';

  // Model choices for the left pane.
  final List<String> _modelOptions = ["Sug", "Pep", "MLC"];

  @override
  void initState() {
    super.initState();
    messages = List.from(widget.initialMessages);
    _selectedModel = widget.selectedModel;
  }

  void _startFunnyTimer() {
    _currentFunnyMessage = EnvConfig.randomChatMessage();
    _funnyTimer ??= Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentFunnyMessage = EnvConfig.randomChatMessage();
      });
    });
  }

  void _stopFunnyTimer() {
    _funnyTimer?.cancel();
    _funnyTimer = null;
  }

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

  Future<void> _getMessage(String userMessage) async {
    setState(() {
      _waitingResponse = true;
    });
    _startFunnyTimer();

    final uri = Uri.parse(ApiConfig.askEndpoint(userMessage, _selectedModel));
    try {
      final response = await http.get(
        uri,
        headers: ApiConfig.defaultHeaders(isJson: false),
      );
      if (response.statusCode == 200) {
        final rawAnswer = response.body.trim();
        setState(() {
          messages.add(Message(sender: 'bot', text: rawAnswer));
        });
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
      _stopFunnyTimer();
    }
  }

  Future<void> _changeModel(String newModel) async {
    setState(() {
      _modelChanging = true;
      _selectedModel = newModel;
    });
    if (widget.onModelChanged != null) {
      widget.onModelChanged!(newModel);
    }
    final uri = Uri.parse(ApiConfig.updateModelEndpoint());
    try {
      await http.post(
        uri,
        headers: ApiConfig.defaultHeaders(),
        body: jsonEncode({
          "new_model": "",
          "new_model_type": newModel,
        }),
      );
    } catch (e) {
      // Handle error if needed.
    } finally {
      setState(() {
        _modelChanging = false;
      });
    }
  }

  Future<void> _pickAndSendImage() async {
    if (_waitingResponse) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final task = await _showImageTaskDialog();
      if (task != null) {
        await _sendImageWithTask(image, task);
      }
    }
  }

  Future<String?> _showImageTaskDialog() async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) {
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

  Future<void> _sendImageWithTask(XFile image, String task) async {
    setState(() {
      messages.add(Message(sender: 'user', text: 'Sent an image for $task'));
      _waitingResponse = true;
    });
    _startFunnyTimer();

    final uri = Uri.parse(ApiConfig.recognizeEndpoint(task));
    var request = http.MultipartRequest('POST', uri);
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
          if (data.containsKey('result')) {
            setState(() {
              messages.add(Message(sender: 'bot', text: data['result'].toString()));
            });
          } else {
            setState(() {
              messages.add(Message(sender: 'bot', text: body));
            });
          }
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
            text: 'Error ${response.statusCode}: $errorDetail',
          ));
        });
      }
    } catch (e) {
      setState(() {
        messages.add(Message(sender: 'bot', text: "Error uploading image: $e"));
      });
    } finally {
      setState(() {
        _waitingResponse = false;
      });
      _stopFunnyTimer();
      _scrollToBottom();
    }
  }

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

  // Build the left pane with model choices.
  Widget _buildLeftPane() {
    return Container(
      width: 200,
      color: const Color(0xFF202123),
      child: ListView(
        children: _modelOptions.map((model) {
          return ListTile(
            title: Text(
              model.toUpperCase(),
              style: TextStyle(
                color: _selectedModel == model ? Colors.white : Colors.white70,
                fontWeight: _selectedModel == model ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () async {
              await _changeModel(model);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _funnyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> messageWidgets = messages.map((msg) {
      return OptimizedMessageBubble(
        text: msg.text, // Alternatively, you might use ApiConfig.parseResult(msg.text)
        isUser: msg.sender == 'user',
      );
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context, messages);
          },
        ),
        title: Text("Chat with $_selectedModel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree),
            onPressed: () {
              _changeModel("Pep"); // Example: change model to "Pep"
            },
          ),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile) _buildLeftPane(),
          Expanded(
            child: Container(
              color: const Color(0xFF343541),
              child: Column(
                children: [
                  if (_modelChanging)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.blue.shade50,
                      child: Center(
                        child: Text(
                          _currentFunnyMessage,
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ),
                  if (_waitingResponse)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.blue.shade50,
                      child: Center(
                        child: Text(
                          _currentFunnyMessage,
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      children: messageWidgets,
                    ),
                  ),
                  Container(
                    color: const Color(0xFF343541),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image, color: Colors.indigo),
                          onPressed: (_waitingResponse || _modelChanging)
                              ? null
                              : _pickAndSendImage,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Your message…',
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: _waitingResponse ? null : _sendMessage,
                            enabled: !_waitingResponse,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: (_waitingResponse || _modelChanging)
                              ? null
                              : () {
                                  if (_controller.text.trim().isNotEmpty) {
                                    _sendMessage(_controller.text);
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (_waitingResponse || _modelChanging)
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
        ],
      ),
    );
  }
}
