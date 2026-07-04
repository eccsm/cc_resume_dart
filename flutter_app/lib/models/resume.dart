/// Typed models for /data/resume.json — the single source of truth emitted
/// from site/src/data/resume.ts. No resume content is hardcoded here or
/// anywhere else in the Flutter app.
library;

class ResumeExperience {
  final String company;
  final String role;
  final String location;
  final String start;
  final String? end;
  final String periodLabel;
  final List<String> points;
  final List<String> tags;

  const ResumeExperience({
    required this.company,
    required this.role,
    required this.location,
    required this.start,
    required this.end,
    required this.periodLabel,
    required this.points,
    required this.tags,
  });

  factory ResumeExperience.fromJson(Map<String, dynamic> json) =>
      ResumeExperience(
        company: json['company'] as String,
        role: json['role'] as String,
        location: json['location'] as String,
        start: json['start'] as String,
        end: json['end'] as String?,
        periodLabel: json['periodLabel'] as String,
        points: (json['points'] as List).cast<String>(),
        tags: (json['tags'] as List).cast<String>(),
      );
}

class EducationEntry {
  final String institution;
  final String degree;
  final String location;
  final String periodLabel;

  const EducationEntry({
    required this.institution,
    required this.degree,
    required this.location,
    required this.periodLabel,
  });

  factory EducationEntry.fromJson(Map<String, dynamic> json) => EducationEntry(
        institution: json['institution'] as String,
        degree: json['degree'] as String,
        location: json['location'] as String,
        periodLabel: json['periodLabel'] as String,
      );
}

class Certification {
  final String name;
  final String issuer;
  final int year;
  final String url;

  const Certification({
    required this.name,
    required this.issuer,
    required this.year,
    required this.url,
  });

  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
        name: json['name'] as String,
        issuer: json['issuer'] as String,
        year: (json['year'] as num).toInt(),
        url: json['url'] as String,
      );
}

class LanguageEntry {
  final String language;
  final String level;

  const LanguageEntry({required this.language, required this.level});

  factory LanguageEntry.fromJson(Map<String, dynamic> json) => LanguageEntry(
        language: json['language'] as String,
        level: json['level'] as String,
      );
}

class SkillLevel {
  final String name;
  final double value;

  const SkillLevel({required this.name, required this.value});

  factory SkillLevel.fromJson(Map<String, dynamic> json) => SkillLevel(
        name: json['name'] as String,
        value: (json['value'] as num).toDouble(),
      );
}

class Resume {
  final String name;
  final String title;
  final String location;
  final String profileIntro;
  final String tagline;
  final List<ResumeExperience> experiences;

  /// Category -> group -> items, matching the shape SkillsSection renders.
  final Map<String, Map<String, List<String>>> skills;
  final List<SkillLevel> skillLevels;
  final List<EducationEntry> education;
  final List<Certification> certifications;
  final List<LanguageEntry> languageEntries;
  final String contactEmail;
  final String contactLinkedIn;
  final String contactGitHub;
  final String contactHuggingFace;
  final String contactWebsite;

  /// Phone is never part of resume.json (public repo) — inject at build time
  /// with --dart-define=RESUME_PHONE=... ; the PDF omits it when empty.
  static const String contactPhone = String.fromEnvironment('RESUME_PHONE');

  const Resume({
    required this.name,
    required this.title,
    required this.location,
    required this.profileIntro,
    required this.tagline,
    required this.experiences,
    required this.skills,
    required this.skillLevels,
    required this.education,
    required this.certifications,
    required this.languageEntries,
    required this.contactEmail,
    required this.contactLinkedIn,
    required this.contactGitHub,
    required this.contactHuggingFace,
    required this.contactWebsite,
  });

  static Resume? _current;

  /// The loaded resume. Only safe after ResumeRepository.load() completes —
  /// the app gates all content UI behind that future.
  static Resume get I {
    final r = _current;
    assert(r != null, 'Resume accessed before ResumeRepository.load()');
    return r!;
  }

  static set current(Resume value) => _current = value;

  factory Resume.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>;
    final contact = json['contact'] as Map<String, dynamic>;

    final skills = <String, Map<String, List<String>>>{};
    for (final category in (json['skills'] as List)) {
      final cat = category as Map<String, dynamic>;
      final groups = <String, List<String>>{};
      for (final group in (cat['groups'] as List)) {
        final g = group as Map<String, dynamic>;
        groups[g['name'] as String] = (g['items'] as List).cast<String>();
      }
      skills[cat['category'] as String] = groups;
    }

    return Resume(
      name: profile['name'] as String,
      title: profile['title'] as String,
      location: profile['location'] as String,
      profileIntro: profile['intro'] as String,
      tagline: profile['tagline'] as String,
      experiences: (json['experiences'] as List)
          .map((e) => ResumeExperience.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: skills,
      skillLevels: (json['skillLevels'] as List)
          .map((e) => SkillLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
      education: (json['education'] as List)
          .map((e) => EducationEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      certifications: (json['certifications'] as List)
          .map((e) => Certification.fromJson(e as Map<String, dynamic>))
          .toList(),
      languageEntries: (json['languages'] as List)
          .map((e) => LanguageEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      contactEmail: contact['email'] as String,
      contactLinkedIn: contact['linkedin'] as String,
      contactGitHub: contact['github'] as String,
      contactHuggingFace: contact['huggingface'] as String,
      contactWebsite: contact['website'] as String,
    );
  }

  /// "Turkish (Native), English (Fluent — ...)" — one line for PDF/chat.
  String get languages =>
      languageEntries.map((l) => '${l.language} (${l.level})').join(', ');

  /// Multi-line education summary in the layout the About/PDF sections use.
  String get educationSummary => education
      .map((e) => '${e.institution}, ${e.location} | ${e.periodLabel}\n'
          '${e.degree}')
      .join('\n\n');

  /// One line per certification for the chat prompt.
  String get certificates => certifications
      .map((c) => '${c.name} — ${c.year} (${c.issuer})')
      .join('\n');
}
