// lib/widgets/pinned_git_repos_widget.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

class PinnedGithubReposWidget extends StatefulWidget {
  const PinnedGithubReposWidget({
    super.key,
    this.username = 'eccsm',
    this.maxRepos = 5,
    this.onReposLoaded,
  });

  final String username;
  final int maxRepos;

  /// Called once repos are fetched, e.g. to feed them to the chatbot.
  final void Function(List<Map<String, dynamic>> repos)? onReposLoaded;

  @override
  State<PinnedGithubReposWidget> createState() =>
      _PinnedGithubReposWidgetState();
}

class _PinnedGithubReposWidgetState extends State<PinnedGithubReposWidget> {
  List<Map<String, dynamic>> _pinnedRepos = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Public services that resolve pinned repositories; tried in order.
  static const List<String> _pinnedRepoApis = [
    'https://api.kremilly.com/github?user=',
    'https://gh-pinned-repos-api.vercel.app/api/user/',
    'https://gh-pinned-repos.egoist.dev/?username=',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPinnedRepos();
  }

  Future<void> _fetchPinnedRepos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool success = false;
      for (final api in _pinnedRepoApis) {
        try {
          await _fetchFromApi(api);
          success = true;
          break;
        } catch (e) {
          debugPrint('Pinned repo API failed: $e');
        }
      }

      if (!success) {
        // If all pinned APIs failed, fall back to recently updated repos.
        await _fetchStandardRepositories();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load GitHub repositories';
        _isLoading = false;
      });
    }
  }

  void _publishRepos(List<Map<String, dynamic>> repos) {
    if (!mounted) return;
    setState(() {
      _pinnedRepos = repos;
      _isLoading = false;
    });
    widget.onReposLoaded?.call(repos);
  }

  Future<void> _fetchFromApi(String apiBaseUrl) async {
    final url = Uri.parse('$apiBaseUrl${widget.username}');
    final response =
        await http.get(url).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('API returned status code ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    List<Map<String, dynamic>> repos = [];

    if (data is List) {
      repos = data
          .whereType<Map>()
          .map((repo) => _normalizeRepoData(Map<String, dynamic>.from(repo)))
          .toList();
    } else if (data is Map && data.containsKey('repos')) {
      repos = (data['repos'] as List)
          .whereType<Map>()
          .map((repo) => _normalizeRepoData(Map<String, dynamic>.from(repo)))
          .toList();
    } else if (data is Map) {
      repos = [_normalizeRepoData(Map<String, dynamic>.from(data))];
    }

    if (repos.isEmpty) throw Exception('No repositories in response');

    if (repos.length > widget.maxRepos) {
      repos = repos.sublist(0, widget.maxRepos);
    }
    _publishRepos(repos);
  }

  Map<String, dynamic> _normalizeRepoData(Map<String, dynamic> repo) {
    return {
      'name': repo['name'] ?? repo['repo'] ?? '',
      'url': repo['url'] ??
          repo['link'] ??
          'https://github.com/${widget.username}/${repo['name'] ?? ''}',
      'description': repo['description'] ?? repo['desc'] ?? '',
      'language': repo['language'] ?? repo['primaryLanguage']?['name'] ?? '',
      'languageColor': repo['languageColor'] ??
          repo['primaryLanguage']?['color'] ??
          '#4F5D95',
      'stargazerCount': repo['stars'] ?? repo['stargazerCount'] ?? 0,
      'forkCount': repo['forks'] ?? repo['forkCount'] ?? 0,
    };
  }

  Future<void> _fetchStandardRepositories() async {
    final url = Uri.parse(
        'https://api.github.com/users/${widget.username}/repos?sort=updated&per_page=${widget.maxRepos}');
    final response = await http.get(url).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Failed to load repositories');
    }

    final List repos = jsonDecode(response.body);
    final normalizedRepos = repos
        .whereType<Map>()
        .map((repo) => {
              'name': repo['name'] ?? '',
              'url': repo['html_url'] ?? '',
              'description': repo['description'] ?? '',
              'language': repo['language'] ?? '',
              'languageColor': '#4F5D95',
              'stargazerCount': repo['stargazers_count'] ?? 0,
              'forkCount': repo['forks_count'] ?? 0,
            })
        .toList();

    _publishRepos(List<Map<String, dynamic>>.from(normalizedRepos));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.getColors(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.push_pin_outlined,
                size: 16, color: colors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Pinned Repositories',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => _launchUrl('https://github.com/${widget.username}'),
              child: Text(
                'View all →',
                style:
                    TextStyle(fontSize: 12, color: AppTheme.secondaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_errorMessage != null && _pinnedRepos.isEmpty)
          Text(_errorMessage!, style: TextStyle(color: Colors.red[700]))
        else
          _buildBentoGrid(),
      ],
    );
  }

  /// Bento layout: the first repo gets a full-width featured tile, the rest
  /// flow in a two-column grid (single column on narrow screens).
  Widget _buildBentoGrid() {
    if (_pinnedRepos.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth > 620;
        final rest = _pinnedRepos.skip(1).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RepoCard(
              repo: _pinnedRepos.first,
              featured: true,
              onOpen: _launchUrl,
            ),
            if (rest.isNotEmpty) ...[
              const SizedBox(height: 12),
              if (twoColumns)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final repo in rest)
                      SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child:
                            _RepoCard(repo: repo, onOpen: _launchUrl),
                      ),
                  ],
                )
              else
                Column(
                  children: [
                    for (final repo in rest)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child:
                            _RepoCard(repo: repo, onOpen: _launchUrl),
                      ),
                  ],
                ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    // Repo URLs come from third-party APIs — only open https links.
    if (uri == null || uri.scheme != 'https') {
      debugPrint('Blocked non-https repo URL: $url');
      return;
    }
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $url');
    }
  }
}

class _RepoCard extends StatefulWidget {
  final Map<String, dynamic> repo;
  final bool featured;
  final Future<void> Function(String url) onOpen;

  const _RepoCard({
    required this.repo,
    required this.onOpen,
    this.featured = false,
  });

  @override
  State<_RepoCard> createState() => _RepoCardState();
}

class _RepoCardState extends State<_RepoCard> {
  bool _hovered = false;

  Color get _languageColor {
    final raw = widget.repo['languageColor']?.toString() ?? '';
    if (raw.startsWith('#')) {
      try {
        return Color(int.parse(raw.substring(1), radix: 16) + 0xFF000000);
      } catch (_) {}
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.getColors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = widget.repo;
    final language = repo['language']?.toString() ?? '';
    final description = repo['description']?.toString() ?? '';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onOpen(repo['url'].toString()),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          padding: EdgeInsets.all(widget.featured ? 20 : 14),
          decoration: BoxDecoration(
            color: isDark
                ? colors.cardHeader.withAlpha(_hovered ? 255 : 200)
                : colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? AppTheme.primaryColor.withAlpha(isDark ? 130 : 160)
                  : colors.border,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withAlpha(isDark ? 35 : 25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    widget.featured
                        ? Icons.auto_awesome_rounded
                        : Icons.code_rounded,
                    size: widget.featured ? 20 : 16,
                    color: widget.featured
                        ? AppTheme.primaryColor
                        : colors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      repo['name'].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: widget.featured ? 17 : 14,
                        color: colors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 14,
                    color: _hovered
                        ? AppTheme.primaryColor
                        : colors.textSecondary.withAlpha(120),
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: widget.featured ? 13.5 : 12,
                    height: 1.45,
                    color: colors.textSecondary,
                  ),
                  maxLines: widget.featured ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: widget.featured ? 14 : 10),
              Row(
                children: [
                  if (language.isNotEmpty) ...[
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _languageColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      language,
                      style: TextStyle(
                          fontSize: 12, color: colors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(Icons.star_outline_rounded,
                      size: 15, color: colors.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    repo['stargazerCount'].toString(),
                    style:
                        TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  const SizedBox(width: 14),
                  Icon(Icons.fork_right_rounded,
                      size: 15, color: colors.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    repo['forkCount'].toString(),
                    style:
                        TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
