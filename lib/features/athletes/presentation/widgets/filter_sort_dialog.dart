import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/athlete.dart';
import '../bloc/filter_athletes_bloc.dart';

class FilterSortDialog extends StatefulWidget {
  const FilterSortDialog({Key? key}) : super(key: key);

  @override
  State<FilterSortDialog> createState() => _FilterSortDialogState();
}

class _FilterSortDialogState extends State<FilterSortDialog> {
  // Local state to track changes before applying
  late String _searchQuery;
  late AthleteStatus? _selectedStatus;
  late List<AthleteMajor> _selectedMajors;
  late List<AthleteCareer> _selectedCareers;
  late AthleteSortOption _sortOption;
  late bool _sortAscending;

  @override
  void initState() {
    super.initState();
    
    // Initialize local state from current BLoC state
    final state = context.read<FilterAthletesBloc>().state;
    _searchQuery = state.searchQuery;
    _selectedStatus = state.selectedStatus;
    _selectedMajors = List.from(state.selectedMajors);
    _selectedCareers = List.from(state.selectedCareers);
    _sortOption = state.sortOption;
    _sortAscending = state.sortAscending;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildDialogTitle(),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchField(),
                      const Divider(),
                      _buildStatusFilter(),
                      const Divider(),
                      _buildMajorFilters(),
                      const Divider(),
                      _buildCareerFilters(),
                      const Divider(),
                      _buildSortOptions(),
                      const SizedBox(height: 16),
                      _buildSortDirection(),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogTitle() {
    return const Center(
      child: Text(
        'Filter & Sort Athletes',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search athletes...',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Status:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<AthleteStatus?>(
                title: const Text('All'),
                value: null,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<AthleteStatus?>(
                title: const Text('Current'),
                value: AthleteStatus.current,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<AthleteStatus?>(
                title: const Text('Former'),
                value: AthleteStatus.former,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMajorFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Majors:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 0,
          children: AthleteMajor.values.map((major) {
            return CheckboxListTile(
              title: Text(major.displayName),
              value: _selectedMajors.contains(major),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    if (!_selectedMajors.contains(major)) {
                      _selectedMajors.add(major);
                    }
                  } else {
                    _selectedMajors.remove(major);
                  }
                });
              },
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCareerFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Careers:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 0,
          children: AthleteCareer.values.map((career) {
            return CheckboxListTile(
              title: Text(career.displayName),
              value: _selectedCareers.contains(career),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    if (!_selectedCareers.contains(career)) {
                      _selectedCareers.add(career);
                    }
                  } else {
                    _selectedCareers.remove(career);
                  }
                });
              },
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Sort By:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          children: AthleteSortOption.values.map((option) {
            IconData icon;
            switch (option) {
              case AthleteSortOption.name:
                icon = Icons.person;
                break;
              case AthleteSortOption.graduationYear:
                icon = Icons.school;
                break;
              case AthleteSortOption.sport:
                icon = Icons.sports;
                break;
              case AthleteSortOption.university:
                icon = Icons.account_balance;
                break;
              case AthleteSortOption.major:
                icon = Icons.book;
                break;
              case AthleteSortOption.career:
                icon = Icons.work;
                break;
            }
            
            return RadioListTile<AthleteSortOption>(
              title: Row(
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(_getSortOptionLabel(option)),
                ],
              ),
              value: option,
              groupValue: _sortOption,
              onChanged: (value) {
                setState(() {
                  _sortOption = value!;
                });
              },
              dense: true,
              selected: _sortOption == option,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getSortOptionLabel(AthleteSortOption option) {
    switch (option) {
      case AthleteSortOption.name:
        return 'Name';
      case AthleteSortOption.graduationYear:
        return 'Graduation Year';
      case AthleteSortOption.sport:
        return 'Sport';
      case AthleteSortOption.university:
        return 'University';
      case AthleteSortOption.major:
        return 'Major';
      case AthleteSortOption.career:
        return 'Career';
    }
  }

  Widget _buildSortDirection() {
    return Row(
      children: [
        const Text(
          'Sort Direction:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(
              value: true,
              label: Text('Ascending'),
              icon: Icon(Icons.arrow_upward),
            ),
            ButtonSegment<bool>(
              value: false,
              label: Text('Descending'),
              icon: Icon(Icons.arrow_downward),
            ),
          ],
          selected: {_sortAscending},
          onSelectionChanged: (selection) {
            setState(() {
              _sortAscending = selection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _resetFilters,
          child: const Text('Reset Filters'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _applyFilters,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  void _resetFilters() {
    // First update local state
    setState(() {
      _searchQuery = '';
      _selectedStatus = null;
      _selectedMajors = [];
      _selectedCareers = [];
      _sortOption = AthleteSortOption.name;
      _sortAscending = true;
    });
    
    // Then directly apply the reset to the BLoC
    final bloc = context.read<FilterAthletesBloc>();
    bloc.add(ResetFiltersEvent());
    
    // Close the dialog
    Navigator.of(context).pop();
  }

  void _applyFilters() {
    final bloc = context.read<FilterAthletesBloc>();
    
    // Compare with current state and dispatch events only for changes
    final currentState = bloc.state;
    
    // Update search query if changed
    if (_searchQuery != currentState.searchQuery) {
      bloc.add(SearchAthletesEvent(query: _searchQuery));
    }
    
    // Update status filter if changed
    if (_selectedStatus != currentState.selectedStatus) {
      debugPrint('Updating status filter: ${_selectedStatus?.name ?? "All"}');
      bloc.add(UpdateStatusFilterEvent(status: _selectedStatus));
    }
    
    // Update major filters
    _updateMajorFilters(bloc, currentState);
    
    // Update career filters
    _updateCareerFilters(bloc, currentState);
    
    // Update sort option if changed
    if (_sortOption != currentState.sortOption) {
      bloc.add(UpdateSortOptionEvent(sortOption: _sortOption));
    }
    
    // Update sort direction if changed
    if (_sortAscending != currentState.sortAscending) {
      bloc.add(ToggleSortDirectionEvent());
    }
    
    // Close the dialog
    Navigator.of(context).pop();
  }

  void _updateMajorFilters(FilterAthletesBloc bloc, FilterAthletesState currentState) {
    // Majors to add (in new selection but not in current state)
    for (final major in _selectedMajors) {
      if (!currentState.selectedMajors.contains(major)) {
        bloc.add(AddMajorFilterEvent(major: major));
      }
    }
    
    // Majors to remove (in current state but not in new selection)
    for (final major in currentState.selectedMajors) {
      if (!_selectedMajors.contains(major)) {
        bloc.add(RemoveMajorFilterEvent(major: major));
      }
    }
  }

  void _updateCareerFilters(FilterAthletesBloc bloc, FilterAthletesState currentState) {
    // Careers to add
    for (final career in _selectedCareers) {
      if (!currentState.selectedCareers.contains(career)) {
        bloc.add(AddCareerFilterEvent(career: career));
      }
    }
    
    // Careers to remove
    for (final career in currentState.selectedCareers) {
      if (!_selectedCareers.contains(career)) {
        bloc.add(RemoveCareerFilterEvent(career: career));
      }
    }
  }
} 