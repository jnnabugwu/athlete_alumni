import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../core/models/athlete.dart';

/// Utility class to handle web storage operations
class WebStorage {
  static const String _athletesKey = 'athlete_alumni_data';
  
  /// Save athletes JSON string to localStorage
  static Future<void> saveAthletes(String jsonData) async {
    try {
      html.window.localStorage[_athletesKey] = jsonData;
      
      if (kDebugMode) {
        print('Athletes data saved to localStorage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving to localStorage: $e');
      }
      rethrow;
    }
  }
  
  /// Load athletes from localStorage
  static Future<List<Athlete>> loadAthletes() async {
    try {
      final jsonData = html.window.localStorage[_athletesKey];
      
      if (jsonData == null || jsonData.isEmpty) {
        if (kDebugMode) {
          print('No athletes found in localStorage');
        }
        return [];
      }
      
      final List<dynamic> decodedData = jsonDecode(jsonData);
      final athletes = decodedData
          .map<Athlete>((item) => Athlete.fromJson(item))
          .toList();
      
      if (kDebugMode) {
        print('Loaded ${athletes.length} athletes from localStorage');
      }
      
      return athletes;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading athletes from localStorage: $e');
      }
      return [];
    }
  }
  
  /// Check if athletes data exists in localStorage
  static bool hasStoredAthletes() {
    final jsonData = html.window.localStorage[_athletesKey];
    return jsonData != null && jsonData.isNotEmpty;
  }
  
  /// Clear athletes data from localStorage
  static void clearAthletes() {
    html.window.localStorage.remove(_athletesKey);
    if (kDebugMode) {
      print('Athletes data cleared from localStorage');
    }
  }
} 