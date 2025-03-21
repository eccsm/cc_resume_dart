// lib/main.dart

import 'package:cc_resume_app/config/env_config.dart';
import 'package:cc_resume_app/pdf/resume_constants.dart';
import 'package:cc_resume_app/widgets/enhanced_chatbot_widget.dart';
import 'package:cc_resume_app/widgets/draggable_chat_widget.dart';
import 'package:cc_resume_app/widgets/navigation_pane.dart';
import 'package:cc_resume_app/widgets/pinned_git_repos_widget.dart';
import 'package:cc_resume_app/widgets/timeline_experience_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'config/api_config.dart';
import 'widgets/section_card.dart';
import 'widgets/skills_section.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await EnvConfig.init();
  
  runApp(const ResumeApp());
}

class ResumeApp extends StatelessWidget {
  
  const ResumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ekincan Casim',
      debugShowCheckedModeBanner: false,

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
        primaryColor: const Color(0xFFFBAD48),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
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
        // Add app bar theme for consistent styling
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade900.withOpacity(0.85),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.5),
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.oswald(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
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

class _ResumePageState extends State<ResumePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _chatOpen = false;

  final Map<String, GlobalKey> _sectionKeys = {
    'professional_summary': GlobalKey(),
    'experience': GlobalKey(),
    'skills': GlobalKey(),
    'education': GlobalKey(),
    'github_repos': GlobalKey(),
  };

  final ScrollController _scrollController = ScrollController();

  String _activeSection = 'professional_summary'; 

  double _chatbotTop = 0;
  double _chatbotLeft = 0;
  
  // Animation controllers
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize animation controllers
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _chatbotTop = size.height - 100; 
        _chatbotLeft = size.width - 100; 
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _backgroundController.dispose();
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

  


  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.45 + (_backgroundAnimation.value * 0.05)),
                BlendMode.lighten,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResumeContent() {
    bool isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        16, 
        isLargeScreen ? 16 : 86, 
        16, 
        16
      ),
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - (isLargeScreen ? 100 : 180), 
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: _sectionKeys['professional_summary'],
              child: const SectionCard(
                title: 'About',
                icon: Icons.person,
                accentColor: Color(0xFFFBAD48),
                content: Text(
                  ResumeConstants.profileIntro,
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ),
            
            
            Container(
              key: _sectionKeys['experience'],
              child: _buildExperienceSection(),
            ),

            Container(
              key: _sectionKeys['skills'],
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SkillsSection(),
              ),
            ),

            Container(
              key: _sectionKeys['education'],
              child: const SectionCard(
                title: 'Education',
                icon: Icons.school,
                accentColor: Color(0xFFFBAD48),
                content: Text(
                  ResumeConstants.educationSummary,
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ),

            Container(
              key: _sectionKeys['github_repos'], 
              child: const SectionCard(
                title: 'GitHub Projects',
                icon: Icons.code_rounded,
                accentColor: Color(0xFFFBAD48),
                content: PinnedGithubReposWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.work, color: Color(0xFFFBAD48), size: 28),
              SizedBox(width: 12),
              Text(
                'Experience',
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFBAD48),
                ),
              ),
            ],
          ),
        ),
        for (final experience in ResumeConstants.experiences)
          TimelineExperienceCard(
            title: experience.title,
            role: experience.role,
            location: experience.location,
            period: '2022 - Present', 
            points: experience.points,
            notableProjects: experience.notableProjects,
            accentColor: const Color(0xFFFBAD48),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: isLargeScreen
          ? null
          : AppBar(
              backgroundColor: Colors.grey.shade900.withOpacity(0.95),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.5),
              toolbarHeight: 60,
              titleSpacing: 0,
            ),
      drawer: isLargeScreen
          ? null
          : NavigationPane(
              isDrawer: true, 
              onPdfExport: () => ApiConfig.exportResumePdf(context),
              onNavigate: _scrollToSection, 
              activeSection: _activeSection,
            ),
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          // Main content
          Row(
            children: [
              if (isLargeScreen)
                SizedBox(
                  width: 280, 
                  child: NavigationPane(
                    isDrawer: false, 
                    onPdfExport: () => ApiConfig.exportResumePdf(context),
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
          
          // Floating chat button
          Positioned(
            top: _chatbotTop,
            left: _chatbotLeft,
            child: EnhancedChatbotWidget(
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