part of 'athlete_bloc.dart';

/// Base class for all athlete-related states
abstract class AthleteState extends Equatable {
  const AthleteState();
  
  @override
  List<Object> get props => [];
}

/// Initial state before any athlete data is loaded
class AthleteInitial extends AthleteState {}

/// State during data loading
class AthleteLoading extends AthleteState {}

/// State when a list of athletes is successfully loaded
class AthletesLoaded extends AthleteState {
  final List<Athlete> athletes;
  
  const AthletesLoaded(this.athletes);
  
  @override
  List<Object> get props => [athletes];
}

/// State when a single athlete's details are loaded
class AthleteDetailsLoaded extends AthleteState {
  final Athlete athlete;
  
  const AthleteDetailsLoaded(this.athlete);
  
  @override
  List<Object> get props => [athlete];
}

/// State when an error occurs during data loading
class AthleteError extends AthleteState {
  final String message;
  
  const AthleteError(this.message);
  
  @override
  List<Object> get props => [message];
} 