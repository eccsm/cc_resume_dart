import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'env_config.dart';
import 'package:http/http.dart' as http;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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

  /// GET /generate_resume_pdf
  static String generateResumePdfEndpoint() => '$baseUrl/generate_resume_pdf';

   static Future<Uint8List?> fetchResumePdf() async {
    final url = generateResumePdfEndpoint();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: defaultHeaders(isJson: false), // no JSON needed for PDF
      );
      if (response.statusCode == 200) {
        return response.bodyBytes; // The PDF bytes
      } else {
        debugPrint('Failed to fetch PDF. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching PDF: $e\n$stackTrace');
      return null;
    }
  }

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

  static Future<void> handleOpenPdf(BuildContext context, Uint8List pdfBytes) async {
  if (kIsWeb) {
    // Web: open PDF in a new tab
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');

    // Optionally revoke the object URL later to free memory:
    // html.Url.revokeObjectUrl(url);

  } else {
    // Mobile/Desktop
    try {
      final tempDir = await getTemporaryDirectory();
      final pdfFile = File('${tempDir.path}/resume.pdf');
      await pdfFile.writeAsBytes(pdfBytes);

      // Open the PDF
      final result = await OpenFilex.open(pdfFile.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening PDF: ${result.message}')),
        );
      }
    } catch (e, st) {
      debugPrint('Error opening PDF: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error opening PDF')),
      );
    }
  }
}

static Future<void> handleDownloadPdf(BuildContext context, Uint8List pdfBytes) async {
  if (kIsWeb) {
    // Web: Force file download
    final base64data = base64Encode(pdfBytes);
    final a = html.AnchorElement(
      href: 'data:application/octet-stream;base64,$base64data',
    )
      ..download = 'resume.pdf'
      ..target = 'blank';
    html.document.body?.append(a);
    a.click();
    a.remove();
  } else {
    // Mobile/Desktop
    try {
      // Attempt to save in Downloads directory (Android only).
      // iOS does not allow direct filesystem access to 'Downloads', so fallback to temp.
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        // or use a library like ext_storage to get the official downloads dir
      }

      if (downloadsDir == null || !downloadsDir.existsSync()) {
        // fallback to temp if not Android or folder not found
        downloadsDir = await getTemporaryDirectory();
      }

      final pdfFile = File('${downloadsDir.path}/resume_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await pdfFile.writeAsBytes(pdfBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to: ${pdfFile.path}')),
      );
    } catch (e, st) {
      debugPrint('Error downloading PDF: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error downloading PDF')),
      );
    }
  }
}


}
