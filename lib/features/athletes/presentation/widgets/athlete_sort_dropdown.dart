import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/athlete.dart';
import '../bloc/filter_athletes_bloc.dart';

/// A dropdown widget that provides options for sorting athletes
class AthleteSortDropdown extends StatelessWidget {
  /// Constructor
  const AthleteSortDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterAthletesBloc, FilterAthletesState>(
      builder: (context, state) {
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sort by:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                _buildSortDropdown(context, state),
                const SizedBox(width: 8),
                _buildSortDirectionButton(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortDropdown(BuildContext context, FilterAthletesState state) {
    return DropdownButton<AthleteSortOption>(
      value: state.sortOption,
      underline: const SizedBox.shrink(),
      onChanged: (AthleteSortOption? newSortOption) {
        if (newSortOption != null) {
          context.read<FilterAthletesBloc>().add(
            UpdateSortOptionEvent(sortOption: newSortOption),
          );
        }
      },
      items: AthleteSortOption.values.map((option) {
        return DropdownMenuItem<AthleteSortOption>(
          value: option,
          child: Text(_getSortOptionLabel(option)),
        );
      }).toList(),
    );
  }

  Widget _buildSortDirectionButton(BuildContext context, FilterAthletesState state) {
    final icon = state.sortAscending
        ? Icons.arrow_upward
        : Icons.arrow_downward;
    
    final tooltip = state.sortAscending
        ? 'Sort ascending'
        : 'Sort descending';
        
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: () {
        context.read<FilterAthletesBloc>().add(
          ToggleSortDirectionEvent(),
        );
      },
    );
  }
  
  String _getSortOptionLabel(AthleteSortOption option) {
    switch (option) {
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
      default:
        return 'Unknown';
    }
  }
} 