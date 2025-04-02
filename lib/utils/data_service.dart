import 'package:flutter/foundation.dart';
import '../core/models/athlete.dart';
import 'web_storage.dart';
import 'init_test_data.dart';

/// Service class to access athlete data throughout the app
class AthleteDataService {
  /// Get all athletes from storage
  static Future<List<Athlete>> getAllAthletes() async {
    await _ensureDataInitialized();
    return WebStorage.loadAthletes();
  }
  
  /// Get athletes filtered by status
  static Future<List<Athlete>> getAthletesByStatus(AthleteStatus status) async {
    final allAthletes = await getAllAthletes();
    return allAthletes.where((athlete) => athlete.status == status).toList();
  }
  
  /// Get former athletes (helper method)
  static Future<List<Athlete>> getFormerAthletes() async {
    return getAthletesByStatus(AthleteStatus.former);
  }
  
  /// Get current athletes (helper method)
  static Future<List<Athlete>> getCurrentAthletes() async {
    return getAthletesByStatus(AthleteStatus.current);
  }
  
  /// Get athlete by ID
  static Future<Athlete?> getAthleteById(String id) async {
    final allAthletes = await getAllAthletes();
    try {
      return allAthletes.firstWhere((athlete) => athlete.id == id);
    } catch (e) {
      if (kDebugMode) {
        print('Athlete with ID $id not found');
      }
      return null;
    }
  }
  
  /// Reset all athlete data (for testing)
  static Future<void> resetData() async {
    await TestDataInitializer.regenerateTestData();
  }
  
  /// Export data to JSON (for backing up)
  static Future<String> exportToJson() async {
    return TestDataInitializer.exportCurrentData();
  }
  
  /// Private method to ensure data is initialized
  static Future<void> _ensureDataInitialized() async {
    await TestDataInitializer.initializeAthleteData();
  }
}

/// Usage examples:
/// ```dart
/// // Get all athletes
/// final athletes = await AthleteDataService.getAllAthletes();
/// 
/// // Get athletes filtered by status
/// final formerAthletes = await AthleteDataService.getFormerAthletes();
/// final currentAthletes = await AthleteDataService.getCurrentAthletes();
/// 
/// // Get athlete by ID
/// final athlete = await AthleteDataService.getAthleteById('ath-12345');
/// 
/// // Reset data for testing
/// await AthleteDataService.resetData();
/// ``` 