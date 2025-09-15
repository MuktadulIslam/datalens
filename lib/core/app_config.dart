import 'package:flutter/foundation.dart';

/// Application-wide static configuration and environment flags.
class AppConfig {
  AppConfig._();

  static const String appName = 'DataLens';
  static const String version = '1.0.0';

  /// Toggle additional logging or mock behaviors based on environment.
  static bool get isDebugMode => kDebugMode;
}


