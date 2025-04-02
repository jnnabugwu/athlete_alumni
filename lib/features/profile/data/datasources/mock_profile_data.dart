import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import '../../../../core/models/athlete.dart';

/// Class to manage mock profile data with browser storage persistence
class MockProfileData {
  static const _storageKey = 'mock_athlete_profiles';
  
  /// Get the initial list of athletes
  static List<Athlete> getInitialAthletes() {
    // Base sample data
    final sampleAthletes = [
      Athlete(
        id: '1',
        name: 'Michael Johnson',
        email: 'michael.johnson@example.com',
        status: AthleteStatus.current,
        major: AthleteMajor.engineering,
        career: AthleteCareer.softwareEngineer,
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
        major: AthleteMajor.business,
        career: AthleteCareer.marketing,
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
        major: AthleteMajor.other,
        career: AthleteCareer.inSchool,
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
        major: AthleteMajor.psychology,
        career: AthleteCareer.other,
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
        major: AthleteMajor.engineering,
        career: AthleteCareer.inSchool,
        sport: 'Track & Field',
        university: 'Tech University',
        profileImageUrl: 'https://i.pravatar.cc/150?img=8',
        achievements: ['Conference Record Holder', 'National Finalist'],
        graduationYear: DateTime(2026),
      ),
    ];
    
    // Generate additional random athletes
    final randomAthletes = _generateRandomAthletes(20);
    
    // Combine both lists
    return [...sampleAthletes, ...randomAthletes];
  }

  /// Generate a list of random athletes for testing
  static List<Athlete> _generateRandomAthletes(int count) {
    final random = Random();
    final athletes = <Athlete>[];
    
    final firstNames = [
      'John', 'Emma', 'Lucas', 'Olivia', 'William', 'Ava', 'James', 
      'Sophia', 'Benjamin', 'Isabella', 'Mason', 'Mia', 'Elijah', 
      'Charlotte', 'Liam', 'Amelia', 'Noah', 'Harper', 'Ethan', 'Evelyn'
    ];
    
    final lastNames = [
      'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller',
      'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez',
      'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin'
    ];
    
    final sports = [
      'Basketball', 'Football', 'Soccer', 'Baseball', 'Volleyball',
      'Track & Field', 'Swimming', 'Tennis', 'Golf', 'Lacrosse',
      'Hockey', 'Rugby', 'Gymnastics', 'Wrestling', 'Rowing'
    ];
    
    final universities = [
      'State University', 'Tech University', 'National University',
      'Pacific University', 'University of the East', 'Central College',
      'Western Institute', 'Lakeview University', 'Coastal College',
      'Mountain State University', 'Valley College', 'Metropolitan University'
    ];
    
    final achievements = [
      'Team Captain', 'Conference Champion', 'All-American', 'MVP',
      'Rookie of the Year', 'Academic All-Star', 'National Finalist',
      'Record Holder', 'All-Conference Team', 'Tournament Champion',
      'Scholar-Athlete Award', 'Leadership Award', 'Community Service Award'
    ];
    
    for (int i = 0; i < count; i++) {
      final firstName = firstNames[random.nextInt(firstNames.length)];
      final lastName = lastNames[random.nextInt(lastNames.length)];
      final id = (100 + i).toString();
      final status = random.nextBool() ? AthleteStatus.current : AthleteStatus.former;
      
      // Generate random graduation year based on status
      final currentYear = DateTime.now().year;
      final graduationYear = status == AthleteStatus.current
          ? DateTime(currentYear + random.nextInt(4) + 1)
          : DateTime(currentYear - random.nextInt(10) - 1);
          
      // Set career based on status
      final career = status == AthleteStatus.current
          ? AthleteCareer.inSchool
          : AthleteCareer.values[random.nextInt(AthleteCareer.values.length - 1) + 1];
      
      // Generate random achievements
      final athleteAchievements = <String>[];
      final achievementCount = random.nextInt(3) + 1; // 1-3 achievements
      
      for (int j = 0; j < achievementCount; j++) {
        final achievement = achievements[random.nextInt(achievements.length)];
        if (!athleteAchievements.contains(achievement)) {
          athleteAchievements.add(achievement);
        }
      }
      
      // Create the athlete
      athletes.add(Athlete(
        id: id,
        name: '$firstName $lastName',
        email: '${firstName.toLowerCase()}.${lastName.toLowerCase()}@example.com',
        status: status,
        major: AthleteMajor.values[random.nextInt(AthleteMajor.values.length)],
        career: career,
        sport: sports[random.nextInt(sports.length)],
        university: universities[random.nextInt(universities.length)],
        profileImageUrl: 'https://i.pravatar.cc/150?img=${10 + random.nextInt(50)}',
        achievements: athleteAchievements,
        graduationYear: graduationYear,
      ));
    }
    
    return athletes;
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