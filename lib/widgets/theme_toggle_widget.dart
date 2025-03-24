// lib/widgets/theme_toggle_widget.dart

import 'package:flutter/material.dart';

class ThemeToggleWidget extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentTheme;

  const ThemeToggleWidget({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<ThemeToggleWidget> createState() => _ThemeToggleWidgetState();
}

class _ThemeToggleWidgetState extends State<ThemeToggleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Set initial animation state based on current theme
    if (widget.currentTheme == ThemeMode.dark) {
      _animationController.value = 1.0;
    } else {
      _animationController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(ThemeToggleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update animation value when theme changes externally
    if (widget.currentTheme != oldWidget.currentTheme) {
      if (widget.currentTheme == ThemeMode.dark) {
        _animationController.value = 1.0;
      } else {
        _animationController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isDark) {
      widget.onThemeChanged(ThemeMode.light);
      _animationController.reverse();
    } else {
      widget.onThemeChanged(ThemeMode.dark);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeText = isDark ? 'Light Mode' : 'Dark Mode';
    
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return InkWell(
              onTap: _toggleTheme,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.grey.shade800 
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isDark 
                        ? Colors.grey.shade700 
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: _rotationAnimation.value * 6.28,
                      child: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: isDark 
                            ? Colors.amber 
                            : Colors.indigo,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      themeText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark 
                            ? Colors.white 
                            : Colors.black87,
                        inherit: true,
                      ),
                    ),
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