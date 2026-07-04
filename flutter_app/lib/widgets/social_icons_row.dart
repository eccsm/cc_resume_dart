import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/resume.dart';

class SocialIconsRow extends StatelessWidget {
  final bool includePdfExport;
  final VoidCallback? onPdfExport;
  final double iconSize;
  final bool useCircularBackground;

  const SocialIconsRow({
    super.key,
    this.includePdfExport = false,
    this.onPdfExport,
    this.iconSize = 0,
    this.useCircularBackground = true,
  });

  Future<void> _launchLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double effectiveIconSize = iconSize > 0
        ? iconSize
        : screenWidth > 1200 ? 20 : screenWidth > 800 ? 18 : 16;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<Widget> socialIcons = [
      _SocialIconButton(
        icon: FontAwesomeIcons.linkedin,
        iconColor: const Color(0xFF0A66C2),
        size: effectiveIconSize,
        tooltip: 'LinkedIn',
        onPressed: () => _launchLink(Resume.I.contactLinkedIn),
      ),
      _SocialIconButton(
        icon: FontAwesomeIcons.github,
        iconColor: isDark ? Colors.white : const Color(0xFF24292E),
        size: effectiveIconSize,
        tooltip: 'GitHub',
        onPressed: () => _launchLink(Resume.I.contactGitHub),
      ),
      _SocialIconButton(
        icon: FontAwesomeIcons.envelope,
        iconColor: const Color(0xFFEA4335),
        size: effectiveIconSize,
        tooltip: 'Email',
        onPressed: () => _launchLink("mailto:${Resume.I.contactEmail}"),
      ),
      if (includePdfExport)
        _SocialIconButton(
          icon: Icons.picture_as_pdf_rounded,
          iconColor: const Color(0xFFF44336),
          size: effectiveIconSize,
          tooltip: 'Export as PDF',
          onPressed: onPdfExport,
          isMaterialIcon: true,
        ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < socialIcons.length; i++) ...[
          socialIcons[i],
          if (i < socialIcons.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _SocialIconButton extends StatefulWidget {
  final dynamic icon;
  final Color iconColor;
  final double size;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isMaterialIcon;

  const _SocialIconButton({
    required this.icon,
    required this.iconColor,
    required this.size,
    required this.tooltip,
    required this.onPressed,
    this.isMaterialIcon = false,
  });

  @override
  State<_SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<_SocialIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseBg = isDark ? Colors.white.withAlpha(8) : const Color(0xFF1A1D26).withAlpha(8);
    final hoverBg = isDark ? Colors.white.withAlpha(20) : const Color(0xFF1A1D26).withAlpha(15);
    final baseBorder = isDark ? Colors.white.withAlpha(15) : const Color(0xFFD0D5E0);

    return Semantics(
      label: widget.tooltip,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Tooltip(
            message: widget.tooltip,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.size * 2,
              height: widget.size * 2,
              decoration: BoxDecoration(
                color: _isHovered ? hoverBg : baseBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isHovered
                      ? widget.iconColor.withAlpha(80)
                      : baseBorder,
                  width: 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.iconColor.withAlpha(30),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Transform.scale(
                  scale: _isHovered ? 1.15 : 1.0,
                  child: widget.isMaterialIcon
                      ? Icon(
                          widget.icon as IconData,
                          color: widget.iconColor,
                          size: widget.size * 0.8,
                        )
                      : FaIcon(
                          widget.icon,
                          color: widget.iconColor,
                          size: widget.size * 0.8,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}