// lib/widgets/social_icons_row.dart

import 'package:enhanced_url_launcher/enhanced_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../pdf/resume_constants.dart';


class SocialIconsRow extends StatelessWidget {
  final bool includePdfExport;
  final VoidCallback? onPdfExport;
  final double iconSize;
  final bool useCircularBackground;

  const SocialIconsRow({
    super.key,
    this.includePdfExport = false,
    this.onPdfExport,
    this.iconSize = 0, // 0 means auto-size based on screen width
    this.useCircularBackground = true,
  });

  // Helper to open a URL or mailto link.
  Future<void> _launchLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically adjust icon size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double effectiveIconSize = iconSize > 0 
        ? iconSize 
        : screenWidth > 1200
            ? 22
            : screenWidth > 800
                ? 20
                : 18;
    
    // Base colors for icons with proper dark theme matching
    const Color linkedInColor = Color(0xFF0A66C2);
    const Color githubColor = Colors.white;
    const Color emailColor = Color(0xFFEA4335);
    const Color pdfColor = Color(0xFFF44336);
    
    // Determine background colors and text colors for the icons
    final Color backgroundBase = Colors.grey.shade800;
    final Color hoverColor = Colors.grey.shade700;

    // Create the social media icons
    List<Widget> socialIcons = [
      _buildSocialIcon(
        context,
        icon: FontAwesomeIcons.linkedin,
        iconColor: linkedInColor,
        backgroundColor: backgroundBase,
        hoverColor: hoverColor,
        size: effectiveIconSize,
        tooltip: 'LinkedIn',
        onPressed: () => _launchLink(ResumeConstants.contactLinkedIn),
      ),
      _buildSocialIcon(
        context,
        icon: FontAwesomeIcons.github,
        iconColor: githubColor,
        backgroundColor: backgroundBase,
        hoverColor: hoverColor,
        size: effectiveIconSize,
        tooltip: 'GitHub',
        onPressed: () => _launchLink(ResumeConstants.contactGitHub),
      ),
      _buildSocialIcon(
        context,
        icon: FontAwesomeIcons.envelope,
        iconColor: emailColor,
        backgroundColor: backgroundBase,
        hoverColor: hoverColor,
        size: effectiveIconSize,
        tooltip: 'Email',
        onPressed: () => _launchLink("mailto:${ResumeConstants.contactEmail}"),
      ),
      if (includePdfExport)
        _buildSocialIcon(
          context,
          icon: Icons.picture_as_pdf,
          iconColor: pdfColor,
          backgroundColor: backgroundBase,
          hoverColor: hoverColor,
          size: effectiveIconSize,
          tooltip: 'Export as PDF',
          onPressed: onPdfExport,
        ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < socialIcons.length; i++) ...[
          socialIcons[i],
          if (i < socialIcons.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _buildSocialIcon(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color hoverColor,
    required double size,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Semantics(
      label: tooltip,
      button: true,
      child: useCircularBackground
          ? _buildCircularIcon(
              icon: icon,
              iconColor: iconColor,
              backgroundColor: backgroundColor,
              hoverColor: hoverColor,
              size: size,
              tooltip: tooltip,
              onPressed: onPressed,
            )
          : IconButton(
              onPressed: onPressed,
              icon: icon.fontFamily == 'FontAwesomeBrands'
                  ? FaIcon(
                      icon,
                      color: iconColor,
                      size: size * 0.7,
                    )
                  : Icon(
                      icon,
                      color: iconColor,
                      size: size * 0.7,
                    ),
              iconSize: size,
              tooltip: tooltip,
              splashRadius: size * 0.8,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: size * 1.2,
                minHeight: size * 1.2,
              ),
            ),
    );
  }

  Widget _buildCircularIcon({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color hoverColor,
    required double size,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size),
        hoverColor: hoverColor,
        splashColor: iconColor.withOpacity(0.1),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: size * 1.8,
            height: size * 1.8,
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade700,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: icon.fontFamily == 'FontAwesomeBrands'
                ? FaIcon(
                    icon,
                    color: iconColor,
                    size: size,
                  )
                : Icon(
                    icon,
                    color: iconColor,
                    size: size,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}