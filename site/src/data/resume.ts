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
export const homepageProjectsHref = '/#projects';

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

export type ProjectStatus = 'in-development' | 'experimental-learning';
export type ProjectDetailStatus = 'documented' | 'optional' | 'experimental' | 'planned';

export interface ProjectLink {
  label: string;
  url: string;
}

export interface ProjectModule {
  name: string;
  summary: string;
  status: ProjectDetailStatus;
}

export interface ProjectBullet {
  title: string;
  detail: string;
  status: ProjectDetailStatus;
}

export interface ProjectDecision {
  title: string;
  detail: string;
}

export interface Project {
  id: string;
  slug: string;
  name: string;
  tagline: string;
  supportingMessage?: string;
  shortSummary: string;
  status: ProjectStatus;
  statusLabel: string;
  statusNote: string;
  role: string;
  executiveSummary: string[];
  problem: string[];
  solution: string[];
  differentiators: string[];
  architecture: string[];
  keyDecisions: ProjectDecision[];
  tradeoffs: ProjectDecision[];
  modules: ProjectModule[];
  technologies: string[];
  privacyOrSecurityTitle?: string;
  privacyOrSecurity?: string[];
  currentCapabilities: ProjectBullet[];
  plannedCapabilities?: ProjectBullet[];
  repositoryLinks?: ProjectLink[];
  documentationLinks?: ProjectLink[];
  relatedCaseStudySlugs: string[];
  seoTitle?: string;
  seoDescription?: string;
  namingNote?: string;
}

export interface ProjectRouteChange {
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

export const projects: Project[] = validateProjects([
  {
    id: 'archmet',
    slug: 'archmet',
    name: 'Archmet',
    tagline: 'Deterministic Software Intelligence',
    supportingMessage: 'Measure architecture. Govern change.',
    shortSummary:
      'A deterministic-first architecture analysis platform that models multi-language codebases, scores architecture health, and keeps LLM commentary separate from verifiable findings.',
    status: 'in-development',
    statusLabel: 'In development',
    statusNote:
      'This portfolio summary is based on the supplied README material. A local Archmet source checkout was not available in this workspace, so component maturity is described conservatively.',
    role: 'Architecture analysis platform design, deterministic rule-engine direction, AI-optional product framing',
    executiveSummary: [
      'Archmet is designed to analyze software architecture rather than only code style. The documented core combines deterministic parsing, dependency graphs, shared metrics, and calibrated rules so the same source and configuration produce reproducible findings.',
      'Archimet is the optional interpretation layer on top. It can explain findings through a user-chosen LLM, but the evidence still comes from deterministic metrics, thresholds, and graph paths.',
    ],
    problem: [
      'Style linters and isolated static checks can miss architecture drift: coupling hotspots, god classes, dependency cycles, N+1 query patterns, and slow technical-debt accumulation across layers.',
      'The product direction in the supplied README focuses on making those structural issues measurable without replacing evidence with opaque AI output.',
    ],
    solution: [
      'The documented design normalizes Java, Kotlin, C#, Python, and TypeScript into one shared model, then evaluates that model with architecture-aware rules and calibrated thresholds.',
      'Framework detection, layer classification, and boilerplate awareness are meant to reduce false positives so findings stay useful in real codebases rather than in toy examples.',
    ],
    differentiators: [
      'Deterministic engine first, optional LLM second.',
      'One normalized language model instead of separate per-language reports.',
      'Evidence-backed findings with metrics, thresholds, and graph paths attached.',
      'Self-hosted-first deployment with BYO-LLM as an explicit choice rather than a requirement.',
    ],
    architecture: [
      'The supplied README describes a multi-language pipeline built around Eclipse JDT, Kotlin compiler PSI, Roslyn, Python ast, and SWC, all normalized into a shared class model and dependency graph.',
      'Metrics named in the source material include WMC, LCOM, CBO, RFC, fan-in/fan-out, and cyclomatic complexity, alongside detections such as god classes, coupling hotspots, circular dependencies, and N+1 query patterns.',
      'The platform surface is described as a scanner/CLI, CI templates and GitHub Action, a Spring Boot server, a Next.js dashboard, IDE plugins, chat integrations, and the optional Archimet layer.',
    ],
    keyDecisions: [
      {
        title: 'Deterministic findings before LLM commentary',
        detail:
          'The deterministic engine is the source of truth so reports remain reproducible, CI-friendly, and reviewable without trusting model output.',
      },
      {
        title: 'Unified multi-language model',
        detail:
          'Normalizing multiple ecosystems into one model enables cross-language scoring and governance instead of producing isolated parser-specific reports.',
      },
      {
        title: 'Optional graph and queue infrastructure',
        detail:
          'The README positions Neo4j and Kafka as optional so teams can keep a simpler deployment mode when they do not need graph exploration or queue-backed jobs.',
      },
      {
        title: 'Validate evidence before explanation',
        detail:
          'LLM recommendations are intended to stay grounded in already-validated metrics and paths rather than inventing unsupported remediation advice.',
      },
    ],
    tradeoffs: [
      {
        title: 'Higher implementation complexity than lint-only tooling',
        detail:
          'A calibrated, graph-aware, multi-language engine is more expensive to build and maintain than isolated rule packs, but it targets architecture problems that simpler tooling often misses.',
      },
      {
        title: 'Optional platform services add operational weight',
        detail:
          'Server, dashboard, graph storage, and queueing broaden the product surface, which creates more deployment choices and more system ownership overhead.',
      },
      {
        title: 'LLM value depends on evidence quality',
        detail:
          'Keeping the LLM layer optional protects determinism, but it also means the usefulness of natural-language guidance depends entirely on the fidelity of the underlying engine.',
      },
    ],
    modules: [
      {
        name: 'Scanner / CLI',
        summary:
          'Documented as the deterministic entry point for one-shot analysis and JSON reporting in local workflows or CI.',
        status: 'documented',
      },
      {
        name: 'CI templates and GitHub Action',
        summary:
          'Documented quality-gate templates for pull requests and architectural budget enforcement.',
        status: 'documented',
      },
      {
        name: 'Server REST API',
        summary:
          'Documented Spring Boot service for persisted reports, async analysis jobs, diffs, and webhooks.',
        status: 'documented',
      },
      {
        name: 'Dashboard',
        summary:
          'Documented Next.js interface for scores, dependency views, trends, and what-if analysis.',
        status: 'documented',
      },
      {
        name: 'IDE plugins',
        summary:
          'Documented editor integrations for inline diagnostics and local feedback loops, but not independently verified in this workspace.',
        status: 'documented',
      },
      {
        name: 'Chat integrations',
        summary:
          'Mentioned as Slack, Teams, and Zoom Team Chat integrations, with enterprise positioning called out in the README.',
        status: 'planned',
      },
      {
        name: 'Archimet optional LLM layer',
        summary:
          'Optional interpretation layer that turns deterministic findings into grounded refactoring guidance with a user-selected model.',
        status: 'optional',
      },
    ],
    technologies: [
      'Java',
      'Kotlin',
      'Gradle',
      'Eclipse JDT',
      'Kotlin compiler PSI',
      'Roslyn',
      'Python ast',
      'SWC',
      'Spring Boot',
      'PostgreSQL',
      'Redis',
      'Neo4j',
      'Kafka',
      'Next.js',
      'Docker',
      'Ollama',
      'llama.cpp',
      'OpenAI-compatible providers',
    ],
    privacyOrSecurityTitle: 'Privacy and deployment',
    privacyOrSecurity: [
      'The supplied README describes Archmet as self-hosted first: code stays on your infrastructure by default.',
      'Archimet is BYO-LLM, with local Ollama or llama.cpp support positioned as first-class options and cloud providers used only by explicit choice.',
      'Telemetry is described as anonymous and opt-in only; self-hosted deployments are documented as sending nothing by default.',
    ],
    currentCapabilities: [
      {
        title: 'Deterministic architecture analysis',
        detail:
          'The documented current scope centers on deterministic parsing, dependency graphs, and calibrated rules rather than AI-generated findings.',
        status: 'documented',
      },
      {
        title: 'Shared metrics and detections',
        detail:
          'The README names WMC, LCOM, CBO, RFC, fan-in/fan-out, cyclomatic complexity, god classes, coupling hotspots, circular dependencies, and N+1 query patterns.',
        status: 'documented',
      },
      {
        title: 'Framework and layer awareness',
        detail:
          'Layer classification, framework detection, and boilerplate awareness are part of the documented false-positive reduction strategy.',
        status: 'documented',
      },
      {
        title: 'Optional LLM interpretation',
        detail:
          'Archimet can explain deterministic findings with local or cloud-hosted models, but it is positioned as an overlay rather than the analysis engine.',
        status: 'optional',
      },
    ],
    plannedCapabilities: [
      {
        title: 'Enterprise governance surface',
        detail:
          'The README associates organization-wide trend governance, scaled PR automation, chat-bot integrations, and SSO with enterprise positioning rather than the minimal deterministic core.',
        status: 'planned',
      },
    ],
    relatedCaseStudySlugs: ['allianz-core-transformation', 'insurance-ddd-kafka'],
    seoTitle: 'Archmet - Deterministic Software Intelligence | Ekincan Casim',
    seoDescription:
      'Archmet is a deterministic-first software architecture analysis concept that models multi-language systems, measures architectural drift, and keeps LLM interpretation optional.',
    namingNote:
      'Archmet is the product name. Archimet is the optional LLM layer, and the original AMF codename remains in machine-facing identifiers for compatibility.',
  },
  {
    id: 'harmonova',
    slug: 'harmonova',
    name: 'Harmonova',
    tagline: 'Deterministic-first music theory and beat composition',
    shortSummary:
      'A learning-focused polyrepo that keeps music theory deterministic in pure Java, uses Spring AI and MCP for orchestration, and isolates audio analysis inside a separate Python service.',
    status: 'experimental-learning',
    statusLabel: 'Experimental learning project',
    statusNote:
      'This summary is based on the supplied Harmonova README. No local Harmonova source checkout was available in this workspace, so implementation maturity is stated with explicit status labels.',
    role: 'Spring AI experimentation, MCP boundary design, deterministic domain modeling, multi-service orchestration',
    executiveSummary: [
      'Harmonova combines a pure Java music-theory core with an MCP tool surface, a Spring Boot orchestration layer, RAG-backed agents, and a separate Python audio-analysis service.',
      'The central design principle is deterministic-first: musical facts and theory operations come from Java code, while LLMs handle natural-language interpretation and orchestration instead of replacing theory calculations.',
    ],
    problem: [
      'LLMs are helpful for conversational composition workflows, but they are unreliable for exact scale spelling, chord progressions, or deterministic beat-generation rules on their own.',
      'At the same time, audio, DSP, and ML workloads can quickly pollute an otherwise clean domain core unless their boundaries are enforced deliberately.',
    ],
    solution: [
      'The documented architecture keeps harmonova-core free of Spring, AI, and audio dependencies, then wraps deterministic operations through MCP tools and REST endpoints where appropriate.',
      'A Spring Boot web app orchestrates the tutor and beat-maker flows with RAG and provider routing, while a single thin HTTP boundary isolates Python-based audio analysis and ML.',
    ],
    differentiators: [
      'Deterministic work stays in the core; LLMs are reserved for natural language and orchestration.',
      'Dependencies point inward: web and MCP depend on core, but core depends on neither.',
      'Deterministic endpoints can bypass MCP and LLM layers when conversational orchestration is unnecessary.',
      'Audio bytes, DSP, and ML remain isolated in Python instead of leaking into the Java core.',
    ],
    architecture: [
      'The supplied README describes four repositories: harmonova-core, harmonova-mcp-server, harmonova, and harmonova-audio-analysis-service.',
      'The web app and MCP server both depend on harmonova-core, while the Python audio service sits outside that dependency graph and is reached only through a thin HTTP proxy.',
      'Agent flows are described as a fixed PLAN -> FACTS -> RAG -> COMPOSE -> VERIFY -> EMIT pipeline, with separate tutor and beat-maker agents and a lightweight router.',
    ],
    keyDecisions: [
      {
        title: 'Deterministic core versus probabilistic orchestration',
        detail:
          'Music theory, beat composition parameters, and fact verification remain in the pure Java core so the AI layer cannot invent exact musical facts.',
      },
      {
        title: 'MCP boundary instead of direct tool coupling',
        detail:
          'Tool definitions stay in the MCP server, which makes the domain core reusable without dragging web or AI concerns into it.',
      },
      {
        title: 'RAG grounding for conversational flows',
        detail:
          'The tutor and beat-maker flows are documented as grounding prompts in retrieved material rather than relying on unconstrained model generation.',
      },
      {
        title: 'Python ML isolation',
        detail:
          'Keeping audio analysis outside the Java core reduces domain pollution at the cost of another service boundary.',
      },
    ],
    tradeoffs: [
      {
        title: 'More moving parts than a single app',
        detail:
          'Polyrepo ownership, MCP transport, vector storage, and the Python service make the system more modular, but also more operationally involved.',
      },
      {
        title: 'Local-first options still require infrastructure',
        detail:
          'Ollama, pgvector, reranking, and observability can stay self-hosted, but that local-first posture still brings setup overhead that a simpler demo would avoid.',
      },
      {
        title: 'Deterministic boundaries limit shortcutting',
        detail:
          'The design deliberately prevents the LLM from becoming the source of musical truth, which improves correctness but can slow down rapid prototyping.',
      },
    ],
    modules: [
      {
        name: 'harmonova-core',
        summary:
          'Documented as the authoritative pure-Java theory and beat-generation engine, with no Spring, AI, or audio dependencies.',
        status: 'documented',
      },
      {
        name: 'harmonova-mcp-server',
        summary:
          'Documented MCP tool surface that wraps deterministic core operations for model-facing orchestration.',
        status: 'documented',
      },
      {
        name: 'harmonova',
        summary:
          'Documented Spring Boot web app for REST endpoints, agents, RAG, provider routing, and the frontend.',
        status: 'documented',
      },
      {
        name: 'harmonova-audio-analysis-service',
        summary:
          'Documented Python and FastAPI service for audio analysis, embeddings, and ML, treated as a scoped exception to the pure-core rule.',
        status: 'experimental',
      },
    ],
    technologies: [
      'Java',
      'Spring Boot',
      'Spring AI',
      'MCP',
      'Ollama',
      'PostgreSQL',
      'pgvector',
      'Infinity reranker',
      'Python',
      'FastAPI',
      'librosa',
      'PyTorch',
      'MERT',
      'OpenTelemetry',
      'Langfuse',
      'Prometheus',
      'Loki',
      'Grafana',
      'Docker Compose',
    ],
    privacyOrSecurityTitle: 'Local-first and boundary choices',
    privacyOrSecurity: [
      'The supplied README emphasizes local Ollama, local embeddings, and local reranking, but it does not claim every optional dependency always stays offline in every deployment mode.',
      'The architecture keeps audio bytes and ML workloads behind one HTTP boundary instead of distributing them across the rest of the Java system.',
      'BYOK model routing is documented for provider flexibility, while embeddings remain pinned to the local retrieval path described in the README.',
    ],
    currentCapabilities: [
      {
        title: 'Deterministic music theory in core',
        detail:
          'The documented core covers scales, chord progressions, seeded beat composition, melody analysis, and MIDI export without Spring or AI dependencies.',
        status: 'documented',
      },
      {
        title: 'Agent orchestration over deterministic facts',
        detail:
          'The tutor and beat-maker flows are documented as Spring AI agents that verify theory claims against deterministic tools and retrieved context.',
        status: 'documented',
      },
      {
        title: 'RAG with local retrieval components',
        detail:
          'PostgreSQL with pgvector, local bge-m3 embeddings, and optional reranking are part of the documented retrieval path.',
        status: 'optional',
      },
      {
        title: 'Isolated audio analysis service',
        detail:
          'The Python service is documented as the only place server-side audio bytes, DSP, and ML are allowed to live.',
        status: 'experimental',
      },
    ],
    plannedCapabilities: [
      {
        title: 'Stronger audio classification path',
        detail:
          'The README marks the current genre and mood analysis as heuristic-v1 and points to a richer v2 path instead of presenting it as complete.',
        status: 'planned',
      },
    ],
    repositoryLinks: [
      { label: 'harmonova-core repository', url: 'https://github.com/harmonova/core' },
      { label: 'harmonova-mcp-server repository', url: 'https://github.com/harmonova/mcp-server' },
      { label: 'harmonova web repository', url: 'https://github.com/harmonova/base' },
      {
        label: 'harmonova-audio-analysis-service repository',
        url: 'https://github.com/harmonova/audio-analysis',
      },
    ],
    relatedCaseStudySlugs: ['genai-hr-chatbot'],
    seoTitle: 'Harmonova - Deterministic Music AI Architecture | Ekincan Casim',
    seoDescription:
      'Harmonova is an experimental, deterministic-first music AI project that combines a pure Java theory core, Spring AI orchestration, MCP tools, and an isolated Python audio service.',
  },
]);

export const projectRouteChanges: ProjectRouteChange[] = validateProjectRouteChanges(projects, []);

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

export function validateProjects(records: Project[]): Project[] {
  const seen = new Set<string>();

  for (const record of records) {
    if (!record.slug.trim()) {
      throw new Error('Projects must have a non-empty slug.');
    }
    if (seen.has(record.slug)) {
      throw new Error(`Duplicate project slug: ${record.slug}`);
    }
    seen.add(record.slug);

    const requiredFields = [
      ['id', record.id],
      ['name', record.name],
      ['tagline', record.tagline],
      ['shortSummary', record.shortSummary],
      ['statusLabel', record.statusLabel],
      ['statusNote', record.statusNote],
      ['role', record.role],
    ] as const;

    for (const [field, value] of requiredFields) {
      if (!value.trim()) {
        throw new Error(`Project "${record.slug}" is missing ${field}.`);
      }
    }

    if (record.executiveSummary.length === 0) {
      throw new Error(`Project "${record.slug}" must have an executive summary.`);
    }
    if (record.problem.length === 0) {
      throw new Error(`Project "${record.slug}" must describe a problem.`);
    }
    if (record.solution.length === 0) {
      throw new Error(`Project "${record.slug}" must describe a solution.`);
    }
    if (record.modules.length === 0) {
      throw new Error(`Project "${record.slug}" must describe at least one module.`);
    }
    if (record.currentCapabilities.length === 0) {
      throw new Error(`Project "${record.slug}" must describe current capabilities.`);
    }
    if (record.technologies.length === 0) {
      throw new Error(`Project "${record.slug}" must list technologies.`);
    }
  }

  return records;
}

export function validateProjectRouteChanges(
  records: Project[],
  changes: ProjectRouteChange[]
): ProjectRouteChange[] {
  const activeSlugs = new Set(records.map((record) => record.slug));
  const seen = new Set<string>();

  for (const change of changes) {
    if (!change.fromSlug.trim()) {
      throw new Error('Legacy project routes must have a non-empty fromSlug.');
    }
    if (seen.has(change.fromSlug)) {
      throw new Error(`Duplicate legacy project route: ${change.fromSlug}`);
    }
    if (activeSlugs.has(change.fromSlug)) {
      throw new Error(`Legacy project route conflicts with active slug: ${change.fromSlug}`);
    }
    seen.add(change.fromSlug);

    if (change.toSlug !== null) {
      if (!change.toSlug.trim()) {
        throw new Error(
          `Legacy project route "${change.fromSlug}" must use null or a non-empty toSlug.`
        );
      }
      if (change.toSlug === change.fromSlug) {
        throw new Error(`Legacy project route "${change.fromSlug}" cannot redirect to itself.`);
      }
      if (!activeSlugs.has(change.toSlug)) {
        throw new Error(
          `Legacy project route "${change.fromSlug}" points to unknown slug: ${change.toSlug}`
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

export function getProjectPath(projectOrSlug: Project | string): string {
  const slug = typeof projectOrSlug === 'string' ? projectOrSlug : projectOrSlug.slug;
  return `/projects/${slug}/`;
}

export function getProjectCanonicalUrl(projectOrSlug: Project | string): string {
  return new URL(getProjectPath(projectOrSlug), canonicalOrigin).toString();
}

export function getLegacyProjectPath(routeChangeOrSlug: ProjectRouteChange | string): string {
  const slug = typeof routeChangeOrSlug === 'string' ? routeChangeOrSlug : routeChangeOrSlug.fromSlug;
  return getProjectPath(slug);
}

export function getLegacyProjectCanonicalUrl(
  routeChangeOrSlug: ProjectRouteChange | string
): string {
  return new URL(getLegacyProjectPath(routeChangeOrSlug), canonicalOrigin).toString();
}

export function getProjectSeoTitle(project: Project): string {
  return project.seoTitle ?? `${project.name} | ${profile.name}`;
}

export function getProjectSeoDescription(project: Project): string {
  return project.seoDescription ?? project.shortSummary;
}

export function getProjectBySlug(slug: string): Project | undefined {
  return projects.find((project) => project.slug === slug);
}

export function getProjectPages(records: Project[] = projects) {
  validateProjects(records);
  return records.map((project, index) => ({
    project,
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
