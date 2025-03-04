// lib/models/message.dart (for example)

class Message {
  final String sender;
  final String text;
  bool containsCode;

  Message({
    required this.sender,
    required this.text,
    this.containsCode = false,
  });
}
