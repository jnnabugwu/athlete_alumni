import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athlete_alumni/core/di/injection.dart' as di;
import 'package:athlete_alumni/core/router/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file first
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Loaded .env file successfully');
    
    // Get and log Supabase configuration (without the actual key)
    final supabaseUrl = dotenv.get('SUPABASE_URL');
    print('🔍 Supabase URL configured as: $supabaseUrl');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: dotenv.get('SUPABASE_ANON_KEY'),
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