import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/athlete.dart';
import '../../domain/usecases/get_athlete_by_id_usecase.dart';

part 'athlete_details_event.dart';
part 'athlete_details_state.dart';

/// BLoC for managing detailed athlete information
class AthleteDetailsBloc extends Bloc<AthleteDetailsEvent, AthleteDetailsState> {
  final GetAthleteByIdUseCase getAthleteByIdUseCase;
  
  AthleteDetailsBloc({
    required this.getAthleteByIdUseCase,
  }) : super(AthleteDetailsInitial()) {
    on<LoadAthleteById>(_onLoadAthleteById);
    on<MockAthleteDetails>(_onMockAthleteDetails);
  }
  
  /// Handle loading an athlete by their ID
  Future<void> _onLoadAthleteById(LoadAthleteById event, Emitter<AthleteDetailsState> emit) async {
    emit(AthleteDetailsLoading());
    
    final result = await getAthleteByIdUseCase(event.id);
    
    result.fold(
      (failure) => emit(AthleteDetailsError(failure.message)),
      (athlete) => emit(AthleteDetailsLoaded(athlete)),
    );
  }
  
  /// Handle loading mock athlete data for development
  void _onMockAthleteDetails(MockAthleteDetails event, Emitter<AthleteDetailsState> emit) {
    emit(AthleteDetailsLoaded(event.athlete));
  }
} 