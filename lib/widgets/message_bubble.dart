import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OptimizedMessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const OptimizedMessageBubble({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  // Build a widget for normal text.
  Widget _buildNormalText(String content) {
    return Text(
      content,
      style: const TextStyle(fontSize: 16, color: Colors.white),
    );
  }

  // Build a widget for a code block with a copy button.
  Widget _buildCodeBlock(BuildContext context, String code) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tools row with a copy button.
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.copy, size: 20, color: Colors.white70),
                tooltip: 'Copy Code',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copied to clipboard')),
                  );
                },
              ),
            ],
          ),
          // Code content in a horizontal scroll view.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Splits the message text into normal and code block segments.
  List<Widget> _buildContent(BuildContext context) {
    // This regex captures code blocks delimited by triple backticks and ignores any language tag.
    final RegExp codeBlockRegExp = RegExp(r'```(?:\w+)?\n([\s\S]*?)```');
    final matches = codeBlockRegExp.allMatches(text);
    List<Widget> widgets = [];
    int lastIndex = 0;

    for (final match in matches) {
      // Add normal text preceding the code block.
      if (match.start > lastIndex) {
        final normalText = text.substring(lastIndex, match.start).trim();
        if (normalText.isNotEmpty) {
          widgets.add(_buildNormalText(normalText));
        }
      }
      // Extract code block content.
      final codeContent = match.group(1)?.trim() ?? "";
      if (codeContent.isNotEmpty) {
        widgets.add(_buildCodeBlock(context, codeContent));
      }
      lastIndex = match.end;
    }
    // Add any remaining text after the last code block.
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex).trim();
      if (remainingText.isNotEmpty) {
        widgets.add(_buildNormalText(remainingText));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue : Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildContent(context),
      ),
    );
  }
}
