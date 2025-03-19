// lib/widgets/enhanced_chatbot_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class EnhancedChatbotWidget extends StatefulWidget {
  final VoidCallback onTap;
  final Function(Offset) onDragEnd;

  const EnhancedChatbotWidget({
    super.key,
    required this.onTap,
    required this.onDragEnd,
  });

  @override
  State<EnhancedChatbotWidget> createState() => _EnhancedChatbotWidgetState();
}

class _EnhancedChatbotWidgetState extends State<EnhancedChatbotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Draggable(
      feedback: _buildIcon(showFeedback: true),
      childWhenDragging: Container(), // Hide when dragging
      onDragEnd: (details) {
        // Convert global position to local position
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localOffset = box.globalToLocal(details.offset);
        widget.onDragEnd(localOffset);
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact(); // Adds a medium haptic feedback
            widget.onTap();
          },
          child: _buildIcon(),
        ),
      ),
    );
  }

  Widget _buildIcon({bool showFeedback = false}) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.indigo,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              colors: [
                Colors.indigo.shade400,
                Colors.indigo.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          transform: Matrix4.identity()
            ..scale(showFeedback ? 1.0 : (_isHovered ? 1.1 : _pulseAnimation.value)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Icon
              const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 28,
              ),
              
              // Pulsing ring (only when not being dragged)
              if (!showFeedback)
                SizedBox(
                  width: 65,
                  height: 65,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.4),
                    ),
                    strokeWidth: 2,
                  ),
                ),
                
              // Tooltip
              if (_isHovered && !showFeedback)
                Positioned(
                  bottom: -40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Chat with me',
                            speed: const Duration(milliseconds: 80),
                          ),
                        ],
                        isRepeatingAnimation: false,
                        totalRepeatCount: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}