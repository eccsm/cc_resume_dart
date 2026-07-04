// lib/service/webllm_service_web.dart
//
// Web implementation, compiled when dart.library.html is available.
// Talks to window.webLLMHelper (web/assets/js/webllm_helper.js) through
// dart:js_interop — no eval, CSP-safe.

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';

import '../data/resume_knowledge.dart';
import 'webllm_service.dart';

class WebLLMServiceWeb extends WebLLMService {
  bool _isWebLLMAvailable = false;
  StreamController<String>? _respCtl;

  WebLLMServiceWeb() : super.base() {
    _log('ctor');
    _checkWebLLM();
  }

  /// The JS helper object, or null when the script did not load.
  JSObject? get _helper {
    final h = globalContext.getProperty('webLLMHelper'.toJS);
    return h.isDefinedAndNotNull ? h as JSObject : null;
  }

  @override
  void dispose() {
    _respCtl?.close();
    super.dispose();
  }

  // ---------------------------------------------------------------- init
  Future<void> _checkWebLLM() async {
    _log('checking helper');
    updateDownloadStatus('Checking WebLLM…');
    final helper = _helper;
    if (helper == null) {
      enableFallbackMode();
      return;
    }
    try {
      final ok = (await helper
              .callMethod<JSPromise<JSBoolean>>('init'.toJS)
              .toDart)
          .toDart;
      if (!ok) {
        enableFallbackMode();
        return;
      }
      _isWebLLMAvailable = true;
      _fetchModelList();
      updateDownloadStatus('');
      markCapabilityChecked();
    } catch (_) {
      enableFallbackMode();
    }
  }

  void _fetchModelList() {
    try {
      final helper = _helper;
      if (helper != null) {
        final list =
            helper.callMethod<JSAny?>('getAvailableModels'.toJS).dartify();
        if (list is List) {
          for (final m in list) {
            addAvailableModel(m.toString());
          }
        }
      }
    } catch (_) {}
    if (availableModels.isEmpty) {
      addAvailableModel(WebLLMService.defaultModel);
      addAvailableModel(WebLLMService.largerModel);
    }
  }

  // ---------------------------------------------------------------- engine
  @override
  Future<void> initializeEngine() async {
    final helper = _helper;
    if (isFallbackMode || !_isWebLLMAvailable || helper == null) {
      enableFallbackMode();
      return;
    }

    updateDownloadStatus('Downloading $selectedModel…');

    try {
      final onProgress = ((JSString status) {
        updateDownloadStatus(status.toDart);
      }).toJS;
      final result = await helper
          .callMethod<JSPromise<JSAny?>>(
              'loadModel'.toJS, selectedModel.toJS, onProgress)
          .toDart;
      if (result.dartify() == true) {
        disableFallbackMode();
        setInitialized(true);
        updateDownloadStatus('');
      } else {
        setError('Model failed to load');
        enableFallbackMode();
      }
    } catch (e) {
      setError(e.toString());
      enableFallbackMode();
    }
  }

  // ---------------------------------------------------------------- chat
  @override
  Future<Stream<String>> sendMessage(String user) async {
    _respCtl?.close();
    _respCtl = StreamController<String>.broadcast();

    addMessage(Message(role: 'user', content: user));

    // Fallback quick-answer ➜ stream it, then store it
    if (isFallbackMode) {
      final txt = ResumeKnowledge.keywordResponse(user);
      _respCtl!.addStream(_typeStream(txt)).whenComplete(() {
        addMessage(Message(role: 'assistant', content: txt));
        setGenerating(false);
        _respCtl?.close();
      });
      return _respCtl!.stream;
    }

    final helper = _helper;
    if (!isInitialized || helper == null) {
      _respCtl!.add('Model still loading, please wait.');
      _respCtl!.close();
      return _respCtl!.stream;
    }
    if (isGenerating) {
      _respCtl!.add('Still answering previous message…');
      _respCtl!.close();
      return _respCtl!.stream;
    }

    setGenerating(true);

    // History includes the grounded system prompt but not the current user
    // message — the helper appends that itself.
    final all = messages;
    final history = all
        .sublist(0, all.length - 1)
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    String assembled = '';

    final onChunk = ((JSString ch) {
      final text = ch.toDart;
      _respCtl?.add(text);
      assembled += text;
    }).toJS;
    final onDone = (() {
      _finishAssistant(assembled);
    }).toJS;
    final onErr = ((JSString e) {
      _finishAssistant('Error: ${e.toDart}');
    }).toJS;

    helper.callMethodVarArgs('generateCompletion'.toJS,
        [user.toJS, history.jsify(), onChunk, onDone, onErr]);

    return _respCtl!.stream;
  }

  void _finishAssistant(String msg) {
    final ctl = _respCtl;
    if (ctl != null && !ctl.isClosed) ctl.close();
    addMessage(Message(role: 'assistant', content: msg));
    setGenerating(false);
  }

  // ---------------------------------------------------------------- util
  /// Creates a `Stream<String>` that yields the text 3 chars at a time.
  Stream<String> _typeStream(String full) async* {
    const step = 3;
    int pos = 0;
    while (pos < full.length) {
      await Future.delayed(const Duration(milliseconds: 25));
      final end = (pos + step < full.length) ? pos + step : full.length;
      yield full.substring(pos, end);
      pos = end;
    }
  }

  void _log(String m) => debugPrint('[WebLLM] $m');

  // ---------------------------------------------------------------- modes
  @override
  Future<void> setFallbackMode(bool fallback) async {
    if (fallback) {
      enableFallbackMode();
      return;
    }

    // user wants full WebLLM again
    if (!_isWebLLMAvailable) {
      await _checkWebLLM(); // try once more
    }

    if (_isWebLLMAvailable) {
      disableFallbackMode();
      setInitialized(false);
      updateDownloadStatus('');
      await initializeEngine(); // load current model
    } else {
      enableFallbackMode(); // still impossible
    }
  }
}

// factory for conditional import
WebLLMService getWebLLMService() => WebLLMServiceWeb();
