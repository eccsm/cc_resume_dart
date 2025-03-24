// lib/widgets/github_activity_calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubActivityCalendar extends StatefulWidget {
  final String username;
  final int numberOfWeeks;
  final bool showContributionCount;

  const GitHubActivityCalendar({
    super.key,
    required this.username,
    this.numberOfWeeks = 26, // Show last 6 months by default
    this.showContributionCount = true,
  });

  @override
  State<GitHubActivityCalendar> createState() => _GitHubActivityCalendarState();
}

class _GitHubActivityCalendarState extends State<GitHubActivityCalendar> {
  bool _isLoading = true;
  List<List<int>> _activityData = [];
  int _totalContributions = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGitHubActivity();
  }

  Future<void> _fetchGitHubActivity() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real implementation, you would query the GitHub GraphQL API
      // For demo purposes, we'll generate random data
      final random = DateTime.now().millisecondsSinceEpoch % 100;
      
      final data = List.generate(widget.numberOfWeeks, (weekIndex) {
        return List.generate(7, (dayIndex) {
          // Generate random contribution counts (0-5)
          final contributions = (random + weekIndex + dayIndex) % 6;
          if (contributions > 0) {
            _totalContributions += contributions;
          }
          return contributions;
        });
      });

      setState(() {
        _activityData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load GitHub activity: $e';
        _isLoading = false;
      });
    }
  }

  Color _getIntensityColor(int value) {
    if (value == 0) {
      return Colors.grey.shade800;
    } else if (value == 1) {
      return Colors.green.shade200.withOpacity(0.3);
    } else if (value == 2) {
      return Colors.green.shade200.withOpacity(0.5);
    } else if (value == 3) {
      return Colors.green.shade200.withOpacity(0.7);
    } else if (value == 4) {
      return Colors.green.shade200.withOpacity(0.9);
    } else {
      return Colors.green.shade200;
    }
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
              onPressed: _fetchGitHubActivity,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FIX: Wrap this with Flexible/Expanded to handle potential overflow
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'GitHub Contribution Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (widget.showContributionCount)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '$_totalContributions contributions in the last ${widget.numberOfWeeks ~/ 4} months',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // FIX: Ensure the calendar fits within available width
        SizedBox(
          height: 110,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 32, // Accounting for padding
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day labels
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 12), // Offset for month labels
                      Text('Mon', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 1),
                      Text('Wed', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 1),
                      Text('Fri', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(),
                    ],
                  ),
                  const SizedBox(width: 4),
                  // Activity grid
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month labels
                      _buildMonthLabels(),
                      const SizedBox(height: 2),
                      // Activity cells
                      Row(
                        mainAxisSize: MainAxisSize.min, // FIX: Don't expand to fill width
                        children: List.generate(_activityData.length, (weekIndex) {
                          return Column(
                            children: List.generate(7, (dayIndex) {
                              return Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Tooltip(
                                  message: '${_activityData[weekIndex][dayIndex]} contributions on ${_getDayInfo(weekIndex, dayIndex)}',
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _getIntensityColor(_activityData[weekIndex][dayIndex]),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Legend - FIX: Use Wrap instead of Row for responsive layout
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Less',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                ...List.generate(5, (index) {
                  return Container(
                    margin: const EdgeInsets.all(2),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getIntensityColor(index),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
                const SizedBox(width: 4),
                const Text(
                  'More',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextButton(
                onPressed: () {
                  launchUrl(Uri.parse('https://github.com/${widget.username}'));
                },
                child: const Text('View on GitHub'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthLabels() {
    final now = DateTime.now();
    final months = <Widget>[];
    int currentPosition = 0;

    // Calculate months to display
    for (int i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthName = DateFormat('MMM').format(month);
      
      // Calculate position (each week is 12 pixels wide including padding)
      final weeksFromStart = (widget.numberOfWeeks - (i * 4.33).round());
      final position = weeksFromStart * 12;
      
      // Only add if it's a new month and the position is different enough
      if ((position - currentPosition) > 30) {
        currentPosition = position;
        months.add(
          Positioned(
            right: position.toDouble(),
            child: Text(
              monthName,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      }
    }

    // FIX: Limit the width to avoid overflow
    return SizedBox(
      height: 20,
      width: min(widget.numberOfWeeks * 12.0, MediaQuery.of(context).size.width - 100),
      child: Stack(children: months),
    );
  }

  String _getDayInfo(int weekIndex, int dayIndex) {
    final now = DateTime.now();
    final day = now.subtract(Duration(days: (widget.numberOfWeeks - weekIndex - 1) * 7 + (6 - dayIndex)));
    return DateFormat('MMM d, yyyy').format(day);
  }
  
  // Helper function to handle minimum value
  double min(double a, double b) {
    return a < b ? a : b;
  }
}