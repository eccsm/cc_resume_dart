import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class ProfilePicture extends StatefulWidget {
  final VoidCallback? onChatRequested;

  const ProfilePicture({
    super.key,
    this.onChatRequested,
  });

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double size;
    if (screenWidth > 1200) {
      size = 110;
    } else if (screenWidth > 800) {
      size = 95;
    } else {
      size = 80;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          if (widget.onChatRequested != null) {
            HapticFeedback.mediumImpact();
            widget.onChatRequested!();
          }
        },
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            final glowIntensity = _isHovered ? 1.0 : _glowAnimation.value;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    AppTheme.primaryColor.withAlpha((80 * glowIntensity).round()),
                    AppTheme.secondaryColor.withAlpha((60 * glowIntensity).round()),
                    AppTheme.primaryColor.withAlpha((80 * glowIntensity).round()),
                    AppTheme.secondaryColor.withAlpha((60 * glowIntensity).round()),
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                  transform: GradientRotation(_glowAnimation.value * 6.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(_isHovered ? 70 : 30),
                    blurRadius: _isHovered ? 20 : 12,
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(_isHovered ? 80 : 40),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/profile_picture.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}