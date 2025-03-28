import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // For web, we'll use these values directly
  static const String _webSupabaseUrl = 'https://kszcjniwbqxyndpsajhr.supabase.co';
  static const String _webSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzemNqbml3YnF4eW5kcHNhamhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMwMDkyNzUsImV4cCI6MjA1ODU4NTI3NX0.yq3167J6pckeTZYIMYEXdytMdoYJOSfyeMqyGFr9dpY';

  static String get supabaseUrl => kIsWeb ? _webSupabaseUrl : (dotenv.env['SUPABASE_URL'] ?? '');
  static String get supabaseAnonKey => kIsWeb ? _webSupabaseAnonKey : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  static Future<void> initialize() async {
    if (!kIsWeb) {
      await dotenv.load();
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
} 