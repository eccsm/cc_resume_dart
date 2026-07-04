import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume.dart';

class PdfGenerator {
  // Brand colors shared with the website theme
  static const PdfColor _accent = PdfColor.fromInt(0xFFE8991A);
  static const PdfColor _ink = PdfColor.fromInt(0xFF1A1D26);
  static const PdfColor _muted = PdfColor.fromInt(0xFF555B67);

  static Future<Uint8List> generateResumePdf() async {
    final pdf = pw.Document();

    // Load fonts
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();
    final italicFont = await PdfGoogleFonts.openSansItalic();

    // Define styles
    final headerNameStyle = pw.TextStyle(font: boldFont, fontSize: 24, color: _ink);
    final headerTitleStyle = pw.TextStyle(font: boldFont, fontSize: 14, color: _accent);
    final headerContactStyle = pw.TextStyle(font: font, fontSize: 10.5, color: _muted);

    final sectionTitleStyle = pw.TextStyle(font: boldFont, fontSize: 13, color: _ink, letterSpacing: 0.4);
    final companyNameStyle = pw.TextStyle(font: boldFont, fontSize: 12, color: _ink);
    final positionStyle = pw.TextStyle(font: boldFont, fontSize: 12, color: _ink);
    final normalStyle = pw.TextStyle(font: font, fontSize: 10.5, color: _ink, lineSpacing: 1.5);
    final locationPeriodStyle = pw.TextStyle(font: italicFont, fontSize: 10, color: _muted);

    // ATS notes: single-column flow, standard section headings, no repeated
    // page headers/footers (stray text confuses parsers), ASCII punctuation.
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Hero header (page 1)
          _buildHeader(headerNameStyle, headerTitleStyle, headerContactStyle),
          _vSpace(12),

          // Professional Summary
          _sectionHeader('Professional Summary', sectionTitleStyle),
          _buildSummary(normalStyle),
          _divider(),

          // Core Skills (before experience — recruiters and ATS scanners
          // both read keywords first)
          _sectionHeader('Core Skills', sectionTitleStyle),
          _buildCoreSkills(normalStyle, boldFont),
          _divider(),

          // Work Experience
          _sectionHeader('Work Experience', sectionTitleStyle),
          ...Resume.I.experiences.map((exp) => _buildExperienceEntryPaginated(
                company: exp.company,
                position: exp.role,
                location: exp.location,
                period: exp.periodLabel,
                responsibilities: exp.points,
                projects: null,
                companyStyle: companyNameStyle,
                positionStyle: positionStyle,
                locationStyle: locationPeriodStyle,
                bodyStyle: normalStyle,
              )),
          _divider(),

          // Education
          _sectionHeader('Education', sectionTitleStyle),
          _buildEducation(normalStyle, boldFont),
          _divider(),

          // Certifications (own single-column section — ATS parsers mangle
          // side-by-side columns)
          _sectionHeader('Certifications', sectionTitleStyle),
          _buildCertificatesOneLine(normalStyle),
          _divider(),

          // Languages
          _sectionHeader('Languages', sectionTitleStyle),
          pw.Text(_ats(Resume.I.languages), style: normalStyle),
        ],
      ),
    );

    return pdf.save();
  }

  /// Normalizes typographic punctuation to ASCII so older ATS text
  /// extractors never trip on it.
  static String _ats(String s) => s
      .replaceAll('–', '-') // en dash
      .replaceAll('—', '-') // em dash
      .replaceAll('→', '->') // arrow
      .replaceAll('’', "'")
      .replaceAll('“', '"')
      .replaceAll('”', '"');

  // ---------- Helpers ----------
  /// Section title with a short amber accent bar underneath.
  static pw.Widget _sectionHeader(String title, pw.TextStyle style) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title.toUpperCase(), style: style),
            pw.SizedBox(height: 3),
            pw.Container(width: 36, height: 2.2, color: _accent),
          ],
        ),
      );

  static pw.Widget _divider() => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 9),
      child: pw.Divider(thickness: 0.6, color: PdfColors.grey400));

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
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: Resume.I.certifications
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Text(
                  '• ${_ats('${c.name} - ${c.year} (${c.issuer})')}',
                  style: style,
                ),
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

    final websiteLabel =
        Resume.I.contactWebsite.replaceFirst(RegExp(r'^https?://'), '');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(Resume.I.name, style: nameStyle),
        pw.SizedBox(height: 5),
        pw.Text(Resume.I.title, style: titleStyle),
        pw.SizedBox(height: 6),

        // Contact row (Email | LinkedIn | GitHub)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.UrlLink(
              destination: 'mailto:${Resume.I.contactEmail}',
              child: pw.Text(Resume.I.contactEmail, style: contactStyle),
            ),
            sep(),
            pw.UrlLink(
              destination: Resume.I.contactLinkedIn,
              child: pw.Text('LinkedIn', style: contactStyle),
            ),
            sep(),
            pw.UrlLink(
              destination: Resume.I.contactGitHub,
              child: pw.Text('GitHub', style: contactStyle),
            ),
          ],
        ),
        pw.SizedBox(height: 4),

        // Website
        pw.UrlLink(
          destination: Resume.I.contactWebsite,
          child: pw.Text(websiteLabel, style: contactStyle),
        ),
        pw.SizedBox(height: 2),

        // Location | Phone (phone only when injected via --dart-define)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(Resume.I.location, style: contactStyle),
            if (Resume.contactPhone.isNotEmpty) ...[
              sep(),
              pw.UrlLink(
                destination:
                    'tel:${Resume.contactPhone.replaceAll(' ', '')}',
                child: pw.Text(Resume.contactPhone, style: contactStyle),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ---------- Summary ----------
  static pw.Widget _buildSummary(pw.TextStyle style) {
    return pw.Text(_ats(Resume.I.profileIntro), style: style);
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
    // Build responsibility bullets once
    List<pw.Widget> buildRespBullets(List<String> items) => items
        .map((point) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('•  ', style: bodyStyle.copyWith(color: _accent)),
                  pw.Expanded(child: pw.Text(_ats(point), style: bodyStyle)),
                ],
              ),
            ))
        .toList();

    // "Role - Company" on the first line, "Location | Period" beneath it,
    // matching the markdown resume layout (ASCII separators for ATS).
    final blocks = <pw.Widget>[
      pw.Text(_ats('$position - $company'), style: positionStyle),
      _vSpace(2),
      pw.Text(_ats('${_extractLocation(location)} | $period'),
          style: locationStyle),
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
  /// Renders every category from ResumeConstants.skills as
  /// "**Category:** item, item, item" — the same structure the website uses.
  static pw.Widget _buildCoreSkills(pw.TextStyle style, pw.Font boldFont) {
    final skillSections = Resume.I.skills.entries.map((entry) {
      final items =
          entry.value.values.expand((skills) => skills).join(', ');
      if (items.isEmpty) return pw.SizedBox();

      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 165,
              child: pw.Text(
                '${entry.key}:',
                style: style.copyWith(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Expanded(child: pw.Text(_ats(items), style: style)),
          ],
        ),
      );
    }).toList();

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: skillSections);
  }

  // ---------- Education ----------
  static pw.Widget _buildEducation(pw.TextStyle style, pw.Font boldFont) {
    final widgets = <pw.Widget>[];

    for (final entry in Resume.I.education) {
      widgets.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(_ats('${entry.institution}, ${entry.location}'),
                  style: style.copyWith(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Text(_ats(entry.periodLabel), style: style),
          ],
        ),
      );
      widgets.add(pw.Text(_ats(entry.degree), style: style));
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
