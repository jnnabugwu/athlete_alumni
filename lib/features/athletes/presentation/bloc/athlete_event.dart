part of 'athlete_bloc.dart';

/// Base class for all athlete-related events
abstract class AthleteEvent extends Equatable {
  const AthleteEvent();
  
  @override
  List<Object> get props => [];
}

/// Event to load all athletes
class LoadAllAthletes extends AthleteEvent {}

/// Event to load athletes filtered by status
class LoadAthletesByStatus extends AthleteEvent {
  final AthleteStatus status;
  
  const LoadAthletesByStatus(this.status);
  
  @override
  List<Object> get props => [status];
}

/// Event to search athletes by query
class SearchAthletes extends AthleteEvent {
  final String query;
  
  const SearchAthletes(this.query);
  
  @override
  List<Object> get props => [query];
}

/// Event to load details for a specific athlete
class LoadAthleteDetails extends AthleteEvent {
  final String id;
  
  const LoadAthleteDetails(this.id);
  
  @override
  List<Object> get props => [id];
} 