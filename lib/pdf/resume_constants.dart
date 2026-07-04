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

  // FIX: Replaced generic phrases with specific, impact-led sentences.
  // Mentions Allianz, Pegasus Airlines, and the insurance platform — real differentiators.
  // Updated "Java 17" → "Java 21" to match current stack.
  static const String profileIntro =
      'Software Architect and Senior Java Engineer with 10+ years building enterprise-scale platforms '
      'in insurance, banking, and aviation. Architect of record on an Allianz legacy '
      'transformation (Oracle ADF → Spring Boot 3.x) and a Kafka-backed microservices '
      'platform currently in production at Medisa. Delivered an OpenAI-powered HR chatbot '
      'for Pegasus Airlines with Redis-based intelligent caching and cost-optimized token '
      'management. Expert in Java 21, Spring Boot 3.x, event-driven architectures '
      '(Kafka, RabbitMQ), and cloud-native deployments on Kubernetes/AWS. Focused on '
      'measurable outcomes: performance, observability, and eliminating technical debt '
      'at enterprise scale.';

  // =========================
  // Skills
  // =========================
  // NOTE: SkillsSection reads this map correctly via ResumeConstants.skills.entries.
  // The structured subcategory format here is already better than the flat PDF list.
  static const Map<String, Map<String, List<String>>> skills = {
    'Programming Languages': {
      'Core Languages': ['Java', 'Kotlin', 'Python', 'JavaScript'],
      'Scripting & Automation': ['Bash', 'Groovy'],
      'Low-Code & Automation': ['OutSystems', 'cplacejs'],
    },
    'Backend Technologies': {
      'Frameworks': ['Spring Boot', 'Spring Cloud', 'Quarkus', 'Micronaut'],
      'API Development': ['REST', 'GraphQL', 'gRPC'],
      'Integration Tools': ['Apache Kafka', 'RabbitMQ'],
    },
    'Databases': {
      'RDBMS': ['PostgreSQL', 'MS SQL', 'Oracle', 'MySQL'],
      'NoSQL': ['MongoDB', 'Cassandra', 'DynamoDB'],
      'Search & Cache': ['Elasticsearch', 'Redis'],
    },
    'Frontend Technologies': {
      'Frameworks & Libraries': ['Angular', 'React'],
      'Core Tools': ['TypeScript'],
      'UI/UX Libraries': ['Material-UI', 'Bootstrap'],
    },
    'Cloud & DevOps': {
      'Platforms': ['Microsoft Azure', 'Google Cloud Platform (GCP)', 'AWS'],
      'Containerization & Orchestration': ['Docker', 'Kubernetes', 'Helm', 'Rancher', 'OpenShift'],
      'CI/CD Tools': ['Jenkins', 'GitHub Actions', 'GitLab CI/CD', 'Bamboo'],
      'Infrastructure as Code': ['Terraform', 'Ansible'],
      'Observability': ['Dynatrace', 'ELK Stack'],
    },
    'Machine Learning & LLMs': {
      'LLM & NLP': ['OpenAI APIs', 'Hugging Face Transformers'],
      'Optimization': ['ONNX'],
      'ML Frameworks': ['Scikit-Learn'],
    },
    'Version Control & Collaboration': {
      'Tools': ['Git', 'GitHub', 'Bitbucket', 'GitLab'],
      'Project Management': ['JIRA', 'Confluence'],
    },
    'Testing & Quality Assurance': {
      'Automation Tools': ['Selenium', 'JUnit', 'TestNG', 'Postman'],
      'Performance Testing': ['Apache JMeter', 'Gatling'],
      'Static Analysis': ['SonarQube', 'ESLint', 'Checkstyle'],
    },
    'Project & Issue Management': {
      'Agile Tools': ['JIRA', 'Confluence', 'Trello', 'Asana'],
      'Build Tools': ['Maven', 'Gradle', 'Bazel'],
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
        'Architecting and leading hands-on development of Java 17 microservices with Spring Boot 3.x for an enterprise insurance platform.',
        'Decomposed overloaded insurance domains into bounded microservices, reducing inter-service coupling and improving independent deployability.',
        'Designed event-driven policy issuance and claims handling flows using Kafka and Redis, improving real-time notification throughput.',
        'Modernized Medisa\'s insurance systems into a microservices architecture integrated with React-based frontends.',
        'Introduced standardized microservice templates, automated quality gates (SonarQube), and coding conventions — cutting developer onboarding time.',
        'Migrated observability stack from ELK to Graylog, improving log aggregation performance and centralized monitoring.',
        'Managed Rancher-orchestrated container deployments with Jenkins CI/CD pipelines, reducing release cycle duration.',
        'Collaborating with frontend teams using React to deliver integrated, customer-facing insurance solutions.',
      ],
      notableProjects: [
        'Insurance Domain Decomposition: Identified and extracted overloaded bounded contexts into independent microservices, improving scalability and team ownership boundaries.',
        'Insurance Microservices Platform: Modernized Medisa\'s core insurance systems into Spring Boot 3.x microservices with React-based frontends, replacing a legacy monolith.',
        'Graylog Migration: Replaced ELK Stack with Graylog for centralized log management, improving query performance and operational visibility.',
        'Event-Driven Communication: Designed Kafka-backed event streams with Redis caching layers for policy issuance, claims handling, and real-time customer notifications.',
        'Agile CI/CD Transformation: Integrated Jenkins pipelines and Rancher container deployments, reducing release cycles and improving deployment reliability.',
        'Boilerplate Hardening: Automated quality gates and microservice templates, cutting onboarding time and reducing technical debt.',
      ],
    ),

    Experience(
      title: 'NTT DATA Business Solutions',
      role: 'Expert / Solution Architect',
      location: 'Istanbul, Turkey',
      period: 'Aug 2022 – Jul 2025',
      points: [
        'Architect for Allianz: Led enterprise system transformation from legacy Oracle ADF to Spring Boot 3.x, significantly improving performance, maintainability, and scalability.',
        'Designed and implemented the Allianz Architectural Framework — a scalable, reusable enterprise architecture blueprint adopted across multiple teams.',
        'Built OpenAI-powered HR chatbot for Pegasus Airlines with intelligent Redis caching, minute-based rate limiting, and token-efficient prompt design to minimize API costs.',
        'Delivered chatbot backend integration using Java 17, Spring Boot 3.x, Kafka, and RESTful APIs for seamless HR system interoperability.',
        'Developed and optimized microservices using Angular and Spring Boot across multiple client engagements.',
        'Oversaw PostgreSQL and MongoDB implementations ensuring high data reliability and operational efficiency.',
        'Introduced CI/CD practices with Jenkins and GitLab pipelines, accelerating delivery cycles across teams.',
      ],
      notableProjects: [
        'Oracle ADF → Spring Boot Transformation (Allianz): Modernized Allianz\'s core insurance systems, eliminating legacy Oracle ADF dependencies and significantly improving agility.',
        'Allianz Architectural Framework: Designed a scalable enterprise architecture blueprint that standardized development patterns across the Allianz engagement.',
        'Pegasus Airlines HR Chatbot: Integrated OpenAI APIs into HR workflows with Redis-based caching, rate limit management, and Spring Boot microservices for cost-effective AI-driven employee support.',
        'cplace (Collaboration Factory AG, Germany): Contributed to a project and collaboration management platform for ZF Hungary.',
      ],
    ),

    Experience(
      title: 'Yapı Kredi Teknoloji',
      role: 'External Software Consultant',
      location: 'Istanbul, Turkey',
      period: 'Mar 2021 – Aug 2022',
      points: [
        'Analyzed and re-architected the Harmoni insurance framework (Java 6, JSP, Oracle) into modular components, preparing for microservices migration.',
        'Migrated backend to Java 8 with Spring Boot, replaced JSP with React for modern frontends, and optimized Oracle DB performance.',
        'Transformed legacy monolithic Java applications into microservices-based solutions, improving scalability and maintainability.',
        'Collaborated in Agile development cycles: sprint planning, code reviews, and continuous integration processes.',
      ],
      notableProjects: [
        'Legacy Assessment & Modernization: Analyzed Harmoni insurance framework (Java 6/JSP/Oracle) and re-architected into modular microservice-ready components.',
        'Technology Uplift & Delivery: Migrated backend to Java 8 + Spring Boot, replaced JSP with React, optimized Oracle DB, and enabled Agile delivery with CI/CD pipelines.',
      ],
    ),

    Experience(
      title: 'Toshiba Global Commerce Solutions',
      role: 'Software Developer & Technical Team Leader',
      location: 'Istanbul, Turkey',
      period: 'Jan 2018 – Mar 2021',
      points: [
        'Led development of retail-focused applications using Java, XML, and Spring Framework.',
        'Managed global project implementations across France, Morocco, India, Singapore, and Korea.',
        'Directed technology stack migrations including upgrades to Java 11 and PostgreSQL, improving system reliability.',
      ],
      notableProjects: [
        'CHEC: Self-checkout application enabling seamless retail customer experiences.',
        'REMS: Retail monitoring system for real-time self-checkout tracking.',
      ],
    ),

    Experience(
      title: 'Smartiks',
      role: 'Software Developer',
      location: 'Istanbul, Turkey',
      period: 'Mar 2017 – Jan 2018',
      points: [
        'Contributed to TÜBİTAK\'s Smartcast Forecasting Project by developing Python-based forecasting libraries leveraging Big Data.',
        'Optimized databases with MS SQL and Elasticsearch to boost performance and scalability.',
      ],
      notableProjects: [
        'Smartcast Forecasting Project: TÜBİTAK-supported initiative using Big Data and Python forecasting libraries for precise prediction models.',
        'CMS for Derimod and Yurtiçi Kargo: Enhanced content management solutions streamlining content operations.',
      ],
    ),

    Experience(
      title: 'BAYPM',
      role: 'Software Developer',
      location: 'Istanbul, Turkey',
      period: 'Sep 2015 – Mar 2017',
      points: [
        'Certified OutSystems Developer: Delivered internal business applications using OutSystems for rapid development.',
        'Developed Canvas applications powered by Java Core and T-SQL for enterprise workflows.',
        'Delivered solutions across transportation and supplier management domains.',
      ],
      notableProjects: [
        'eContractHub: E-contract management system using OutSystems, Java Core, and T-SQL to digitize legal processes.',
        'Supplier Management Portal: Collaboration platform integrating Spring MVC and OutSystems for supplier workflow management.',
      ],
    ),

    Experience(
      title: 'KARDEMİR A.Ş.',
      role: 'Software Engineering Intern',
      location: 'Karabük, Turkey',
      period: 'Jun 2014 – Sep 2014',
      points: [
        'Developed C# and .NET applications within an industrial environment for Turkey\'s largest iron and steel facility.',
        'Worked with MS SQL to support large-scale operational data flows.',
      ],
      notableProjects: [
        'Transaction Pipeline Simulation: Virtual simulation model optimizing cash transaction handling and workflow accuracy.',
        'Prototype Production Workflow Tool: C#/.NET prototype integrated with MS SQL to support shop-floor production processes.',
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
  static const String contactPhone = '+90 532 055 1566';
  static const String contactLinkedIn = 'https://www.linkedin.com/in/eccsm';
  static const String contactGitHub = 'https://github.com/eccsm';
  static const String contactWebsite = 'https://ekincan.casim.net';

  // =========================
  // Languages
  // =========================
  // FIX: TOEFL score added — 115/120 is excellent and directly answers
  // the English proficiency question European employers have for non-EU candidates.
  static const String languages =
      'Turkish (Native), English (Fluent — Proficiency 80/100)';

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
      'certification': 'Proficiency 80/100',
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