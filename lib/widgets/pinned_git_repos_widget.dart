
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/env_config.dart';

class PinnedGithubReposWidget extends StatefulWidget {
  const PinnedGithubReposWidget({
    super.key,
    this.username = 'eccsm', // Your GitHub username as default
    this.maxRepos = 4,
  });

  final String username;
  final int maxRepos;

  @override
  State<PinnedGithubReposWidget> createState() => _PinnedGithubReposWidgetState();
}

class _PinnedGithubReposWidgetState extends State<PinnedGithubReposWidget> {
  List<Map<String, dynamic>> _pinnedRepos = [];
  bool _isLoading = true;
  String? _errorMessage;

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
      final githubToken = EnvConfig.githubApiToken;
      final url = Uri.parse('https://api.github.com/graphql');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $githubToken', // Replace with your GitHub token
        },
        body: jsonEncode({
          'query': '''
          {
            user(login: "${widget.username}") {
              pinnedItems(first: ${widget.maxRepos}, types: REPOSITORY) {
                nodes {
                  ... on Repository {
                    name
                    url
                    stargazerCount
                    forkCount
                    primaryLanguage {
                      name
                      color
                    }
                  }
                }
              }
            }
          }
          ''',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final repos = data['data']['user']['pinnedItems']['nodes'] as List;
        
        setState(() {
          _pinnedRepos = repos.map((repo) => repo as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load pinned repositories');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load GitHub repositories';
        _isLoading = false;
        _pinnedRepos = []; // Empty list instead of fallback data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Waiting for your contribution',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_errorMessage != null && _pinnedRepos.isEmpty)
          Text(_errorMessage!, style: TextStyle(color: Colors.red[700]))
        else
          _buildReposList(),
      ],
    );
  }

  Widget _buildReposList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we should use a grid or list based on available width
        final useGrid = constraints.maxWidth > 600;
        final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
        
        if (useGrid) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 2.5, // Making cards more compact
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _pinnedRepos.length,
            itemBuilder: (context, index) => _buildRepoCard(_pinnedRepos[index]),
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pinnedRepos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _buildRepoCard(_pinnedRepos[index]),
          );
        }
      },
    );
  }

  Widget _buildRepoCard(Map<String, dynamic> repo) {
    final primaryLanguage = repo['primaryLanguage'] as Map<String, dynamic>?;
    
    return Card(
      elevation: 1, // Reduced elevation for a subtler appearance
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _launchUrl(repo['url']),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First row: code icon + repo name, then primary language (if exists)
              Row(
                children: [
                  const Icon(Icons.code, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      repo['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (primaryLanguage != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(
                            primaryLanguage['color'].substring(1),
                            radix: 16,
                          ) + 0xFF000000,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      primaryLanguage['name'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Second row: star and fork counts
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_outline, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        repo['stargazerCount'].toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fork_right_outlined, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        repo['forkCount'].toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}