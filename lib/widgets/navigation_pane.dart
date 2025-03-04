// lib/widgets/navigation_pane.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'profile_picture.dart';
import 'social_icons_row.dart';

class NavigationPane extends StatelessWidget {
  final bool isDrawer;
  final VoidCallback? onPdfExport;
  final Function(String)? onNavigate; // Added onNavigate callback
  final String activeSection; // Added activeSection

  const NavigationPane({
    super.key,
    this.isDrawer = false,
    this.onPdfExport,
    this.onNavigate, // Included in constructor
    this.activeSection = '', // Default value
  });

  // Helper to build navigation links
  Widget _buildNavLink(BuildContext context, String title, IconData icon, String section) {
    bool isActive = section == activeSection;
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white, // Consistent color
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          decoration: isActive ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
      onTap: () {
        // Close the drawer if in drawer mode
        if (isDrawer && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        // Call the onNavigate callback with the section identifier
        if (onNavigate != null) {
          onNavigate!(section);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation links with titles, icons, and corresponding section keys
    final List<Map<String, dynamic>> navLinks = [
      {'title': 'About', 'icon': Icons.home, 'section': 'professional_summary'},
      {'title': 'Skills', 'icon': Icons.code, 'section': 'skills'}, // Updated link
      {'title': 'Experience', 'icon': Icons.work, 'section': 'experience'},
      {'title': 'Education', 'icon': Icons.school, 'section': 'education'},
      {'title': 'Github Projects', 'icon': FontAwesomeIcons.github, 'section': 'github_repos'},
    ];

    return isDrawer
        ? Drawer(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.grey, // Drawer background color
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40), // Spacing from top
                  const ProfilePicture(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: navLinks
                          .map(
                            (link) => _buildNavLink(
                              context,
                              link['title'],
                              link['icon'],
                              link['section'],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const Divider(color: Colors.white54),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SocialIconsRow(
                      includePdfExport: onPdfExport != null,
                      onPdfExport: onPdfExport,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5), // Semi-transparent background
              border: Border(
                right: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40), // Spacing from top
                const ProfilePicture(),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: navLinks
                        .map(
                          (link) => _buildNavLink(
                            context,
                            link['title'],
                            link['icon'],
                            link['section'],
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Divider(color: Colors.white54),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SocialIconsRow(
                    includePdfExport: onPdfExport != null,
                    onPdfExport: onPdfExport,
                  ),
                ),
              ],
            ),
          );
  }
}
