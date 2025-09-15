import 'package:flutter/foundation.dart';

void logInfo(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('[INFO] $message');
  }
}

void logError(Object error, [StackTrace? stackTrace]) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('[ERROR] $error');
    if (stackTrace != null) {
      // ignore: avoid_print
      print(stackTrace);
    }
  }
}


