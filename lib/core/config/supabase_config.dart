import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:js' as js;
import '../../utils/environment.dart';
import '../../features/auth/data/services/google_auth_service.dart';

class SupabaseConfig {
  static String get supabaseUrl {
    try {
      // Use our Environment utility class that has fallbacks
      return Environment.supabaseUrl;
    } catch (e) {
      debugPrint('❌ Error getting Supabase URL: $e');
      // Return fallback directly here as a last resort
      return 'https://kszcjniwbqxyndpsajhr.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    try {
      // Use our Environment utility class that has fallbacks
      return Environment.supabaseAnonKey;
    } catch (e) {
      debugPrint('❌ Error getting Supabase Anon Key: $e');
      // Return fallback directly here as a last resort
      return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzemNqbml3YnF4eW5kcHNhamhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2NTEzNjQsImV4cCI6MjA1OTIyNzM2NH0.UnN4xuo783XDrR5nQTlwZAIcW6DqrbFY3bo4nssOvu4';
    }
  }

  static Future<void> initialize() async {
    try {
      if (!kIsWeb) {
        await dotenv.load().catchError((e) {
          debugPrint('⚠️ Warning: Could not load .env file: $e');
          debugPrint('Using fallback values instead');
        });
      }
      
      final url = supabaseUrl;
      final key = supabaseAnonKey;
      
      debugPrint('🔄 Initializing Supabase...');
      debugPrint('📍 URL Length: ${url.length}');
      debugPrint('🔑 Key Length: ${key.length}');
      
      if (url.isEmpty || key.isEmpty) {
        throw AssertionError('Supabase URL or Anon Key is empty. Check your configuration.');
      }
      
      await Supabase.initialize(
        url: url,
        anonKey: key,
        debug: kDebugMode,
      );
      
      // Test the connection
      final client = Supabase.instance.client;
      debugPrint('🔍 Testing connection...');
      try {
        // Simple test query that should always work
        await client.from('athletes').select('id').limit(1);
        debugPrint('✅ Connection test successful!');
      } catch (e) {
        debugPrint('⚠️ Connection test failed: $e');
      }
      
      // Handle OAuth redirects for web (if we came from an OAuth flow)
      if (kIsWeb) {
        debugPrint('🔄 Checking for OAuth redirects...');
        
        // Delay slightly to ensure the app is fully loaded
        await Future.delayed(Duration(milliseconds: 500));
        
        _handlePossibleOAuthRedirect(client);
      }
      
      debugPrint('✅ Supabase initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing Supabase: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Handle OAuth redirects for web platforms
  static void _handlePossibleOAuthRedirect(SupabaseClient client) {
    if (!kIsWeb) return;
    
    try {
      // Create a GoogleAuthService instance to handle the redirect
      final googleAuthService = GoogleAuthService();
      
      // Use the improved method that properly refreshes the session
      googleAuthService.checkForRedirectSession().then((success) {
        if (success) {
          debugPrint('✅ Successfully processed OAuth redirect and established session');
          // The Google auth service has already refreshed the session
        } else {
          debugPrint('ℹ️ No OAuth redirect detected or session couldn\'t be established');
        }
      }).catchError((error) {
        debugPrint('❌ Error handling OAuth redirect: $error');
      });
    } catch (e) {
      debugPrint('❌ Error handling OAuth redirect: $e');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
} 