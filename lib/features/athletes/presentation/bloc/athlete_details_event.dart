part of 'athlete_details_bloc.dart';

/// Base class for all athlete details events
abstract class AthleteDetailsEvent extends Equatable {
  const AthleteDetailsEvent();
  
  @override
  List<Object> get props => [];
}

/// Event to load an athlete by their ID
class LoadAthleteById extends AthleteDetailsEvent {
  final String id;
  
  const LoadAthleteById(this.id);
  
  @override
  List<Object> get props => [id];
}

/// Event to use mock data for development purposes
class MockAthleteDetails extends AthleteDetailsEvent {
  final Athlete athlete;
  
  const MockAthleteDetails(this.athlete);
  
  @override
  List<Object> get props => [athlete];
} 