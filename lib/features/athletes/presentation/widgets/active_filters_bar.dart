import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/athlete.dart';
import '../bloc/filter_athletes_bloc.dart';

class ActiveFiltersBar extends StatelessWidget {
  const ActiveFiltersBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterAthletesBloc, FilterAthletesState>(
      builder: (context, state) {
        // If no filters are active, don't show the bar
        if (state.isDefault) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Filters:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Status filter chip
                  if (state.selectedStatus != null)
                    _buildFilterChip(
                      context,
                      label: 'Status: ${state.selectedStatus == AthleteStatus.current ? 'Current' : 'Former'}',
                      onRemove: () => context.read<FilterAthletesBloc>().add(
                            const UpdateStatusFilterEvent(),
                          ),
                    ),
                  
                  // Search query chip
                  if (state.searchQuery.isNotEmpty)
                    _buildFilterChip(
                      context,
                      label: 'Search: ${state.searchQuery}',
                      onRemove: () => context.read<FilterAthletesBloc>().add(
                            const SearchAthletesEvent(query: ''),
                          ),
                    ),
                  
                  // Major filter chips
                  ...state.selectedMajors.map(
                    (major) => _buildFilterChip(
                      context,
                      label: 'Major: ${major.displayName}',
                      onRemove: () => context.read<FilterAthletesBloc>().add(
                            RemoveMajorFilterEvent(major: major),
                          ),
                    ),
                  ),
                  
                  // Career filter chips
                  ...state.selectedCareers.map(
                    (career) => _buildFilterChip(
                      context,
                      label: 'Career: ${career.displayName}',
                      onRemove: () => context.read<FilterAthletesBloc>().add(
                            RemoveCareerFilterEvent(career: career),
                          ),
                    ),
                  ),
                  
                  // Sort indicator
                  _buildSortChip(context, state),
                ],
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => context.read<FilterAthletesBloc>().add(ResetFiltersEvent()),
                child: const Text('Clear All'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required VoidCallback onRemove,
  }) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onRemove,
    );
  }
  
  Widget _buildSortChip(BuildContext context, FilterAthletesState state) {
    String sortLabel;
    switch (state.sortOption) {
      case AthleteSortOption.name:
        sortLabel = 'Name';
        break;
      case AthleteSortOption.graduationYear:
        sortLabel = 'Graduation Year';
        break;
      case AthleteSortOption.sport:
        sortLabel = 'Sport';
        break;
      case AthleteSortOption.university:
        sortLabel = 'University';
        break;
      case AthleteSortOption.major:
        sortLabel = 'Major';
        break;
      case AthleteSortOption.career:
        sortLabel = 'Career';
        break;
    }
    
    return Chip(
      avatar: Icon(
        state.sortAscending 
            ? Icons.arrow_upward 
            : Icons.arrow_downward,
        size: 18,
      ),
      label: Text('Sort: $sortLabel'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      deleteIcon: const Icon(Icons.swap_vert, size: 18),
      onDeleted: () => context.read<FilterAthletesBloc>().add(ToggleSortDirectionEvent()),
    );
  }
} 