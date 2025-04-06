import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:js' as js;

/// A utility class to handle environment variables
class Environment {
  /// Initialize environment variables
  static Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('Environment: Initializing environment - isWeb: $kIsWeb');
      }
      
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
        // In web mode, log info about the environment
        if (kDebugMode) {
          print('Running on web, using web config.js environment values');
          try {
            bool hasEnvObj = js.context.hasProperty('ENV');
            print('Web ENV object exists: $hasEnvObj');
            if (hasEnvObj) {
              bool hasUrl = js.context['ENV'].hasProperty('SUPABASE_URL');
              bool hasKey = js.context['ENV'].hasProperty('SUPABASE_ANON_KEY');
              print('ENV contains SUPABASE_URL: $hasUrl');
              print('ENV contains SUPABASE_ANON_KEY: $hasKey');
            }
          } catch (e) {
            print('Error checking web ENV: $e');
          }
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
          if (js.context.hasProperty('ENV') && js.context['ENV'].hasProperty(key)) {
            String value = js.context['ENV'][key] as String;
            if (kDebugMode) {
              print('Retrieved $key from web ENV: ${value.substring(0, 10)}...');
            }
            return value;
          } else {
            if (kDebugMode) {
              print('Key $key not found in web ENV, using fallback');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error accessing web ENV for key $key: $e');
          }
        }
      }
      
      // For non-web or if web ENV doesn't have the key, try dotenv
      String? value = dotenv.env[key];
      if (value != null) {
        if (kDebugMode) {
          print('Retrieved $key from dotenv: ${value.substring(0, 10)}...');
        }
        return value;
      }
      
      if (kDebugMode) {
        print('Key $key not found in any source, using fallback value');
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