import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:js' as js;

/// A utility class to handle environment variables
class Environment {
  /// Initialize environment variables
  static Future<void> initialize() async {
    try {
      // Only try to load .env file if not on web
      if (!kIsWeb) {
        // For non-web platforms, load from .env file
        await dotenv.load(fileName: ".env").catchError((e) {
          if (kDebugMode) {
            print('Error loading .env file: $e');
            print('Using fallback environment values');
          }
        });
      } else {
        if (kDebugMode) {
          print('Running on web, using web config.js environment values');
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
        // Check if window.ENV exists and has the key
        if (js.context.hasProperty('ENV') && js.context['ENV'].hasProperty(key)) {
          return js.context['ENV'][key] as String;
        }
      }
      
      // For non-web or if web ENV doesn't have the key, try dotenv
      return dotenv.env[key] ?? fallback;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting environment variable $key: $e');
      }
      return fallback;
    }
  }

  /// Get Supabase URL
  static String get supabaseUrl {
    // NOTE: This fallback contains the public Supabase URL which is safe to include in the application
    // This is used only when the .env file or config.js values are unavailable
    const fallback = 'https://kszcjniwbqxyndpsajhr.supabase.co/';
    return get('SUPABASE_URL', fallback: fallback);
  }

  /// Get Supabase Anon Key
  static String get supabaseAnonKey {
    // NOTE: This fallback contains the Supabase Anon Key which is designed to be public-facing
    // The Anon Key only has permissions defined by Row Level Security (RLS) policies
    // Make sure your Supabase RLS policies are properly configured to protect your data
    const fallback = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzemNqbml3YnF4eW5kcHNhamhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2NTEzNjQsImV4cCI6MjA1OTIyNzM2NH0.UnN4xuo783XDrR5nQTlwZAIcW6DqrbFY3bo4nssOvu4';
    return get('SUPABASE_ANON_KEY', fallback: fallback);
  }
} 