import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/athlete.dart';
import '../../../../features/athletes/presentation/bloc/filter_athletes_bloc.dart';

/// A panel that provides controls for filtering a list of athletes
class AthleteFilterPanel extends StatefulWidget {
  /// Whether the panel should be displayed in an expanded state
  final bool initiallyExpanded;

  /// Constructor
  const AthleteFilterPanel({
    Key? key,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  State<AthleteFilterPanel> createState() => _AthleteFilterPanelState();
}

class _AthleteFilterPanelState extends State<AthleteFilterPanel> {
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              _buildFilterContent(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filter Athletes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            OutlinedButton(
              onPressed: _resetFilters,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              child: const Text('Reset'),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildFilterContent() {
    return BlocBuilder<FilterAthletesBloc, FilterAthletesState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusFilter(state),
            const SizedBox(height: 16),
            _buildMajorFilter(state),
            const SizedBox(height: 16),
            _buildCareerFilter(state),
          ],
        );
      },
    );
  }
  
  Widget _buildStatusFilter(FilterAthletesState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: AthleteStatus.values.map((status) {
            final isSelected = state.selectedStatus == status;
            return FilterChip(
              label: Text(status.displayName),
              selected: isSelected,
              onSelected: (selected) {
                _onStatusSelected(selected ? status : null);
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildMajorFilter(FilterAthletesState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Major',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AthleteMajor.values.map((major) {
            final isSelected = state.selectedMajors.contains(major);
            return FilterChip(
              label: Text(major.displayName),
              selected: isSelected,
              onSelected: (selected) {
                _onMajorSelected(major, selected);
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildCareerFilter(FilterAthletesState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Career',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AthleteCareer.values.map((career) {
            final isSelected = state.selectedCareers.contains(career);
            return FilterChip(
              label: Text(career.displayName),
              selected: isSelected,
              onSelected: (selected) {
                _onCareerSelected(career, selected);
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }
  
  void _onStatusSelected(AthleteStatus? status) {
    context.read<FilterAthletesBloc>().add(
      UpdateStatusFilterEvent(status: status),
    );
  }
  
  void _onMajorSelected(AthleteMajor major, bool selected) {
    context.read<FilterAthletesBloc>().add(
      selected
          ? AddMajorFilterEvent(major: major)
          : RemoveMajorFilterEvent(major: major),
    );
  }
  
  void _onCareerSelected(AthleteCareer career, bool selected) {
    context.read<FilterAthletesBloc>().add(
      selected
          ? AddCareerFilterEvent(career: career)
          : RemoveCareerFilterEvent(career: career),
    );
  }
  
  void _resetFilters() {
    context.read<FilterAthletesBloc>().add(ResetFiltersEvent());
  }
} 