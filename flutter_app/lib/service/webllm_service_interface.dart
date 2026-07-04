import 'webllm_service.dart';

/// Default implementation factory that will be overridden by platform-specific versions
WebLLMService getWebLLMService() => throw UnsupportedError(
    'Cannot create a WebLLMService without the packages dart:html or dart:io');