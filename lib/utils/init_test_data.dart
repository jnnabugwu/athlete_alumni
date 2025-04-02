import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'athlete_generator.dart';
import 'web_storage.dart';

/// Initialize the application with test data
class TestDataInitializer {
  static const String _assetPath = 'assets/data/athletes.json';
  

  
  /// Initialize athlete data with the following priority:
  /// 1. Use data already in localStorage if it exists
  /// 2. Try to load from bundled asset file
  /// 3. Generate random data as a last resort
  static Future<void> initializeAthleteData({int count = 50}) async {
    // Step 1: Check if data already exists in localStorage
    if (WebStorage.hasStoredAthletes()) {
      if (kDebugMode) {
        print('Using existing athlete data from localStorage');
      }
      return; // Data already exists, no need to do anything
    }
    
    // Step 2: Try to load from bundled asset
    try {
      if (kDebugMode) {
        print('Attempting to load athlete data from bundled asset: $_assetPath');
      }
      
      final jsonString = await rootBundle.loadString(_assetPath);
      
      // If we got here, the asset exists - save it to localStorage
      await WebStorage.saveAthletes(jsonString);
      
      if (kDebugMode) {
        print('Successfully loaded athlete data from asset file');
      }
      return;
    } catch (e) {
      if (kDebugMode) {
        print('Asset file not found or invalid: $e');
        print('Falling back to random data generation');
      }
      // Continue to step 3 if asset loading fails
    }
    
    // Step 3: Generate random data as last resort
    if (kDebugMode) {
      print('Generating $count random test athletes...');
    }
    
    final athletes = AthleteGenerator.generateAthletes(count: count, formerRatio: 0.7);
    await WebStorage.saveAthletes(AthleteGenerator.athletesToJson(athletes));
    
    if (kDebugMode) {
      print('Test data generated and saved to localStorage');
    }
  }
  
  /// Force regeneration of test data
  static Future<void> regenerateTestData({int count = 50}) async {
    if (kDebugMode) {
      print('Regenerating test data with $count athletes...');
    }
    
    WebStorage.clearAthletes();
    final athletes = AthleteGenerator.generateAthletes(count: count, formerRatio: 0.7);
    await WebStorage.saveAthletes(AthleteGenerator.athletesToJson(athletes));
    
    if (kDebugMode) {
      print('Test data regenerated successfully');
    }
  }
  
  /// Export current data to a JSON string (useful for saving as an asset)
  static Future<String> exportCurrentData() async {
    final athletes = await WebStorage.loadAthletes();
    return jsonEncode(athletes.map((athlete) => athlete.toJson()).toList());
  }
} 