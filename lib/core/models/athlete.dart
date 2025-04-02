part 'athlete_enums.dart';

class Athlete {
  final String id;
  final String name;
  final String email;
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
    return Athlete(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      status: AthleteStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AthleteStatus.current,
      ),
      // Convert string to AthleteMajor enum, defaulting to "other" if not recognized
      major: json['major'] != null 
        ? AthleteMajor.fromString(json['major'] as String) 
        : AthleteMajor.other,
      // Convert string to AthleteCareer enum, defaulting to "other" if not recognized
      career: json['career'] != null 
        ? AthleteCareer.fromString(json['career'] as String) 
        : AthleteCareer.other,
      profileImageUrl: json['profileImageUrl'] as String?,
      university: json['university'] as String?,
      sport: json['sport'] as String?,
      achievements: (json['achievements'] as List<dynamic>?)?.cast<String>(),
      graduationYear: json['graduationYear'] != null 
        ? DateTime.parse(json['graduationYear'] as String)
        : null,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status.name,
      // Store major and career as display names for better readability
      'major': major.displayName,
      'career': career.displayName,
      'profileImageUrl': profileImageUrl,
      'university': university,
      'sport': sport,
      'achievements': achievements,
      'graduationYear': graduationYear?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Athlete(id: $id, name: $name, status: ${status.displayName}, major: ${major.displayName}, career: ${career.displayName})';
  }
} 