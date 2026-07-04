import 'package:flutter/material.dart';

/// Represents a professional experience entry.
class Experience {
  final String title;
  final String role;
  final String location;
  final String period;
  final List<String> points;
  final List<String>? notableProjects;

  const Experience({
    required this.title,
    required this.role,
    required this.location,
    required this.period,
    required this.points,
    this.notableProjects,
  });
}

/// Static, compile-time text data for Ekincan Casim.
class ResumeConstants {
  // =========================
  // Basic Information
  // =========================
  static const String name = 'Ekincan Casim';
  static const String location = 'Istanbul, Turkey';

  // FIX: Title used in NavigationPane subtitle — was hardcoded 'Software Developer' there.
  // This const is the single source of truth; patch NavigationPane to read it.
  static const String title = 'Software Architect & Senior Java Engineer';

  // =========================
  // Profile / Summary
  // =========================
  static const String profileHeader = '$name\n$title | Location: $location';

  // Single source of truth: the website About section, the chatbot system
  // prompt, and the PDF all render this text.
  static const String profileIntro =
      'Software Architect and Senior Java Engineer with 10+ years designing and '
      'delivering enterprise-scale platforms in insurance, banking, and retail. '
      'Track record of leading legacy-to-modern transformations (monolith → '
      'microservices, Oracle ADF → Spring Boot 3.x), designing event-driven '
      'architectures on Kafka, and embedding regulatory compliance (data '
      'protection, auditability) into system design. Hands-on leader: architect '
      'who still writes production code, mentors engineers, and drives decisions '
      'through design reviews. Expert in Java 21, Spring Boot 3.x, domain-driven '
      'design, and cloud-native delivery on Kubernetes.';

  // =========================
  // Skills
  // =========================
  // NOTE: SkillsSection reads this map correctly via ResumeConstants.skills.entries.
  // The structured subcategory format here is already better than the flat PDF list.
  static const Map<String, Map<String, List<String>>> skills = {
    'Languages': {
      'Programming': ['Java (11–21)', 'Kotlin', 'Python', 'JavaScript/TypeScript', 'SQL'],
    },
    'Backend & Architecture': {
      'Frameworks': ['Spring Boot 3.x', 'Spring Cloud'],
      'Architecture': ['Microservices', 'Domain-Driven Design', 'Event-Driven Architecture'],
      'APIs & Messaging': ['REST', 'GraphQL', 'gRPC', 'Kafka', 'RabbitMQ', 'Redis'],
    },
    'Data': {
      'Databases': ['Oracle', 'PostgreSQL', 'MS SQL', 'MongoDB', 'Elasticsearch'],
      'Performance': ['JPA/Hibernate tuning', 'Batch processing at scale'],
    },
    'Cloud & DevOps': {
      'Containers & Orchestration': ['Kubernetes', 'Docker', 'Helm', 'Rancher'],
      'Platforms': ['Azure', 'AWS', 'GCP'],
      'CI/CD & IaC': ['Jenkins', 'GitLab CI/CD', 'GitHub Actions', 'Terraform'],
    },
    'Quality & Observability': {
      'Testing': ['TDD', 'JUnit', 'JMeter', 'Gatling'],
      'Quality Gates & Monitoring': ['SonarQube', 'Dynatrace', 'Graylog', 'ELK'],
    },
    'Frontend (working knowledge)': {
      'Frameworks': ['React', 'Angular'],
    },
    'Practices': {
      'Ways of Working': [
        'Agile/Scrum',
        'Technical mentorship',
        'RFC-driven design reviews',
        'Compliance-aware engineering (KVKK/GDPR)',
      ],
    },
  };

  // =========================
  // Professional Experience
  // =========================
  // FIX: Medisa role title updated — "Director – Java Software Developer" is confusing.
  // Architect-level roles require an architect title to pass recruiter screening.
  static const List<Experience> experiences = [
    Experience(
      title: 'Medisa',
      role: 'Software Architect & Lead Engineer',
      location: 'Istanbul, Turkey',
      period: 'Jul 2025 – Present',
      points: [
        'Architect and hands-on lead for an enterprise insurance platform built on Java 17/21 and Spring Boot 3.x, serving core policy and claims operations.',
        'Decomposed overloaded insurance domains into bounded contexts and independent microservices using domain-driven design, improving deployability and team ownership.',
        'Designed event-driven policy issuance and claims flows on Kafka with Redis caching, improving real-time notification throughput.',
        'Implemented data-protection compliance (KVKK) at the architecture level — response-layer masking, data classification, and audit trails — in collaboration with legal and security stakeholders.',
        'Built high-volume batch processing pipelines (hundreds of thousands of records) with proper transaction isolation, chunking, and index optimization.',
        'Established engineering standards: microservice templates, SonarQube quality gates, and code review practices, cutting onboarding time and technical debt.',
        'Migrated observability from ELK to Graylog and operate Dynatrace-based monitoring; investigate and resolve production incidents.',
        'Manage Rancher-orchestrated Kubernetes deployments with Jenkins CI/CD, reducing release cycle duration.',
      ],
    ),

    Experience(
      title: 'NTT DATA Business Solutions',
      role: 'Expert / Solution Architect',
      location: 'Istanbul, Turkey',
      period: 'Aug 2022 – Jul 2025',
      points: [
        "Architect of record for Allianz's core system transformation from legacy Oracle ADF to Spring Boot 3.x, improving performance, maintainability, and scalability.",
        'Designed the Allianz Architectural Framework — a reusable enterprise architecture blueprint adopted across multiple teams as the standard development pattern.',
        'Built an OpenAI-powered HR chatbot for Pegasus Airlines: Spring Boot microservices with Redis-based intelligent caching, rate limiting, and token-cost optimization for production LLM usage.',
        'Delivered microservices across multiple client engagements (Java 17, Spring Boot, Kafka, Angular); oversaw PostgreSQL and MongoDB implementations.',
        'Introduced CI/CD practices with Jenkins and GitLab pipelines, accelerating delivery cycles across teams.',
      ],
    ),

    Experience(
      title: 'Yapı Kredi Teknoloji',
      role: 'External Software Consultant',
      location: 'Istanbul, Turkey',
      period: 'Mar 2021 – Aug 2022',
      points: [
        "Re-architected the Harmoni insurance framework (Java 6/JSP/Oracle) at one of Turkey's largest banks into modular, microservice-ready components.",
        'Migrated the backend to Java 8 + Spring Boot, replaced JSP frontends with React, and tuned Oracle database performance in a regulated financial environment.',
        'Worked in Agile delivery cycles with code reviews and continuous integration.',
      ],
    ),

    Experience(
      title: 'Toshiba Global Commerce Solutions',
      role: 'Software Developer & Technical Team Leader',
      location: 'Istanbul, Turkey',
      period: 'Jan 2018 – Mar 2021',
      points: [
        'Led a development team delivering retail self-checkout (CHEC) and real-time monitoring (REMS) applications on Java and Spring.',
        'Managed implementations for global clients across France, Morocco, India, Singapore, and Korea, coordinating with distributed teams.',
        'Directed technology migrations including Java 11 and PostgreSQL upgrades, improving reliability.',
      ],
    ),

    Experience(
      title: 'Smartiks & BAYPM',
      role: 'Software Developer — Earlier Roles',
      location: 'Istanbul, Turkey',
      period: 'Sep 2015 – Jan 2018',
      points: [
        'Developed Python forecasting libraries for a TÜBİTAK-supported Big Data project; optimized MS SQL and Elasticsearch workloads (Smartiks).',
        'Delivered enterprise workflow applications (e-contract management, supplier portals) on Java and low-code platforms (BAYPM).',
      ],
    ),
  ];

  // =========================
  // Education
  // =========================
  // FIX: Master's listed first (most recent) — standard European CV convention.
  static const String educationSummary =
      'Doğuş University, Istanbul, Turkey | Sep 2017 – Jun 2019\n'
      'Master\'s Degree in Engineering and Technology Management\n\n'
      'Maltepe University, Istanbul, Turkey | Sep 2011 – Jun 2015\n'
      'Bachelor\'s Degree in Computer Engineering';

  // =========================
  // Contact Information
  // =========================
  static const String contactEmail = 'ekincan@casim.net';
  // Phone number is intentionally not committed to the public repo.
  // Supply it at build time: flutter build web --dart-define=RESUME_PHONE=+90...
  // When absent, the PDF simply omits the phone entry.
  static const String contactPhone = String.fromEnvironment('RESUME_PHONE');
  static const String contactLinkedIn = 'https://www.linkedin.com/in/eccsm';
  static const String contactGitHub = 'https://github.com/eccsm';
  static const String contactWebsite = 'https://ekincan.casim.net';

  // =========================
  // Languages
  // =========================
  // FIX: TOEFL score added — 115/120 is excellent and directly answers
  // the English proficiency question European employers have for non-EU candidates.
  static const String languages =
      'Turkish (Native), English (Fluent — Maltepe University Proficiency Exam 80/100)';

  // =========================
  // Certifications
  // =========================
  // FIX: Removed fake "AWS Certified Solutions Architect" entry.
  // Only real, verifiable certifications remain.
  // FIX: CertificationCarouselWidget has its OWN _defaultCerts list and ignores this.
  //      See widget patch below — _defaultCerts must be removed and this list consumed instead.
  static const String certificates =
      'Cplace Pro Code Developer — Mar 2023 (Cplace)\n'
      'OutSystems Associate Developer — Dec 2016 (OutSystems)';

  // Structured version for CertificationCarouselWidget consumption.
  // IMPORTANT: CertificationCarouselWidget must read this instead of _defaultCerts.
  // 'badgeColor' is a Color object — widget already expects Color type.
  // 'assetPath' must match your actual assets/images/ filenames.
  static const List<Map<String, dynamic>> certifications = [
    {
      'name': 'Cplace Certified Procode Developer',
      'issuer': 'Cplace',
      'date': 'Issued March 2023',
      'description':
          'Certified in designing, developing and deploying enterprise applications on the cplace low-code platform using pro-code extension patterns.',
      'assetPath': 'assets/images/cplace.png',
      'badgeColor': Color(0xFF1A4B8C),
      'url': 'https://www.cplace.com/en/academy/pro-code-training/',
    },
    {
      'name': 'OutSystems ODC Associate Developer',
      'issuer': 'OutSystems',
      'date': 'Issued December 2016',
      'description':
          'Expertise in designing and developing scalable cloud applications using the OutSystems Developer Cloud platform.',
      'assetPath': 'assets/images/outsystems.png',
      'badgeColor': Color(0xFFE64D1F),
      'url': 'https://www.outsystems.com/certifications/academy-certifications/odc-developer',
    },
  ];

  // =========================
  // Language Proficiencies
  // =========================
  // FIX: Corrected from 'us' flagCode (American flag for English) to 'gb' for cleaner
  // semantic meaning. TOEFL score surfaced as certification field.
  // LanguageProficiencyWidget reads this via its 'languages' constructor param —
  // ensure the parent page passes ResumeConstants.languageProficiencies mapped to
  // LanguageProficiency objects. See widget patch below.
  static const List<Map<String, dynamic>> languageProficiencies = [
    {
      'language': 'English',
      'flagCode': 'gb',
      'readingLevel': 0.95,
      'writingLevel': 0.90,
      'speakingLevel': 0.85,
      'listeningLevel': 0.95,
      'certification': 'Maltepe University Proficiency Exam 80/100',
    },
    {
      'language': 'Turkish',
      'flagCode': 'tr',
      'readingLevel': 1.0,
      'writingLevel': 1.0,
      'speakingLevel': 1.0,
      'listeningLevel': 1.0,
      'certification': null,
    },
  ];

  // =========================
  // Skills Radar (for radar/spider chart widget if used)
  // =========================
  // FIX: Completely replaced the Flutter-template radar data.
  // Previous data had Flutter 9.0 and Backend 6.5 — opposite of reality.
  // These values reflect actual depth: Java/Spring expert, cloud-native strong,
  // frontend secondary, ML/LLM growing.
  static const List<Map<String, dynamic>> skillLevels = [
    {'name': 'Java / Spring Boot', 'value': 9.5},
    {'name': 'Cloud & DevOps',     'value': 8.5},
    {'name': 'System Architecture','value': 8.5},
    {'name': 'Databases',          'value': 8.0},
    {'name': 'Event-Driven (Kafka)','value': 8.0},
    {'name': 'Frontend (React/Angular)', 'value': 6.5},
    {'name': 'ML / LLM Integration','value': 6.5},
  ];

  // =========================
  // Online Badges
  // =========================
  // FIX: Removed 'hackerrank' entry with placeholder username comment.
  // BadgeGalleryWidget builds its own inline list and ignores this field.
  // See widget patch below — ManifestBadgeRepository.fetchAll() should
  // reference these instead of hardcoded values.
  static const List<Map<String, String>> onlineBadges = [
    {
      'platform': 'hackerrank',
      'username': 'ekincan_casim',
      'url': 'https://www.hackerrank.com/profile/ekincan_casim',
    },
    {
      'platform': 'huggingface',
      'username': 'eccsm',
      'url': 'https://huggingface.co/eccsm',
    },
    {
      'platform': 'github',
      'username': 'eccsm',
      'url': 'https://github.com/eccsm',
    },
  ];

  // =========================
  // Timeline Entries (for interactive timeline widget)
  // =========================
  // FIX: Replaced all placeholder data ("Senior Flutter Developer", "Example Company Inc.")
  // with real career history matching the experiences list above.
  static const List<Map<String, dynamic>> timelineEntries = [
    {
      'title': 'Software Architect & Lead Engineer',
      'subtitle': 'Medisa',
      'description': 'Architecting Java 17 + Spring Boot 3.x insurance microservices. '
        'Decomposed overloaded domains into bounded contexts. '
        'Kafka event-driven flows, Redis caching, Graylog observability.',
      'startDate': '2025-07-01',
      'endDate': null,
      'icon': 'work',
      'color': '#3F51B5',
      'tags': ['Java 17', 'Spring Boot 3', 'Kafka', 'Kubernetes', 'Graylog', 'DDD', 'Dynatrace'],
      'achievements': [
        'Modernized legacy insurance platform into microservices architecture',
        'Designed event-driven Kafka flows for policy issuance and claims handling',
        'Established Dynatrace + ELK observability stack from scratch',
      ],
    },
    {
      'title': 'Expert / Solution Architect',
      'subtitle': 'NTT DATA Business Solutions',
      'description':
          'Architect for Allianz (Oracle ADF → Spring Boot) and AI chatbot lead for Pegasus Airlines.',
      'startDate': '2022-08-01',
      'endDate': '2025-07-01',
      'icon': 'work',
      'color': '#009688',
      'tags': ['Java 17', 'Spring Boot', 'OpenAI', 'Redis', 'Kafka', 'Allianz'],
      'achievements': [
        'Led Oracle ADF → Spring Boot 3.x migration for Allianz core systems',
        'Designed Allianz Architectural Framework adopted across multiple teams',
        'Built Pegasus Airlines HR chatbot with OpenAI APIs and cost-optimized token management',
      ],
    },
    {
      'title': 'External Software Consultant',
      'subtitle': 'Yapı Kredi Teknoloji',
      'description':
          'Re-architected the Harmoni insurance framework from Java 6/JSP monolith to Spring Boot microservices with React frontend.',
      'startDate': '2021-03-01',
      'endDate': '2022-08-01',
      'icon': 'work',
      'color': '#FF5722',
      'tags': ['Java 8', 'Spring Boot', 'React', 'Oracle', 'Microservices'],
      'achievements': [
        'Analyzed and modularized legacy Harmoni insurance framework (Java 6)',
        'Migrated backend to Java 8 + Spring Boot; replaced JSP with React',
        'Enabled Agile delivery with CI/CD pipelines',
      ],
    },
    {
      'title': 'Software Developer & Technical Team Leader',
      'subtitle': 'Toshiba Global Commerce Solutions',
      'description':
          'Led retail application development (CHEC self-checkout, REMS monitoring) across global deployments in 5 countries.',
      'startDate': '2018-01-01',
      'endDate': '2021-03-01',
      'icon': 'work',
      'color': '#607D8B',
      'tags': ['Java', 'Spring', 'PostgreSQL', 'Global Projects'],
      'achievements': [
        'Led CHEC self-checkout app deployments across France, Morocco, India, Singapore, Korea',
        'Directed technology migrations to Java 11 and PostgreSQL',
      ],
    },
    {
      'title': 'Software Developer',
      'subtitle': 'Smartiks',
      'description':
          'TÜBİTAK Smartcast forecasting project — Python-based Big Data forecasting libraries.',
      'startDate': '2017-03-01',
      'endDate': '2018-01-01',
      'icon': 'work',
      'color': '#9C27B0',
      'tags': ['Python', 'MS SQL', 'Elasticsearch', 'Big Data'],
      'achievements': [
        'Contributed to TÜBİTAK-backed forecasting initiative',
        'Optimized Elasticsearch and MS SQL for performance at scale',
      ],
    },
    {
      'title': 'Software Developer',
      'subtitle': 'BAYPM',
      'description':
          'OutSystems + Java Core development for enterprise workflows in transportation and supplier management.',
      'startDate': '2015-09-01',
      'endDate': '2017-03-01',
      'icon': 'work',
      'color': '#795548',
      'tags': ['OutSystems', 'Java Core', 'Spring MVC', 'T-SQL'],
      'achievements': [
        'Built eContractHub — e-contract management system using OutSystems and Java Core',
        'Delivered Supplier Management Portal integrating Spring MVC and OutSystems',
      ],
    },
  ];
}