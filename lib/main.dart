import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athlete_alumni/core/di/injection.dart' as di;
import 'package:athlete_alumni/core/router/app_router.dart';
import 'package:athlete_alumni/utils/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    // Initialize environment variables with fallbacks
    await Environment.initialize();
    print('✅ Environment initialized successfully');
    
    // Get and log Supabase configuration (without the actual key)
    final supabaseUrl = Environment.supabaseUrl;
    print('🔍 Supabase URL configured as: $supabaseUrl');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
    print('✅ Supabase initialized successfully');

    // Initialize dependency injection
    await di.init();
    print('✅ Dependency injection initialized');

    runApp(const MyApp());

  } catch (e) {
    print('❌ Error during initialization:');
    print('Error type: ${e.runtimeType}');
    print('Error details: $e');
    
    if (e is Error) {
      print('Stack trace: ${e.stackTrace}');
    }
    
    // Show error UI instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Error initializing app: ${e.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    ));
  }
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