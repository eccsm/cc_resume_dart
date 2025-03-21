import 'dart:convert';
import 'dart:typed_data';
// Import from ui_web to avoid deprecation warning
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

/// Web implementation of utilities for PDF handling
class WebUtils {
  /// Opens a PDF in a new browser tab
  static void openPdfInBrowser(Uint8List pdfBytes) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    
    // Clean up the URL after a delay to free memory
    Future.delayed(const Duration(minutes: 1), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  /// Downloads a PDF file through the browser
  static void downloadPdf(Uint8List pdfBytes, String fileName) {
    // Convert to base64
    final base64data = base64Encode(pdfBytes);
    
    // Create download link
    final a = html.AnchorElement(
      href: 'data:application/pdf;base64,$base64data',
    )
      ..download = fileName
      ..style.display = 'none';
    
    // Add to DOM, trigger click, remove
    html.document.body?.append(a);
    a.click();
    a.remove();
  }

  /// Registers a view factory for PDF viewer (if needed)
  static void registerWebViewFactory(String viewType, Function(int viewId) builder) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, builder);
  }
}