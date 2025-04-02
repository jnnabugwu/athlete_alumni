part of 'athlete.dart';
/// Enum representing the status of an athlete
enum AthleteStatus {
  /// Current athlete (still in school)
  current,
  
  /// Former athlete (graduated)
  former;
  
  /// Get a display name for the status
  String get displayName {
    switch (this) {
      case AthleteStatus.current:
        return 'Current Athlete';
      case AthleteStatus.former:
        return 'Former Athlete';
    }
  }
  
  /// Convert a string to an AthleteStatus enum
  static AthleteStatus fromString(String value) {
    return AthleteStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => AthleteStatus.former,
    );
  }
}

/// Enum representing the possible majors for an athlete
enum AthleteMajor {
  /// Computer Science major
  computerScience,
  
  /// Business major
  business,
  
  /// Engineering major
  engineering,
  
  /// Biology major
  biology,
  
  /// Communications major
  communications,
  
  /// Psychology major
  psychology,
  
  /// Economics major
  economics,
  
  /// Education major
  education,
  
  /// Political Science major
  politicalScience,
  
  /// Other major
  other;


  
  /// Get a display name for the major
  String get displayName {
    switch (this) {
      case AthleteMajor.computerScience:
        return 'Computer Science';
      case AthleteMajor.business:
        return 'Business';
      case AthleteMajor.engineering:
        return 'Engineering';
      case AthleteMajor.biology:
        return 'Biology';
      case AthleteMajor.communications:
        return 'Communications';
      case AthleteMajor.psychology:
        return 'Psychology';
      case AthleteMajor.economics:
        return 'Economics';
      case AthleteMajor.education:
        return 'Education';
      case AthleteMajor.politicalScience:
        return 'Political Science';
      case AthleteMajor.other:
        return 'Other';
    }
  }
  
  /// Convert a string to an AthleteMajor enum
  static AthleteMajor fromString(String value) {
    return AthleteMajor.values.firstWhere(
      (major) => major.name == value,
      orElse: () => AthleteMajor.other,
    );
  }
}

/// Enum representing the possible careers for an athlete
enum AthleteCareer {
  /// Software Engineer career
  softwareEngineer,
  
  /// Business Analyst career
  businessAnalyst,
  
  /// Marketing career
  marketing,
  
  /// Sales career
  sales,
  
  /// Medicine career
  medicine,
  
  /// Engineering career
  engineering,
  
  /// Media Production career
  mediaProduction,
  
  /// Human Resources career
  humanResources,
  
  /// Finance career
  finance,
  
  /// Other career
  other,

  inSchool;
  
  /// Get a display name for the career
  String get displayName {
    switch (this) {
      case AthleteCareer.softwareEngineer:
        return 'Software Engineer';
      case AthleteCareer.businessAnalyst:
        return 'Business Analyst';
      case AthleteCareer.marketing:
        return 'Marketing';
      case AthleteCareer.sales:
        return 'Sales';
      case AthleteCareer.medicine:
        return 'Medicine';
      case AthleteCareer.engineering:
        return 'Engineering';
      case AthleteCareer.mediaProduction:
        return 'Media Production';
      case AthleteCareer.humanResources:
        return 'Human Resources';
      case AthleteCareer.finance:
        return 'Finance';
      case AthleteCareer.other:
        return 'Other';
      case AthleteCareer.inSchool:
        return 'In School';
    }
  }
  
  /// Convert a string to an AthleteCareer enum
  static AthleteCareer fromString(String value) {
    return AthleteCareer.values.firstWhere(
      (career) => career.name == value,
      orElse: () => AthleteCareer.other,
    );
  }
}

/// Enum representing the available sort options for athletes
enum AthleteSortOption {
  /// Sort by name
  name,
  
  /// Sort by graduation year
  graduationYear,
  
  /// Sort by university
  university,
  
  /// Sort by sport
  sport,
  
  /// Sort by major
  major,
  
  /// Sort by career
  career;
  
  /// Get a display name for the sort option
  String get displayName {
    switch (this) {
      case AthleteSortOption.name:
        return 'Name';
      case AthleteSortOption.graduationYear:
        return 'Graduation Year';
      case AthleteSortOption.university:
        return 'University';
      case AthleteSortOption.sport:
        return 'Sport';
      case AthleteSortOption.major:
        return 'Major';
      case AthleteSortOption.career:
        return 'Career';
    }
  }
} 