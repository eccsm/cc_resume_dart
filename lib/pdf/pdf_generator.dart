import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'resume_constants.dart';

class PdfGenerator {
  static Future<Uint8List> generateResumePdf() async {
    final pdf = pw.Document();

    // Load fonts
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();

    // Define styles
    final headerNameStyle = pw.TextStyle(font: boldFont, fontSize: 24, color: PdfColors.black);
    final headerTitleStyle = pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.black);
    final headerContactStyle = pw.TextStyle(font: font, fontSize: 11, color: PdfColors.black);

    final sectionTitleStyle = pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.black);
    final companyNameStyle = pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.black);
    final positionStyle = pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.black);
    final normalStyle = pw.TextStyle(font: font, fontSize: 11, color: PdfColors.black);
    final locationPeriodStyle = pw.TextStyle(font: font, fontSize: 11, color: PdfColors.black);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) {
          // No header on page 1 to avoid duplication with hero header
          if (context.pageNumber == 1) return pw.SizedBox();
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(ResumeConstants.name, style: headerNameStyle.copyWith(fontSize: 18)),
              pw.SizedBox(height: 2),
              pw.Text(ResumeConstants.title, style: headerTitleStyle.copyWith(fontSize: 12)),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1, color: PdfColors.grey500),
            ],
          );
        },
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Ekincan Casim – Resume', style: normalStyle.copyWith(color: PdfColors.grey700)),
            pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: normalStyle.copyWith(color: PdfColors.grey700)),
          ],
        ),
        build: (context) => [
          // Hero header (page 1)
          _buildHeader(headerNameStyle, headerTitleStyle, headerContactStyle),
          _vSpace(12),

          // Professional Summary
          _sectionHeader('Professional Summary', sectionTitleStyle),
          _buildSummary(normalStyle),
          _divider(),

          // Work Experience
          _sectionHeader('Work Experience', sectionTitleStyle),
          ...ResumeConstants.experiences.map((exp) => _buildExperienceEntryPaginated(
                company: exp.title,
                position: exp.role,
                location: exp.location,
                period: exp.period,
                responsibilities: exp.points,
                projects: exp.notableProjects,
                companyStyle: companyNameStyle,
                positionStyle: positionStyle,
                locationStyle: locationPeriodStyle,
                bodyStyle: normalStyle,
              )),
          _divider(),

          // Core Skills 
          _sectionHeader('Core Skills', sectionTitleStyle),
          _buildCoreSkills(normalStyle, boldFont),
          _divider(),

          // Education
          _sectionHeader('Education', sectionTitleStyle),
          _buildEducation(normalStyle, boldFont),
          _divider(),

          // Languages & Certificates
          _sectionHeader('Languages & Certificates', sectionTitleStyle),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Languages', style: companyNameStyle),
                    _vSpace(4),
                    pw.Text(ResumeConstants.languages, style: normalStyle),
                  ],
                ),
              ),
              pw.SizedBox(width: 32),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Certificates', style: companyNameStyle),
                    _vSpace(4),
                    _buildCertificatesOneLine(normalStyle),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ---------- Helpers ----------
  static pw.Widget _sectionHeader(String title, pw.TextStyle style) =>
      pw.Padding(padding: const pw.EdgeInsets.only(bottom: 6), child: pw.Text(title, style: style));

  static pw.Widget _divider() =>
      pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 10), child: pw.Divider(thickness: 1, color: PdfColors.grey500));

  static pw.SizedBox _vSpace(double h) => pw.SizedBox(height: h);

  static List<List<T>> _chunk<T>(List<T> items, int size) {
    if (size <= 0 || items.isEmpty) return [items];
    final chunks = <List<T>>[];
    for (var i = 0; i < items.length; i += size) {
      chunks.add(items.sublist(i, i + size > items.length ? items.length : i + size));
    }
    return chunks;
  }

  // ---------- Certificates (one-line per entry) ----------
  static pw.Widget _buildCertificatesOneLine(pw.TextStyle style) {
    final lines = ResumeConstants.certificates
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final entries = <String>[];
    for (int i = 0; i < lines.length; i++) {
      final current = lines[i];
      final next = (i + 1 < lines.length) ? lines[i + 1] : null;

      if (next != null && !next.contains(' - ')) {
        entries.add('$current ($next)');
        i++;
      } else {
        entries.add(current);
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: entries
          .map((e) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Text('• $e', style: style),
              ))
          .toList(),
    );
  }

  // ---------- Header (hero) with clickable links ----------
  static pw.Widget _buildHeader(
    pw.TextStyle nameStyle,
    pw.TextStyle titleStyle,
    pw.TextStyle contactStyle,
  ) {
    pw.Widget sep() => pw.Text(' | ', style: contactStyle);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(ResumeConstants.name, style: nameStyle),
        pw.SizedBox(height: 5),
        pw.Text(ResumeConstants.title, style: titleStyle),
        pw.SizedBox(height: 6),

        // Contact row (Email | LinkedIn | GitHub)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.UrlLink(
              destination: 'mailto:${ResumeConstants.contactEmail}',
              child: pw.Text(ResumeConstants.contactEmail, style: contactStyle),
            ),
            sep(),
            pw.UrlLink(
              destination: ResumeConstants.contactLinkedIn,
              child: pw.Text('LinkedIn', style: contactStyle),
            ),
            sep(),
            pw.UrlLink(
              destination: ResumeConstants.contactGitHub,
              child: pw.Text('GitHub', style: contactStyle),
            ),
          ],
        ),
        pw.SizedBox(height: 4),

        // Website
        pw.UrlLink(
          destination: 'https://ekincan.casim.net',
          child: pw.Text('ekincan.casim.net', style: contactStyle),
        ),
        pw.SizedBox(height: 2),

        // Location | Phone
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(ResumeConstants.location, style: contactStyle),
            sep(),
            pw.UrlLink(
              destination: 'tel:${ResumeConstants.contactPhone.replaceAll(' ', '')}',
              child: pw.Text(ResumeConstants.contactPhone, style: contactStyle),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- Summary ----------
  static pw.Widget _buildSummary(pw.TextStyle style) {
    return pw.Text(ResumeConstants.profileIntro, style: style);
  }

  // ---------- Experience (fallback pagination strategy) ----------
  static pw.Widget _buildExperienceEntryPaginated({
    required String company,
    required String position,
    required String location,
    required String period,
    required List<String> responsibilities,
    List<String>? projects,
    required pw.TextStyle companyStyle,
    required pw.TextStyle positionStyle,
    required pw.TextStyle locationStyle,
    required pw.TextStyle bodyStyle,
  }) {
    final normalizedPeriod = period.replaceAll('–', 'to').replaceAll('—', 'to');
    final headerLineText = '$position | $company | ${_extractLocation(location)} | $normalizedPeriod';

    // Build responsibility bullets once
    List<pw.Widget> buildRespBullets(List<String> items) => items
        .map((point) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('•  ', style: bodyStyle),
                  pw.Expanded(child: pw.Text(point, style: bodyStyle)),
                ],
              ),
            ))
        .toList();

    final blocks = <pw.Widget>[
      pw.Text(headerLineText, style: positionStyle),
      _vSpace(6),
    ];

    // Responsibilities in chunks — reduces mid-page splits
    final respChunks = _chunk<String>(responsibilities, 4);
    for (final chunk in respChunks) {
      blocks.add(pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: buildRespBullets(chunk),
      ));
    }

    // Notable Projects (optional) with small “title + first chunk” group
    final hasProjects = projects != null && projects.isNotEmpty;
    if (hasProjects) {
      final projChunks = _chunk<String>(projects, 4);

      blocks.add(_vSpace(6));
      blocks.add(pw.Text('Notable Projects', style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)));
      blocks.add(_vSpace(3));

      // First chunk
      blocks.add(pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: projChunks.first
            .map((p) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('– ', style: bodyStyle),
                      pw.Expanded(child: pw.Text(p, style: bodyStyle)),
                    ],
                  ),
                ))
            .toList(),
      ));

      // Remaining chunks (if any)
      for (var i = 1; i < projChunks.length; i++) {
        blocks.add(pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: projChunks[i]
              .map((p) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('– ', style: bodyStyle),
                        pw.Expanded(child: pw.Text(p, style: bodyStyle)),
                      ],
                    ),
                  ))
              .toList(),
        ));
      }
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: blocks,
      ),
    );
  }

  // ---------- Core Skills ----------
  static pw.Widget _buildCoreSkills(pw.TextStyle style, pw.Font boldFont) {
    final Map<String, List<String>> simplifiedSkills = {
      'Programming Languages': _extractSkillList(['Programming Languages']),
      'Frameworks & Libraries': _extractSkillList(['Frontend Technologies', 'Backend Technologies']),
      'Database Technologies': _extractSkillList(['Databases']),
      'DevOps & Cloud': _extractSkillList(['Cloud & DevOps']),
      'Version Control & Collaboration': _extractSkillList(['Version Control & Collaboration']),
      'Testing & Quality Assurance': _extractSkillList(['Testing & Quality Assurance']),
    };

    final List<pw.Widget> skillSections = simplifiedSkills.entries.map((entry) {
    final category = entry.key;
    final skills = entry.value;

    if (skills.isEmpty) return pw.SizedBox();

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 150, 
            child: pw.Text(
              category,
              style: style.copyWith(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          // Skills list
          pw.Expanded(
            child: pw.Text(
              skills.join(', '),
              style: style,
            ),
          ),
        ],
      ),
    );
  }).toList();

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start, children: skillSections);
  }

  static List<String> _extractSkillList(List<String> categories) {
    final result = <String>[];
    for (final category in categories) {
      if (ResumeConstants.skills.containsKey(category)) {
        final subcategories = ResumeConstants.skills[category]!;
        for (final subEntry in subcategories.entries) {
          result.addAll(subEntry.value);
        }
      }
    }
    return result;
  }

  // ---------- Education ----------
  static pw.Widget _buildEducation(pw.TextStyle style, pw.Font boldFont) {
    final blocks = ResumeConstants.educationSummary
        .split(RegExp(r'\n\s*\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final widgets = <pw.Widget>[];

    for (final block in blocks) {
      final lines = block.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

      String universityLine = lines.isNotEmpty ? lines.first : '';
      String period = '';
      String degreeLine = lines.length > 1 ? lines[1] : '';

      final pipeIdx = universityLine.indexOf(' | ');
      if (pipeIdx >= 0) {
        period = universityLine.substring(pipeIdx + 3).trim();
        universityLine = universityLine.substring(0, pipeIdx).trim();
      }
      period = period.replaceAll('–', 'to').replaceAll('—', 'to');

      if (degreeLine.isNotEmpty) {
        // normalize common verbose phrasing a bit (optional)
        degreeLine = degreeLine.replaceAll(RegExp(r'\s+'), ' ').trim();
      }

      widgets.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(universityLine, style: style.copyWith(fontWeight: pw.FontWeight.bold)),
            ),
            if (period.isNotEmpty) pw.Text(period, style: style),
          ],
        ),
      );

      if (degreeLine.isNotEmpty) {
        widgets.add(pw.Text(degreeLine, style: style));
      }
      widgets.add(pw.SizedBox(height: 6));
    }

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: widgets);
  }

  // ---------- Parsers ----------
  static String _extractLocation(String locationString) {
    final idx = locationString.indexOf(' | ');
    return idx >= 0 ? locationString.substring(0, idx).trim() : locationString.trim();
  }

}
