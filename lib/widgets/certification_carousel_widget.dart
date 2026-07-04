import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pdf/resume_constants.dart';
import '../theme/app_theme.dart';

class CertificationCarouselWidget extends StatefulWidget {
  final List<Map<String, dynamic>>? certifications;
  const CertificationCarouselWidget({super.key, this.certifications});

  @override
  State<CertificationCarouselWidget> createState() =>
      _CertificationCarouselWidgetState();
}

class _CertificationCarouselWidgetState
    extends State<CertificationCarouselWidget> {
  late final PageController _ctrl;
  int _page = 0;
  late final List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    // Use provided certifications (from ResumeConstants) — no more hardcoded _defaultCerts
    _items = widget.certifications ??
        ResumeConstants.certifications
            .map((c) => Map<String, dynamic>.from(c))
            .toList();
    _ctrl = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.getColors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_items.isEmpty) {
      return Center(
        child: Text(
          'No certifications available.',
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Professional Certifications',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: colors.text,
              letterSpacing: -0.2,
            ),
          ),
        ),

        // Carousel
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 520;
            return SizedBox(
              height: narrow ? 300 : 220,
              child: PageView.builder(
                controller: _ctrl,
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _items.length,
                itemBuilder: (c, i) {
                  final cert = _items[i];
                  final focus = i == _page;
                  final badgeColor = cert['badgeColor'] as Color;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    margin: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: focus ? 0 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colors.card.withAlpha(168)
                          : colors.card.withValues(alpha: 0.74),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: focus
                            ? badgeColor.withAlpha(isDark ? 100 : 60)
                            : colors.border,
                        width: focus ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: focus
                              ? badgeColor.withAlpha(isDark ? 30 : 15)
                              : Colors.black.withAlpha(isDark ? 20 : 5),
                          blurRadius: focus ? 20 : 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _open(cert['url']),
                      child: Padding(
                        padding: EdgeInsets.all(narrow ? 14 : 20),
                        child: LayoutBuilder(
                          builder: (context, cardConstraints) {
                            final compact = cardConstraints.maxWidth < 250;
                            final badgeIcon = Container(
                              decoration: BoxDecoration(
                                color: badgeColor.withAlpha(isDark ? 30 : 15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(compact ? 8 : 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  cert['assetPath'],
                                  width: compact ? 22 : 28,
                                  height: compact ? 22 : 28,
                                ),
                              ),
                            );

                            final titleBlock = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cert['name'],
                                  maxLines: compact ? 3 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: compact ? 14 : 15,
                                    fontWeight: FontWeight.w700,
                                    color: colors.text,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  cert['issuer'],
                                  maxLines: compact ? 2 : 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: compact ? 12 : 13,
                                    color: colors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );

                            final action = Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'View details',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: compact ? 11 : 12,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: compact ? 12 : 13,
                                  color: AppTheme.primaryColor,
                                ),
                              ],
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                compact
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          badgeIcon,
                                          const SizedBox(height: 10),
                                          titleBlock,
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          badgeIcon,
                                          const SizedBox(width: 14),
                                          Expanded(child: titleBlock),
                                        ],
                                      ),
                                SizedBox(height: compact ? 12 : 14),
                                Expanded(
                                  child: Text(
                                    cert['description'],
                                    maxLines: compact ? 6 : null,
                                    overflow: compact
                                        ? TextOverflow.ellipsis
                                        : TextOverflow.fade,
                                    style: TextStyle(
                                      fontSize: compact ? 12 : 13,
                                      color: colors.textSecondary,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 10 : 0),
                                compact
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cert['date'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: colors.textSecondary
                                                  .withAlpha(180),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          action,
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              cert['date'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: colors.textSecondary
                                                    .withAlpha(180),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Flexible(child: action),
                                        ],
                                      ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),

        // Pager dots
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: compact ? 20 : 24,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: compact ? 28 : 40,
                    height: compact ? 28 : 40,
                  ),
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: _page > 0
                        ? colors.text
                        : colors.textSecondary.withAlpha(80),
                  ),
                  onPressed: _page > 0
                      ? () => _ctrl.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          )
                      : null,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _items.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: i == _page ? (compact ? 16 : 20) : 8,
                          height: 8,
                          margin:
                              EdgeInsets.symmetric(horizontal: compact ? 2 : 3),
                          decoration: BoxDecoration(
                            color: i == _page
                                ? AppTheme.primaryColor
                                : colors.textSecondary.withAlpha(60),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  iconSize: compact ? 20 : 24,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: compact ? 28 : 40,
                    height: compact ? 28 : 40,
                  ),
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: _page < _items.length - 1
                        ? colors.text
                        : colors.textSecondary.withAlpha(80),
                  ),
                  onPressed: _page < _items.length - 1
                      ? () => _ctrl.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          )
                      : null,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
