part of 'athlete_details_bloc.dart';

/// Base class for all athlete details states
abstract class AthleteDetailsState extends Equatable {
  const AthleteDetailsState();
  
  @override
  List<Object> get props => [];
}

/// Initial state before any athlete details are loaded
class AthleteDetailsInitial extends AthleteDetailsState {}

/// State during data loading
class AthleteDetailsLoading extends AthleteDetailsState {}

/// State when athlete details are successfully loaded
class AthleteDetailsLoaded extends AthleteDetailsState {
  final Athlete athlete;
  
  const AthleteDetailsLoaded(this.athlete);
  
  @override
  List<Object> get props => [athlete];
}

/// State when an error occurs during data loading
class AthleteDetailsError extends AthleteDetailsState {
  final String message;
  
  const AthleteDetailsError(this.message);
  
  @override
  List<Object> get props => [message];
} 