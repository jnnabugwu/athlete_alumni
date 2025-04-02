import 'package:athlete_alumni/core/models/athlete.dart';

/// Class that provides mock athlete profile data for development and testing
class ProfileMockData {
  /// Get a list of mock athletes
  static List<Athlete> getMockAthletes() {
    return [
      Athlete(
        id: '1',
        name: 'John Smith',
        email: 'john.smith@example.com',
        status: AthleteStatus.current,
        major: AthleteMajor.computerScience,
        career: AthleteCareer.softwareEngineer,
        sport: 'Football',
        university: 'State University',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        achievements: [
          'Conference Champion 2017',
          'MVP 2016',
          'All-Star Team 2015-2017'
        ],
        graduationYear: DateTime(2018),
      ),
      Athlete(
        id: '2',
        name: 'Sarah Johnson',
        email: 'sarah.johnson@example.com',
        status: AthleteStatus.former,
        major: AthleteMajor.business,
        career: AthleteCareer.businessAnalyst,
        sport: 'Basketball',
        university: 'Pacific University',
        profileImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
        achievements: [
          'National Champion 2019',
          'Rookie of the Year 2020',
          'All-Star Team 2021-2023'
        ],
        graduationYear: DateTime(2019),
      ),
      Athlete(
        id: '3',
        name: 'Michael Williams',
        email: 'michael.williams@example.com',
        status: AthleteStatus.current,
        major: AthleteMajor.psychology,
        career: AthleteCareer.other,
        sport: 'Soccer',
        university: 'Coastal College',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
        achievements: [
          'League Champion 2022',
          'Best Midfielder 2021',
          'Team Captain 2019-2020'
        ],
        graduationYear: DateTime(2020),
      ),
    ];
  }

  /// Get a mock athlete by ID
  static Athlete? getMockAthleteById(String id) {
    try {
      return getMockAthletes().firstWhere((athlete) => athlete.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update a mock athlete
  /// This would need to be connected to some local storage in a real implementation
  static Athlete updateMockAthlete(Athlete updatedAthlete) {
    // In a real app, this would persist the changes
    // For now, we just return the updated athlete
    return updatedAthlete;
  }
} 