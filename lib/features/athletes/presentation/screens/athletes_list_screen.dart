import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/models/athlete.dart';
import '../../../../features/athletes/presentation/bloc/filter_athletes_bloc.dart';
import '../widgets/athlete_card.dart';
import '../widgets/athlete_filter_panel.dart';
import '../widgets/athlete_sort_dropdown.dart';
import '../widgets/athletes_search_delegate.dart';

/// Screen that displays a filterable, sortable list of athletes
class AthletesListScreen extends StatelessWidget {
  /// Whether to enable dev mode features
  final bool isDevMode;

  /// Constructor
  const AthletesListScreen({
    Key? key,
    this.isDevMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FilterAthletesBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Athletes'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Implement search functionality
                final filterAthletesBloc = context.read<FilterAthletesBloc>();
                showSearch(
                  context: context,
                  delegate: AthletesSearchDelegate(
                    filterAthletesBloc: filterAthletesBloc,
                  ),
                );
              },
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Sample data for demonstration
    final sampleAthletes = _getSampleAthletes();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AthleteFilterPanel(initiallyExpanded: true),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<FilterAthletesBloc, FilterAthletesState>(
                builder: (context, state) {
                  final count = _filterAthletes(sampleAthletes, state).length;
                  return Text(
                    '$count athletes found',
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
                final filteredAthletes = _filterAthletes(sampleAthletes, state);
                final sortedAthletes = _sortAthletes(filteredAthletes, state);
                
                if (sortedAthletes.isEmpty) {
                  return const Center(
                    child: Text('No athletes match your filters'),
                  );
                }
                
                return ListView.separated(
                  itemCount: sortedAthletes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return AthleteCard(
                      athlete: sortedAthletes[index],
                      isCompact: true,
                      isDevMode: isDevMode,
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
  
  List<Athlete> _filterAthletes(List<Athlete> athletes, FilterAthletesState state) {
    return athletes.where((athlete) {
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
  
  List<Athlete> _sortAthletes(List<Athlete> athletes, FilterAthletesState state) {
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
  
  List<Athlete> _getSampleAthletes() {
    // This would normally come from a repository/API
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
      ),
    ];
  }
} 