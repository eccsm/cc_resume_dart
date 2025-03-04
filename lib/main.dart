// lib/main.dart

import 'package:cc_resume_app/env_config.dart';
import 'package:cc_resume_app/pdf/pdf_generator.dart';
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await EnvConfig.init();
  // Initialize Firebase Analytics
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
          // Define other text styles as needed
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

  // Define GlobalKeys for each section with unique identifiers
  final Map<String, GlobalKey> _sectionKeys = {
    'professional_summary': GlobalKey(),
    'skills': GlobalKey(),
    'experience': GlobalKey(),
    'education': GlobalKey(),
    'github_repos': GlobalKey(),
  };

  // Add a ScrollController
  final ScrollController _scrollController = ScrollController();

  // Track the active section for navigation highlighting
  String _activeSection = 'professional_summary'; // Default active section

  // Position state for ChatbotIconWidget
  double _chatbotTop = 0;
  double _chatbotLeft = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize chatbot position after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _chatbotTop = size.height - 80; // 60 (icon height) + 20 padding
        _chatbotLeft = size.width - 80; // 60 (icon width) + 20 padding
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  // Listen for screen size changes
  @override
  void didChangeMetrics() {
    final size = MediaQuery.of(context).size;
    setState(() {
      // Ensure the chatbot icon remains within the new screen bounds
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

  // Implement the scrollToSection method
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

  Future<void> _exportPdf() async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final pdf = await PdfGenerator.generateResumePdf();

      // Use the printing package to preview or share the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      Navigator.of(context).pop(); // Close the loading dialog

      // Optionally, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF Exported Successfully!')),
      );
    } catch (e, stackTrace) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Close the loading dialog

      // Log the error details
      debugPrint('PDF Export Error: $e');
      debugPrint('StackTrace: $stackTrace');

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export PDF. Please try again.')),
      );
    }
  }

  Widget _buildResumeContent() {
    return SingleChildScrollView(
      controller: _scrollController, // Assign the ScrollController
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Professional Summary Section
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

          // Skills Section
          Container(
            key: _sectionKeys['skills'],
            child: const SectionCard(
              title: 'Skills',
              content: SkillsSection(), // Pass the SkillsSection widget
            ),
          ),

          // Professional Experience Section
          Container(
            key: _sectionKeys['experience'],
            child: _buildExperienceSection(),
          ),

          // Education Section
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
          key: _sectionKeys['github_repos'], // Add this key to your _sectionKeys map
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
        // Iterate over experiences
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
    // Determine if the screen is large enough to show a persistent navigation pane
    bool isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    
    return Scaffold(
      // Conditionally include AppBar
      appBar: isLargeScreen
          ? null
          : AppBar(
              actions: [
                // Include SocialIconsRow in AppBar's actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SocialIconsRow(
                    includePdfExport: true,
                    onPdfExport: _exportPdf,
                  ),
                ),
              ],
            ),
      // Conditionally include Drawer for small screens
      drawer: isLargeScreen
          ? null
          : NavigationPane(
              isDrawer: true, // Specify that it's used as a drawer
              onPdfExport: _exportPdf, // Pass the PDF export callback
              onNavigate: _scrollToSection, // Pass the navigation callback
              activeSection: _activeSection, // Pass the active section
            ),
      body: Stack(
        children: [
          // Background image covering the entire screen
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
              // Left Navigation Pane for Large Screens
              if (isLargeScreen)
                SizedBox(
                  width: 250,
                  child: NavigationPane(
                    isDrawer: false, // Specify that it's used as a sidebar
                    onPdfExport: _exportPdf, // Pass the PDF export callback
                    onNavigate: _scrollToSection, // Pass the navigation callback
                    activeSection: _activeSection, // Pass the active section
                  ),
                ),
              // Main Content
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
          // Draggable Chatbot Icon positioned using Positioned
          Positioned(
            top: _chatbotTop,
            left: _chatbotLeft,
            child: ChatbotIconWidget(
              onTap: _toggleChat,
              onDragEnd: (newPosition) {
                setState(() {
                  // Update the position ensuring it stays within bounds
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