import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athlete_alumni/core/di/injection.dart' as di;
import 'package:athlete_alumni/core/router/app_router.dart';
import 'utils/init_test_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  // Initialize dependency injection
  await di.init();
  
  // Initialize test data for development
  if (kDebugMode) {
    await TestDataInitializer.initializeAthleteData(count: 50);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Athlete Alumni',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        // Add additional theming here
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}