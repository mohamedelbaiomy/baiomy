import 'package:flutter/foundation.dart';

class BaiomyLogger {
  BaiomyLogger._();
  static final BaiomyLogger _instance = BaiomyLogger._();
  factory BaiomyLogger() => _instance;
  static BaiomyLogger get instance => _instance;

  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[LOG] $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ [INFO] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ [WARNING] $message');
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('❌ [ERROR] $message');
      if (error != null) debugPrint('❌ Error: $error');
      if (stackTrace != null) debugPrint('❌ StackTrace: $stackTrace');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      debugPrint('✅ [SUCCESS] $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('💡 [DEBUG] $message');
    }
  }
}
