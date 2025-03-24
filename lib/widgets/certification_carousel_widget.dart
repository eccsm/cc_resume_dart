// lib/widgets/certification_carousel_widget.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CertificationCarouselWidget extends StatefulWidget {
  final List<Map<String, dynamic>>? certifications;

  const CertificationCarouselWidget({
    super.key,
    this.certifications,
  });

  @override
  State<CertificationCarouselWidget> createState() => _CertificationCarouselWidgetState();
}

class _CertificationCarouselWidgetState extends State<CertificationCarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<Map<String, dynamic>> _certifications;

  @override
  void initState() {
    super.initState();
    _certifications = widget.certifications ?? _getDefaultCertifications();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.85,
    );
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    int page = (_pageController.page ?? 0).round();
    if (_currentPage != page) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  List<Map<String, dynamic>> _getDefaultCertifications() {
    return [
      {
        'name': 'Cplace Certified Procode Developer',
        'issuer': 'Cplace',
        'date': 'Issued March 2023',
        'description': 'Certified in designing and deploying scalable systems and applications on cplace.',
        'iconData': FontAwesomeIcons.aws,
        'iconColor': const Color(0xFFFF9900),
        'badgeColor': const Color(0xFF232F3E),
        'url': 'https://www.cplace.com/en/academy/pro-code-training/',
      },
      {
        'name': 'Outsystems ODC Developer',
        'issuer': 'Outsystems',
        'date': 'Issued December 2016',
        'description': 'Expertise in designing, developing, and managing secure Google Cloud solutions.',
        'iconData': FontAwesomeIcons.google,
        'iconColor': const Color(0xFF4285F4),
        'badgeColor': const Color(0xFF34A853),
        'url': 'https://www.outsystems.com/certifications/academy-certifications/odc-developer',
      }
    ];
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchCertificationUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            'Professional Certifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _certifications.length,
            itemBuilder: (context, index) {
              final certification = _certifications[index];
              final isCurrentPage = index == _currentPage;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuint,
                margin: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: isCurrentPage ? 0 : 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (certification['badgeColor'] as Color).withOpacity(isCurrentPage ? 0.4 : 0.1),
                      blurRadius: isCurrentPage ? 12 : 4,
                      spreadRadius: isCurrentPage ? 2 : 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: (certification['badgeColor'] as Color).withOpacity(isCurrentPage ? 0.5 : 0.2),
                    width: isCurrentPage ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: () => _launchCertificationUrl(certification['url']),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: (certification['badgeColor'] as Color).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: FaIcon(
                                  certification['iconData'],
                                  color: certification['iconColor'],
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    certification['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    certification['issuer'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Text(
                            certification['description'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              certification['date'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const Row(
                              children: [
                                Text(
                                  'View Details',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 12,
                                  color: Colors.blue,
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
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _certifications.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: index == _currentPage ? 16 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index == _currentPage
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}