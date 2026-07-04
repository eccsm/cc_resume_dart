import 'dart:convert';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;


class WebUtils {
  static void openPdfInBrowser(Uint8List pdfBytes) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    
    Future.delayed(const Duration(minutes: 1), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  static void downloadPdf(Uint8List pdfBytes, String fileName) {
    final base64data = base64Encode(pdfBytes);
    
    final a = html.AnchorElement(
      href: 'data:application/pdf;base64,$base64data',
    )
      ..download = fileName
      ..style.display = 'none';
    
    html.document.body?.append(a);
    a.click();
    a.remove();
  }


}