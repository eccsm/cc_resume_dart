// lib/widgets/animated_page_transition.dart

import 'package:flutter/material.dart';

enum TransitionType {
  fade,
  scale,
  slide,
  slideUp,
}

class AnimatedPageTransition extends PageRouteBuilder {
  final Widget page;
  final TransitionType transitionType;
  final Curve curve;
  final Duration duration;

  AnimatedPageTransition({
    required this.page,
    this.transitionType = TransitionType.fade,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 500),
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            switch (transitionType) {
              case TransitionType.fade:
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: curve),
                  ),
                  child: child,
                );
              case TransitionType.scale:
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: curve),
                  ),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: curve),
                    ),
                    child: child,
                  ),
                );
              case TransitionType.slide:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: curve),
                  ),
                  child: child,
                );
              case TransitionType.slideUp:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: curve),
                  ),
                  child: child,
                );
            }
          },
          transitionDuration: duration,
        );
}

// Simple section transition widget for in-page animations
class SectionTransition extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final Curve curve;

  const SectionTransition({
    super.key,
    required this.child,
    this.isActive = false,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.0,
      duration: duration,
      curve: curve,
      child: AnimatedSlide(
        offset: isActive ? Offset.zero : const Offset(0, 0.1),
        duration: duration,
        curve: curve,
        child: child,
      ),
    );
  }
}