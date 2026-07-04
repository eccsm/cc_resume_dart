import 'dart:io';
import 'package:cc_resume_app/pdf/pdf_generator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'web_utils.dart';


class PdfConfig {

  static List<Widget> parseResult(String result) {
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


static Future<void> exportResumePdf(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );


    Uint8List? pdfBytes;
    try {
      pdfBytes = await PdfGenerator.generateResumePdf();
    } catch (e, stackTrace) {
      debugPrint('Error generating PDF: $e\n$stackTrace');
    }

    if (!context.mounted) return;
    Navigator.of(context).pop();

    if (pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate PDF.')),
      );
      return;
    }

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
      WebUtils.openPdfInBrowser(pdfBytes);
    } else {
      try {
        final tempDir = await getTemporaryDirectory();
        final pdfFile = File('${tempDir.path}/resume.pdf');
        await pdfFile.writeAsBytes(pdfBytes);

        final result = await OpenFilex.open(pdfFile.path);
        if (result.type != ResultType.done && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening PDF: ${result.message}')),
          );
        }
      } catch (e) {
        debugPrint('Error opening PDF: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error opening PDF')),
          );
        }
      }
    }
  }

  static Future<void> _downloadPdf(BuildContext context, Uint8List pdfBytes) async {
    if (kIsWeb) {
      WebUtils.downloadPdf(pdfBytes, 'resume.pdf');
    } else {
      try {
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
        }

        if (downloadsDir == null || !downloadsDir.existsSync()) {
          downloadsDir = await getTemporaryDirectory();
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final pdfFile = File('${downloadsDir.path}/resume_$timestamp.pdf');
        await pdfFile.writeAsBytes(pdfBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF saved to: ${pdfFile.path}')),
          );
        }
      } catch (e) {
        debugPrint('Error downloading PDF: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error downloading PDF')),
          );
        }
      }
    }
  }
}