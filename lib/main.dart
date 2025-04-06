import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athlete_alumni/core/di/injection.dart' as di;
import 'package:athlete_alumni/core/router/app_router.dart';
import 'package:athlete_alumni/utils/environment.dart';
import 'package:athlete_alumni/core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize environment variables first
    await Environment.initialize();
    if (kDebugMode) {
      print('✅ Environment initialized successfully');
      
      // Get and log Supabase configuration
      final supabaseUrl = Environment.supabaseUrl;
      print('🔍 Supabase URL configured as: $supabaseUrl');
      print('🔍 URL length: ${supabaseUrl.length}');
    }
    
    // Initialize Supabase using our config
    await SupabaseConfig.initialize();
    if (kDebugMode) {
      print('✅ Supabase initialized successfully');
    }

    // Initialize dependency injection
    await di.init();
    if (kDebugMode) {
      print('✅ Dependency injection initialized');
    }

    runApp(const MyApp());

  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ Error during initialization:');
      print('Error type: ${e.runtimeType}');
      print('Error details: $e');
      print('Stack trace: $stackTrace');
    }
    
    // Show error UI instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 20),
                Text(
                  'Error initializing app:',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  e.toString(),
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // This is a simple restart attempt
                    // In a real app, you'd want a more robust solution
                    main();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
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