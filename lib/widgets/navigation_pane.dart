// lib/widgets/navigation_pane.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'profile_picture.dart';
import 'social_icons_row.dart';

class NavigationPane extends StatelessWidget {
  final bool isDrawer;
  final VoidCallback? onPdfExport;
  final Function(String)? onNavigate;
  final String activeSection;

  const NavigationPane({
    super.key,
    this.isDrawer = false,
    this.onPdfExport,
    this.onNavigate,
    this.activeSection = '',
  });

  Widget _buildNavLink(BuildContext context, String title, IconData icon, String section) {
    bool isActive = section == activeSection;
    
    const activeColor = Colors.white;
    final inactiveColor = Colors.white.withOpacity(0.7);
    final hoverColor = Colors.grey.shade800;
    final selectedColor = Colors.black.withOpacity(0.4);
    
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
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ) 
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navLinks = [
      {'title': 'About', 'icon': Icons.person_outline, 'section': 'professional_summary'},
      {'title': 'Experience', 'icon': Icons.work_outline, 'section': 'experience'},
      {'title': 'Skills', 'icon': Icons.code, 'section': 'skills'},
      {'title': 'Education', 'icon': Icons.school_outlined, 'section': 'education'},
      {'title': 'Projects', 'icon': FontAwesomeIcons.github, 'section': 'github_repos'},
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
                Colors.grey.shade600,
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
        
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade800,
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
                    Colors.grey.shade900,
                    Colors.black,
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
                  Colors.grey.shade900,
                  Colors.black,
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
                  color: Colors.grey.shade800,
                  width: 1,
                ),
              ),
            ),
            child: contentWidget,
          );
  }
}