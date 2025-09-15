import 'package:flutter/material.dart';
import 'package:datalens/core/app_theme.dart';
import 'package:datalens/core/app_routes.dart';
import 'package:datalens/core/app_config.dart';
import 'package:datalens/features/image_processor/view/image_processor_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const ImageProcessorPage(),
    );
  }
}
 
