/**
 * Single source of truth for all site content.
 * Converted from the Flutter app's lib/pdf/resume_constants.dart.
 *
 * NOTE: this repo is public — never add a phone number or other PII here.
 */

export interface Profile {
  name: string;
  title: string;
  location: string;
  /** One-paragraph professional summary shown in the hero. */
  intro: string;
  /** Short tagline for meta descriptions and the og-image. */
  tagline: string;
}

export interface ExperienceEntry {
  company: string;
  role: string;
  location: string;
  /** ISO date (YYYY-MM) for <time datetime> and JSON-LD. */
  start: string;
  /** ISO date (YYYY-MM), or null while the role is current. */
  end: string | null;
  /** Human-readable range, e.g. "Jul 2025 – Present". */
  periodLabel: string;
  points: string[];
  tags: string[];
}

export interface CaseStudy {
  slug: string;
  title: string;
  client: string;
  /** Where this work happened, matching an ExperienceEntry company. */
  employer: string;
  challenge: string;
  approach: string[];
  outcome: string;
  stack: string[];
}

export interface SkillCategory {
  category: string;
  groups: { name: string; items: string[] }[];
}

export interface EducationEntry {
  institution: string;
  degree: string;
  location: string;
  start: string;
  end: string;
  periodLabel: string;
}

export interface Certification {
  name: string;
  issuer: string;
  year: number;
  url: string;
}

export interface Contact {
  email: string;
  linkedin: string;
  github: string;
  huggingface: string;
  website: string;
}

export const profile: Profile = {
  name: 'Ekincan Casim',
  title: 'Software Architect & Senior Java Engineer',
  location: 'Istanbul, Turkey',
  intro:
    'Software Architect and Senior Java Engineer with 10+ years designing and ' +
    'delivering enterprise-scale platforms in insurance, banking, and retail. ' +
    'Track record of leading legacy-to-modern transformations (monolith → ' +
    'microservices, Oracle ADF → Spring Boot 3.x), designing event-driven ' +
    'architectures on Kafka, and embedding regulatory compliance (data ' +
    'protection, auditability) into system design. Hands-on leader: architect ' +
    'who still writes production code, mentors engineers, and drives decisions ' +
    'through design reviews. Expert in Java 21, Spring Boot 3.x, domain-driven ' +
    'design, and cloud-native delivery on Kubernetes.',
  tagline:
    'Enterprise platforms in insurance, banking, and retail — Java 21, Spring Boot 3.x, Kafka, Kubernetes.',
};

export const experiences: ExperienceEntry[] = [
  {
    company: 'Medisa',
    role: 'Software Architect & Lead Engineer',
    location: 'Istanbul, Turkey',
    start: '2025-07',
    end: null,
    periodLabel: 'Jul 2025 – Present',
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
    tags: ['Java 17/21', 'Spring Boot 3', 'Kafka', 'Kubernetes', 'DDD', 'Graylog', 'Dynatrace'],
  },
  {
    company: 'NTT DATA Business Solutions',
    role: 'Expert / Solution Architect',
    location: 'Istanbul, Turkey',
    start: '2022-08',
    end: '2025-07',
    periodLabel: 'Aug 2022 – Jul 2025',
    points: [
      "Architect of record for Allianz's core system transformation from legacy Oracle ADF to Spring Boot 3.x, improving performance, maintainability, and scalability.",
      'Designed the Allianz Architectural Framework — a reusable enterprise architecture blueprint adopted across multiple teams as the standard development pattern.',
      'Built a GenAI-powered HR chatbot for Pegasus Airlines: Spring Boot microservices with Redis-based intelligent caching, rate limiting, and token-cost optimization for production LLM usage.',
      'Delivered microservices across multiple client engagements (Java 17, Spring Boot, Kafka, Angular); oversaw PostgreSQL and MongoDB implementations.',
      'Introduced CI/CD practices with Jenkins and GitLab pipelines, accelerating delivery cycles across teams.',
    ],
    tags: ['Java 17', 'Spring Boot', 'GenAI', 'Redis', 'Kafka', 'Allianz'],
  },
  {
    company: 'Yapı Kredi Teknoloji',
    role: 'External Software Consultant',
    location: 'Istanbul, Turkey',
    start: '2021-03',
    end: '2022-08',
    periodLabel: 'Mar 2021 – Aug 2022',
    points: [
      "Re-architected the Harmoni insurance framework (Java 6/JSP/Oracle) at one of Turkey's largest banks into modular, microservice-ready components.",
      'Migrated the backend to Java 8 + Spring Boot, replaced JSP frontends with React, and tuned Oracle database performance in a regulated financial environment.',
      'Worked in Agile delivery cycles with code reviews and continuous integration.',
    ],
    tags: ['Java 8', 'Spring Boot', 'React', 'Oracle', 'Microservices'],
  },
  {
    company: 'Toshiba Global Commerce Solutions',
    role: 'Software Developer & Technical Team Leader',
    location: 'Istanbul, Turkey',
    start: '2018-01',
    end: '2021-03',
    periodLabel: 'Jan 2018 – Mar 2021',
    points: [
      'Led a development team delivering retail self-checkout (CHEC) and real-time monitoring (REMS) applications on Java and Spring.',
      'Managed implementations for global clients across France, Morocco, India, Singapore, and Korea, coordinating with distributed teams.',
      'Directed technology migrations including Java 11 and PostgreSQL upgrades, improving reliability.',
    ],
    tags: ['Java', 'Spring', 'PostgreSQL', 'Global rollouts'],
  },
  {
    company: 'Smartiks & BAYPM',
    role: 'Software Developer — Earlier Roles',
    location: 'Istanbul, Turkey',
    start: '2015-09',
    end: '2018-01',
    periodLabel: 'Sep 2015 – Jan 2018',
    points: [
      'Developed Python forecasting libraries for a TÜBİTAK-supported Big Data project; optimized MS SQL and Elasticsearch workloads (Smartiks).',
      'Delivered enterprise workflow applications (e-contract management, supplier portals) on Java and low-code platforms (BAYPM).',
    ],
    tags: ['Python', 'MS SQL', 'Elasticsearch', 'OutSystems', 'Java'],
  },
];

export const caseStudies: CaseStudy[] = [
  {
    slug: 'allianz-core-transformation',
    title: 'Allianz core system transformation',
    client: 'Allianz',
    employer: 'NTT DATA Business Solutions',
    challenge:
      'A legacy Oracle ADF core insurance system had become slow to change and hard to scale, and every team was solving the same architectural problems independently.',
    approach: [
      'Served as architect of record for the migration from Oracle ADF to Spring Boot 3.x, replacing the monolithic presentation-and-logic coupling with layered, testable services.',
      'Designed the Allianz Architectural Framework — a reusable enterprise blueprint covering project structure, cross-cutting concerns, and integration patterns.',
      'Drove adoption through design reviews and reference implementations rather than mandates.',
    ],
    outcome:
      'The framework was adopted across multiple teams as the standard development pattern, and the modernized stack improved performance, maintainability, and scalability of core systems.',
    stack: ['Java 17', 'Spring Boot 3.x', 'Oracle ADF (legacy)', 'Kafka', 'PostgreSQL'],
  },
  {
    slug: 'medisa-insurance-platform',
    title: 'Insurance platform modernization with DDD and Kafka',
    client: 'Medisa',
    employer: 'Medisa',
    challenge:
      'An enterprise insurance platform with overloaded domains: policy, claims, and notification logic tangled together, slowing releases and blurring team ownership — all under KVKK data-protection obligations.',
    approach: [
      'Decomposed the domain into bounded contexts and independent microservices using domain-driven design.',
      'Designed event-driven policy issuance and claims flows on Kafka with Redis caching for real-time notifications.',
      'Embedded compliance into the architecture itself: response-layer masking, data classification, and audit trails designed with legal and security stakeholders.',
      'Built high-volume batch pipelines (hundreds of thousands of records) with transaction isolation, chunking, and index optimization.',
    ],
    outcome:
      'Improved deployability and team ownership, higher notification throughput, and KVKK compliance enforced by design rather than by convention — plus shorter release cycles via Rancher-orchestrated Kubernetes and Jenkins CI/CD.',
    stack: ['Java 21', 'Spring Boot 3.x', 'Kafka', 'Redis', 'Kubernetes', 'Graylog', 'Dynatrace'],
  },
  {
    slug: 'pegasus-genai-chatbot',
    title: 'GenAI-powered HR chatbot for Pegasus Airlines',
    client: 'Pegasus Airlines',
    employer: 'NTT DATA Business Solutions',
    challenge:
      'HR needed a conversational assistant for employees, but naive LLM integration would have meant unpredictable API costs and no protection against traffic spikes.',
    approach: [
      'Built the chatbot as Spring Boot microservices with a clean boundary between conversation logic and the LLM provider.',
      'Implemented Redis-based intelligent caching so repeated questions never hit the LLM twice.',
      'Added rate limiting and token-cost optimization strategies tuned for production LLM usage.',
    ],
    outcome:
      'A production GenAI service with controlled, predictable API costs and stable behavior under load — one of the earliest LLM systems shipped to production in the company\'s portfolio.',
    stack: ['Java 17', 'Spring Boot', 'GenAI APIs', 'Redis', 'Rate limiting'],
  },
  {
    slug: 'harmoni-banking-modernization',
    title: 'Harmoni insurance framework re-architecture',
    client: 'Yapı Kredi',
    employer: 'Yapı Kredi Teknoloji',
    challenge:
      "A Java 6/JSP/Oracle insurance framework at one of Turkey's largest banks had reached the end of its maintainable life, inside a heavily regulated financial environment.",
    approach: [
      'Analyzed and modularized the monolith into microservice-ready components.',
      'Migrated the backend to Java 8 + Spring Boot and replaced JSP frontends with React.',
      'Tuned Oracle database performance and worked in Agile cycles with code reviews and CI.',
    ],
    outcome:
      'A modular, testable codebase ready for incremental microservice extraction, delivered without disrupting a regulated production banking environment.',
    stack: ['Java 8', 'Spring Boot', 'React', 'Oracle'],
  },
];

export const skills: SkillCategory[] = [
  {
    category: 'Languages',
    groups: [
      { name: 'Programming', items: ['Java (11–21)', 'Kotlin', 'Python', 'JavaScript/TypeScript', 'SQL'] },
    ],
  },
  {
    category: 'Backend & Architecture',
    groups: [
      { name: 'Frameworks', items: ['Spring Boot 3.x', 'Spring Cloud'] },
      { name: 'Architecture', items: ['Microservices', 'Domain-Driven Design', 'Event-Driven Architecture'] },
      { name: 'APIs & Messaging', items: ['REST', 'GraphQL', 'gRPC', 'Kafka', 'RabbitMQ', 'Redis'] },
    ],
  },
  {
    category: 'Data',
    groups: [
      { name: 'Databases', items: ['Oracle', 'PostgreSQL', 'MS SQL', 'MongoDB', 'Elasticsearch'] },
      { name: 'Performance', items: ['JPA/Hibernate tuning', 'Batch processing at scale'] },
    ],
  },
  {
    category: 'Cloud & DevOps',
    groups: [
      { name: 'Containers & Orchestration', items: ['Kubernetes', 'Docker', 'Helm', 'Rancher'] },
      { name: 'Platforms', items: ['Azure', 'AWS', 'GCP'] },
      { name: 'CI/CD & IaC', items: ['Jenkins', 'GitLab CI/CD', 'GitHub Actions', 'Terraform'] },
    ],
  },
  {
    category: 'Quality & Observability',
    groups: [
      { name: 'Testing', items: ['TDD', 'JUnit', 'JMeter', 'Gatling'] },
      { name: 'Quality Gates & Monitoring', items: ['SonarQube', 'Dynatrace', 'Graylog', 'ELK'] },
    ],
  },
  {
    category: 'Frontend (working knowledge)',
    groups: [{ name: 'Frameworks', items: ['React', 'Angular'] }],
  },
  {
    category: 'Practices',
    groups: [
      {
        name: 'Ways of Working',
        items: [
          'Agile/Scrum',
          'Technical mentorship',
          'RFC-driven design reviews',
          'Compliance-aware engineering (KVKK/GDPR)',
        ],
      },
    ],
  },
];

export const education: EducationEntry[] = [
  {
    institution: 'Doğuş University',
    degree: "Master's Degree in Engineering and Technology Management",
    location: 'Istanbul, Turkey',
    start: '2017-09',
    end: '2019-06',
    periodLabel: 'Sep 2017 – Jun 2019',
  },
  {
    institution: 'Maltepe University',
    degree: "Bachelor's Degree in Computer Engineering",
    location: 'Istanbul, Turkey',
    start: '2011-09',
    end: '2015-06',
    periodLabel: 'Sep 2011 – Jun 2015',
  },
];

export const certifications: Certification[] = [
  {
    name: 'Cplace Certified Procode Developer',
    issuer: 'Cplace',
    year: 2023,
    url: 'https://www.cplace.com/en/academy/pro-code-training/',
  },
  {
    name: 'OutSystems ODC Associate Developer',
    issuer: 'OutSystems',
    year: 2016,
    url: 'https://www.outsystems.com/certifications/academy-certifications/odc-developer',
  },
];

export const languages: { language: string; level: string }[] = [
  { language: 'Turkish', level: 'Native' },
  { language: 'English', level: 'Fluent — Maltepe University Proficiency Exam 80/100' },
];

// Phone number is intentionally absent — public repo (see repo policy).
export const contact: Contact = {
  email: 'ekincan@casim.net',
  linkedin: 'https://www.linkedin.com/in/eccsm',
  github: 'https://github.com/eccsm',
  huggingface: 'https://huggingface.co/eccsm',
  website: 'https://casim.net',
};

/** Flat skill list for JSON-LD knowsAbout and the og-image. */
export const knowsAbout: string[] = [
  'Java',
  'Spring Boot',
  'Software Architecture',
  'Domain-Driven Design',
  'Event-Driven Architecture',
  'Apache Kafka',
  'Microservices',
  'Kubernetes',
  'PostgreSQL',
  'Oracle Database',
  'Redis',
  'CI/CD',
  'GenAI / LLM Integration',
];
