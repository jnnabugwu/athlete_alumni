enum AthleteStatus { current, former }

class Athlete {
  final String id;
  final String name;
  final String profileImageUrl;
  final AthleteStatus status;
  final List<String> sports;
  final String bio;
  
  // Current athlete fields
  final String? major;
  final int? expectedGraduationYear;
  
  // Former athlete fields
  final String? career;
  final int? graduationYear;
  
  const Athlete({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.status,
    required this.sports,
    required this.bio,
    this.major,
    this.expectedGraduationYear,
    this.career,
    this.graduationYear,
  });
  
  // Factory method to create a mock current athlete
  factory Athlete.mockCurrent() {
    return const Athlete(
      id: '1',
      name: 'John Doe',
      profileImageUrl: 'https://via.placeholder.com/150',
      status: AthleteStatus.current,
      sports: ['Basketball', 'Track & Field'],
      bio: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      major: 'Computer Science',
      expectedGraduationYear: 2025,
    );
  }
  
  // Factory method to create a mock former athlete
  factory Athlete.mockFormer() {
    return const Athlete(
      id: '2',
      name: 'Jane Smith',
      profileImageUrl: 'https://via.placeholder.com/150',
      status: AthleteStatus.former,
      sports: ['Swimming', 'Volleyball'],
      bio: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      career: 'Software Engineer',
      graduationYear: 2020,
    );
  }
} 