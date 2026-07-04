import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimelineExperienceCard extends StatefulWidget {
  final String title;
  final String role;
  final String location;
  final String period;
  final List<String> points;
  final List<String>? notableProjects;
  final Color? accentColor;
  final bool isFirst;

  const TimelineExperienceCard({
    super.key,
    required this.title,
    required this.role,
    required this.location,
    required this.period,
    required this.points,
    this.notableProjects,
    this.accentColor,
    this.isFirst = false,
  });

  @override
  State<TimelineExperienceCard> createState() => _TimelineExperienceCardState();
}

class _TimelineExperienceCardState extends State<TimelineExperienceCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isFirst) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = AppTheme.getColors(context);
    final effectiveAccentColor = widget.accentColor ?? AppTheme.primaryColor;

    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // Timeline dot — pulses for current role
                widget.isFirst
                    ? AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: effectiveAccentColor.withAlpha(30),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: effectiveAccentColor,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: effectiveAccentColor.withAlpha(
                                    (60 * _pulseAnimation.value).round(),
                                  ),
                                  blurRadius: 8 * _pulseAnimation.value,
                                  spreadRadius: 2 * _pulseAnimation.value,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: effectiveAccentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isDark ? colors.cardHeader : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: effectiveAccentColor.withAlpha(150),
                            width: 2,
                          ),
                        ),
                      ),
                // Connecting line
                Container(
                  width: 2,
                  height: _expanded ? 350 : 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        effectiveAccentColor.withAlpha(100),
                        effectiveAccentColor.withAlpha(20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Card
          Expanded(
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8, top: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? colors.card.withAlpha(168)
                      : colors.card.withValues(alpha: 0.74),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withAlpha(_isHovered ? 80 : 40)
                          : effectiveAccentColor.withAlpha(_isHovered ? 15 : 5),
                      blurRadius: _isHovered ? 20 : 8,
                      offset: Offset(0, _isHovered ? 6 : 2),
                    ),
                  ],
                  border: Border.all(
                    color: _isHovered || _expanded
                        ? effectiveAccentColor.withAlpha(isDark ? 60 : 40)
                        : colors.border,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colors.cardHeader.withAlpha(136)
                              : colors.cardHeader.withValues(alpha: 0.58),
                          border: Border(
                            bottom: BorderSide(
                              color: effectiveAccentColor.withAlpha(40),
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
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: colors.text,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (widget.isFirst) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGreen.withAlpha(25),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            AppTheme.accentGreen.withAlpha(60),
                                      ),
                                    ),
                                    child: Text(
                                      'Current',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.accentGreen,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    widget.role,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: colors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.location,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Points
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...(_expanded
                                    ? widget.points
                                    : widget.points.take(
                                        widget.notableProjects != null ? 2 : 3))
                                .map(
                              (point) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color:
                                            effectiveAccentColor.withAlpha(180),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        point,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.45,
                                          color: colors.text,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!_expanded &&
                                widget.points.length >
                                    (widget.notableProjects != null ? 2 : 3))
                              _buildExpandButton(
                                  'Show all ${widget.points.length} points'),
                            if (widget.notableProjects != null &&
                                widget.notableProjects!.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Icon(
                                    Icons.rocket_launch_rounded,
                                    color: effectiveAccentColor.withAlpha(200),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Notable Projects',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.text,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...(_expanded
                                      ? widget.notableProjects!
                                      : widget.notableProjects!.take(1))
                                  .map(
                                (project) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 6, left: 24),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        margin: const EdgeInsets.only(top: 6),
                                        decoration: BoxDecoration(
                                          color: effectiveAccentColor
                                              .withAlpha(120),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          project,
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.4,
                                            color: colors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!_expanded &&
                                  widget.notableProjects!.length > 1)
                                Padding(
                                  padding: const EdgeInsets.only(left: 24),
                                  child: _buildExpandButton(
                                      'Show all ${widget.notableProjects!.length} projects'),
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
          ),
        ],
      ),
    );
  }

  Widget _buildExpandButton(String text) {
    final effectiveAccentColor = widget.accentColor ?? AppTheme.primaryColor;

    return TextButton(
      onPressed: () => setState(() => _expanded = true),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.expand_more_rounded,
              color: effectiveAccentColor, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
                fontSize: 12,
                color: effectiveAccentColor,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapseButton() {
    final effectiveAccentColor = widget.accentColor ?? AppTheme.primaryColor;

    return TextButton(
      onPressed: () => setState(() => _expanded = false),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.expand_less_rounded,
              color: effectiveAccentColor, size: 16),
          const SizedBox(width: 4),
          Text(
            'Collapse',
            style: TextStyle(
                fontSize: 12,
                color: effectiveAccentColor,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
