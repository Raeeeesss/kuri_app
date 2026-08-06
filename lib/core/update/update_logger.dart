import 'package:flutter/foundation.dart';

class UpdateLogger {
  static void logHeader(String title) {
    if (kDebugMode) {
      debugPrint('========== $title ==========');
    }
  }

  static void logFooter() {
    if (kDebugMode) {
      debugPrint('=================================');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[UPDATE INFO] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('[UPDATE WARNING] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[UPDATE ERROR] $message');
      if (error != null) debugPrint('Error detail: $error');
      if (stackTrace != null) debugPrint('StackTrace:\n$stackTrace');
    }
  }
}
