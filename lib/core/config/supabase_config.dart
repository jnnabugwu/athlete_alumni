import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:js' as js;

class SupabaseConfig {
  static String get supabaseUrl {
    try {
      if (kIsWeb) {
        if (js.context['ENV'] == null) {
          debugPrint('❌ ERROR: window.ENV is not defined! Check if config.js is loaded');
          throw Exception('window.ENV is not defined');
        }
        final env = js.context['ENV'];
        if (env['SUPABASE_URL'] == null) {
          debugPrint('❌ ERROR: SUPABASE_URL not found in window.ENV');
          throw Exception('SUPABASE_URL not found in config');
        }
        final url = env['SUPABASE_URL'] as String;
        debugPrint('✅ Loaded Supabase URL from web config: $url');
        return url;
      }
      return dotenv.env['SUPABASE_URL'] ?? '';
    } catch (e) {
      debugPrint('❌ Error getting Supabase URL: $e');
      rethrow;
    }
  }

  static String get supabaseAnonKey {
    try {
      if (kIsWeb) {
        if (js.context['ENV'] == null) {
          debugPrint('❌ ERROR: window.ENV is not defined! Check if config.js is loaded');
          throw Exception('window.ENV is not defined');
        }
        final env = js.context['ENV'];
        if (env['SUPABASE_ANON_KEY'] == null) {
          debugPrint('❌ ERROR: SUPABASE_ANON_KEY not found in window.ENV');
          throw Exception('SUPABASE_ANON_KEY not found in config');
        }
        final key = env['SUPABASE_ANON_KEY'] as String;
        debugPrint('✅ Loaded Supabase Anon Key from web config');
        return key;
      }
      return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    } catch (e) {
      debugPrint('❌ Error getting Supabase Anon Key: $e');
      rethrow;
    }
  }

  static Future<void> initialize() async {
    try {
      if (!kIsWeb) {
        await dotenv.load();
      }
      
      final url = supabaseUrl;
      final key = supabaseAnonKey;
      
      debugPrint('🔄 Initializing Supabase...');
      debugPrint('📍 URL Length: ${url.length}');
      debugPrint('🔑 Key Length: ${key.length}');
      
      await Supabase.initialize(
        url: url,
        anonKey: key,
        debug: true,
      );
      
      // Test the connection
      final client = Supabase.instance.client;
      debugPrint('🔍 Testing connection...');
      try {
        // Simple test query that should always work
        await client.from('_dummy_test').select().limit(1);
        debugPrint('✅ Connection test successful!');
      } catch (e) {
        debugPrint('⚠️ Connection test failed: $e');
      }
      
      debugPrint('✅ Supabase initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing Supabase: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
} 