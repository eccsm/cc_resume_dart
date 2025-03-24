// lib/main.dart

import 'package:cc_resume_app/config/env_config.dart';
import 'package:cc_resume_app/pdf/resume_constants.dart';
import 'package:cc_resume_app/widgets/enhanced_chatbot_widget.dart';
import 'package:cc_resume_app/widgets/draggable_chat_widget.dart';
import 'package:cc_resume_app/widgets/navigation_pane.dart';
import 'package:cc_resume_app/widgets/pinned_git_repos_widget.dart';
import 'package:cc_resume_app/widgets/timeline_experience_card.dart';
import 'package:cc_resume_app/widgets/theme_toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'config/api_config.dart';
import 'widgets/badge_gallery_widget.dart';
import 'widgets/certification_carousel_widget.dart';
import 'widgets/github_activity_calendar_widget.dart';
import 'widgets/language_proiciency_widget.dart';
import 'widgets/section_card.dart';
import 'widgets/skills_section.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.init();
  runApp(const ResumeApp());
}

class ResumeApp extends StatefulWidget {
  const ResumeApp({super.key});

  @override
  State<ResumeApp> createState() => _ResumeAppState();
}

class _ResumeAppState extends State<ResumeApp> {
  ThemeMode _themeMode = ThemeMode.system;
  
  void _toggleTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Create consistent text themes with inherit=true
    final lightTextTheme = _createTextTheme(Colors.black87, true);
    final darkTextTheme = _createTextTheme(Colors.white, true);
    
    return MaterialApp(
      title: 'Ekincan Casim',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      
      builder: (context, widget) => ResponsiveBreakpoints.builder(
        child: widget!,
        breakpoints: const [
          Breakpoint(start: 0, end: 450, name: MOBILE),
          Breakpoint(start: 451, end: 800, name: TABLET),
          Breakpoint(start: 801, end: 1920, name: DESKTOP),
          Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      
      // Light theme
      theme: ThemeData(
        primaryColor: const Color(0xFFFBAD48),
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        textTheme: lightTextTheme,
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
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: Colors.black.withOpacity(0.2),
          elevation: 4,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        dividerColor: Colors.grey.shade300,
        indicatorColor: const Color(0xFFFBAD48),
      ),
      
      // Dark theme
      darkTheme: ThemeData(
        primaryColor: const Color(0xFFFBAD48),
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        textTheme: darkTextTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade900,
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
        cardTheme: CardTheme(
          color: Colors.grey.shade900,
          shadowColor: Colors.black.withOpacity(0.4),
          elevation: 4,
        ),
        scaffoldBackgroundColor: Colors.black87,
        dividerColor: Colors.grey.shade700,
        indicatorColor: const Color(0xFFFBAD48),
      ),
      
      home: ResumePage(onThemeChanged: _toggleTheme, currentTheme: _themeMode),
    );
  }
  
  // Helper method to create consistent text themes
  TextTheme _createTextTheme(Color textColor, bool inherit) {
    return GoogleFonts.oswaldTextTheme(
      TextTheme(
        displayLarge: TextStyle(color: textColor, inherit: inherit),
        displayMedium: TextStyle(color: textColor, inherit: inherit),
        displaySmall: TextStyle(color: textColor, inherit: inherit),
        headlineLarge: TextStyle(color: textColor, inherit: inherit),
        headlineMedium: TextStyle(
          color: textColor, 
          inherit: inherit, 
          fontSize: 32, 
          fontWeight: FontWeight.bold
        ),
        headlineSmall: TextStyle(color: textColor, inherit: inherit),
        titleLarge: TextStyle(color: textColor, inherit: inherit),
        titleMedium: TextStyle(color: textColor, inherit: inherit),
        titleSmall: TextStyle(color: textColor, inherit: inherit),
        bodyLarge: TextStyle(color: textColor, inherit: inherit),
        bodyMedium: GoogleFonts.openSans(
          fontSize: 16,
          color: textColor,
        ),
        bodySmall: TextStyle(color: textColor, inherit: inherit),
        labelLarge: TextStyle(color: textColor, inherit: inherit),
        labelMedium: TextStyle(color: textColor, inherit: inherit),
        labelSmall: TextStyle(color: textColor, inherit: inherit),
      ),
    );
  }
}

class ResumePage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentTheme;
  
  const ResumePage({
    super.key, 
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _chatOpen = false;

  final Map<String, GlobalKey> _sectionKeys = {
    'professional_summary': GlobalKey(),
    'skills_overview': GlobalKey(),
    'experience': GlobalKey(),
    'skills': GlobalKey(),
    'certifications': GlobalKey(),
    'languages': GlobalKey(),
    'education': GlobalKey(),
    'online_presence': GlobalKey(),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                isDarkMode 
                  ? Colors.black.withOpacity(0.75 + (_backgroundAnimation.value * 0.05))
                  : Colors.white.withOpacity(0.45 + (_backgroundAnimation.value * 0.05)),
                isDarkMode ? BlendMode.darken : BlendMode.lighten,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResumeContent() {
    bool isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    const accentColor = Color(0xFFFBAD48);
    
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
            // About section
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
            
            
            // Experience section
            Container(
              key: _sectionKeys['experience'],
              child: _buildExperienceSection(),
            ),

            // Technical Skills section
            Container(
              key: _sectionKeys['skills'],
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SkillsSection(),
              ),
            ),
            Container(
              key: _sectionKeys['certifications'],
              child: const SectionCard(
                title: 'Certifications',
                icon: Icons.workspace_premium,
                accentColor: accentColor,
                content: CertificationCarouselWidget(),
                    ),
                  ),
                  
                  Container(
                    key: _sectionKeys['languages'],
                    child: const SectionCard(
                      title: 'Languages',
                      icon: Icons.language,
                      accentColor: accentColor,
                      content: LanguageProficiencyWidget(
                        languages: [
                          LanguageProficiency(
                            language: 'English',
                            flagCode: 'us',
                            readingLevel: 0.95,
                            writingLevel: 0.9,
                            speakingLevel: 0.85,
                            listeningLevel: 0.95,
                            certification: 'Maltepe University\n'
                            'School of Foreign Languages - 80/100',
                          ),
                          LanguageProficiency(
                            language: 'Turkish',
                            flagCode: 'tr',
                            readingLevel: 1.0,
                            writingLevel: 1.0,
                            speakingLevel: 1.0,
                            listeningLevel: 1.0,
                          ),
                        ],
                        accentColor: accentColor,
                      ),
                    ),
                  ),
            
            // Education section
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
            
            // Merged GitHub Projects with Online Presence
            Container(
              key: _sectionKeys['online_presence'],
              child: SectionCard(
                title: 'Online Presence & Projects',
                icon: Icons.public,
                accentColor: accentColor,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GitHub Projects
                    Text(
                      'GitHub Projects',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const PinnedGithubReposWidget(),
                    
                    const SizedBox(height: 32),
                    Divider(color: Theme.of(context).dividerColor),
                    const SizedBox(height: 32),
                    
                    // GitHub Activity Calendar
                    const GitHubActivityCalendar(
                      username: 'eccsm',
                      numberOfWeeks: 20,
                    ),
                    const SizedBox(height: 32),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 32),
                    
                    // Badge Gallery
                    const BadgeGalleryWidget(),
                  ],
                ),
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.work, color: Theme.of(context).primaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                'Experience',
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
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
            accentColor: Theme.of(context).primaryColor,
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
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.5),
              toolbarHeight: 60,
              titleSpacing: 0,
              actions: [
                ThemeToggleWidget(
                  onThemeChanged: widget.onThemeChanged,
                  currentTheme: widget.currentTheme,
                ),
                const SizedBox(width: 8),
              ],
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
                    extraWidgets: [
                      ThemeToggleWidget(
                        onThemeChanged: widget.onThemeChanged,
                        currentTheme: widget.currentTheme,
                      ),
                    ],
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