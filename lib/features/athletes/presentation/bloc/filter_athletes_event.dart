part of 'filter_athletes_bloc.dart';

/// Base class for FilterAthletes events
abstract class FilterAthletesEvent extends Equatable {
  /// Constructor
  const FilterAthletesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to update status filter
class UpdateStatusFilterEvent extends FilterAthletesEvent {
  /// Status to filter by (null to clear filter)
  final AthleteStatus? status;

  /// Constructor
  const UpdateStatusFilterEvent({this.status});

  @override
  List<Object?> get props => [status];
}

/// Event to add a major to filter
class AddMajorFilterEvent extends FilterAthletesEvent {
  /// Major to add
  final AthleteMajor major;

  /// Constructor
  const AddMajorFilterEvent({required this.major});

  @override
  List<Object> get props => [major];
}

/// Event to remove a major from filter
class RemoveMajorFilterEvent extends FilterAthletesEvent {
  /// Major to remove
  final AthleteMajor major;

  /// Constructor
  const RemoveMajorFilterEvent({required this.major});

  @override
  List<Object> get props => [major];
}

/// Event to add a career to filter
class AddCareerFilterEvent extends FilterAthletesEvent {
  /// Career to add
  final AthleteCareer career;

  /// Constructor
  const AddCareerFilterEvent({required this.career});

  @override
  List<Object> get props => [career];
}

/// Event to remove a career from filter
class RemoveCareerFilterEvent extends FilterAthletesEvent {
  /// Career to remove
  final AthleteCareer career;

  /// Constructor
  const RemoveCareerFilterEvent({required this.career});

  @override
  List<Object> get props => [career];
}

/// Event to update the sort option
class UpdateSortOptionEvent extends FilterAthletesEvent {
  /// Sort option to use
  final AthleteSortOption sortOption;

  /// Constructor
  const UpdateSortOptionEvent({required this.sortOption});

  @override
  List<Object> get props => [sortOption];
}

/// Event to toggle sort direction
class ToggleSortDirectionEvent extends FilterAthletesEvent {}

/// Event to search athletes by text
class SearchAthletesEvent extends FilterAthletesEvent {
  /// Text query
  final String query;

  /// Constructor
  const SearchAthletesEvent({required this.query});

  @override
  List<Object> get props => [query];
}

/// Event to reset all filters
class ResetFiltersEvent extends FilterAthletesEvent {} 