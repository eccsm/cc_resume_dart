// lib/widgets/chatbot_icon_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatbotIconWidget extends StatelessWidget {
  final VoidCallback onTap;
  final Function(Offset) onDragEnd;

  const ChatbotIconWidget({
    super.key,
    required this.onTap,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable(
      feedback: _buildIcon(),
      childWhenDragging: Container(), // Optionally hide the icon while dragging
      onDragEnd: (details) {
        // Convert global position to local position
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localOffset = box.globalToLocal(details.offset);
        onDragEnd(localOffset);
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact(); // Adds a medium haptic feedback
          onTap();
        },
        child: _buildIcon(),
      ),
    );
  }

  /// Builds the chatbot icon widget.
  Widget _buildIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.indigo,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.chat_bubble_outline, // High-quality chatbot icon
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
