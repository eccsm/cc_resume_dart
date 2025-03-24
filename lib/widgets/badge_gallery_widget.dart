import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BadgeGalleryWidget extends StatefulWidget {
  final String huggingFaceUsername;
  final String githubUsername;
  final bool showSkillBadges;

  const BadgeGalleryWidget({
    super.key,
    this.huggingFaceUsername = 'eccsm',
    this.githubUsername = 'eccsm',
    this.showSkillBadges = true,
  });

  @override
  State<BadgeGalleryWidget> createState() => _BadgeGalleryWidgetState();
}

class _BadgeGalleryWidgetState extends State<BadgeGalleryWidget> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _badges = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBadges();
  }

  Color _getBadgeBorderColor(String platform) {
    switch (platform) {
      case 'hackerrank':
        return const Color(0xFF00EA64);
      case 'huggingface':
        return const Color(0xFFFFD21E);
      case 'github':
        return const Color(0xFF6E5494);
      case 'skill':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  Future<void> _fetchBadges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Map<String, dynamic>> badges = [];

      // Add skill badges if enabled
      if (widget.showSkillBadges) {
        badges.addAll(_getSkillBadges());
      }

      final hackerRankBadges = await _fetchHackerRankBadges();
      badges.addAll(hackerRankBadges);

      if (widget.huggingFaceUsername.isNotEmpty) {
        try {
          final huggingFaceBadges = await _fetchHuggingFaceBadges(widget.huggingFaceUsername);
          badges.addAll(huggingFaceBadges);
        } catch (e) {
          debugPrint('Error fetching HuggingFace badges: $e');
        }
      }

      if (widget.githubUsername.isNotEmpty) {
        try {
          final githubBadges = await _fetchGitHubBadges(widget.githubUsername);
          badges.addAll(githubBadges);
        } catch (e) {
          debugPrint('Error fetching GitHub badges: $e');
        }
      }

      setState(() {
        _badges = badges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load badges: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getSkillBadges() {
    return [
      {
        'imageUrl': 'assets/images/flutter.png',
        'url': 'https://flutter.dev',
        'platform': 'skill'
      },
      {
        'imageUrl': 'assets/images/dart.png',
        'url': 'https://dart.dev',
        'platform': 'skill'
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _fetchHackerRankBadges() async {
    return [
      {
        'imageUrl': 'assets/images/problem_solving.png',
        'url': 'https://www.hackerrank.com/certificates/837fa434e371',
        'platform': 'hackerrank'
      },
      {
        'imageUrl': 'assets/images/java.png',
        'url': 'https://www.hackerrank.com/certificates/d1c676de5e95',
        'platform': 'hackerrank'
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _fetchHuggingFaceBadges(String username) async {
    return [
      {
        'imageUrl': 'assets/images/huggingface.png',
        'url': 'https://huggingface.co/$username',
        'platform': 'huggingface'
      }
    ];
  }

  Future<List<Map<String, dynamic>>> _fetchGitHubBadges(String username) async {
    return [
      {
        'imageUrl': 'assets/images/github_c.png',
        'url': 'https://github.com/$username',
        'platform': 'github'
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBadges,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Badges & Certifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 16,
          children: _badges.map((badge) => _buildBadge(badge)).toList(),
        ),
      ],
    );
  }

  Widget _buildBadge(Map<String, dynamic> badge) {
    final Color borderColor = _getBadgeBorderColor(badge['platform']);

    return InkWell(
      onTap: () => _launchUrl(badge['url']),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200, minWidth: 160, minHeight: 80),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildImageWidget(badge['imageUrl']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return Image.asset(
      imageUrl,
      height: 36,
      width: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image: $error');
        return Container(
          height: 36,
          width: double.infinity,
          color: Colors.grey.shade800,
          child: const Icon(Icons.image, color: Colors.white54, size: 28),
        );
      },
    );
  }
}

class BadgeImageHelper {
  // Helper method to create PNG badges with star ratings
  static Widget createBadgeWithStars({
    required String badgePath,
    required String name,
    required int stars,
    Color backgroundColor = Colors.transparent,
    double height = 40,
    double width = 40,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge image
        Image.asset(
          badgePath,
          height: height,
          width: width,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: height,
              width: width,
              color: Colors.grey.shade100,
              child: const Center(
                child: Icon(Icons.broken_image, color: Color.fromARGB(228, 255, 255, 255)),
              ),
            );
          },
        ),
        
        const SizedBox(height: 8),
        
        // Badge name
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),       
      ],
    );
  }
  
  // Usage:
  // BadgeImageHelper.createBadgeWithStars(
  //   badgePath: 'assets/images/problem_solving_badge.png', 
  //   name: 'Problem Solving',
  //   stars: 3,
  // )
}