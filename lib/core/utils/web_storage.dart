import 'dart:html' as html;
import 'dart:async';

class WebStorage {
  static const String _authKey = 'auth_state';
  static const String _athleteKey = 'athlete_data';
  
  // Stream controller for auth state changes
  static final _authStateController = StreamController<void>.broadcast();

  // Stream for auth state changes
  static Stream<void> get onAuthStateChange => _authStateController.stream;

  static Future<void> saveAuthState(String state) async {
    html.window.localStorage[_authKey] = state;
    _authStateController.add(null); // Notify listeners of state change
  }

  static Future<String?> getAuthState() async {
    return html.window.localStorage[_authKey];
  }

  static Future<void> saveAthleteData(String athleteJson) async {
    html.window.localStorage[_athleteKey] = athleteJson;
    _authStateController.add(null); // Notify listeners of state change
  }

  static Future<String?> getAthleteData() async {
    return html.window.localStorage[_athleteKey];
  }

  static Future<void> clearAuthData() async {
    html.window.localStorage.remove(_authKey);
    html.window.localStorage.remove(_athleteKey);
    _authStateController.add(null); // Notify listeners of state change
  }

  // Clean up the stream controller when done
  static void dispose() {
    _authStateController.close();
  }
} 