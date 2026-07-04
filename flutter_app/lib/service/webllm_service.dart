import 'dart:async';
import 'package:flutter/foundation.dart';

import '../data/resume_knowledge.dart';

// Conditional import for platform-specific implementation
import 'webllm_service_interface.dart'
    if (dart.library.js_interop) 'webllm_service_web.dart'
    if (dart.library.io) 'webllm_service_mobile.dart';

/// Message model for WebLLM interactions
class Message {
  final String content;
  final String role;

  Message({required this.content, required this.role});

  Map<String, dynamic> toJson() => {
        'content': content,
        'role': role,
      };
}

/// Base service class for WebLLM integration.
///
/// Holds all shared state and notifier plumbing; platform implementations
/// extend this and only provide the engine-specific behaviour.
abstract class WebLLMService extends ChangeNotifier {
  // Factory constructor returns the platform-specific implementation.
  factory WebLLMService() => getWebLLMService();

  /// Generative constructor for subclasses.
  WebLLMService.base();

  /// Small on-device model (~880 MB) that loads in a reasonable time.
  /// The previous default (Llama-3-8B, ~4.5 GB) was unusable for visitors.
  static const String defaultModel = 'Llama-3.2-1B-Instruct-q4f32_1-MLC';

  /// Slightly larger alternative for capable machines.
  static const String largerModel = 'Qwen2.5-1.5B-Instruct-q4f16_1-MLC';

  // ─── State ───────────────────────────────────────────────────────
  final List<Message> _messages = [
    Message(content: ResumeKnowledge.buildSystemPrompt(), role: 'system'),
  ];
  final List<String> _availableModels = [];
  String _selectedModel = defaultModel;
  bool _isInitialized = false;
  bool _isGenerating = false;
  String _downloadStatus = '';
  String _chatStats = '';
  bool _isFallbackMode = false;
  String _lastErrorMessage = '';

  final Completer<void> _initializedCompleter = Completer<void>();
  final Completer<void> _capabilityCompleter = Completer<void>();

  // ─── Getters ─────────────────────────────────────────────────────
  List<Message> get messages => _messages.toList();
  List<String> get availableModels => List.unmodifiable(_availableModels);
  String get selectedModel => _selectedModel;
  bool get isInitialized => _isInitialized;
  bool get isGenerating => _isGenerating;
  String get downloadStatus => _downloadStatus;
  String get chatStats => _chatStats;
  bool get isFallbackMode => _isFallbackMode;
  String get lastErrorMessage => _lastErrorMessage;
  Future<void> get initialized => _initializedCompleter.future;

  /// Completes once the platform knows whether WebLLM can run at all
  /// (before any model download). UI can await this instead of guessing
  /// with arbitrary delays.
  Future<void> get capabilityChecked => _capabilityCompleter.future;

  /// Called by implementations when the browser/platform capability check
  /// has finished (in either direction).
  void markCapabilityChecked() {
    if (!_capabilityCompleter.isCompleted) {
      _capabilityCompleter.complete();
    }
  }

  // ─── Platform-specific behaviour ─────────────────────────────────
  Future<void> setFallbackMode(bool fallback);
  Future<void> initializeEngine();
  Future<Stream<String>> sendMessage(String content);

  // ─── Shared behaviour ────────────────────────────────────────────
  Future<void> resetEngine() async {
    await setFallbackMode(true);
    clearMessages();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void setSelectedModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }

  /// Refreshes the grounded system prompt, optionally injecting live
  /// GitHub repo summaries so the model can discuss current projects.
  void updateSystemPrompt({List<String> pinnedRepos = const []}) {
    if (_messages.isEmpty) return;
    _messages[0] = Message(
      content: ResumeKnowledge.buildSystemPrompt(pinnedRepos: pinnedRepos),
      role: 'system',
    );
  }

  void enableFallbackMode() {
    _isFallbackMode = true;
    _isInitialized = true; // Service is usable (canned answers) in fallback

    if (!_initializedCompleter.isCompleted) {
      _initializedCompleter.complete();
    }
    markCapabilityChecked();

    notifyListeners();
  }

  /// Leaves fallback mode (called when the real engine becomes available).
  void disableFallbackMode() {
    _isFallbackMode = false;
    notifyListeners();
  }

  void addAvailableModel(String model) {
    if (!_availableModels.contains(model)) {
      _availableModels.add(model);
      notifyListeners();
    }
  }

  void updateDownloadStatus(String status) {
    _downloadStatus = status;
    notifyListeners();
  }

  void setInitialized(bool value) {
    _isInitialized = value;

    if (value && !_initializedCompleter.isCompleted) {
      _initializedCompleter.complete();
    }

    notifyListeners();
  }

  void setGenerating(bool value) {
    _isGenerating = value;
    notifyListeners();
  }

  void updateChatStats(String stats) {
    _chatStats = stats;
    notifyListeners();
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  /// Clear all messages except the system message.
  void clearMessages() {
    if (_messages.isNotEmpty) {
      final systemMessage = _messages.first;
      _messages.clear();
      _messages.add(systemMessage);
    }
    notifyListeners();
  }

  void setError(String error) {
    _lastErrorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _lastErrorMessage = '';
    notifyListeners();
  }

  void clearModels() {
    _availableModels.clear();
    notifyListeners();
  }
}
