import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  // Use URL strategy without hash (#) for cleaner web URLs
  setUrlStrategy(PathUrlStrategy());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    
    return MaterialApp.router(
      title: 'AthleteAlumni',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter.router,
    );
  }
}