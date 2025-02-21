// lib/widgets/social_icons_row.dart

import 'package:enhanced_url_launcher/enhanced_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cc_resume_app/resume_constants.dart';

class SocialIconsRow extends StatelessWidget {
  final bool includePdfExport;
  final VoidCallback? onPdfExport;

  const SocialIconsRow({
    super.key,
    this.includePdfExport = false,
    this.onPdfExport,
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
    double iconSize = screenWidth > 1200
        ? 24
        : screenWidth > 800
            ? 22
            : 20;

    return Wrap(
      spacing: 8.0, // Horizontal spacing between icons
      runSpacing: 4.0, // Vertical spacing when wrapped
      alignment: WrapAlignment.center, // Center alignment
      children: [
        // LinkedIn icon
        Semantics(
          label: 'LinkedIn',
          button: true,
          child: IconButton(
            onPressed: () => _launchLink(ResumeConstants.contactLinkedIn),
            icon: const FaIcon(
              FontAwesomeIcons.linkedin,
              color: Colors.blue,
            ),
            iconSize: iconSize,
            tooltip: 'LinkedIn',
          ),
        ),
        // GitHub icon
        Semantics(
          label: 'GitHub',
          button: true,
          child: IconButton(
            onPressed: () => _launchLink(ResumeConstants.contactGitHub),
            icon: const FaIcon(
              FontAwesomeIcons.github,
              color: Colors.black,
            ),
            iconSize: iconSize,
            tooltip: 'GitHub',
          ),
        ),
        // Email icon
        Semantics(
          label: 'Email',
          button: true,
          child: IconButton(
            onPressed: () => _launchLink("mailto:${ResumeConstants.contactEmail}"),
            icon: const FaIcon(
              FontAwesomeIcons.envelope,
              color: Colors.redAccent,
            ),
            iconSize: iconSize,
            tooltip: 'Email',
          ),
        ),
        // PDF Export icon (optional)
        if (includePdfExport)
          Semantics(
            label: 'Export as PDF',
            button: true,
            child: IconButton(
              onPressed: onPdfExport,
              icon: const Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
              ),
              iconSize: iconSize,
              tooltip: 'Export as PDF',
            ),
          ),
      ],
    );
  }
}
