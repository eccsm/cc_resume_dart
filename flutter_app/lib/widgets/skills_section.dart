import 'package:flutter/material.dart';
import 'package:cc_resume_app/models/resume.dart';
import '../theme/app_theme.dart';
import 'section_card.dart';

class SkillsSection extends StatelessWidget {

  const SkillsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Map<String, Color> categoryColors = {
      'Programming Languages': isDark ? const Color(0xFF5B8DEF) : const Color(0xFF3B7DDD),
      'Frontend Technologies': isDark ? const Color(0xFF2DD4BF) : const Color(0xFF14B8A6),
      'Databases': isDark ? AppTheme.primaryColor : const Color(0xFFE88A1A),
      'Backend Technologies': isDark ? const Color(0xFFA78BFA) : const Color(0xFF8B5CF6),
      'Cloud & DevOps': isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
      'Machine Learning & LLMs': isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      'Version Control & Collaboration': isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
      'Testing & Quality Assurance': isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
      'Project & Issue Management': isDark ? const Color(0xFFEF4444) : const Color(0xFFB91C1C),
    };

    return SectionCard(
      title: "Skills",
      icon: Icons.code_rounded,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var categoryEntry in Resume.I.skills.entries)
            _buildCategorySection(
              context,
              categoryEntry.key,
              categoryEntry.value,
              categoryColors[categoryEntry.key] ?? Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context, String category, Map<String, List<String>> subcategories, Color color) {
    final colors = AppTheme.getColors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header with gradient underline
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  color.withAlpha(isDark ? 25 : 15),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: color, width: 3),
              ),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.text,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var subcategoryEntry in subcategories.entries)
                for (var skill in subcategoryEntry.value)
                  _SkillChip(skill: skill, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatefulWidget {
  final String skill;
  final Color color;
  const _SkillChip({required this.skill, required this.color});

  @override
  State<_SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<_SkillChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppTheme.getColors(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.color.withAlpha(isDark ? 50 : 30)
              : widget.color.withAlpha(isDark ? 20 : 12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? widget.color.withAlpha(isDark ? 120 : 80)
                : widget.color.withAlpha(isDark ? 50 : 35),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withAlpha(isDark ? 20 : 10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          widget.skill,
          style: TextStyle(
            fontSize: 12,
            color: _isHovered
                ? (isDark ? Colors.white : widget.color)
                : colors.text.withAlpha(220),
            fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}