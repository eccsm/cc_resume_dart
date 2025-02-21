// lib/widgets/skills_section.dart

import 'package:flutter/material.dart';
import 'package:cc_resume_app/resume_constants.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...ResumeConstants.skills.entries.map((categoryEntry) {
          final category = categoryEntry.key;
          final subcategories = categoryEntry.value;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                ...subcategories.entries.map((subEntry) {
                  final subcategory = subEntry.key;
                  final skills = subEntry.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subcategory,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: skills.map((skill) {
                            return Chip(
                              label: Text(skill),
                              backgroundColor: Colors.yellow.shade50.withOpacity(0.5),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }
}
