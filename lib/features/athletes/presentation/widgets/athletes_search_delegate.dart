import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/athletes/presentation/bloc/filter_athletes_bloc.dart';
import 'athlete_card.dart';

class AthletesSearchDelegate extends SearchDelegate<String> {
  final FilterAthletesBloc filterAthletesBloc;

  AthletesSearchDelegate({required this.filterAthletesBloc});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, '');
          } else {
            query = '';
            showSuggestions(context);
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Dispatch search event to the bloc
    filterAthletesBloc.add(SearchAthletesEvent(query: query));
    
    return BlocBuilder<FilterAthletesBloc, FilterAthletesState>(
      bloc: filterAthletesBloc,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.filteredAthletes.isEmpty) {
          return Center(
            child: Text(
              'No athletes found for "$query"',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        } else {
          return ListView.builder(
            itemCount: state.filteredAthletes.length,
            itemBuilder: (context, index) {
              final athlete = state.filteredAthletes[index];
              return AthleteCard(athlete: athlete);
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Simple placeholder for now
    return const Center(
      child: Text('Enter athlete name, major, sport, or career'),
    );
    
    /* 
    // Suggestions functionality commented out for now
    if (query.isNotEmpty) {
      filterAthletesBloc.add(SearchAthletesEvent(query));
      
      return BlocBuilder<FilterAthletesBloc, FilterAthletesState>(
        bloc: filterAthletesBloc,
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.athletes.isEmpty) {
            return Center(
              child: Text(
                'No athletes found for "$query"',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          } else {
            return ListView.builder(
              itemCount: state.athletes.length,
              itemBuilder: (context, index) {
                final athlete = state.athletes[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: athlete.profileImageUrl != null
                        ? NetworkImage(athlete.profileImageUrl!)
                        : null,
                    child: athlete.profileImageUrl == null
                        ? Text(athlete.name[0])
                        : null,
                  ),
                  title: Text(athlete.name),
                  subtitle: Text(athlete.major.displayName),
                  onTap: () {
                    query = athlete.name;
                    showResults(context);
                  },
                );
              },
            );
          }
        },
      );
    }
    
    return const Center(
      child: Text('Enter athlete name, major, sport, or career'),
    );
    */
  }
} 