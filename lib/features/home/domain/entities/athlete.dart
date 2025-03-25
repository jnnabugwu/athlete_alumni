class Athlete {
  final String id;
  final String name;
  final String profileImageUrl;
  final String university;
  final String sport;
  final String status; // 'Current Athlete' or 'Former Athlete'
  final String position;
  final String location;
  final int? graduationYear;
  final int? mentorConnections;
  final List<String>? achievements;
  final String? bio;

  Athlete({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.university,
    required this.sport,
    required this.status,
    required this.position,
    required this.location,
    this.graduationYear,
    this.mentorConnections,
    this.achievements,
    this.bio,
  });

  // Create from Supabase JSON data
  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: json['id'],
      name: json['name'],
      profileImageUrl: json['profile_image_url'] ?? 'assets/images/athletes/placeholder.jpg',
      university: json['university'] ?? '',
      sport: json['sport'] ?? '',
      status: json['status'] ?? 'Former Athlete',
      position: json['position'] ?? '',
      location: json['location'] ?? '',
      graduationYear: json['graduation_year'],
      mentorConnections: json['mentor_connections'],
      achievements: json['achievements'] != null 
          ? List<String>.from(json['achievements']) 
          : null,
      bio: json['bio'],
    );
  }

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image_url': profileImageUrl,
      'university': university,
      'sport': sport,
      'status': status,
      'position': position,
      'location': location,
      'graduation_year': graduationYear,
      'mentor_connections': mentorConnections,
      'achievements': achievements,
      'bio': bio,
    };
  }

  // Create a copy with updated fields
  Athlete copyWith({
    String? id,
    String? name,
    String? profileImageUrl,
    String? university,
    String? sport,
    String? status,
    String? position,
    String? location,
    int? graduationYear,
    int? mentorConnections,
    List<String>? achievements,
    String? bio,
  }) {
    return Athlete(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      university: university ?? this.university,
      sport: sport ?? this.sport,
      status: status ?? this.status,
      position: position ?? this.position,
      location: location ?? this.location,
      graduationYear: graduationYear ?? this.graduationYear,
      mentorConnections: mentorConnections ?? this.mentorConnections,
      achievements: achievements ?? this.achievements,
      bio: bio ?? this.bio,
    );
  }
}