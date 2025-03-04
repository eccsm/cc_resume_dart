import 'dart:convert';
import 'package:flutter/material.dart';
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
}
