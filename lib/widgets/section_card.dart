// lib/widgets/enhanced_section_card.dart

import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget content;
  final IconData? icon;
  final Color? accentColor;
  final bool animate;
  final double headerFontSize;
  final EdgeInsets contentPadding;
  final EdgeInsets margin;
  final double borderRadius;

  const SectionCard({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.accentColor,
    this.animate = true,
    this.headerFontSize = 20,
    this.contentPadding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 12),
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = accentColor ?? Theme.of(context).primaryColor;
    
    return TweenAnimationBuilder<double>(
      duration: animate ? const Duration(milliseconds: 800) : Duration.zero,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withOpacity(0.85),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: effectiveAccentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: effectiveAccentColor.withOpacity(0.9),
                      size: headerFontSize + 2,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: contentPadding,
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}