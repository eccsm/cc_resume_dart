// lib/widgets/timeline_experience_card.dart

import 'package:flutter/material.dart';

class TimelineExperienceCard extends StatefulWidget {
  final String title;
  final String role;
  final String location;
  final String period;
  final List<String> points;
  final List<String>? notableProjects;
  final Color? accentColor;
  final bool animate;

  const TimelineExperienceCard({
    super.key,
    required this.title,
    required this.role,
    required this.location,
    required this.period,
    required this.points,
    this.notableProjects,
    this.accentColor,
    this.animate = true,
  });

  @override
  State<TimelineExperienceCard> createState() => _TimelineExperienceCardState();
}

class _TimelineExperienceCardState extends State<TimelineExperienceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // Get theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Set theme-appropriate colors
    final effectiveAccentColor = widget.accentColor ?? theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final cardColor = isDark ? Colors.grey.shade900.withOpacity(0.85) : Colors.white;
    final headerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade50;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: effectiveAccentColor,
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: _expanded ? 320 : 200,
                  color: effectiveAccentColor.withOpacity(0.6),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TweenAnimationBuilder<double>(
              duration: widget.animate ? const Duration(milliseconds: 800) : Duration.zero,
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Card(
                color: cardColor,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8, top: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _expanded 
                        ? effectiveAccentColor.withOpacity(0.5) 
                        : borderColor,
                    width: _expanded ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with theme-appropriate background
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: headerColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: effectiveAccentColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.role,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor.withOpacity(0.9),
                                  ),
                                ),
                              ),
                              Text(
                                widget.period,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: textColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...(_expanded 
                            ? widget.points 
                            : widget.points.take(widget.notableProjects != null ? 2 : 3)
                          ).map(
                            (point) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.arrow_right_alt,
                                    color: effectiveAccentColor.withOpacity(0.85),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.3,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          if (!_expanded && widget.points.length > (widget.notableProjects != null ? 2 : 3))
                            _buildExpandButton('Show all ${widget.points.length} points'),
                            
                          if (widget.notableProjects != null && 
                              widget.notableProjects!.isNotEmpty) ...[
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Icon(
                                  Icons.work_outline,
                                  color: effectiveAccentColor.withOpacity(0.9),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Notable Projects',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            ...(_expanded 
                              ? widget.notableProjects! 
                              : widget.notableProjects!.take(1)
                            ).map(
                              (project) => Padding(
                                padding: const EdgeInsets.only(bottom: 8, left: 26),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.only(top: 6),
                                      decoration: BoxDecoration(
                                        color: effectiveAccentColor.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        project,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.3,
                                          color: textColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            if (!_expanded && widget.notableProjects!.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 26),
                                child: _buildExpandButton('Show all ${widget.notableProjects!.length} projects'),
                              ),
                          ],

                          if (_expanded)
                            Align(
                              alignment: Alignment.centerRight,
                              child: _buildCollapseButton(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandButton(String text) {
    final theme = Theme.of(context);
    final effectiveAccentColor = widget.accentColor ?? theme.primaryColor;
    
    return TextButton(
      onPressed: () {
        setState(() {
          _expanded = true;
        });
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.expand_more,
            color: effectiveAccentColor.withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: effectiveAccentColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapseButton() {
    final theme = Theme.of(context);
    final effectiveAccentColor = widget.accentColor ?? theme.primaryColor;
    
    return TextButton(
      onPressed: () {
        setState(() {
          _expanded = false;
        });
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.expand_less,
            color: effectiveAccentColor.withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Collapse',
            style: TextStyle(
              fontSize: 13,
              color: effectiveAccentColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}