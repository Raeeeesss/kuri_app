import 'package:flutter/foundation.dart';

class UpdateLogger {
  static void logHeader(String title) {
    if (kDebugMode) {
      final bar = '=' * 16;
      debugPrint('$bar $title $bar');
    }
  }

  static void logFooter() {
    if (kDebugMode) {
      debugPrint('=' * 46);
    }
  }

  /// Prints each line without any prefix — used for the structured update block.
  static void logRaw(String message) {
    if (kDebugMode) {
      debugPrint(message);
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
