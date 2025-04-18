import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/log_utils.dart';
part 'athlete_enums.dart';

class Athlete {
  final String id;
  final String name;
  final String email;
  final String? username;
  final AthleteStatus status;
  final AthleteMajor major;
  final AthleteCareer career;
  final String? profileImageUrl;
  final String? university;
  final String? sport;
  final List<String>? achievements;
  final DateTime? graduationYear;

  const Athlete({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    required this.status,
    required this.major,
    required this.career,
    this.profileImageUrl,
    this.university,
    this.sport,
    this.achievements,
    this.graduationYear,
  });

  // Copy with method for immutability
  Athlete copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    AthleteStatus? status,
    AthleteMajor? major,
    AthleteCareer? career,
    String? profileImageUrl,
    String? university,
    String? sport,
    List<String>? achievements,
    DateTime? graduationYear,
  }) {
    return Athlete(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      status: status ?? this.status,
      major: major ?? this.major,
      career: career ?? this.career,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      university: university ?? this.university,
      sport: sport ?? this.sport,
      achievements: achievements ?? this.achievements,
      graduationYear: graduationYear ?? this.graduationYear,
    );
  }

  // From JSON factory
  factory Athlete.fromJson(Map<String, dynamic> json) {
    // Helper to get value from JSON with fallback between camelCase and snake_case
    T? getValue<T>(String camelCase, String snakeCase) {
      if (json[camelCase] != null) return json[camelCase] as T?;
      if (json[snakeCase] != null) return json[snakeCase] as T?;
      return null;
    }

    return Athlete(
      id: json['id'] as String,
      name: getValue<String>('name', 'full_name') ?? '',
      email: getValue<String>('email', 'email') ?? '',
      username: getValue<String>('username', 'username'),
      status: _parseStatus(json),
      major: _parseMajor(json),
      career: _parseCareer(json),
      profileImageUrl: getValue<String>('profileImageUrl', 'profile_image_url'),
      university: getValue<String>('university', 'college'),
      sport: getValue<String>('sport', 'sport'),
      achievements: _parseAchievements(json),
      graduationYear: _parseGraduationYear(json),
    );
  }

  // Helper method to parse status from different formats
  static AthleteStatus _parseStatus(Map<String, dynamic> json) {
    // Try various possible field names
    final statusValue = json['status'] ?? json['athlete_status'];
    
    if (statusValue == null) return AthleteStatus.current;
    
    if (statusValue is String) {
      return AthleteStatus.values.firstWhere(
        (e) => e.name == statusValue || e.displayName == statusValue,
        orElse: () => AthleteStatus.current,
      );
    }
    
    return AthleteStatus.current;
  }
  
  // Helper method to parse major from different formats
  static AthleteMajor _parseMajor(Map<String, dynamic> json) {
    final majorValue = json['major'];
    
    // FORCE VISIBLE LOGGING
    print('');
    print('🔍🔍🔍 PARSING MAJOR VALUE: "$majorValue" 🔍🔍🔍');
    
    if (majorValue == null) {
      print('🔍🔍🔍 Major is NULL, defaulting to OTHER 🔍🔍🔍');
      return AthleteMajor.other;
    }
    
    if (majorValue is String) {
      // First try matching by exact enum name (case insensitive)
      for (final major in AthleteMajor.values) {
        if (major.name.toLowerCase() == majorValue.toLowerCase()) {
          print('🔍🔍🔍 Found major by name match: ${major.name} 🔍🔍🔍');
          return major;
        }
      }
      
      // Then try matching by display name (case insensitive)
      for (final major in AthleteMajor.values) {
        if (major.displayName.toLowerCase() == majorValue.toLowerCase()) {
          print('🔍🔍🔍 Found major by display name match: ${major.name} 🔍🔍🔍');
          return major;
        }
      }
      
      print('🔍🔍🔍 NO MATCH FOUND for major: "$majorValue", defaulting to OTHER 🔍🔍🔍');
      print('');
    }
    
    return AthleteMajor.other;
  }
  
  // Helper method to parse career from different formats
  static AthleteCareer _parseCareer(Map<String, dynamic> json) {
    final careerValue = json['career'];
    
    // FORCE VISIBLE LOGGING
    print('');
    print('🔎🔎🔎 PARSING CAREER VALUE: "$careerValue" 🔎🔎🔎');
    
    if (careerValue == null) {
      print('🔎🔎🔎 Career is NULL, defaulting to OTHER 🔎🔎🔎');
      return AthleteCareer.other;
    }
    
    if (careerValue is String) {
      // First try matching by exact enum name (case insensitive)
      for (final career in AthleteCareer.values) {
        if (career.name.toLowerCase() == careerValue.toLowerCase()) {
          print('🔎🔎🔎 Found career by name match: ${career.name} 🔎🔎🔎');
          return career;
        }
      }
      
      // Then try matching by display name (case insensitive)
      for (final career in AthleteCareer.values) {
        if (career.displayName.toLowerCase() == careerValue.toLowerCase()) {
          print('🔎🔎🔎 Found career by display name match: ${career.name} 🔎🔎🔎');
          return career;
        }
      }
      
      print('🔎🔎🔎 NO MATCH FOUND for career: "$careerValue", defaulting to OTHER 🔎🔎🔎');
      print('');
    }
    
    return AthleteCareer.other;
  }
  
  // Helper method to parse achievements from different formats
  static List<String>? _parseAchievements(Map<String, dynamic> json) {
    final achievements = json['achievements'];
    
    if (achievements == null) return null;
    
    if (achievements is List) {
      return achievements.map((item) => item.toString()).toList();
    }
    
    if (achievements is String) {
      try {
        final decoded = jsonDecode(achievements);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList();
        }
      } catch (_) {
        // If parsing fails, return null
      }
    }
    
    return null;
  }
  
  // Helper method to parse graduation year from different formats
  static DateTime? _parseGraduationYear(Map<String, dynamic> json) {
    final year = json['graduationYear'] ?? json['graduation_year'];
    
    if (year == null) return null;
    
    if (year is String) {
      try {
        return DateTime.parse(year);
      } catch (_) {
        // If parsing fails, return null
      }
    }
    
    if (year is DateTime) return year;
    
    return null;
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    // Use our super-visible logging utility
    forceLog('Serializing Athlete to JSON', tag: 'ATHLETE_TO_JSON');
    forceLog('Major: ${major.name} (${major.displayName})', tag: 'ATHLETE_TO_JSON');
    forceLog('Career: ${career.name} (${career.displayName})', tag: 'ATHLETE_TO_JSON');
    
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'status': status.name,
      // IMPORTANT: Store major and career as enum names for consistent serialization
      'major': major.name,
      'career': career.name,
      'profileImageUrl': profileImageUrl,
      'university': university,
      'sport': sport,
      'achievements': achievements,
      'graduationYear': graduationYear?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Athlete(id: $id, name: $name, username: $username, status: ${status.displayName}, major: ${major.displayName}, career: ${career.displayName})';
  }
} 