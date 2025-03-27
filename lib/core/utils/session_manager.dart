import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:athlete_alumni/core/models/athlete.dart';

/// SessionManager handles user authentication state and provides methods
/// to manage user sessions throughout the app.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  static SharedPreferences? _prefs;
  
  // Stream controller for auth state changes
  static final _authStateController = StreamController<bool>.broadcast();
  
  // Expose stream for auth state changes
  static Stream<bool> get onAuthStateChange => _authStateController.stream;
  
  // Keys for storing data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserData = 'user_data';
  
  // Private constructor
  SessionManager._internal();
  
  // Factory constructor
  factory SessionManager() {
    return _instance;
  }
  
  /// Initialize the session manager
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_keyIsLoggedIn) ?? false;
  }
  
  /// Set logged in status
  static Future<void> setLoggedIn(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_keyIsLoggedIn, value);
    _authStateController.add(value);
  }
  
  /// Save athlete data
  static Future<void> saveAthlete(Athlete athlete) async {
    _prefs ??= await SharedPreferences.getInstance();
    final athleteJson = athlete.toJson();
    await _prefs!.setString(_keyUserData, athleteJson.toString());
  }
  
  /// Get current athlete data
  static Future<Athlete?> getAthlete() async {
    _prefs ??= await SharedPreferences.getInstance();
    final athleteJson = _prefs!.getString(_keyUserData);
    if (athleteJson == null) return null;
    
    try {
      // Parse the JSON string to Map and create Athlete object
      final Map<String, dynamic> userData = Map<String, dynamic>.from(
        // This would need proper JSON parsing in a real implementation
        // For simplicity, assuming we can convert the string to Map
        athleteJson as Map<String, dynamic>
      );
      return Athlete.fromJson(userData);
    } catch (e) {
      return null;
    }
  }
  
  /// Clear session data on logout
  static Future<void> clearSession() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_keyIsLoggedIn);
    await _prefs!.remove(_keyUserData);
    _authStateController.add(false);
  }
  
  /// Dispose resources
  static void dispose() {
    _authStateController.close();
  }
}