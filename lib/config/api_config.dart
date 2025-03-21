import 'dart:convert';
import 'dart:io';
import 'package:cc_resume_app/pdf/pdf_generator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../pdf/web_utils.dart';
import 'env_config.dart';

class ApiConfig {
  static String baseUrl = EnvConfig.apiBaseUrl;

  /// GET /ask?q=...&model=...
  static String askEndpoint(String query, String model) =>
      '$baseUrl/ask?q=${Uri.encodeComponent(query)}&model=${Uri.encodeComponent(model)}';

  /// POST /update_model
  static String updateModelEndpoint() => '$baseUrl/update_model';

  /// POST /recognize?task=...
  static String recognizeEndpoint(String task) =>
      '$baseUrl/recognize?task=${Uri.encodeComponent(task)}';

  /// Returns default headers for HTTP requests.
  /// When [isJson] is true, it adds the JSON content type.
  static Map<String, String> defaultHeaders({bool isJson = true}) {
    return {
      'X-API-Key': EnvConfig.apiKey,
      if (isJson) 'Content-Type': 'application/json',
    };
  }

  /// Parses a result string into a list of widgets.
  /// It detects code blocks wrapped in triple backticks and returns a widget
  /// for normal text segments and for code blocks with a monospaced style.
  static List<Widget> parseResult(String result) {
    // Regex captures code blocks delimited by triple backticks.
    // It ignores any optional language specifier.
    final RegExp codeBlockRegExp = RegExp(r'```(?:\w+)?\n([\s\S]*?)```');
    final matches = codeBlockRegExp.allMatches(result);
    List<Widget> widgets = [];
    int lastIndex = 0;

    for (final match in matches) {
      // Add normal text before this code block.
      if (match.start > lastIndex) {
        final normalText = result.substring(lastIndex, match.start).trim();
        if (normalText.isNotEmpty) {
          widgets.add(Text(normalText, style: const TextStyle(fontSize: 16)));
        }
      }
      // Extract code block content (group 1 captures the code).
      final codeContent = match.group(1)?.trim() ?? "";
      if (codeContent.isNotEmpty) {
        widgets.add(Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              codeContent,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.greenAccent,
              ),
            ),
          ),
        ));
      }
      lastIndex = match.end;
    }
    // Add any remaining normal text after the last code block.
    if (lastIndex < result.length) {
      final remainingText = result.substring(lastIndex).trim();
      if (remainingText.isNotEmpty) {
        widgets.add(Text(remainingText, style: const TextStyle(fontSize: 16)));
      }
    }
    return widgets;
  }

  /// Extracts an error detail from a JSON error response.
  /// If the response contains a 'detail' field, it returns that value;
  /// otherwise, it returns the raw response body.
  static String extractErrorDetail(String responseBody) {
    try {
      final Map<String, dynamic> data = jsonDecode(responseBody);
      if (data.containsKey('detail')) {
        return data['detail'].toString();
      }
    } catch (_) {}
    return responseBody;
  }

static Future<void> exportResumePdf(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Generate PDF
    Uint8List? pdfBytes;
    try {
      pdfBytes = await PdfGenerator.generateResumePdf();
    } catch (e, stackTrace) {
      debugPrint('Error generating PDF: $e\n$stackTrace');
    }

    // Close loading indicator
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();

    // Handle PDF generation failure
    if (pdfBytes == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate PDF.')),
      );
      return;
    }

    // Show options for opening or downloading the PDF
    // ignore: use_build_context_synchronously
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('PDF Generated'),
          content: const Text('Do you want to open or download this PDF?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _openPdf(context, pdfBytes!);
              },
              child: const Text('Open'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _downloadPdf(context, pdfBytes!);
              },
              child: const Text('Download'),
            ),
          ],
        );
      },
    );
  }

  // Method to open the PDF
  static Future<void> _openPdf(BuildContext context, Uint8List pdfBytes) async {
    if (kIsWeb) {
      // Web implementation - delegated to web_utils_web.dart
      WebUtils.openPdfInBrowser(pdfBytes);
    } else {
      // Mobile/Desktop
      try {
        final tempDir = await getTemporaryDirectory();
        final pdfFile = File('${tempDir.path}/resume.pdf');
        await pdfFile.writeAsBytes(pdfBytes);

        // Open the PDF
        final result = await OpenFilex.open(pdfFile.path);
        if (result.type != ResultType.done) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening PDF: ${result.message}')),
          );
        }
      } catch (e) {
        debugPrint('Error opening PDF: $e');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening PDF')),
        );
      }
    }
  }

  // Method to download the PDF
  static Future<void> _downloadPdf(BuildContext context, Uint8List pdfBytes) async {
    if (kIsWeb) {
      // Web implementation - delegated to web_utils_web.dart
      WebUtils.downloadPdf(pdfBytes, 'resume.pdf');
    } else {
      // Mobile/Desktop
      try {
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          // Try to use Downloads directory on Android
          downloadsDir = Directory('/storage/emulated/0/Download');
        }

        if (downloadsDir == null || !downloadsDir.existsSync()) {
          // Fallback to temp directory
          downloadsDir = await getTemporaryDirectory();
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final pdfFile = File('${downloadsDir.path}/resume_$timestamp.pdf');
        await pdfFile.writeAsBytes(pdfBytes);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to: ${pdfFile.path}')),
        );
      } catch (e) {
        debugPrint('Error downloading PDF: $e');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error downloading PDF')),
        );
      }
    }
  }
}


