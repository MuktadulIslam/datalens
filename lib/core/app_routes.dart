import 'package:flutter/material.dart';
import 'package:datalens/features/image_processor/view/image_processor_page.dart';

/// Centralized route definitions and generator.
class AppRoutes {
  AppRoutes._();

  static const String imageProcessor = '/image-processor';
  static const String home = '/';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case imageProcessor:
      case home:
        return MaterialPageRoute(builder: (_) => const ImageProcessorPage());
      default:
        return MaterialPageRoute(builder: (_) => const ImageProcessorPage());
    }
  }
}


