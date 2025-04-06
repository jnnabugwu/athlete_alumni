import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:js' as js;

/// A utility class to handle environment variables
class Environment {
  // Define hard-coded fallbacks for when all else fails
  static const String _fallbackSupabaseUrl = 'https://kszcjniwbqxyndpsajhr.supabase.co/';
  static const String _fallbackSupabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzemNqbml3YnF4eW5kcHNhamhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2NTEzNjQsImV4cCI6MjA1OTIyNzM2NH0.UnN4xuo783XDrR5nQTlwZAIcW6DqrbFY3bo4nssOvu4';

  /// Initialize environment variables
  static Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('Environment: Initializing environment - isWeb: $kIsWeb');
      }
      
      // Web environment uses embedded variables in the HTML
      if (kIsWeb) {
        if (kDebugMode) {
          print('Running on web, using inline ENV variables');
          try {
            bool hasEnvObj = js.context.hasProperty('ENV');
            print('Web ENV object exists: $hasEnvObj');
            if (hasEnvObj) {
              try {
                bool hasUrl = js.context['ENV'].hasProperty('SUPABASE_URL');
                bool hasKey = js.context['ENV'].hasProperty('SUPABASE_ANON_KEY');
                print('ENV contains SUPABASE_URL: $hasUrl');
                print('ENV contains SUPABASE_ANON_KEY: $hasKey');
                
                if (hasUrl && hasKey) {
                  print('All required web environment variables are present');
                }
              } catch (e) {
                print('Error checking web ENV properties: $e');
              }
            } else {
              print('WARNING: Web ENV object not found! Will use fallback values');
            }
          } catch (e) {
            print('Error checking web ENV: $e');
          }
        }
        return; // No need to load .env on web
      }
      
      // For non-web platforms, load from .env file
      try {
        await dotenv.load(fileName: ".env").catchError((e) {
          if (kDebugMode) {
            print('Error loading .env file: $e');
            print('Using fallback environment values');
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error loading .env: $e - Using fallback values');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing environment: $e');
      }
    }
  }

  /// Get an environment variable with a fallback value
  static String get(String key, {String fallback = ''}) {
    try {
      // For web, try to get from window.ENV
      if (kIsWeb) {
        try {
          // Check if window.ENV exists and has the key
          if (js.context.hasProperty('ENV')) {
            var env = js.context['ENV'];
            if (env != null && env.hasProperty(key)) {
              String value = env[key].toString();
              return value;
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error accessing web ENV for key $key: $e');
          }
        }
      }
      
      // For non-web or if web ENV doesn't have the key, try dotenv
      try {
        String? value = dotenv.env[key];
        if (value != null && value.isNotEmpty) {
          return value;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error getting value from dotenv: $e');
        }
      }
      
      return fallback;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting environment variable $key: $e');
      }
      return fallback;
    }
  }

  /// Get Supabase URL
  static String get supabaseUrl {
    return get('SUPABASE_URL', fallback: _fallbackSupabaseUrl);
  }

  /// Get Supabase Anon Key
  static String get supabaseAnonKey {
    return get('SUPABASE_ANON_KEY', fallback: _fallbackSupabaseKey);
  }
} 