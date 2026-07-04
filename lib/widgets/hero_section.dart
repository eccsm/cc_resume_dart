import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pdf/resume_constants.dart';
import '../theme/app_theme.dart';
import 'social_icons_row.dart';

/// Landing hero: name, rotating role line, and primary call-to-actions.
class HeroSection extends StatefulWidget {
  final VoidCallback onDownloadCv;
  final VoidCallback onOpenChat;
  final VoidCallback onViewProjects;

  const HeroSection({
    super.key,
    required this.onDownloadCv,
    required this.onOpenChat,
    required this.onViewProjects,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  static const List<String> _roles = [
    'Software Architect',
    'Senior Java Engineer',
    'Event-Driven Systems Designer',
    'AI & LLM Integrator',
  ];

  int _roleIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (mounted) {
        setState(() => _roleIndex = (_roleIndex + 1) % _roles.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.getColors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 24 : 40,
        vertical: isNarrow ? 36 : 56,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.card.withValues(alpha: isDark ? 0.55 : 0.7),
            AppTheme.secondaryColor.withValues(alpha: isDark ? 0.12 : 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.glassStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting eyebrow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(isDark ? 30 : 20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withAlpha(isDark ? 70 : 50),
              ),
            ),
            child: Text(
              '👋 Hello, I\'m',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name with gradient accent
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                colors.text,
                AppTheme.primaryColor,
              ],
              stops: const [0.55, 1.0],
            ).createShader(bounds),
            child: Text(
              ResumeConstants.name,
              style: GoogleFonts.inter(
                fontSize: isNarrow ? 36 : 52,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                height: 1.05,
                color: Colors.white, // masked by the shader
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Rotating role line
          SizedBox(
            height: isNarrow ? 28 : 34,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.6),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                _roles[_roleIndex],
                key: ValueKey(_roleIndex),
                style: GoogleFonts.inter(
                  fontSize: isNarrow ? 19 : 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // One-line pitch
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              '10+ years building enterprise platforms in insurance, banking '
              'and aviation — from Kafka-backed microservices to '
              'OpenAI-powered chatbots.',
              style: GoogleFonts.inter(
                fontSize: isNarrow ? 14 : 16,
                height: 1.6,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // CTAs
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: widget.onDownloadCv,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download CV'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 16),
                  textStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: widget.onOpenChat,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Ask my AI assistant'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.text,
                  side: BorderSide(
                    color: AppTheme.primaryColor.withAlpha(isDark ? 120 : 160),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 16),
                  textStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: widget.onViewProjects,
                icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                label: const Text('View projects'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.textSecondary,
                  textStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Social row
          const Align(
            alignment: Alignment.centerLeft,
            child: SocialIconsRow(useCircularBackground: true),
          ),
        ],
      ),
    );
  }
}
