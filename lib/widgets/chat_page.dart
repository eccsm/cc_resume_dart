import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../config/env_config.dart';
import '../widgets/message.dart';
import '../widgets/message_bubble.dart';

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
  bool _isDarkMode = false;
  bool _isDrawerOpen = false;

  Timer? _funnyTimer;
  String _currentFunnyMessage = '';

  // Model choices for the left pane
  final List<String> _modelOptions = ["Sug", "Pep", "MLC"];
  
  // For more options
  final List<String> _supportedLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
  ];
  String _selectedLanguage = 'English';
  double _responseTemperature = 0.7;
  int _maxTokens = 500;

  @override
  void initState() {
    super.initState();
    messages = List.from(widget.initialMessages);
    _selectedModel = widget.selectedModel;
    
    // Add welcome message if there are no messages
    if (messages.isEmpty) {
      messages.add(Message(
        sender: 'bot',
        text: 'Welcome to the full-screen chat experience. How can I assist you today?',
      ));
    }
  }

  void _startFunnyTimer() {
    _currentFunnyMessage = EnvConfig.randomChatMessage();
    setState(() {});
    _funnyTimer ??= Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentFunnyMessage = EnvConfig.randomChatMessage();
      });
    });
  }

  void _stopFunnyTimer() {
    _funnyTimer?.cancel();
    _funnyTimer = null;
    setState(() {});
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

    // Build API URL with params
    final baseUri = ApiConfig.askEndpoint(userMessage, _selectedModel);
    final uri = Uri.parse('$baseUri&temperature=${_responseTemperature.toStringAsFixed(1)}&max_tokens=$_maxTokens');
    
    try {
      final response = await http.get(
        uri,
        headers: ApiConfig.defaultHeaders(isJson: false),
      );
      if (response.statusCode == 200) {
        final rawAnswer = response.body.trim();
        final parsedAnswer = _parseAnswer(rawAnswer);
        setState(() {
          messages.add(Message(sender: 'bot', text: parsedAnswer));
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

  /// Parse answer from API
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
      final response = await http.post(
        uri,
        headers: ApiConfig.defaultHeaders(),
        body: jsonEncode({
          "new_model": "",
          "new_model_type": newModel,
        }),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          messages.add(Message(
            sender: 'bot',
            text: 'I\'ve switched to the $newModel model. How can I help you now?',
          ));
        });
      }
    } catch (e) {
      // Handle error if needed
      setState(() {
        messages.add(Message(
          sender: 'bot',
          text: 'Failed to switch models: $e',
        ));
      });
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
      backgroundColor: _isDarkMode ? Colors.grey[850] : Colors.white,
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Select Image Analysis Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield, color: Colors.red),
                ),
                title: const Text('Deepfake Detection'),
                subtitle: const Text('Analyze if an image has been manipulated'),
                onTap: () => Navigator.pop(context, 'deepfake_detection'),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search, color: Colors.blue),
                ),
                title: const Text('Object Recognition'),
                subtitle: const Text('Identify objects in the image'),
                onTap: () => Navigator.pop(context, 'object_recognition'),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.image, color: Colors.green),
                ),
                title: const Text('Image Classification'),
                subtitle: const Text('Categorize the image content'),
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

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _resetConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Conversation', 
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: _isDarkMode ? Colors.grey[850] : Colors.white,
        content: Text(
          'Are you sure you want to clear all messages?',
          style: TextStyle(
            color: _isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                messages.clear();
                messages.add(Message(
                  sender: 'bot',
                  text: 'Conversation has been reset. How can I assist you?',
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  // Build the side drawer with model selection and advanced options
  Widget _buildSideDrawer() {
    return Container(
      width: 300,
      color: _isDarkMode ? const Color(0xFF202123) : Colors.white,
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: _isDarkMode ? Colors.indigo[800] : Colors.indigo,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        'assets/images/seker_icon.png',
                        height: 30,
                        width: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Assistant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Version 2.0',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Model',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          ...List.generate(_modelOptions.length, (index) {
            final model = _modelOptions[index];
            return ListTile(
              title: Text(
                model.toUpperCase(),
                style: TextStyle(
                  color: _selectedModel == model 
                      ? (_isDarkMode ? Colors.white : Colors.indigo)
                      : (_isDarkMode ? Colors.white70 : Colors.black87),
                  fontWeight: _selectedModel == model ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: _selectedModel == model,
              selectedTileColor: _isDarkMode ? Colors.indigo.withOpacity(0.3) : Colors.indigo.withOpacity(0.1),
              leading: Icon(
                model == "Sug" ? Icons.auto_awesome : model == "Pep" ? Icons.psychology : Icons.memory,
                color: model == "Sug" ? Colors.blue : model == "Pep" ? Colors.orange : Colors.green,
              ),
              onTap: () async {
                await _changeModel(model);
                if (mounted) {
                  setState(() {
                    _isDrawerOpen = false;
                  });
                }
              },
            );
          }),
          const Divider(),
          ListTile(
            title: Text(
              'Temperature',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Slider(
              value: _responseTemperature,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: _responseTemperature.toStringAsFixed(1),
              activeColor: Colors.indigo,
              inactiveColor: _isDarkMode ? Colors.grey[700] : Colors.grey[300],
              onChanged: (value) {
                setState(() {
                  _responseTemperature = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text(
              'Max Response Length',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: DropdownButton<int>(
              value: _maxTokens,
              isExpanded: true,
              dropdownColor: _isDarkMode ? Colors.grey[800] : Colors.white,
              items: [
                DropdownMenuItem(value: 250, child: Text('Short (~50 words)', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87))),
                DropdownMenuItem(value: 500, child: Text('Medium (~100 words)', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87))),
                DropdownMenuItem(value: 1000, child: Text('Long (~200 words)', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87))),
                DropdownMenuItem(value: 2000, child: Text('Very Long (~400 words)', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87))),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _maxTokens = value;
                  });
                }
              },
            ),
          ),
          ListTile(
            title: Text(
              'Language',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: DropdownButton<String>(
              value: _selectedLanguage,
              isExpanded: true,
              dropdownColor: _isDarkMode ? Colors.grey[800] : Colors.white,
              items: _supportedLanguages.map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(
                    language,
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                }
              },
            ),
          ),
          ListTile(
            title: Text(
              'Dark Mode',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            trailing: Switch(
              value: _isDarkMode,
              activeColor: Colors.indigo,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
          ),
        ],
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
      return MessageBubble(
        text: msg.text,
        isUser: msg.sender == 'user',
        isDarkMode: _isDarkMode,
      );
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Chat with $_selectedModel",
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context, messages);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDrawerOpen ? Icons.close : Icons.settings,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: _toggleDrawer,
          ),
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: _resetConversation,
          ),
        ],
      ),
      body: Row(
        children: [
          if (_isDrawerOpen) _buildSideDrawer(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              margin: EdgeInsets.all(_isDrawerOpen ? 0 : 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_isDrawerOpen ? 0 : 16),
                child: Column(
                  children: [
                    if (_modelChanging || _waitingResponse)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: _isDarkMode ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _isDarkMode ? Colors.white : Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentFunnyMessage,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isDarkMode ? Colors.white70 : Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: messageWidgets.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64,
                                    color: _isDarkMode ? Colors.grey[700] : Colors.grey[300],
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Start a conversation',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32),
                                    child: Text(
                                      'Type a message below to begin chatting with the AI assistant',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _isDarkMode ? Colors.grey[500] : Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              children: messageWidgets,
                            ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, -2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.image,
                                    color: (_waitingResponse || _modelChanging) 
                                        ? (_isDarkMode ? Colors.grey[600] : Colors.grey[400])
                                        : Colors.indigo,
                                  ),
                                  tooltip: 'Upload Image',
                                  onPressed: (_waitingResponse || _modelChanging)
                                      ? null
                                      : _pickAndSendImage,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.mic,
                                    color: (_waitingResponse || _modelChanging) 
                                        ? (_isDarkMode ? Colors.grey[600] : Colors.grey[400])
                                        : Colors.indigo,
                                  ),
                                  tooltip: 'Voice Input',
                                  onPressed: (_waitingResponse || _modelChanging)
                                      ? null
                                      : () {
                                          // Voice input functionality would go here
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Voice input coming soon')),
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: 'Type your message...',
                                  hintStyle: TextStyle(
                                    color: _isDarkMode ? Colors.grey[500] : Colors.grey[500],
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                style: TextStyle(
                                  color: _isDarkMode ? Colors.white : Colors.black87,
                                ),
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_waitingResponse || _modelChanging)
                                    ? null
                                    : _sendMessage,
                                enabled: !_waitingResponse && !_modelChanging,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: (_waitingResponse || _modelChanging || _controller.text.trim().isEmpty)
                                  ? (_isDarkMode ? Colors.grey[800] : Colors.grey[300])
                                  : Colors.indigo,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                if (!_waitingResponse && !_modelChanging && _controller.text.trim().isNotEmpty)
                                  BoxShadow(
                                    color: Colors.indigo.withOpacity(0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                              ),
                              tooltip: 'Send Message',
                              onPressed: (_waitingResponse || _modelChanging || _controller.text.trim().isEmpty)
                                  ? null
                                  : () => _sendMessage(_controller.text),
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
        ],
      ),
    );
  }
}