import 'dart:convert';
import 'dart:html' as html;
import '../../../../core/models/athlete.dart';

/// Class to manage mock profile data with browser storage persistence
class MockProfileData {
  static const _storageKey = 'mock_athlete_profiles';
  
  /// Get the initial list of athletes
  static List<Athlete> getInitialAthletes() {
    return [
      Athlete(
        id: '1',
        name: 'Michael Johnson',
        email: 'michael.johnson@example.com',
        status: AthleteStatus.current,
        major: 'Computer Science',
        career: '',
        sport: 'Basketball',
        university: 'State University',
        profileImageUrl: 'https://i.pravatar.cc/150?img=1',
        achievements: ['Team Captain 2023', 'Conference Champion'],
        graduationYear: DateTime(2025),
      ),
      Athlete(
        id: '2',
        name: 'Sarah Williams',
        email: 'sarah.williams@example.com',
        status: AthleteStatus.former,
        major: 'Business Administration',
        career: 'Marketing Manager',
        sport: 'Soccer',
        university: 'Tech University',
        profileImageUrl: 'https://i.pravatar.cc/150?img=5',
        achievements: ['MVP 2020', 'National Team Member'],
        graduationYear: DateTime(2020),
      ),
      Athlete(
        id: '3',
        name: 'James Rodriguez',
        email: 'james.rodriguez@example.com',
        status: AthleteStatus.current,
        major: 'Exercise Science',
        career: '',
        sport: 'Baseball',
        university: 'State University',
        profileImageUrl: 'https://i.pravatar.cc/150?img=3',
        achievements: ['All-Conference Team'],
        graduationYear: DateTime(2024),
      ),
      Athlete(
        id: '4',
        name: 'Emily Chen',
        email: 'emily.chen@example.com',
        status: AthleteStatus.former,
        major: 'Psychology',
        career: 'Sports Psychologist',
        sport: 'Swimming',
        university: 'National University',
        profileImageUrl: 'https://i.pravatar.cc/150?img=9',
        achievements: ['Olympic Team Member', 'World Championship Finalist'],
        graduationYear: DateTime(2018),
      ),
      Athlete(
        id: '5',
        name: 'David Miller',
        email: 'david.miller@example.com',
        status: AthleteStatus.current,
        major: 'Engineering',
        career: '',
        sport: 'Track & Field',
        university: 'Tech University',
        profileImageUrl: 'https://i.pravatar.cc/150?img=8',
        achievements: ['Conference Record Holder', 'National Finalist'],
        graduationYear: DateTime(2026),
      ),
    ];
  }

  /// Load athletes from browser storage or use initial data if not available
  static List<Athlete> loadAthletes() {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final List<dynamic> decoded = jsonDecode(stored);
        return decoded.map((json) {
          final Map<String, dynamic> athleteJson = Map<String, dynamic>.from(json);
          
          // Convert graduation year string back to DateTime
          if (athleteJson['graduationYear'] != null) {
            athleteJson['graduationYear'] = DateTime.parse(athleteJson['graduationYear']);
          }
          
          return Athlete.fromJson(athleteJson);
        }).toList();
      }
    } catch (e) {
      print('Error loading mock athlete data: $e');
    }
    
    // Use initial data if nothing is stored or there's an error
    final initialAthletes = getInitialAthletes();
    saveAthletes(initialAthletes);
    return initialAthletes;
  }

  /// Save athletes to browser storage
  static void saveAthletes(List<Athlete> athletes) {
    try {
      final List<Map<String, dynamic>> encoded = athletes.map((athlete) => athlete.toJson()).toList();
      html.window.localStorage[_storageKey] = jsonEncode(encoded);
    } catch (e) {
      print('Error saving mock athlete data: $e');
    }
  }

  /// Get a specific athlete by ID
  static Athlete? getAthlete(String id) {
    final athletes = loadAthletes();
    try {
      return athletes.firstWhere((athlete) => athlete.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Update an existing athlete
  static bool updateAthlete(Athlete updatedAthlete) {
    final athletes = loadAthletes();
    final index = athletes.indexWhere((athlete) => athlete.id == updatedAthlete.id);
    
    if (index >= 0) {
      athletes[index] = updatedAthlete;
      saveAthletes(athletes);
      return true;
    }
    return false;
  }

  /// Add a new profile image URL for an athlete
  static String addProfileImage(String athleteId, String imageUrl) {
    final athletes = loadAthletes();
    final index = athletes.indexWhere((athlete) => athlete.id == athleteId);
    
    if (index >= 0) {
      final updatedAthlete = athletes[index].copyWith(profileImageUrl: imageUrl);
      athletes[index] = updatedAthlete;
      saveAthletes(athletes);
      return imageUrl;
    }
    throw Exception('Athlete not found');
  }
} 