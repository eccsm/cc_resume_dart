// lib/widgets/skills_section.dart

import 'package:flutter/material.dart';
import 'package:cc_resume_app/resume_constants.dart';
import 'section_card.dart';

class SkillsSection extends StatelessWidget {
  final bool animate;

  const SkillsSection({
    super.key,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors for different skill categories
    final Map<String, Color> categoryColors = {
      'Programming Languages': Colors.blue.shade700,
      'Frontend Technologies': Colors.teal.shade600,
      'Databases': const Color(0xFFFBAD48),
      'Backend Technologies': Colors.purple.shade600,
      'Cloud & DevOps': Colors.deepPurple.shade300,
      'Machine Learning & LLMs': Colors.yellow.shade400,
      'Version Control & Collaboration': Colors.green.shade200,
      'Testing & Quality Assurance': Colors.red.shade200,
      'Project & Issue Management': Colors.red.shade700
    };
    
    return SectionCard(
      title: "Skills",
      icon: Icons.code,
      animate: animate,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var categoryEntry in ResumeConstants.skills.entries)
            _buildCategorySection(
              categoryEntry.key, 
              categoryEntry.value, 
              categoryColors[categoryEntry.key] ?? Colors.red
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, Map<String, List<String>> subcategories, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              border: Border(left: BorderSide(color: color, width: 4)),
            ),
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var subcategoryEntry in subcategories.entries)
                for (var skill in subcategoryEntry.value)
                  _buildSkillChip(skill, color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill, Color color) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          skill,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}