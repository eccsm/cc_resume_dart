/**
 * Single source of truth for all site content.
 * Converted from the Flutter app's lib/pdf/resume_constants.dart.
 *
 * NOTE: this repo is public - never add a phone number or other PII here.
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

export const canonicalOrigin = 'https://casim.net';
export const homepageCaseStudiesHref = '/#case-studies';

export interface ExperienceEntry {
  company: string;
  role: string;
  location: string;
  /** ISO date (YYYY-MM) for <time datetime> and JSON-LD. */
  start: string;
  /** ISO date (YYYY-MM), or null while the role is current. */
  end: string | null;
  /** Human-readable range, e.g. "Jul 2025 - Present". */
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
  summary: string;
  challenge: string;
  approach: string[];
  outcome: string;
  stack: string[];
  seoTitle?: string;
  seoDescription?: string;
}

export interface CaseStudyRouteChange {
  fromSlug: string;
  toSlug: string | null;
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
    'Track record of leading legacy-to-modern transformations (monolith -> ' +
    'microservices, Oracle ADF -> Spring Boot 3.x), designing event-driven ' +
    'architectures on Kafka, and embedding regulatory compliance (data ' +
    'protection, auditability) into system design. Hands-on leader: architect ' +
    'who still writes production code, mentors engineers, and drives decisions ' +
    'through design reviews. Expert in Java 21, Spring Boot 3.x, domain-driven ' +
    'design, and cloud-native delivery on Kubernetes.',
  tagline:
    'Enterprise platforms in insurance, banking, and retail - Java 21, Spring Boot 3.x, Kafka, Kubernetes.',
};

export const experiences: ExperienceEntry[] = [
  {
    company: 'Medisa',
    role: 'Software Architect & Lead Engineer',
    location: 'Istanbul, Turkey',
    start: '2025-07',
    end: null,
    periodLabel: 'Jul 2025 - Present',
    points: [
      'Architect and hands-on lead for an enterprise insurance platform built on Java 17/21 and Spring Boot 3.x, serving core policy and claims operations.',
      'Decomposed overloaded insurance domains into bounded contexts and independent microservices using domain-driven design, improving deployability and team ownership.',
      'Designed event-driven policy issuance and claims flows on Kafka with Redis caching, improving real-time notification throughput.',
      'Implemented data-protection compliance (KVKK) at the architecture level - response-layer masking, data classification, and audit trails - in collaboration with legal and security stakeholders.',
      'Built high-volume batch processing pipelines (hundreds of thousands of records) with proper transaction isolation, chunking, and index optimization.',
      'Established engineering standards: microservice templates, SonarQube quality gates, and code review practices, cutting onboarding time and technical debt.',
      'Migrated observability from ELK to Graylog and operate Dynatrace-based monitoring; investigate and resolve production incidents.',
      'Manage Rancher-orchestrated Kubernetes deployments with Jenkins CI/CD, reducing release cycle duration.',
    ],
    tags: ['Java 17/21', 'Spring Boot 3', 'Kafka', 'Kubernetes', 'DDD', 'Graylog', 'Dynatrace'],
  },
  {
    company: 'NTT DATA Business Solutions',
    role: 'Business Applications Foundation Lead',
    location: 'Istanbul, Turkey',
    start: '2022-08',
    end: '2025-07',
    periodLabel: 'Aug 2022 - Jul 2025',
    points: [
      "Architect of record for Allianz's core system transformation from legacy Oracle ADF to Spring Boot 3.x, improving performance, maintainability, and scalability.",
      'Designed the Allianz Architectural Framework - a reusable enterprise architecture blueprint adopted across multiple teams as the standard development pattern.',
      'Built a GenAI-powered HR chatbot for Pegasus Airlines: Spring Boot microservices with Redis-based intelligent caching, rate limiting, and token-cost optimization for production LLM usage.',
      'Delivered microservices across multiple client engagements (Java 17, Spring Boot, Kafka, Angular); oversaw PostgreSQL and MongoDB implementations.',
      'Introduced CI/CD practices with Jenkins and GitLab pipelines, accelerating delivery cycles across teams.',
    ],
    tags: ['Java 17', 'Spring Boot', 'GenAI', 'Redis', 'Kafka', 'Allianz'],
  },
  {
    company: 'Yapi Kredi Teknoloji',
    role: 'External Software Consultant',
    location: 'Istanbul, Turkey',
    start: '2021-03',
    end: '2022-08',
    periodLabel: 'Mar 2021 - Aug 2022',
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
    periodLabel: 'Jan 2018 - Mar 2021',
    points: [
      'Led a development team delivering retail self-checkout (CHEC) and real-time monitoring (REMS) applications on Java and Spring.',
      'Managed implementations for global clients across France, Morocco, India, Singapore, and Korea, coordinating with distributed teams.',
      'Directed technology migrations including Java 11 and PostgreSQL upgrades, improving reliability.',
    ],
    tags: ['Java', 'Spring', 'PostgreSQL', 'Global rollouts'],
  },
  {
    company: 'Smartiks & BAYPM',
    role: 'Software Developer - Earlier Roles',
    location: 'Istanbul, Turkey',
    start: '2015-09',
    end: '2018-01',
    periodLabel: 'Sep 2015 - Jan 2018',
    points: [
      'Developed Python forecasting libraries for a TUBITAK-supported Big Data project; optimized MS SQL and Elasticsearch workloads (Smartiks).',
      'Delivered enterprise workflow applications (e-contract management, supplier portals) on Java and low-code platforms (BAYPM).',
    ],
    tags: ['Python', 'MS SQL', 'Elasticsearch', 'OutSystems', 'Java'],
  },
];

export const caseStudies: CaseStudy[] = validateCaseStudies([
  {
    slug: 'allianz-core-transformation',
    title: 'Allianz core system transformation',
    client: 'Allianz',
    employer: 'NTT DATA Business Solutions',
    summary:
      "Modernizing Allianz's core insurance stack from Oracle ADF to Spring Boot 3.x and packaging the resulting patterns into a reusable architectural framework.",
    challenge:
      'A legacy Oracle ADF core insurance system had become slow to change and hard to scale, and every team was solving the same architectural problems independently.',
    approach: [
      'Served as architect of record for the migration from Oracle ADF to Spring Boot 3.x, replacing the monolithic presentation-and-logic coupling with layered, testable services.',
      'Designed the Allianz Architectural Framework - a reusable enterprise blueprint covering project structure, cross-cutting concerns, and integration patterns.',
      'Drove adoption through design reviews and reference implementations rather than mandates.',
    ],
    outcome:
      'The framework was adopted across multiple teams as the standard development pattern, and the modernized stack improved performance, maintainability, and scalability of core systems.',
    stack: ['Java 17', 'Spring Boot 3.x', 'Oracle ADF (legacy)', 'Kafka', 'PostgreSQL'],
    seoDescription:
      "How Allianz's core insurance platform moved from Oracle ADF to Spring Boot 3.x, with a reusable architecture framework for multiple delivery teams.",
  },
  {
    slug: 'insurance-ddd-kafka',
    title: 'Insurance platform modernization with DDD and Kafka',
    client: 'Medisa',
    employer: 'Medisa',
    summary:
      'Breaking a policy-and-claims platform into bounded contexts and Kafka-driven flows while baking KVKK compliance into the architecture.',
    challenge:
      'An enterprise insurance platform with overloaded domains: policy, claims, and notification logic tangled together, slowing releases and blurring team ownership - all under KVKK data-protection obligations.',
    approach: [
      'Decomposed the domain into bounded contexts and independent microservices using domain-driven design.',
      'Designed event-driven policy issuance and claims flows on Kafka with Redis caching for real-time notifications.',
      'Embedded compliance into the architecture itself: response-layer masking, data classification, and audit trails designed with legal and security stakeholders.',
      'Built high-volume batch pipelines (hundreds of thousands of records) with transaction isolation, chunking, and index optimization.',
    ],
    outcome:
      'Improved deployability and team ownership, higher notification throughput, and KVKK compliance enforced by design rather than by convention - plus shorter release cycles via Rancher-orchestrated Kubernetes and Jenkins CI/CD.',
    stack: ['Java 21', 'Spring Boot 3.x', 'Kafka', 'Redis', 'Kubernetes', 'Graylog', 'Dynatrace'],
    seoDescription:
      'A case study in decomposing an insurance platform with domain-driven design, Kafka event flows, and architecture-level KVKK compliance.',
  },
  {
    slug: 'genai-hr-chatbot',
    title: 'GenAI-powered HR chatbot for Pegasus Airlines',
    client: 'Pegasus Airlines',
    employer: 'NTT DATA Business Solutions',
    summary:
      'Building a production HR chatbot with caching, rate limiting, and cost controls around real-world LLM usage.',
    challenge:
      'HR needed a conversational assistant for employees, but naive LLM integration would have meant unpredictable API costs and no protection against traffic spikes.',
    approach: [
      'Built the chatbot as Spring Boot microservices with a clean boundary between conversation logic and the LLM provider.',
      'Implemented Redis-based intelligent caching so repeated questions never hit the LLM twice.',
      'Added rate limiting and token-cost optimization strategies tuned for production LLM usage.',
    ],
    outcome:
      "A production GenAI service with controlled, predictable API costs and stable behavior under load - one of the earliest LLM systems shipped to production in the company's portfolio.",
    stack: ['Java 17', 'Spring Boot', 'GenAI APIs', 'Redis', 'Rate limiting'],
    seoDescription:
      'How a production HR chatbot for Pegasus Airlines balanced Spring Boot microservices, Redis caching, rate limiting, and predictable LLM cost control.',
  },
  {
    slug: 'harmoni-modernization',
    title: 'Harmoni insurance framework re-architecture',
    client: 'Yapi Kredi',
    employer: 'Yapi Kredi Teknoloji',
    summary:
      'Re-architecting a Java 6/JSP/Oracle insurance framework into modular, Spring Boot-ready components for a regulated banking environment.',
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
    seoDescription:
      'A case study in re-architecting the Harmoni insurance framework from Java 6 and JSP into modular Spring Boot-ready services for a regulated bank.',
  },
]);

export const caseStudyRouteChanges: CaseStudyRouteChange[] = validateCaseStudyRouteChanges(
  caseStudies,
  []
);

export function validateCaseStudies(records: CaseStudy[]): CaseStudy[] {
  const seen = new Set<string>();

  for (const record of records) {
    if (!record.slug.trim()) {
      throw new Error('Case studies must have a non-empty slug.');
    }
    if (seen.has(record.slug)) {
      throw new Error(`Duplicate case study slug: ${record.slug}`);
    }
    seen.add(record.slug);

    const requiredFields = [
      ['title', record.title],
      ['client', record.client],
      ['employer', record.employer],
      ['summary', record.summary],
      ['challenge', record.challenge],
      ['outcome', record.outcome],
    ] as const;

    for (const [field, value] of requiredFields) {
      if (!value.trim()) {
        throw new Error(`Case study "${record.slug}" is missing ${field}.`);
      }
    }

    if (record.approach.length === 0) {
      throw new Error(`Case study "${record.slug}" must have at least one approach item.`);
    }
    if (record.stack.length === 0) {
      throw new Error(`Case study "${record.slug}" must have at least one technology.`);
    }
  }

  return records;
}

export function validateCaseStudyRouteChanges(
  records: CaseStudy[],
  changes: CaseStudyRouteChange[]
): CaseStudyRouteChange[] {
  const activeSlugs = new Set(records.map((record) => record.slug));
  const seen = new Set<string>();

  for (const change of changes) {
    if (!change.fromSlug.trim()) {
      throw new Error('Legacy case study routes must have a non-empty fromSlug.');
    }
    if (seen.has(change.fromSlug)) {
      throw new Error(`Duplicate legacy case study route: ${change.fromSlug}`);
    }
    if (activeSlugs.has(change.fromSlug)) {
      throw new Error(`Legacy case study route conflicts with active slug: ${change.fromSlug}`);
    }
    seen.add(change.fromSlug);

    if (change.toSlug !== null) {
      if (!change.toSlug.trim()) {
        throw new Error(
          `Legacy case study route "${change.fromSlug}" must use null or a non-empty toSlug.`
        );
      }
      if (change.toSlug === change.fromSlug) {
        throw new Error(`Legacy case study route "${change.fromSlug}" cannot redirect to itself.`);
      }
      if (!activeSlugs.has(change.toSlug)) {
        throw new Error(
          `Legacy case study route "${change.fromSlug}" points to unknown slug: ${change.toSlug}`
        );
      }
    }
  }

  return changes;
}

export function getCaseStudyPath(caseStudyOrSlug: CaseStudy | string): string {
  const slug = typeof caseStudyOrSlug === 'string' ? caseStudyOrSlug : caseStudyOrSlug.slug;
  return `/case-studies/${slug}/`;
}

export function getCaseStudyCanonicalUrl(caseStudyOrSlug: CaseStudy | string): string {
  return new URL(getCaseStudyPath(caseStudyOrSlug), canonicalOrigin).toString();
}

export function getLegacyCaseStudyPath(routeChangeOrSlug: CaseStudyRouteChange | string): string {
  const slug =
    typeof routeChangeOrSlug === 'string' ? routeChangeOrSlug : routeChangeOrSlug.fromSlug;
  return getCaseStudyPath(slug);
}

export function getLegacyCaseStudyCanonicalUrl(
  routeChangeOrSlug: CaseStudyRouteChange | string
): string {
  return new URL(getLegacyCaseStudyPath(routeChangeOrSlug), canonicalOrigin).toString();
}

export function getCaseStudySeoTitle(caseStudy: CaseStudy): string {
  return caseStudy.seoTitle ?? `${caseStudy.title} | ${profile.name}`;
}

export function getCaseStudySeoDescription(caseStudy: CaseStudy): string {
  return caseStudy.seoDescription ?? caseStudy.summary;
}

export function getCaseStudyContext(caseStudy: CaseStudy): string {
  return `${caseStudy.client} · via ${caseStudy.employer}`;
}

export function getCaseStudyExperience(caseStudy: CaseStudy): ExperienceEntry | undefined {
  return experiences.find((experience) => experience.company === caseStudy.employer);
}

export function getCaseStudyPeriodLabel(caseStudy: CaseStudy): string | null {
  return getCaseStudyExperience(caseStudy)?.periodLabel ?? null;
}

export function getCaseStudyBySlug(slug: string): CaseStudy | undefined {
  return caseStudies.find((caseStudy) => caseStudy.slug === slug);
}

export function getCaseStudyPages(records: CaseStudy[] = caseStudies) {
  validateCaseStudies(records);
  return records.map((caseStudy, index) => ({
    caseStudy,
    previous: index > 0 ? records[index - 1] : null,
    next: index < records.length - 1 ? records[index + 1] : null,
  }));
}

export const skills: SkillCategory[] = [
  {
    category: 'Languages',
    groups: [
      { name: 'Programming', items: ['Java (11-21)', 'Kotlin', 'Python', 'JavaScript/TypeScript', 'SQL'] },
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
    institution: 'Dogus University',
    degree: "Master's Degree in Engineering and Technology Management",
    location: 'Istanbul, Turkey',
    start: '2017-09',
    end: '2019-06',
    periodLabel: 'Sep 2017 - Jun 2019',
  },
  {
    institution: 'Maltepe University',
    degree: "Bachelor's Degree in Computer Engineering",
    location: 'Istanbul, Turkey',
    start: '2011-09',
    end: '2015-06',
    periodLabel: 'Sep 2011 - Jun 2015',
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
  { language: 'English', level: 'Fluent - Maltepe University Proficiency Exam 80/100' },
];

// Phone number is intentionally absent - public repo (see repo policy).
export const contact: Contact = {
  email: 'ekincan@casim.net',
  linkedin: 'https://www.linkedin.com/in/eccsm',
  github: 'https://github.com/eccsm',
  huggingface: 'https://huggingface.co/eccsm',
  website: canonicalOrigin,
};

/** Self-assessed depth per area (0-10) for the Flutter radar chart. */
export const skillLevels: { name: string; value: number }[] = [
  { name: 'Java / Spring Boot', value: 9.5 },
  { name: 'Cloud & DevOps', value: 8.5 },
  { name: 'System Architecture', value: 8.5 },
  { name: 'Databases', value: 8.0 },
  { name: 'Event-Driven (Kafka)', value: 8.0 },
  { name: 'Frontend (React/Angular)', value: 6.5 },
  { name: 'ML / LLM Integration', value: 6.5 },
];

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
