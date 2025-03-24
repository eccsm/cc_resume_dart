import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cc_resume_app/widgets/message.dart';
import 'package:cc_resume_app/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../config/env_config.dart';
import 'chat_page.dart';

class DraggableChatWidget extends StatefulWidget {
  const DraggableChatWidget({super.key});

  @override
  _DraggableChatWidgetState createState() => _DraggableChatWidgetState();
}

class _DraggableChatWidgetState extends State<DraggableChatWidget> with SingleTickerProviderStateMixin {
  double top = 100;
  double left = 20;
  bool isMinimized = true;
  bool isAnimating = false;

  List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  bool _waitingResponse = false;
  String _selectedModel = "Sug";
  final List<String> _modelOptions = ["Sug", "Pep", "MLC"];
  final String apiKey = EnvConfig.apiKey;
  bool _isModelChanging = false;
  Timer? _modelChangeTimer;
  String _currentModelMessages = "";
  Timer? _chatWaitTimer;
  String _currentFunnyChatMessage = "";
  bool _isDarkMode = false;
  
  // Screen metrics
  late double _screenWidth;
  late double _screenHeight;
  late double _miniWidth = 350;
  late double _miniHeight = 500;
  late double _maxiWidth;
  late double _maxiHeight;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Schedule layout calculation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateSizes();
      _updateAnimation();
    });
  }

  void _calculateSizes() {
    final size = MediaQuery.of(context).size;
    _screenWidth = size.width;
    _screenHeight = size.height;
    
    // Define mini and maxi sizes
    _miniWidth = _screenWidth * 0.3;
    _miniHeight = _screenHeight * 0.6;
    _maxiWidth = _screenWidth * 0.8;
    _maxiHeight = _screenHeight * 0.8;
    
    // Ensure mini size is not too small or too big
    _miniWidth = _miniWidth.clamp(300.0, 400.0);
    _miniHeight = _miniHeight.clamp(450.0, 550.0);
    
    // Ensure max width is not too big for small screens
    if (_screenWidth < 768) {
      _maxiWidth = _screenWidth * 0.95;
    }
    
    // Update position if outside screen bounds
    _ensureInScreenBounds();
  }
  
  void _ensureInScreenBounds() {
    // Clamp the widget position to ensure it stays within screen bounds
    final currentWidth = isMinimized ? _miniWidth : _maxiWidth;
    final currentHeight = isMinimized ? _miniHeight : _maxiHeight;
    
    top = top.clamp(0.0, _screenHeight - currentHeight);
    left = left.clamp(0.0, _screenWidth - currentWidth);
    
    setState(() {});
  }
  
  void _updateAnimation() {
    
    // Reset animation controller
    if (isMinimized) {
      _animationController.reset();
    } else {
      _animationController.forward();
    }
  }

  void _toggleSize() {
    setState(() {
      isAnimating = true;
      isMinimized = !isMinimized;
    });
    
    _updateAnimation();
    
    // Start animation
    if (isMinimized) {
      _animationController.reverse().then((_) {
        setState(() {
          isAnimating = false;
        });
      });
    } else {
      _animationController.forward().then((_) {
        setState(() {
          isAnimating = false;
        });
      });
    }
    
    // Ensure position is valid
    _ensureInScreenBounds();
  }

  void _startChatWaitTimer() {
    _currentFunnyChatMessage = EnvConfig.randomChatMessage();
    setState(() {});

    _chatWaitTimer ??= Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentFunnyChatMessage = EnvConfig.randomChatMessage();
      });
    });
  }

  void _stopChatWaitTimer() {
    _chatWaitTimer?.cancel();
    _chatWaitTimer = null;
    setState(() {});
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
      messages.add(Message(
        sender: 'bot',
        text: 'Conversation has been reset. How can I assist you?',
      ));
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
        setState(() {
          messages.add(Message(
            sender: 'bot',
            text: 'I\'ve switched to $modelType mode. How can I help you?',
          ));
        });
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
      _scrollToBottom();
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  /// Image logic: shows a dialog to choose a task.
  Future<String?> _showImageTaskDialog() async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: _isDarkMode ? Colors.grey[850] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
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

  void _openFullChatPage() {
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _modelChangeTimer?.cancel();
    _chatWaitTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Recalculate sizes if screen changes
    _calculateSizes();
    
    final List<Widget> messageWidgets = messages.map((msg) {
      return MessageBubble(
        text: msg.text,
        isUser: msg.sender == 'user',
        isDarkMode: _isDarkMode,
      );
    }).toList();

    final currentWidth = isMinimized ? _miniWidth : _maxiWidth;
    final currentHeight = isMinimized ? _miniHeight : _maxiHeight;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
      top: top,
      left: left,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (isMinimized) {
            setState(() {
              top += details.delta.dy;
              left += details.delta.dx;
              _ensureInScreenBounds();
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: currentWidth,
          height: currentHeight,
          child: Material(
            elevation: 8.0,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: _isDarkMode 
                        ? Colors.grey[900]!.withOpacity(0.9) 
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isDarkMode 
                          ? Colors.grey[800]! 
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Chat Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _isDarkMode 
                              ? Colors.indigo[800] 
                              : Colors.indigo,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Avatar and title
                            Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      getCatIconPath(),
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getChatHeader(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Online',
                                          style: TextStyle(
                                            color: Colors.grey[200],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Action buttons
                            Row(
                              children: [
                                // Theme toggle
                                IconButton(
                                  icon: Icon(
                                    _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  tooltip: 'Toggle Theme',
                                  onPressed: _toggleTheme,
                                ),
                                // Expand/minimize
                                IconButton(
                                  icon: Icon(
                                    isMinimized ? Icons.open_in_full : Icons.close_fullscreen,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  tooltip: isMinimized ? 'Expand' : 'Minimize',
                                  onPressed: _toggleSize,
                                ),
                                // Full page mode
                                if (isMinimized)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.launch,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    tooltip: 'Open in Full Page',
                                    onPressed: _openFullChatPage,
                                  ),
                                // Reset conversation
                                IconButton(
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  tooltip: 'Reset Conversation',
                                  onPressed: _resetConversation,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Model selection pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: _isDarkMode ? Colors.grey[850] : Colors.grey[100],
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: Colors.indigo,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Model:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _isDarkMode ? Colors.grey[800] : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedModel,
                                    isDense: true,
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
                                    dropdownColor: _isDarkMode ? Colors.grey[800] : Colors.white,
                                    items: _modelOptions.map((model) {
                                      return DropdownMenuItem(
                                        value: model,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: model == "Sug" 
                                                    ? Colors.blue 
                                                    : model == "Pep"
                                                        ? Colors.orange
                                                        : Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              model.toUpperCase(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: _isDarkMode ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status banners
                      if (_isModelChanging)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: _isDarkMode ? Colors.blue.shade900 : Colors.blue.shade50,
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
                                  _currentModelMessages,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isDarkMode ? Colors.white : Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_waitingResponse)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: _isDarkMode ? Colors.blue.shade900 : Colors.blue.shade50,
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
                                  _currentFunnyChatMessage,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isDarkMode ? Colors.white : Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Messages
                      Expanded(
                        child: Container(
                          color: _isDarkMode 
                              ? Colors.grey[900] 
                              : Colors.grey[50],
                          child: messageWidgets.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        size: 48,
                                        color: _isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No messages yet',
                                        style: TextStyle(
                                          color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Start chatting below',
                                        style: TextStyle(
                                          color: _isDarkMode ? Colors.grey[500] : Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  children: messageWidgets,
                                ),
                        ),
                      ),

                      // Input area
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isDarkMode ? Colors.grey[850] : Colors.white,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, -2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Image upload button
                            Container(
                              decoration: BoxDecoration(
                                color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.image,
                                  color: (_waitingResponse || _isModelChanging) 
                                      ? (_isDarkMode ? Colors.grey[600] : Colors.grey[400])
                                      : Colors.indigo,
                                  size: 22,
                                ),
                                tooltip: 'Upload Image',
                                onPressed: (_waitingResponse || _isModelChanging)
                                    ? null
                                    : _pickAndSendImage,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Text field
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
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
                                  onSubmitted: (_waitingResponse || _isModelChanging)
                                      ? null
                                      : _sendMessage,
                                  enabled: !_waitingResponse && !_isModelChanging,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Send button
                            Container(
                              decoration: BoxDecoration(
                                color: (_waitingResponse || _isModelChanging || _controller.text.trim().isEmpty)
                                    ? (_isDarkMode ? Colors.grey[800] : Colors.grey[300])
                                    : Colors.indigo,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  if (!_waitingResponse && !_isModelChanging && _controller.text.trim().isNotEmpty)
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
                                  size: 20,
                                ),
                                tooltip: 'Send Message',
                                onPressed: (_waitingResponse || _isModelChanging || _controller.text.trim().isEmpty)
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
          ),
        ),
      ),
    );
  }
}