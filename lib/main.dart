import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athlete_alumni/core/di/injection.dart' as di;
import 'package:athlete_alumni/core/router/app_router.dart';
import 'utils/init_test_data.dart';
import 'features/profile/data/datasources/mock_profile_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void _initializeData() {
  try {
    // Try to load existing athletes
    final existingAthletes = MockProfileData.loadAthletes();
    
    if (existingAthletes.isEmpty) {
      // No athletes found, generate initial data
      print('No athlete data found. Initializing mock data...');
      final initialAthletes = MockProfileData.getInitialAthletes();
      MockProfileData.saveAthletes(initialAthletes);
      print('✅ Successfully initialized ${initialAthletes.length} mock athletes');
    } else {
      // If we have fewer than 10 athletes, regenerate
      if (existingAthletes.length < 10) {
        print('Found only ${existingAthletes.length} athletes - regenerating data...');
        final initialAthletes = MockProfileData.getInitialAthletes();
        MockProfileData.saveAthletes(initialAthletes);
        print('✅ Successfully regenerated ${initialAthletes.length} mock athletes');
      } else {
        print('✅ Found existing athlete data: ${existingAthletes.length} athletes');
      }
    }
  } catch (e) {
    // Handle any errors during initialization
    print('❌ Error initializing mock data: $e');
    print('Attempting to reset with initial data...');
    
    // Fallback: reset with initial data
    try {
      final initialAthletes = MockProfileData.getInitialAthletes();
      MockProfileData.saveAthletes(initialAthletes);
      print('✅ Successfully reset with ${initialAthletes.length} mock athletes');
    } catch (e2) {
      print('❌ Critical error initializing mock data: $e2');
    }
  }
}

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
    
    // Initialize test data for development
    if (kDebugMode) {
      await TestDataInitializer.initializeAthleteData(count: 50);
      print('✅ Test data initialized');
    }

    // Initialize mock data before running the app
    _initializeData();

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