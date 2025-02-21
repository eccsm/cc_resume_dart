// lib/refactored_resume_constants.dart

/// Represents a professional experience entry.
class Experience {
  final String title;
  final String role;
  final String location;
  final List<String> points;
  final List<String>? notableProjects;

  const Experience({
    required this.title,
    required this.role,
    required this.location,
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

  // =========================
  // Profile / Summary
  // =========================
  static const String profileHeader = '$name\nSoftware Developer | Location: $location';

  static const String profileIntro =
      'Innovation, leadership, and a relentless drive for excellence have defined my journey in the software industry. '
      'Over the years, I have honed my skills in Java development, software architecture, and leading technical teams to deliver scalable and efficient solutions. '
      'My passion lies in transforming complex enterprise systems into modern, high-performing architectures.\n\n'
      'As a Lead Java Architect, I have been instrumental in designing and implementing microservices-based architectures, streamlining system integrations, and driving forward digital transformation initiatives. '
      'My expertise spans backend development, database optimization, and emerging technologies such as Generative AI. I take pride in fostering a culture of innovation, mentoring teams, and delivering high-quality solutions that align with business objectives.\n\n'
      'I am eager to bring my technical expertise, leadership abilities, and problem-solving mindset to new challenges. I look forward to the opportunity to discuss how my skills can contribute to your organization’s success.';

  // =========================
  // Skills
  // =========================
  static const Map<String, Map<String, List<String>>> skills = {
    'Programming Languages': {
      'Core Languages': ['Java', 'Kotlin', 'Python', 'JavaScript', 'TypeScript'],
      'Scripting & Automation': ['Bash', 'Groovy'],
      'Low-Code & Automation': ['OutSystems', 'cplacejs'],
    },
    'Frontend Technologies': {
      'Frameworks & Libraries': ['Angular', 'React', 'Vue.js'],
      'Core Tools': ['Babel', 'TypeScript', 'Webpack', 'Vite'],
      'UI/UX Libraries': ['Material-UI', 'Tailwind CSS', 'Bootstrap'],
    },
    'Backend Technologies': {
      'Frameworks': ['Spring Boot', 'Quarkus', 'Micronaut', 'Node.js', '.NET Core'],
      'API Development': ['REST', 'GraphQL', 'gRPC'],
      'Integration Tools': ['Apache Kafka', 'RabbitMQ'],
    },
    'Databases': {
      'RDBMS': ['PostgreSQL', 'MS SQL', 'Oracle', 'MySQL'],
      'NoSQL': ['MongoDB', 'Cassandra', 'DynamoDB'],
      'Search & Analytics': ['Elasticsearch', 'Redis'],
    },
    'Cloud & DevOps': {
      'Platforms': ['Microsoft Azure', 'Google Cloud Platform (GCP)', 'AWS'],
      'Containerization & Orchestration': ['Docker', 'Kubernetes', 'Helm','Openshift'],
      'CI/CD Tools': ['Jenkins', 'GitHub Actions', 'GitLab CI/CD', 'Bamboo'],
      'Infrastructure as Code': ['Terraform', 'Ansible', 'CloudFormation'],
    },
    'Machine Learning & LLMs': {
      'ML Frameworks': ['TensorFlow', 'PyTorch', 'Scikit-Learn'],
      'LLM & NLP': ['Hugging Face Transformers', 'MLC LLM', 'Llama.cpp', 'OpenAI APIs'],
      'Optimization': ['ONNX', 'TensorRT', 'LoRA Fine-Tuning'],
    },
    'Version Control & Collaboration': {
      'Tools': ['Git', 'GitHub', 'Bitbucket', 'GitLab'],
      'Project Management': ['JIRA', 'Confluence', 'Trello', 'Asana'],
    },
    'Testing & Quality Assurance': {
      'Automation Tools': ['Selenium', 'JUnit', 'TestNG', 'Postman'],
      'Performance Testing': ['Apache JMeter', 'Gatling'],
      'Static Analysis': ['SonarQube', 'ESLint', 'Checkstyle'],
    },
     'Project & Issue Management': {
      'Agile Tools': ['JIRA', 'Confluence', 'Trello', 'Asana'],
      'CI/CD & Build Tools': ['Maven', 'Gradle', 'Bazel'],
    },
  };

  // =========================
  // Project / Service Experience
  // =========================
  static const List<Experience> experiences = [
    Experience(
      title: 'NTT Data Business Solutions',
      role: 'Expert',
      location: 'Istanbul, Turkey | Present',
      points: [
        'Architect for Allianz: Played a pivotal role in transforming Allianz\'s enterprise systems to meet modern technological standards and business objectives.',
        'Spearheaded the Oracle ADF to Spring Boot transformation.',
        'Designed and implemented scalable architectures.',
        'Developed and optimized Angular and Spring Boot applications.',
        'Contributed to the German-based cplace framework transformation.',
        'Managed PostgreSQL and MongoDB databases.',
      ],
      notableProjects: [
        'Oracle ADF to Spring Boot Transformation: Modernized Allianz\'s core systems.',
        'Allianz Architectural Framework: Developed enterprise-level architecture.',
        'ZF Hungary Collaboration Platform: Enhanced project management capabilities.',
      ],
    ),
    Experience(
      title: 'Yapı Kredi Teknoloji',
      role: 'Software Consultant',
      location: 'Istanbul, Turkey | 2021 – 2022',
      points: [
        'Transformed monolithic Java applications into microservices.',
        'Managed Oracle DB to ensure data integrity.',
      ],
      notableProjects: [
        'Harmoni Framework: Transitioned legacy insurance systems to modern technologies.',
      ],
    ),
    Experience(
      title: 'Toshiba Global Commerce Solutions',
      role: 'Software Developer | Technical Team Leader',
      location: 'Istanbul, Turkey | 2018 – 2021',
      points: [
        'Led development of retail-focused applications.',
        'Directed global projects in multiple countries.',
        'Migrated technology stacks to Java 11 and PostgreSQL.',
      ],
      notableProjects: [
        'CHEC: A self-checkout application.',
        'REMS: A retail monitoring system.',
      ],
    ),
    Experience(
      title: 'Smartiks',
      role: 'Software Developer',
      location: 'Istanbul, Turkey | 2017 – 2018',
      points: [
        'Developed applications with .NET Core and SPAs.',
        'Optimized databases with MS SQL and Elasticsearch.',
      ],
      notableProjects: [
        'Smartcast: TÜBİTAK-supported ML and Big Data project.',
        'CMS for Derimod and Yurtiçi Kargo.',
      ],
    ),
    Experience(
      title: 'BAYPM',
      role: 'Software Developer',
      location: 'Istanbul, Turkey | 2015 – 2017',
      points: [
        'Certified OutSystems developer.',
        'Developed e-contract management and supplier collaboration platforms.',
      ],
      notableProjects: [
        'eContractHub: A streamlined e-contract management system.',
        'Supplier Management Portal.',
      ],
    ),
    Experience(
      title: 'KARDEMİR A.Ş.',
      role: 'Intern',
      location: 'Karabük, Turkey | 2014',
      points: [
        'Designed a transactional pipeline simulation using .NET and MS SQL.',
        'Gained practical experience in C# application development.',
      ],
      notableProjects: [],
    ),
  ];

  // =========================
  // Education
  // =========================

  static const String educationSummary = 'Master’s Degree in Engineering and Technology Management\n'
      'Doğuş University, Istanbul, Turkey | 2017 – 2019\n\n'
      'Bachelor’s Degree in Computer Engineering (Full Scholarship)\n'
      'Maltepe University, Istanbul, Turkey | 2011 – 2015';

  // =========================
  // Contact Information
  // =========================
  static const String contactEmail = 'ekincan@casim.net';
  static const String contactPhone = '+90 532 055 1566';
  static const String contactLinkedIn = 'https://www.linkedin.com/in/eccsm';
  static const String contactGitHub = 'https://github.com/eccsm';
}
