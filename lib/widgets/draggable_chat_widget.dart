import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:cc_resume_app/widgets/typing_indicator_bubble.dart';
import 'message_bubble.dart';

/// A simple message model to represent a chat message.
class Message {
  final String sender;
  final String text;
  Message({required this.sender, required this.text});
}

/// Configuration for the API endpoints
class ApiConfig {
  // Base URL - change to your production server when deploying
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL', 
    defaultValue: 'http://127.0.0.1:8000'
  );
  
  // Endpoints
  static String askEndpoint(String query, String model) => 
      '$baseUrl/ask?q=${Uri.encodeComponent(query)}&model=$model';
  
  static String updateModelEndpoint() => '$baseUrl/update_model';
  
  static String recognizeEndpoint(String task) => 
      '$baseUrl/recognize?task=$task';
  
  // Timeout duration for API calls
  static const Duration requestTimeout = Duration(seconds: 30);
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
  bool _isConnecting = false;

  // Model selection for text chat.
  String _selectedModel = "vicuna_ggml";
  final List<String> _modelOptions = ["vicuna_ggml", "mlc_llm"];

  /// Returns the cat icon path based on the current day (Pep or Sug).
  String getCatIconPath() {
    final int day = DateTime.now().day;
    return (day % 2 == 0)
        ? 'assets/images/seker_icon.png'
        : 'assets/images/biber_icon.png';
  }

  String getChatHeader() {
    final int day = DateTime.now().day;
    return (day % 2 == 0) ? 'Talk with Sug' : 'Talk with Pep';
  }

  String _parseAnswer(String answer) {
    try {
      // Try to parse the entire response as JSON.
      final Map<String, dynamic> data = jsonDecode(answer);

      if (data.containsKey("result")) {
        return data["result"] as String;
      }
    } catch (e) {
      // If it's not valid JSON, just fall through.
    }

    if (answer.contains("User:")) {
      return answer.split("User:")[0].trim();
    }
    return answer;
  }

  Future<void> _getMessage(String message) async {
    setState(() {
      _isConnecting = true;
    });
    
    // Build the request URI with the selected model.
    final uri = Uri.parse(ApiConfig.askEndpoint(message, _selectedModel));
    
    try {
      // Set a timeout so we don't hang indefinitely.
      final response = await http.get(uri).timeout(ApiConfig.requestTimeout);
      debugPrint("Response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final rawAnswer = response.body;
        final sanitizedAnswer = rawAnswer.trim();
        final parsedAnswer = _parseAnswer(sanitizedAnswer);
        setState(() {
          messages.add(Message(sender: 'bot', text: parsedAnswer));
        });
      } else {
        // Handle error responses with more detail
        String errorDetail = '';
        try {
          final errorData = jsonDecode(response.body);
          errorDetail = errorData['detail'] ?? '';
        } catch (_) {
          // If response body isn't valid JSON
          errorDetail = response.body.substring(0, response.body.length.clamp(0, 100));
        }
        
        setState(() {
          messages.add(Message(
            sender: 'bot',
            text: 'Error ${response.statusCode}: $errorDetail',
          ));
        });
      }
    } catch (e, stack) {
      // Log the error details.
      debugPrint("Error in _getMessage: $e\n$stack");
      setState(() {
        messages.add(Message(
          sender: 'bot',
          text: 'Error connecting to server: ${e.toString()}',
        ));
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
      _scrollToBottom();
    }
  }

  /// Called when user sends a text message.
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    setState(() {
      messages.add(Message(sender: 'user', text: message));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();
    await _getMessage(message);
    setState(() {
      _isLoading = false;
    });
    _scrollToBottom();
  }

  /// Resets the entire conversation.
  void _resetConversation() {
    setState(() {
      messages.clear();
    });
  }

  /// Scrolls the ListView to the bottom.
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

  /// Sends a request to update the backend text model.
  Future<void> _updateModel(String modelType) async {
    setState(() {
      _isConnecting = true;
    });
    
    final uri = Uri.parse(ApiConfig.updateModelEndpoint());
    try {
      // Send both keys: use an empty string for new_model if not updating the model path.
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: '{"new_model": "", "new_model_type": "$modelType"}',
      ).timeout(ApiConfig.requestTimeout);
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Model changed to $modelType')),
        );
      } else {
        String errorMessage = 'Failed to update model';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['detail'] ?? errorMessage;
        } catch (_) {}
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error. Check if the server is running.')),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  /// Shows a bottom sheet dialog to select an image task.
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

  Future<void> _sendImageWithTask(XFile image, String task) async {
    setState(() {
      messages.add(Message(sender: 'user', text: 'Sent an image for $task'));
      _isLoading = true;
      _isConnecting = true;
    });
    
    final uri = Uri.parse(ApiConfig.recognizeEndpoint(task));
    var request = http.MultipartRequest('POST', uri);
    
    try {
      // Read file bytes
      final bytes = await image.readAsBytes();
      
      // Create the multipart file from bytes with correct parameter name and content type
      request.files.add(http.MultipartFile.fromBytes(
        'file', // This must match the parameter name in FastAPI
        bytes,
        filename: image.name,
        contentType: MediaType.parse('image/jpeg'), // Specify content type
      ));
      
      // Debug the request
      debugPrint("Sending image to: ${uri.toString()}");
      debugPrint("Image filename: ${image.name}");
      
      var streamedResponse = await request.send().timeout(ApiConfig.requestTimeout);
      var response = await http.Response.fromStream(streamedResponse);
      
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final respStr = response.body;
        // Parse the JSON response
        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(respStr);
          // Format the result nicely for display
          String parsedResult = '';
          
          if (responseData.containsKey('result')) {
            final result = responseData['result'];
            
            if (task == 'deepfake_detection' && result is Map) {
              // Handle deepfake detection result
              final isFake = result['is_fake'] as bool;
              final confidence = (result['confidence'] as num).toStringAsFixed(2);
              parsedResult = "${result['interpretation']}\nConfidence: $confidence";
            } else if (task == 'object_recognition' && result is Map) {
              // Handle object detection result
              final detections = result['detections'] as List;
              parsedResult = "Detected ${detections.length} objects:\n";
              for (var detection in detections) {
                parsedResult += "• ${detection['label']} (${(detection['confidence'] as num).toStringAsFixed(2)})\n";
              }
            } else if (task == 'image_classification' && result is Map) {
              // Handle classification result
              final classifications = result['classifications'] as List;
              parsedResult = "Top classifications:\n";
              for (var item in classifications.take(3)) {
                parsedResult += "• ${item['label']} (${(item['confidence'] as num).toStringAsFixed(2)})\n";
              }
            } else {
              // Generic result handling
              parsedResult = respStr;
            }
          } else {
            parsedResult = respStr;
          }
          
          setState(() {
            messages.add(Message(sender: 'bot', text: parsedResult));
          });
        } catch (e) {
          // Fallback for parsing errors
          setState(() {
            messages.add(Message(sender: 'bot', text: respStr));
          });
        }
      } else {
        String errorDetail = '';
        try {
          final errorData = jsonDecode(response.body);
          errorDetail = errorData['detail'] ?? '';
        } catch (_) {
          errorDetail = response.body.substring(0, response.body.length.clamp(0, 100));
        }
        
        setState(() {
          messages.add(Message(
            sender: 'bot',
            text: 'Image processing error (${response.statusCode}): $errorDetail',
          ));
        });
      }
    } catch (e) {
      debugPrint("Error sending image: $e");
      setState(() {
        messages.add(Message(
          sender: 'bot', 
          text: 'Error uploading image: ${e.toString()}'
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isConnecting = false;
      });
      _scrollToBottom();
    }
  }

  /// Pick an image from the gallery and then ask for a processing task.
  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Ask user what to do with the image.
      final task = await _showImageTaskDialog();
      if (task != null) {
        await _sendImageWithTask(image, task);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build the list of message widgets.
    final List<Widget> messageWidgets = messages.map<Widget>((msg) {
      return MessageBubble(
        text: msg.text,
        isUser: msg.sender == 'user',
      );
    }).toList();

    // Show typing indicator bubble if waiting for a response.
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
                // Header with cat icon, title, and a refresh button.
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cat avatar and title.
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
                      // Reset conversation button.
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        tooltip: 'Reset Conversation',
                        onPressed: _resetConversation,
                      ),
                    ],
                  ),
                ),
                // Model selection dropdown.
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
                        items: _modelOptions
                            .map((model) => DropdownMenuItem(
                                  value: model,
                                  child: Text(model.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: _isConnecting 
                            ? null  // Disable during API calls
                            : (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedModel = newValue;
                                  });
                                  // Call the endpoint to update the backend text model dynamically.
                                  _updateModel(newValue);
                                }
                              },
                      ),
                      if (_isConnecting) 
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 12, 
                          height: 12, 
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),
                ),
                // Connection status indicator
                if (_isConnecting)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.blue.shade50,
                    child: const Center(
                      child: Text(
                        'Connecting to server...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                // Chat messages.
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    children: messageWidgets,
                  ),
                ),
                // Input field row with text input, image button, and send button.
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Icon button to pick and send an image.
                      IconButton(
                        icon: const Icon(Icons.image, color: Colors.indigo),
                        onPressed: _isConnecting ? null : _pickAndSendImage,
                      ),
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
                          onSubmitted: _isConnecting ? null : _sendMessage,
                          enabled: !_isConnecting,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _isConnecting 
                            ? null 
                            : () {
                                if (_controller.text.trim().isNotEmpty) {
                                  _sendMessage(_controller.text);
                                }
                              },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isConnecting 
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