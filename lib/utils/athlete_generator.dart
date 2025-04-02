import 'dart:convert';
import 'dart:math';
import '../core/models/athlete.dart';

/// Utility class to generate random athlete data for testing purposes
class AthleteGenerator {
  static final Random _random = Random();
  
  // Lists of sample data to choose from
  static const List<String> _firstNames = [
    'James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph',
    'Thomas', 'Emma', 'Olivia', 'Ava', 'Isabella', 'Sophia', 'Charlotte', 'Mia',
    'Amelia', 'Harper', 'Evelyn', 'Abigail', 'Lisa', 'Sarah', 'Karen', 'Nancy',
    'Ashley', 'Elizabeth', 'Maria', 'Jessica', 'Kimberly', 'Linda', 'Melissa'
  ];
  
  static const List<String> _lastNames = [
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
    'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
    'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson',
    'White', 'Harris', 'Sanchez', 'Clark', 'Lewis', 'Robinson', 'Walker', 'Young'
  ];
  
  // Replace string majors with enum values
  static final List<AthleteMajor> _majors = [
    AthleteMajor.business,
    AthleteMajor.computerScience,
    AthleteMajor.psychology,
    AthleteMajor.biology,
    AthleteMajor.engineering,
    AthleteMajor.communications,
    AthleteMajor.education,
    AthleteMajor.politicalScience,
    AthleteMajor.economics,
    AthleteMajor.other,
  ];
  
  // Replace string careers with enum values
  static final List<AthleteCareer> _careers = [
    AthleteCareer.softwareEngineer,
    AthleteCareer.businessAnalyst,
    AthleteCareer.marketing,
    AthleteCareer.sales,
    AthleteCareer.medicine,
    AthleteCareer.engineering,
    AthleteCareer.mediaProduction,
    AthleteCareer.humanResources,
    AthleteCareer.finance,
    AthleteCareer.other,
    AthleteCareer.inSchool,
  ];
  
  static const List<String> _universities = [
    'State University', 'Tech Institute', 'National College', 'Coastal University',
    'Mountain View College', 'Liberal Arts School', 'Metropolitan University',
    'Central College', 'Southern University', 'Northern Technical Institute'
  ];
  
  static const List<String> _sports = [
    'Basketball', 'Football', 'Soccer', 'Baseball', 'Volleyball', 
    'Tennis', 'Track & Field', 'Swimming', 'Golf', 'Wrestling',
    'Lacrosse', 'Hockey', 'Softball', 'Gymnastics', 'Water Polo'
  ];
  
  static const List<List<String>> _achievementsByType = [
    // Academic achievements
    ['Dean\'s List', 'Academic All-American', 'Phi Beta Kappa', 'Summa Cum Laude', 'Research Award'],
    // Athletic achievements
    ['Team Captain', 'All-Conference', 'MVP', 'National Finalist', 'Record Holder', 'All-American'],
    // Leadership achievements
    ['Student Government', 'Club President', 'Community Service Award', 'Leadership Award']
  ];
  
  /// Generates a list of random athletes
  /// [count] - The number of athletes to generate
  /// [formerRatio] - The ratio of former athletes to current (0.0-1.0)
  static List<Athlete> generateAthletes({int count = 50, double formerRatio = 0.6}) {
    final List<Athlete> athletes = [];
    
    for (int i = 0; i < count; i++) {
      // Determine if this athlete is former or current based on ratio
      final AthleteStatus status = _random.nextDouble() < formerRatio 
          ? AthleteStatus.former 
          : AthleteStatus.current;
      
      final String firstName = _firstNames[_random.nextInt(_firstNames.length)];
      final String lastName = _lastNames[_random.nextInt(_lastNames.length)];
      final String name = '$firstName $lastName';
      
      // Create email from name
      final String email = '${firstName.toLowerCase()}.${lastName.toLowerCase()}@example.com';
      
      // Generate graduation year - for former athletes in the past, for current athletes in the future
      final DateTime now = DateTime.now();
      final DateTime graduationYear = status == AthleteStatus.former
          ? DateTime(now.year - _random.nextInt(10) - 1)  // 1-10 years ago
          : DateTime(now.year + _random.nextInt(4) + 1);  // 1-4 years in future
      
      // Generate 1-3 random achievements
      final int numAchievements = _random.nextInt(3) + 1;
      final List<String> achievements = [];
      
      for (int j = 0; j < numAchievements; j++) {
        final achievementType = _random.nextInt(_achievementsByType.length);
        final achievement = _achievementsByType[achievementType][
          _random.nextInt(_achievementsByType[achievementType].length)
        ];
        
        if (!achievements.contains(achievement)) {
          achievements.add(achievement);
        }
      }
      
      // Generate profile image URL using placeholder service
      final int avatarId = _random.nextInt(70) + 1;
      final String gender = _random.nextBool() ? 'men' : 'women';
      final String profileImageUrl = 'https://randomuser.me/api/portraits/$gender/$avatarId.jpg';
      
      // Set career based on status - if current athlete, set to inSchool
      final AthleteCareer career = status == AthleteStatus.current 
          ? AthleteCareer.inSchool 
          : _careers[_random.nextInt(_careers.length)];
      
      athletes.add(Athlete(
        id: 'ath-${_generateRandomId()}',
        name: name,
        email: email,
        status: status,
        major: _majors[_random.nextInt(_majors.length)],
        career: career,
        profileImageUrl: profileImageUrl,
        university: _universities[_random.nextInt(_universities.length)],
        sport: _sports[_random.nextInt(_sports.length)],
        achievements: achievements,
        graduationYear: graduationYear,
      ));
    }
    
    return athletes;
  }
  
  /// Generate a random athlete ID
  static String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(_random.nextInt(chars.length)))
    );
  }
  
  /// Converts generated athletes to JSON string
  static String athletesToJson(List<Athlete> athletes) {
    return jsonEncode(athletes.map((athlete) => athlete.toJson()).toList());
  }
} 