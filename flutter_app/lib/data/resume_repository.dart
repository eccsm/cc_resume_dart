import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/resume.dart';

/// Fetches /data/resume.json (emitted from site/src/data/resume.ts) and
/// exposes it as [Resume.I]. The future is memoized so multiple Flutter
/// views booted from the host page share one fetch.
class ResumeRepository {
  ResumeRepository._();

  static Future<Resume>? _future;

  static Future<Resume> load() => _future ??= _fetch();

  /// Clears the memoized failure so the error screen's Retry works.
  static Future<Resume> retry() {
    _future = null;
    return load();
  }

  static Future<Resume> _fetch() async {
    // Embedded in the Astro shell, Uri.base is the host page origin, so this
    // resolves to casim.net/data/resume.json. Non-web builds (not part of
    // the deployment) fall back to the production URL.
    final uri = kIsWeb
        ? Uri.base.resolve('/data/resume.json')
        : Uri.parse('https://casim.net/data/resume.json');

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw ResumeLoadException('HTTP ${response.statusCode} for $uri');
    }
    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final resume = Resume.fromJson(json);
    Resume.current = resume;
    return resume;
  }
}

class ResumeLoadException implements Exception {
  final String message;
  const ResumeLoadException(this.message);
  @override
  String toString() => 'ResumeLoadException: $message';
}
