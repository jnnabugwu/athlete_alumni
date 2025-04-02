import 'package:athlete_alumni/features/athletes/presentation/bloc/filter_athletes_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/athlete.dart';
import '../widgets/athlete_card.dart';
import '../widgets/athlete_filter_panel.dart';
import '../widgets/athlete_sort_dropdown.dart';

/// A demo screen showcasing the athlete filtering and sorting UI
class AthleteFilterDemoScreen extends StatelessWidget {
  /// Constructor
  const AthleteFilterDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FilterAthletesBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Athlete Filter Demo'),
        ),
        body: const _AthleteFilterDemoContent(),
      ),
    );
  }
}

class _AthleteFilterDemoContent extends StatelessWidget {
  const _AthleteFilterDemoContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This is a demo of the athlete filtering and sorting components',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const AthleteFilterPanel(initiallyExpanded: true),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<FilterAthletesBloc, FilterAthletesState>(
                builder: (context, state) {
                  final filteredAthletes = _getFilteredAthletes(state);
                  return Text(
                    '${filteredAthletes.length} athletes found',
                    style: Theme.of(context).textTheme.titleMedium,
                  );
                },
              ),
              const AthleteSortDropdown(),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<FilterAthletesBloc, FilterAthletesState>(
              builder: (context, state) {
                final filteredAthletes = _getFilteredAthletes(state);
                final sortedAthletes = _getSortedAthletes(filteredAthletes, state);
                
                if (sortedAthletes.isEmpty) {
                  return const Center(
                    child: Text('No athletes match your filters'),
                  );
                }
                
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: sortedAthletes.length,
                  itemBuilder: (context, index) {
                    return AthleteCard(
                      athlete: sortedAthletes[index],
                      isCompact: false,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Athlete> _getFilteredAthletes(FilterAthletesState state) {
    return getMockAthletes().where((athlete) {
      // Status filter
      if (state.selectedStatus != null && athlete.status != state.selectedStatus) {
        return false;
      }
      
      // Major filter
      if (state.selectedMajors.isNotEmpty && !state.selectedMajors.contains(athlete.major)) {
        return false;
      }
      
      // Career filter
      if (state.selectedCareers.isNotEmpty && !state.selectedCareers.contains(athlete.career)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  List<Athlete> _getSortedAthletes(List<Athlete> athletes, FilterAthletesState state) {
    final sortedList = List<Athlete>.from(athletes);
    
    sortedList.sort((a, b) {
      int comparison;
      
      switch (state.sortOption) {
        case AthleteSortOption.name:
          comparison = a.name.compareTo(b.name);
          break;
        case AthleteSortOption.graduationYear:
          final aYear = a.graduationYear?.year ?? 0;
          final bYear = b.graduationYear?.year ?? 0;
          comparison = aYear.compareTo(bYear);
          break;
        case AthleteSortOption.university:
          final aUniversity = a.university ?? '';
          final bUniversity = b.university ?? '';
          comparison = aUniversity.compareTo(bUniversity);
          break;
        case AthleteSortOption.sport:
          final aSport = a.sport ?? '';
          final bSport = b.sport ?? '';
          comparison = aSport.compareTo(bSport);
          break;
        case AthleteSortOption.major:
          comparison = a.major.displayName.compareTo(b.major.displayName);
          break;
        case AthleteSortOption.career:
          comparison = a.career.displayName.compareTo(b.career.displayName);
          break;
      }
      
      // Invert comparison for descending order
      return state.sortAscending ? comparison : -comparison;
    });
    
    return sortedList;
  }
}

/// Get a list of mock athletes for testing
List<Athlete> getMockAthletes() {
  return [
    Athlete(
      id: '1',
      name: 'John Smith',
      email: 'john.smith@example.com',
      status: AthleteStatus.current,
      major: AthleteMajor.computerScience,
      career: AthleteCareer.softwareEngineer,
      sport: 'Basketball',
      university: 'Stanford University',
      graduationYear: DateTime(2024),
      profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    Athlete(
      id: '2',
      name: 'Emma Johnson',
      email: 'emma.johnson@example.com',
      status: AthleteStatus.former,
      major: AthleteMajor.business,
      career: AthleteCareer.marketing,
      sport: 'Soccer',
      university: 'UCLA',
      graduationYear: DateTime(2020),
      profileImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
    ),
    Athlete(
      id: '3',
      name: 'Michael Williams',
      email: 'michael.williams@example.com',
      status: AthleteStatus.current,
      major: AthleteMajor.biology,
      career: AthleteCareer.medicine,
      sport: 'Swimming',
      university: 'UC Berkeley',
      graduationYear: DateTime(2025),
      profileImageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
    ),
    Athlete(
      id: '4',
      name: 'Sophia Garcia',
      email: 'sophia.garcia@example.com',
      status: AthleteStatus.former,
      major: AthleteMajor.communications,
      career: AthleteCareer.mediaProduction,
      sport: 'Volleyball',
      university: 'Duke University',
      graduationYear: DateTime(2019),
      profileImageUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
    ),
    Athlete(
      id: '5',
      name: 'Daniel Brown',
      email: 'daniel.brown@example.com',
      status: AthleteStatus.current,
      major: AthleteMajor.engineering,
      career: AthleteCareer.engineering,
      sport: 'Football',
      university: 'MIT',
      graduationYear: DateTime(2023),
      profileImageUrl: 'https://randomuser.me/api/portraits/men/5.jpg',
    ),
    Athlete(
      id: '6',
      name: 'Olivia Martinez',
      email: 'olivia.martinez@example.com',
      status: AthleteStatus.former,
      major: AthleteMajor.psychology,
      career: AthleteCareer.humanResources,
      sport: 'Tennis',
      university: 'University of Michigan',
      graduationYear: DateTime(2021),
      profileImageUrl: 'https://randomuser.me/api/portraits/women/6.jpg',
    ),
    Athlete(
      id: '7',
      name: 'James Wilson',
      email: 'james.wilson@example.com',
      status: AthleteStatus.current,
      major: AthleteMajor.economics,
      career: AthleteCareer.finance,
      sport: 'Golf',
      university: 'Princeton',
      graduationYear: DateTime(2023),
      profileImageUrl: 'https://randomuser.me/api/portraits/men/7.jpg',
    ),
    Athlete(
      id: '8',
      name: 'Ava Rodriguez',
      email: 'ava.rodriguez@example.com',
      status: AthleteStatus.former,
      major: AthleteMajor.education,
      career: AthleteCareer.businessAnalyst,
      sport: 'Gymnastics',
      university: 'Harvard',
      graduationYear: DateTime(2020),
      profileImageUrl: 'https://randomuser.me/api/portraits/women/8.jpg',
    ),
  ];
} 