import 'dart:html' as html;
import 'dart:async';

class WebStorage {
  static const String _authKey = 'auth_state';
  static const String _athleteKey = 'athlete_data';
  
  // Stream controller for auth state changes
  static final _authStateController = StreamController<void>.broadcast();
  static bool _isDisposed = false;

  // Stream for auth state changes
  static Stream<void> get onAuthStateChange => _authStateController.stream;

  static Future<void> saveAuthState(String state) async {
    print("WebStorage: Saving auth state: $state");
    try {
      html.window.localStorage[_authKey] = state;
      print("WebStorage: Auth state saved successfully");
      
      // Only add to stream if not disposed
      if (!_isDisposed && !_authStateController.isClosed) {
        _authStateController.add(null); // Notify listeners of state change
      }
    } catch (e) {
      print("WebStorage: Error saving auth state: $e");
      rethrow;
    }
  }

  static Future<String?> getAuthState() async {
    try {
      final state = html.window.localStorage[_authKey];
      print("WebStorage: Retrieved auth state: $state");
      return state;
    } catch (e) {
      print("WebStorage: Error getting auth state: $e");
      return null;
    }
  }

  static Future<void> saveAthleteData(String athleteJson) async {
    print("WebStorage: Saving athlete data: $athleteJson");
    try {
      html.window.localStorage[_athleteKey] = athleteJson;
      print("WebStorage: Athlete data saved successfully");
      
      // Only add to stream if not disposed
      if (!_isDisposed && !_authStateController.isClosed) {
        _authStateController.add(null); // Notify listeners of state change
      }
    } catch (e) {
      print("WebStorage: Error saving athlete data: $e");
      rethrow;
    }
  }

  static Future<String?> getAthleteData() async {
    try {
      final data = html.window.localStorage[_athleteKey];
      print("WebStorage: Retrieved athlete data: $data");
      return data;
    } catch (e) {
      print("WebStorage: Error getting athlete data: $e");
      return null;
    }
  }

  static Future<void> clearAuthData() async {
    print("WebStorage: Clearing auth data");
    try {
      html.window.localStorage.remove(_authKey);
      html.window.localStorage.remove(_athleteKey);
      print("WebStorage: Auth data cleared successfully");
      
      // Only add to stream if not disposed
      if (!_isDisposed && !_authStateController.isClosed) {
        _authStateController.add(null); // Notify listeners of state change
      }
    } catch (e) {
      print("WebStorage: Error clearing auth data: $e");
      rethrow;
    }
  }

  // Clean up the stream controller when done
  static void dispose() {
    print("WebStorage: Disposing stream controller");
    _isDisposed = true;
    
    if (!_authStateController.isClosed) {
      _authStateController.close();
    }
  }
} 