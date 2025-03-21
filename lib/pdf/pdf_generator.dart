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
    final headerNameStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 24,
      color: PdfColors.black,
    );
    
    final headerTitleStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 16,
      color: PdfColors.black,
    );
    
    final headerContactStyle = pw.TextStyle(
      font: font,
      fontSize: 11,
      color: PdfColors.black,
    );
    
    final sectionTitleStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 14,
      color: PdfColors.black,
    );
    
    final companyNameStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 12,
      color: PdfColors.black,
    );
    
    final positionStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 12,
      color: PdfColors.black,
    );
    
    final normalStyle = pw.TextStyle(
      font: font,
      fontSize: 11,
      color: PdfColors.black,
    );
    
    final locationPeriodStyle = pw.TextStyle(
      font: font,
      fontSize: 11,
      color: PdfColors.black,
    );
    
    // Add pages to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header section
          _buildHeader(
            headerNameStyle, 
            headerTitleStyle, 
            headerContactStyle
          ),
          pw.SizedBox(height: 20),
          
          // Professional Summary
          _buildSummary(normalStyle),
          pw.SizedBox(height: 20),
          
          // Work Experience
          pw.Text('Work Experience', style: sectionTitleStyle),
          pw.SizedBox(height: 10),
          
          // Experience entries
          ...ResumeConstants.experiences.map((exp) => _buildExperienceEntry(
            company: exp.title,
            position: exp.role,
            location: exp.location,
            period: _extractPeriod(exp.location),
            responsibilities: exp.points,
            projects: exp.notableProjects,
            companyStyle: companyNameStyle,
            positionStyle: positionStyle,
            locationStyle: locationPeriodStyle,
            bodyStyle: normalStyle,
          )),
          
          // Core Skills
          pw.SizedBox(height: 10),
          pw.Text('Core Skills', style: sectionTitleStyle),
          pw.SizedBox(height: 5),
          _buildCoreSkills(normalStyle, boldFont),
          
          // Education
          pw.SizedBox(height: 10),
          pw.Text('Education', style: sectionTitleStyle),
          pw.SizedBox(height: 5),
          _buildEducation(normalStyle, boldFont),
          
          // Languages and Certificates
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Languages', style: sectionTitleStyle),
                    pw.SizedBox(height: 5),
                    pw.Text(ResumeConstants.languages, style: normalStyle),
                  ],
                ),
              ),
              pw.SizedBox(width: 40),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Certificates', style: sectionTitleStyle),
                    pw.SizedBox(height: 5),
                    _buildCertificates(normalStyle),
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
  
  static pw.Widget _buildHeader(
    pw.TextStyle nameStyle,
    pw.TextStyle titleStyle,
    pw.TextStyle contactStyle
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Name
        pw.Text(ResumeConstants.name, style: nameStyle),
        pw.SizedBox(height: 5),
        
        // Title
        pw.Text(ResumeConstants.title, style: titleStyle),
        pw.SizedBox(height: 5),
        
        // Contact information in a row
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(ResumeConstants.contactEmail, style: contactStyle),
            pw.Text(' | ', style: contactStyle),
            pw.Text('LinkedIn', style: contactStyle),
          ],
        ),
        pw.SizedBox(height: 2),
        
        // Website
        pw.Text('ekincan.casim.net', style: contactStyle),
        pw.SizedBox(height: 2),
        
        // Location and phone
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(ResumeConstants.location, style: contactStyle),
            pw.Text(' | ', style: contactStyle),
            pw.Text(ResumeConstants.contactPhone, style: contactStyle),
          ],
        ),
      ],
    );
  }
  
  static pw.Widget _buildSummary(pw.TextStyle style) {
    return pw.Text(
      ResumeConstants.profileIntro,
      style: style,
    );
  }
  
  static pw.Widget _buildExperienceEntry({
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
    // Create the list of responsibilities with hyphens instead of bullet points
    List<pw.Widget> responsibilityWidgets = responsibilities.map((point) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('- ', style: bodyStyle),
            pw.Expanded(
              child: pw.Text(point, style: bodyStyle),
            ),
          ],
        ),
      );
    }).toList();
    
    // Create list of notable projects if available
    List<pw.Widget> projectWidgets = [];
    if (projects != null && projects.isNotEmpty) {
      for (final project in projects) {
        projectWidgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('- ', style: bodyStyle),
                pw.Expanded(
                  child: pw.Text('Notable Projects: $project', style: bodyStyle),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Company and period in the same row
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(position, style: positionStyle),
            pw.Text(period, style: locationStyle),
          ],
        ),
        pw.Text('$company | ${_extractLocation(location)}', style: locationStyle),
        pw.SizedBox(height: 5),
        
        // Responsibilities with bullet points
        ...responsibilityWidgets,
        
        // Projects with bullet points if available
        ...projectWidgets,
        
        pw.SizedBox(height: 10),
      ],
    );
  }
  
  static pw.Widget _buildCoreSkills(pw.TextStyle style, pw.Font boldFont) {
    // Extract key skills from your ResumeConstants.skills map
    Map<String, List<String>> simplifiedSkills = {
      'Programming Languages': _extractSkillList(['Programming Languages']),
      'Frameworks & Libraries': _extractSkillList(['Frontend Technologies', 'Backend Technologies']),
      'Database Technologies': _extractSkillList(['Databases']),
      'DevOps & Cloud': _extractSkillList(['Cloud & DevOps']),
      'Other Technologies': _extractSkillList(['Version Control & Collaboration', 'Testing & Quality Assurance']),
    };
    
    List<pw.Widget> skillSections = [];
    
    simplifiedSkills.forEach((category, skills) {
      if (skills.isNotEmpty) {
        skillSections.add(
          pw.RichText(
            text: pw.TextSpan(
              text: '$category: ',
              style: style.copyWith(
                fontWeight: pw.FontWeight.bold,
              ),
              children: [
                pw.TextSpan(
                  text: skills.join(', '),
                  style: style,
                ),
              ],
            ),
          ),
        );
        
        skillSections.add(pw.SizedBox(height: 3));
      }
    });
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: skillSections,
    );
  }
  
  static List<String> _extractSkillList(List<String> categories) {
    List<String> result = [];
    
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
  
  static pw.Widget _buildEducation(pw.TextStyle style, pw.Font boldFont) {
    // Parse education information from ResumeConstants.educationSummary
    List<String> educationLines = ResumeConstants.educationSummary.split('\n\n');
    List<pw.Widget> educationEntries = [];
    
    for (int i = 0; i < educationLines.length; i += 2) {
      if (i + 1 < educationLines.length) {
        // Get the university and period
        String university = educationLines[i].split(' | ')[0].trim();
        String period = educationLines[i].split(' | ')[1].trim();
        
        // Get the degree and field
        List<String> degreeParts = educationLines[i + 1].split(' ');
        String degreeType = degreeParts[0].trim();
        String field = degreeParts.sublist(1).join(' ').trim();
        
        educationEntries.add(
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(university, style: style.copyWith(fontWeight: pw.FontWeight.bold)),
              pw.Text(period, style: style),
            ],
          ),
        );
        
        educationEntries.add(
          pw.Text('$degreeType $field', style: style),
        );
        
        if (i + 2 < educationLines.length) {
          educationEntries.add(pw.SizedBox(height: 5));
        }
      }
    }
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: educationEntries,
    );
  }
  
  static pw.Widget _buildCertificates(pw.TextStyle style) {
    // Parse certificates from ResumeConstants.certificates
    List<String> certificateLines = ResumeConstants.certificates.split('\n');
    List<pw.Widget> certificateEntries = [];
    
    for (int i = 0; i < certificateLines.length; i += 2) {
      if (i + 1 < certificateLines.length) {
        String certificateName = certificateLines[i].trim();
        String issuer = certificateLines[i + 1].trim();
        
        // Extract date from certificate name
        String date = '';
        List<String> parts = certificateName.split(' - ');
        if (parts.length > 1) {
          date = parts[1].trim();
          certificateName = parts[0].trim();
        }
        
        certificateEntries.add(
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(certificateName, style: style),
              ),
              pw.SizedBox(width: 10),
              pw.Text(date, style: style),
            ],
          ),
        );
        
        certificateEntries.add(
          pw.Text(issuer, style: style),
        );
        
        if (i + 2 < certificateLines.length) {
          certificateEntries.add(pw.SizedBox(height: 5));
        }
      }
    }
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: certificateEntries,
    );
  }
  
  // Helper methods for extracting location and period from the location string
  static String _extractLocation(String locationString) {
    // Extract the actual location (before the pipe or dash)
    List<String> parts = locationString.split(' | ');
    if (parts.length > 1) {
      return parts[0].trim();
    }
    
    // If there's no pipe, try with dash
    parts = locationString.split(' - ');
    if (parts.length > 1) {
      return parts[0].trim();
    }
    
    return locationString;
  }
  
  static String _extractPeriod(String locationString) {
    // Extract the period (after the pipe)
    List<String> parts = locationString.split(' | ');
    if (parts.length > 1) {
      return parts[1].trim();
    }
    
    return "";
  }
}