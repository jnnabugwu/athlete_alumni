import 'package:athlete_alumni/features/auth/domain/entities/user.dart';


final List<Map<String, dynamic>> mockAthletes = [
  {
    'id': '1',
    'name': 'Sarah Johnson',
    'school': 'Princeton University',
    'sport': 'Swimming',
    'graduationYear': 2023,
    'major': 'Economics',
    'currentRole': 'Financial Analyst',
    'company': 'Goldman Sachs',
    'location': 'New York, NY',
    'bio': 'Former Division I swimmer turned finance professional. Passionate about helping athletes transition into business careers.',
    'achievements': [
      'NCAA All-American 2022',
      '3x Conference Champion',
      'Team Captain 2022-2023'
    ],
    'interests': ['Finance', 'Mentoring', 'Swimming'],
    'imageUrl': 'https://picsum.photos/200',
  },
  {
    'id': '2',
    'name': 'Marcus Rodriguez',
    'school': 'UCLA',
    'sport': 'Basketball',
    'graduationYear': 2022,
    'major': 'Computer Science',
    'currentRole': 'Software Engineer',
    'company': 'Google',
    'location': 'San Francisco, CA',
    'bio': 'Ex-college basketball player who found passion in tech. Looking to connect with athletes interested in software engineering.',
    'achievements': [
      'PAC-12 All-Academic Team',
      'Team MVP 2022',
      'Started 85 games'
    ],
    'interests': ['Technology', 'Basketball', 'Startups'],
    'imageUrl': 'https://picsum.photos/201',
  },
  {
    'id': '3',
    'name': 'Emma Chen',
    'school': 'Stanford University',
    'sport': 'Tennis',
    'graduationYear': 2021,
    'major': 'Bioengineering',
    'currentRole': 'Medical Student',
    'company': 'Johns Hopkins School of Medicine',
    'location': 'Baltimore, MD',
    'bio': 'Former D1 tennis player pursuing medicine. Interested in sports medicine and helping athletes maintain peak performance.',
    'achievements': [
      'NCAA Singles Tournament Qualifier',
      'Academic All-American',
      '2x Team Captain'
    ],
    'interests': ['Medicine', 'Tennis', 'Research'],
    'imageUrl': 'https://picsum.photos/202',
  },
];

final List<String> mockSchools = [
  'Princeton University',
  'UCLA',
  'Stanford University',
  'Harvard University',
  'Duke University',
  'University of Michigan',
  'USC',
  'Florida State University',
  'Notre Dame',
  'University of Texas',
  'Morgan State University',
];

final List<String> mockSports = [
  'Basketball',
  'Football',
  'Swimming',
  'Tennis',
  'Track & Field',
  'Soccer',
  'Baseball',
  'Volleyball',
  'Golf',
  'Lacrosse',
];

final List<String> mockMajors = [
  'Business Administration',
  'Computer Science',
  'Economics',
  'Engineering',
  'Psychology',
  'Biology',
  'Communications',
  'Political Science',
  'Mathematics',
  'Exercise Science',
];

final List<String> mockIndustries = [
  'Finance',
  'Technology',
  'Healthcare',
  'Consulting',
  'Sports Management',
  'Marketing',
  'Education',
  'Real Estate',
  'Law',
  'Entertainment',
]; 