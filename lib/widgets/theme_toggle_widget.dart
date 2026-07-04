import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

/// Premium theme toggle with smooth sun/moon icon morph
class ThemeToggleWidget extends StatefulWidget {
  final bool isCompact;
  final bool showLabel;

  const ThemeToggleWidget({
    super.key,
    this.isCompact = false,
    this.showLabel = true,
  });

  @override
  State<ThemeToggleWidget> createState() => _ThemeToggleWidgetState();
}

class _ThemeToggleWidgetState extends State<ThemeToggleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      try {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        _controller.value = themeProvider.themeMode == ThemeMode.dark ? 1.0 : 0.0;
        _isInitialized = true;
      } catch (e) {
        debugPrint('Failed to initialize theme: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    if (!mounted) return;
    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      themeProvider.toggleTheme();
      if (themeProvider.themeMode == ThemeMode.dark) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    } catch (e) {
      debugPrint('Failed to toggle theme: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeText = isDark ? 'Light Mode' : 'Dark Mode';

    if (widget.isCompact) {
      return IconButton(
        icon: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value * 3.14,
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? AppTheme.primaryColor : const Color(0xFF6366F1),
                size: 22,
              ),
            );
          },
        ),
        onPressed: _toggleTheme,
        tooltip: themeText,
      );
    }

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return InkWell(
              onTap: _toggleTheme,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(10)
                      : Colors.black.withAlpha(8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(15)
                        : Colors.black.withAlpha(10),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: _animation.value * 6.28,
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? AppTheme.primaryColor : const Color(0xFF6366F1),
                        size: 18,
                      ),
                    ),
                    if (widget.showLabel) ...[
                      const SizedBox(width: 8),
                      Text(
                        themeText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white.withAlpha(200) : Colors.black.withAlpha(180),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}