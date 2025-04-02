import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/athlete.dart';
import '../../domain/usecases/get_all_athletes_usecase.dart';
import '../../domain/usecases/get_athletes_by_status_usecase.dart';
import '../../domain/usecases/search_athletes_usecase.dart';
import '../../domain/usecases/get_athlete_by_id_usecase.dart';

part 'athlete_event.dart';
part 'athlete_state.dart';

/// BLoC for managing athlete data and states
class AthleteBloc extends Bloc<AthleteEvent, AthleteState> {
  final GetAllAthletesUseCase getAllAthletesUseCase;
  final GetAthletesByStatusUseCase getAthletesByStatusUseCase;
  final SearchAthletesUseCase searchAthletesUseCase;
  final GetAthleteByIdUseCase getAthleteByIdUseCase;
  
  AthleteBloc({
    required this.getAllAthletesUseCase,
    required this.getAthletesByStatusUseCase,
    required this.searchAthletesUseCase,
    required this.getAthleteByIdUseCase,
  }) : super(AthleteInitial()) {
    on<LoadAllAthletes>(_onLoadAllAthletes);
    on<LoadAthletesByStatus>(_onLoadAthletesByStatus);
    on<SearchAthletes>(_onSearchAthletes);
    on<LoadAthleteDetails>(_onLoadAthleteDetails);
  }
  
  /// Handle loading all athletes
  Future<void> _onLoadAllAthletes(LoadAllAthletes event, Emitter<AthleteState> emit) async {
    emit(AthleteLoading());
    
    final result = await getAllAthletesUseCase();
    
    result.fold(
      (failure) => emit(AthleteError(failure.message)),
      (athletes) => emit(AthletesLoaded(athletes)),
    );
  }
  
  /// Handle loading athletes filtered by status
  Future<void> _onLoadAthletesByStatus(LoadAthletesByStatus event, Emitter<AthleteState> emit) async {
    emit(AthleteLoading());
    
    final result = await getAthletesByStatusUseCase(event.status);
    
    result.fold(
      (failure) => emit(AthleteError(failure.message)),
      (athletes) => emit(AthletesLoaded(athletes)),
    );
  }
  
  /// Handle searching athletes
  Future<void> _onSearchAthletes(SearchAthletes event, Emitter<AthleteState> emit) async {
    if (event.query.isEmpty) {
      add(LoadAllAthletes());
      return;
    }
    
    emit(AthleteLoading());
    
    final result = await searchAthletesUseCase(event.query);
    
    result.fold(
      (failure) => emit(AthleteError(failure.message)),
      (athletes) => emit(AthletesLoaded(athletes)),
    );
  }
  
  /// Handle loading details for a specific athlete
  Future<void> _onLoadAthleteDetails(LoadAthleteDetails event, Emitter<AthleteState> emit) async {
    emit(AthleteLoading());
    
    final result = await getAthleteByIdUseCase(event.id);
    
    result.fold(
      (failure) => emit(AthleteError(failure.message)),
      (athlete) => emit(AthleteDetailsLoaded(athlete)),
    );
  }
} 