// lib/service/webllm_service_mobile.dart
//
// Mobile/desktop implementation, compiled when dart.library.io is available.
// WebLLM only runs in browsers, so this always answers from the keyword
// fallback grounded in ResumeConstants.

import 'dart:async';

import '../data/resume_knowledge.dart';
import 'webllm_service.dart';

class WebLLMServiceMobile extends WebLLMService {
  WebLLMServiceMobile() : super.base() {
    enableFallbackMode();
  }

  @override
  Future<void> initializeEngine() async => enableFallbackMode();

  @override
  Future<void> setFallbackMode(bool fallback) async => enableFallbackMode();

  @override
  Future<Stream<String>> sendMessage(String content) async {
    final responseController = StreamController<String>();

    addMessage(Message(content: content, role: 'user'));

    final response = ResumeKnowledge.keywordResponse(content);
    responseController.add(response);
    await Future.delayed(const Duration(milliseconds: 100));

    addMessage(Message(content: response, role: 'assistant'));

    responseController.close();
    return responseController.stream;
  }
}

WebLLMService getWebLLMService() => WebLLMServiceMobile();
