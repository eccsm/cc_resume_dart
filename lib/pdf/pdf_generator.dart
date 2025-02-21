// lib/pdf/pdf_generator.dart

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cc_resume_app/resume_constants.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfGenerator {
  static Future<pw.Document> generateResumePdf() async {
    final pdf = pw.Document();

    // Load custom fonts
    final fonts = await _loadFonts();
    if (fonts == null) {
      throw Exception("Failed to load fonts.");
    }

    // Define text styles
    final styles = _defineStyles(fonts);

    try {
      // Add pages with MultiPage
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) => [
            _buildHeader(styles),
            _buildProfessionalSummary(styles),
            _buildSkillsSection(styles),
            _buildProfessionalExperience(styles),
            _buildEducationSection(styles),
            // Add more sections as needed
          ],
        ),
      );
    } on pw.TooManyPagesException catch (e) {
      print("PDF generation failed: Too many pages. Details: $e");
      // Optionally, handle the exception further, e.g., notify the user
    }

    return pdf;
  }

  /// Loads the custom fonts from assets.
  static Future<_Fonts?> _loadFonts() async {
    try {
      final ttf = await rootBundle.load("assets/fonts/calibri.ttf");
      final ttfBold = await rootBundle.load("assets/fonts/arial.ttf");
      return _Fonts(
        regular: pw.Font.ttf(ttf),
        bold: pw.Font.ttf(ttfBold),
      );
    } catch (e) {
      print("Error loading fonts: $e");
      return null;
    }
  }

  /// Defines the text styles used in the PDF.
  static _TextStyles _defineStyles(_Fonts fonts) {
    return _TextStyles(
      heading: pw.TextStyle(
        font: fonts.bold,
        fontSize: 20,
        color: PdfColors.indigo,
      ),
      subHeading: pw.TextStyle(
        font: fonts.bold,
        fontSize: 16,
        color: PdfColors.black,
      ),
      normal: pw.TextStyle(
        font: fonts.regular,
        fontSize: 12,
        color: PdfColors.black,
      ),
      headerName: pw.TextStyle(
        font: fonts.bold,
        fontSize: 24,
        color: PdfColors.indigo,
      ),
      headerSubtitle: pw.TextStyle(
        font: fonts.regular,
        fontSize: 14,
        color: PdfColors.black,
      ),
      headerContact: pw.TextStyle(
        font: fonts.regular,
        fontSize: 12,
        color: PdfColors.black,
      ),
    );
  }

  /// Builds the header section of the PDF.
  static pw.Widget _buildHeader(_TextStyles styles) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          ResumeConstants.name,
          style: styles.headerName,
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Software Developer',
          style: styles.headerSubtitle,
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Email: ${ResumeConstants.contactEmail} | Phone: ${ResumeConstants.contactPhone}',
          style: styles.headerContact,
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 15),
      ],
    );
  }

  /// Builds the professional summary section.
  static pw.Widget _buildProfessionalSummary(_TextStyles styles) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Professional Summary', style: styles.heading),
        pw.SizedBox(height: 5),
        pw.Text(ResumeConstants.profileIntro, style: styles.normal),
        pw.SizedBox(height: 15),
      ],
    );
  }

  /// Builds the skills section with nested categories.
  static pw.Widget _buildSkillsSection(_TextStyles styles) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ResumeConstants.skills.entries.map((categoryEntry) {
        final category = categoryEntry.key;
        final subcategories = categoryEntry.value;

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(category, style: styles.heading),
            pw.SizedBox(height: 5),
            ...subcategories.entries.map((subEntry) {
              final subcategory = subEntry.key;
              final skills = subEntry.value;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(subcategory, style: styles.subHeading),
                  pw.Bullet(
                    text: skills.join('\n• '),
                    style: styles.normal,
                  ),
                  pw.SizedBox(height: 8),
                ],
              );
            }),
            pw.SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  /// Builds the professional experience section.
  static pw.Widget _buildProfessionalExperience(_TextStyles styles) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Professional Experience', style: styles.heading),
        pw.SizedBox(height: 5),
        ...ResumeConstants.experiences.map((exp) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(exp.title, style: styles.subHeading),
              pw.Text('${exp.role} | ${exp.location}', style: styles.normal),
              pw.Bullet(
                text: exp.points.join('\n• '),
                style: styles.normal,
              ),
              if (exp.notableProjects != null && exp.notableProjects!.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Notable Projects:', style: styles.subHeading),
                    pw.Bullet(
                      text: exp.notableProjects!.join('\n• '),
                      style: styles.normal,
                    ),
                  ],
                ),
              pw.SizedBox(height: 10),
            ],
          );
        }),
      ],
    );
  }

  /// Builds the education section.
  static pw.Widget _buildEducationSection(_TextStyles styles) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Education', style: styles.heading),
        pw.SizedBox(height: 5),
        pw.Bullet(
          text: ResumeConstants.educationSummary,
          style: styles.normal,
        ),
        pw.SizedBox(height: 15),
      ],
    );
  }
}

/// Helper class to encapsulate loaded fonts.
class _Fonts {
  final pw.Font regular;
  final pw.Font bold;

  _Fonts({
    required this.regular,
    required this.bold,
  });
}

/// Helper class to encapsulate text styles.
class _TextStyles {
  final pw.TextStyle heading;
  final pw.TextStyle subHeading;
  final pw.TextStyle normal;
  final pw.TextStyle headerName;
  final pw.TextStyle headerSubtitle;
  final pw.TextStyle headerContact;

  _TextStyles({
    required this.heading,
    required this.subHeading,
    required this.normal,
    required this.headerName,
    required this.headerSubtitle,
    required this.headerContact,
  });
}
