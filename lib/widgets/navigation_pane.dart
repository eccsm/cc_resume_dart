// lib/widgets/navigation_pane.dart

import 'package:flutter/material.dart';
import 'profile_picture.dart';
import 'social_icons_row.dart';

class NavigationPane extends StatelessWidget {
  final bool isDrawer;
  final VoidCallback? onPdfExport;
  final Function(String)? onNavigate;
  final String activeSection;
  final List<Widget>? extraWidgets;

  const NavigationPane({
    super.key,
    this.isDrawer = false,
    this.onPdfExport,
    this.onNavigate,
    this.activeSection = '',
    this.extraWidgets,
  });

  Widget _buildNavLink(BuildContext context, String title, IconData icon, String section) {
    bool isActive = section == activeSection;
    
    // Use theme-aware colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    const Color activeColor = Colors.white;
    final Color inactiveColor = Colors.white.withOpacity(0.7);
    final Color hoverColor = isDark ? Colors.grey.shade800 : Colors.grey.shade700;
    final Color selectedColor = Colors.black.withOpacity(0.4);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? selectedColor : Colors.transparent,
        border: isActive 
            ? Border.all(color: Colors.grey.shade700, width: 1) 
            : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Icon(
          icon,
          color: isActive ? activeColor : inactiveColor,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? activeColor : inactiveColor,
            fontSize: 15,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            inherit: true,
          ),
        ),
        onTap: () {
          if (isDrawer && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          if (onNavigate != null) {
            onNavigate!(section);
          }
        },
        hoverColor: hoverColor,
        selectedTileColor: selectedColor,
        selected: isActive,
        dense: true,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
        trailing: isActive 
            ? Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ) 
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Get appropriate colors based on the current theme
    final backgroundColor1 = isDark ? Colors.grey.shade900 : Colors.grey.shade800;
    final backgroundColor2 = isDark ? Colors.black : Colors.grey.shade900;
    final dividerColor = isDark ? Colors.grey.shade700 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade700;
    
    final List<Map<String, dynamic>> navLinks = [
      {'title': 'About', 'icon': Icons.person_outline, 'section': 'professional_summary'},
      {'title': 'Skills Overview', 'icon': Icons.pie_chart, 'section': 'skills_overview'},
      {'title': 'Professional Journey', 'icon': Icons.timeline, 'section': 'experience'},
      {'title': 'Technical Skills', 'icon': Icons.code, 'section': 'skills'},
      {'title': 'Certifications', 'icon': Icons.workspace_premium, 'section': 'certifications'},
      {'title': 'Languages', 'icon': Icons.language, 'section': 'languages'},
      {'title': 'Education', 'icon': Icons.school_outlined, 'section': 'education'},
      {'title': 'Online Presence', 'icon': Icons.public, 'section': 'online_presence'},
    ];

    Widget contentWidget = Column(
      children: [
        const SizedBox(height: 40),
        
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const ProfilePicture(),
        ),
        
        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const Text(
                'Ekincan Casim',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Software Developer',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                dividerColor,
                Colors.transparent,
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
        
        // Extra widgets (e.g., Theme Toggle)
        if (extraWidgets != null && extraWidgets!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              children: extraWidgets!,
            ),
          ),
        
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border(
              top: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              
              const SizedBox(height: 8),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SocialIconsRow(
                  includePdfExport: onPdfExport != null,
                  onPdfExport: onPdfExport,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return isDrawer
        ? Drawer(
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor1,
                    backgroundColor2,
                  ],
                ),
              ),
              child: contentWidget,
            ),
          )
        : Container(
            width: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor1,
                  backgroundColor2,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
              border: Border(
                right: BorderSide(
                  color: borderColor,
                  width: 1,
                ),
              ),
            ),
            child: contentWidget,
          );
  }
}