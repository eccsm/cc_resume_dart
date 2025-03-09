import 'package:cc_resume_app/env_config.dart';
import 'package:cc_resume_app/resume_constants.dart';
import 'package:cc_resume_app/widgets/chatbot_icon_widget.dart';
import 'package:cc_resume_app/widgets/draggable_chat_widget.dart';
import 'package:cc_resume_app/widgets/experience_card.dart';
import 'package:cc_resume_app/widgets/navigation_pane.dart';
import 'package:cc_resume_app/widgets/pinned_git_repos_widget.dart';
import 'package:cc_resume_app/widgets/section_card.dart';
import 'package:cc_resume_app/widgets/skills_section.dart';
import 'package:cc_resume_app/widgets/social_icons_row.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'api_config.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await EnvConfig.init();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  
  runApp(ResumeApp(analytics: analytics));
}

class ResumeApp extends StatelessWidget {
  final FirebaseAnalytics analytics;
  
  const ResumeApp({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ekincan Casim',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      builder: (context, widget) => ResponsiveBreakpoints.builder(
        child: widget!,
        breakpoints: const [
          Breakpoint(start: 0, end: 450, name: MOBILE),
          Breakpoint(start: 451, end: 800, name: TABLET),
          Breakpoint(start: 801, end: 1920, name: DESKTOP),
          Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      theme: ThemeData(
        textTheme: GoogleFonts.oswaldTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          headlineMedium: GoogleFonts.oswald(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
          bodyMedium: GoogleFonts.openSans(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        primarySwatch: Colors.grey,
      ),
      home: const ResumePage(),
    );
  }
}

class ResumePage extends StatefulWidget {
  const ResumePage({super.key});

  @override
  State<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> with WidgetsBindingObserver {
  bool _chatOpen = false;

  final Map<String, GlobalKey> _sectionKeys = {
    'professional_summary': GlobalKey(),
    'skills': GlobalKey(),
    'experience': GlobalKey(),
    'education': GlobalKey(),
    'github_repos': GlobalKey(),
  };

  final ScrollController _scrollController = ScrollController();

  String _activeSection = 'professional_summary'; 

  double _chatbotTop = 0;
  double _chatbotLeft = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _chatbotTop = size.height - 80; 
        _chatbotLeft = size.width - 80; 
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }


  @override
  void didChangeMetrics() {
    final size = MediaQuery.of(context).size;
    setState(() {
      _chatbotTop = _chatbotTop.clamp(20.0, size.height - 80);
      _chatbotLeft = _chatbotLeft.clamp(20.0, size.width - 80);
    });
    super.didChangeMetrics();
  }

  void _toggleChat() {
    setState(() {
      _chatOpen = !_chatOpen;
    });
  }

  void _scrollToSection(String section) {
    setState(() {
      _activeSection = section;
    });
    final key = _sectionKeys[section];
    if (key != null) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _exportPdf(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  Uint8List? pdfBytes;
  try {
    pdfBytes = await ApiConfig.fetchResumePdf();
  } catch (e, stackTrace) {
    debugPrint('Error fetching PDF: $e\n$stackTrace');
  }

  // ignore: use_build_context_synchronously
  Navigator.of(context).pop();

  if (pdfBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to fetch PDF.')),
    );
    return;
  }

  showDialog<void>(
    // ignore: use_build_context_synchronously
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: const Text('PDF'),
        content: const Text('Do you want to open or download this PDF?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close this dialog
              await ApiConfig.handleOpenPdf(context, pdfBytes!);
            },
            child: const Text('Open'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close this dialog
              await ApiConfig.handleDownloadPdf(context, pdfBytes!);
            },
            child: const Text('Download'),
          ),
        ],
      );
    },
  );
}

  Widget _buildResumeContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: _sectionKeys['professional_summary'],
            child: const SectionCard(
              title: 'Ekincan Casim',
              content: Text(
                ResumeConstants.profileIntro,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          Container(
            key: _sectionKeys['skills'],
            child: const SectionCard(
              title: 'Skills',
              content: SkillsSection(), 
            ),
          ),

          Container(
            key: _sectionKeys['experience'],
            child: _buildExperienceSection(),
          ),

          Container(
            key: _sectionKeys['education'],
            child: const SectionCard(
              title: 'Education',
              content: Text(
                ResumeConstants.educationSummary,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          Container(
          key: _sectionKeys['github_repos'], 
          child: const SectionCard(
            title: 'GitHub Projects',
            content: PinnedGithubReposWidget(),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        for (final experience in ResumeConstants.experiences)
          ExperienceCard(
            title: experience.title,
            role: experience.role,
            location: experience.location,
            points: experience.points,
            notableProjects: experience.notableProjects,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    
    return Scaffold(
      appBar: isLargeScreen
          ? null
          : AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SocialIconsRow(
                    includePdfExport: true,
                    onPdfExport: () => _exportPdf(context),
                  ),
                ),
              ],
            ),
      drawer: isLargeScreen
          ? null
          : NavigationPane(
              isDrawer: true, 
              onPdfExport: () => _exportPdf(context),
              onNavigate: _scrollToSection, 
              activeSection: _activeSection,
            ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Row(
            children: [
              if (isLargeScreen)
                SizedBox(
                  width: 250,
                  child: NavigationPane(
                    isDrawer: false, 
                    onPdfExport: () => _exportPdf(context),
                    onNavigate: _scrollToSection, 
                    activeSection: _activeSection, 
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    _buildResumeContent(),
                    // Chat Overlay
                    if (_chatOpen) const DraggableChatWidget(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: _chatbotTop,
            left: _chatbotLeft,
            child: ChatbotIconWidget(
              onTap: _toggleChat,
              onDragEnd: (newPosition) {
                setState(() {
                  _chatbotTop = newPosition.dy.clamp(
                      20.0, MediaQuery.of(context).size.height - 80);
                  _chatbotLeft = newPosition.dx.clamp(
                      20.0, MediaQuery.of(context).size.width - 80);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}