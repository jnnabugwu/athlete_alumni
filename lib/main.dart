import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/supabase_config.dart';
import 'core/di/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Use URL strategy without hash (#) for cleaner web URLs
  setUrlStrategy(PathUrlStrategy());
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AthleteAlumni',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}