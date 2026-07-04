// lib/widgets/language_proficiency_widget.dart

import 'package:flutter/material.dart';

class LanguageProficiency {
  final String language;
  final String
      flagCode; // ISO 3166-1 alpha-2 code for flag (eg. 'us', 'gb', 'de', 'fr')
  final double readingLevel; // 0-1 scale
  final double writingLevel; // 0-1 scale
  final double speakingLevel; // 0-1 scale
  final double listeningLevel; // 0-1 scale
  final String? certification; // Optional language certification

  const LanguageProficiency({
    required this.language,
    required this.flagCode,
    required this.readingLevel,
    required this.writingLevel,
    required this.speakingLevel,
    required this.listeningLevel,
    this.certification,
  });

  double get overallLevel {
    return (readingLevel + writingLevel + speakingLevel + listeningLevel) / 4;
  }

  // Convert level to human-readable text
  String levelToText(double level) {
    if (level >= 0.95) return 'Native';
    if (level >= 0.85) return 'Fluent';
    if (level >= 0.7) return 'Advanced';
    if (level >= 0.5) return 'Intermediate';
    if (level >= 0.3) return 'Basic';
    return 'Beginner';
  }

  String get overallLevelText => levelToText(overallLevel);
}

class LanguageProficiencyWidget extends StatefulWidget {
  final List<LanguageProficiency> languages;
  final Color? accentColor;
  final bool showCertifications;

  const LanguageProficiencyWidget({
    super.key,
    required this.languages,
    this.accentColor,
    this.showCertifications = true,
  });

  @override
  State<LanguageProficiencyWidget> createState() =>
      _LanguageProficiencyWidgetState();
}

class _LanguageProficiencyWidgetState extends State<LanguageProficiencyWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor =
        widget.accentColor ?? Theme.of(context).primaryColor;
    final LanguageProficiency selectedLanguage =
        widget.languages[_selectedIndex];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final containerBackgroundColor =
        isDarkMode ? Colors.grey.shade900.withAlpha(225) : Colors.white;
    final tabBackgroundColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final tabBorderColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final barBackgroundColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final certBoxBackgroundColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;
    final subtitleColor =
        isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language Proficiency',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),

        // Language selection tabs
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.languages.length,
            itemBuilder: (context, index) {
              final language = widget.languages[index];
              final isSelected = index == _selectedIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? effectiveAccentColor.withAlpha(50)
                        : tabBackgroundColor,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected ? effectiveAccentColor : tabBorderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      _getFlagWidget(language.flagCode),
                      const SizedBox(width: 8),
                      Text(
                        language.language,
                        style: TextStyle(
                          color: textColor,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // Proficiency details for selected language
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: containerBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: effectiveAccentColor.withAlpha(75),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getFlagWidget(selectedLanguage.flagCode, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedLanguage.language,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: effectiveAccentColor.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          selectedLanguage.overallLevelText,
                          style: TextStyle(
                            fontSize: 12,
                            color: effectiveAccentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (selectedLanguage.certification != null &&
                      widget.showCertifications)
                    Tooltip(
                      message: selectedLanguage.certification!,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: certBoxBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              size: 16,
                              color: effectiveAccentColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Certified',
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Proficiency bars
              _buildProficiencyBar(
                'Reading',
                selectedLanguage.readingLevel,
                Icons.menu_book,
                effectiveAccentColor,
                barBackgroundColor,
                textColor,
                subtitleColor,
              ),
              const SizedBox(height: 16),
              _buildProficiencyBar(
                'Writing',
                selectedLanguage.writingLevel,
                Icons.edit,
                effectiveAccentColor,
                barBackgroundColor,
                textColor,
                subtitleColor,
              ),
              const SizedBox(height: 16),
              _buildProficiencyBar(
                'Speaking',
                selectedLanguage.speakingLevel,
                Icons.record_voice_over,
                effectiveAccentColor,
                barBackgroundColor,
                textColor,
                subtitleColor,
              ),
              const SizedBox(height: 16),
              _buildProficiencyBar(
                'Listening',
                selectedLanguage.listeningLevel,
                Icons.hearing,
                effectiveAccentColor,
                barBackgroundColor,
                textColor,
                subtitleColor,
              ),

              // Certification details if available
              if (selectedLanguage.certification != null &&
                  widget.showCertifications) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: certBoxBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: effectiveAccentColor.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.workspace_premium,
                          color: effectiveAccentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Certificate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedLanguage.certification!,
                              style: TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProficiencyBar(
    String title,
    double level,
    IconData icon,
    Color accentColor,
    Color barBackgroundColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final levelText = widget.languages[_selectedIndex].levelToText(level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Text(
              levelText,
              style: TextStyle(
                fontSize: 14,
                color: subtitleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: barBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: constraints.maxWidth * level,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor.withAlpha(175), accentColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withAlpha(75),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getFlagWidget(String countryCode, {double size = 20}) {
    final flagEmoji = _countryCodeToFlagEmoji(countryCode);
    return Text(
      flagEmoji,
      style: TextStyle(
        fontSize: size,
        height: 1,
      ),
    );
  }

  String _countryCodeToFlagEmoji(String countryCode) {
    final normalized = countryCode.trim().toUpperCase();
    if (normalized.length != 2) return '🏳';

    final first = normalized.codeUnitAt(0);
    final second = normalized.codeUnitAt(1);
    const regionalIndicatorOffset = 127397;

    return String.fromCharCode(first + regionalIndicatorOffset) +
        String.fromCharCode(second + regionalIndicatorOffset);
  }
}
