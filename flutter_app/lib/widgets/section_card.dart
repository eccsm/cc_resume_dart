import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium glassmorphic section card
class SectionCard extends StatefulWidget {
  final String title;
  final Widget content;
  final IconData? icon;
  final Color? accentColor;
  final double headerFontSize;
  final EdgeInsets contentPadding;
  final EdgeInsets margin;
  final double borderRadius;
  final ImageProvider? backgroundImage;
  final double backgroundImageOpacity;

  const SectionCard({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.accentColor,
    this.headerFontSize = 20,
    this.contentPadding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.symmetric(vertical: 10),
    this.borderRadius = 16,
    this.backgroundImage,
    this.backgroundImageOpacity = 0.04,
  });

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.getColors(context);
    final effectiveAccentColor = widget.accentColor ?? AppTheme.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: widget.margin,
        decoration: BoxDecoration(
          color: isDark
              ? themeColors.card.withAlpha(_isHovered ? 195 : 170)
              : themeColors.card.withValues(alpha: _isHovered ? 0.82 : 0.76),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          image: widget.backgroundImage != null
              ? DecorationImage(
                  image: widget.backgroundImage!,
                  fit: BoxFit.cover,
                  opacity: widget.backgroundImageOpacity,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    BlendMode.softLight,
                  ),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(_isHovered ? 100 : 60)
                  : const Color(0xFF1A1D26).withAlpha(_isHovered ? 35 : 18),
              blurRadius: _isHovered ? 24 : 14,
              offset: Offset(0, _isHovered ? 8 : 4),
              spreadRadius: isDark ? 0 : (_isHovered ? 1 : 0),
            ),
            if (isDark)
              BoxShadow(
                color: effectiveAccentColor.withAlpha(_isHovered ? 15 : 0),
                blurRadius: 30,
                spreadRadius: -4,
              ),
          ],
          border: Border.all(
            color: _isHovered
                ? effectiveAccentColor.withAlpha(isDark ? 60 : 40)
                : themeColors.border,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient accent
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      themeColors.cardHeader.withValues(
                        alpha: isDark ? 0.72 : 0.64,
                      ),
                      isDark
                          ? themeColors.cardHeader.withAlpha(132)
                          : themeColors.cardHeader.withValues(alpha: 0.56),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: effectiveAccentColor.withAlpha(isDark ? 50 : 30),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              effectiveAccentColor.withAlpha(isDark ? 30 : 20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.icon,
                          color: effectiveAccentColor,
                          size: widget.headerFontSize,
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: widget.headerFontSize,
                          fontWeight: FontWeight.w700,
                          color: themeColors.text,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: widget.contentPadding,
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: themeColors.text,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  child: widget.content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
