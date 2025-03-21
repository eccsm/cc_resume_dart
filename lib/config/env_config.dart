// lib/config/env_config.dart
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();
  
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }
  

  static String get(String key, [String defaultValue = '']) {
    return dotenv.env[key] ?? defaultValue;
  }
  
  static String get githubApiToken => get('GITHUB_API_TOKEN');

  static String get apiBaseUrl => get('API_BASE_URL');
  
  static String get apiKey => get('API_KEY');

  static final _chatEnvString = dotenv.env['FUNNY_MESSAGES_CHAT'] ?? '';
  static final _modelChangeEnvString = dotenv.env['FUNNY_MESSAGES_MODEL_CHANGE'] ?? '';

  static final List<String> _chatMessages = _chatEnvString.split('|').map((s) => s.trim()).toList();
  static final List<String> _modelChangeMessages = _modelChangeEnvString.split('|').map((s) => s.trim()).toList();

  static final _rand = Random();

  static String randomChatMessage() {
    if (_chatMessages.isEmpty) return 'Thinking…';
    return _chatMessages[_rand.nextInt(_chatMessages.length)];
  }

  static String randomModelChangeMessage() {
    if (_modelChangeMessages.isEmpty) return 'Changing model…';
    return _modelChangeMessages[_rand.nextInt(_modelChangeMessages.length)];
  }
  
}