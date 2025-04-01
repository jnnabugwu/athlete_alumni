import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/athlete.dart';
import '../../domain/usecases/update_profile_usecase.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;
  
  EditProfileBloc({
    required this.updateProfileUseCase,
  }) : super(EditProfileInitial()) {
    on<InitializeEditProfileEvent>(_onInitializeEditProfile);
    on<ChangeAthleteStatusEvent>(_onChangeAthleteStatus);
    on<SaveProfileEvent>(_onSaveProfile);
  }
  
  void _onInitializeEditProfile(InitializeEditProfileEvent event, Emitter<EditProfileState> emit) {
    emit(EditProfileLoaded(athlete: event.athlete));
  }
  
  void _onChangeAthleteStatus(ChangeAthleteStatusEvent event, Emitter<EditProfileState> emit) {
    final currentState = state;
    if (currentState is EditProfileLoaded) {
      final updatedAthlete = currentState.athlete.copyWith(status: event.status);
      emit(currentState.copyWith(athlete: updatedAthlete, isDirty: true));
    }
  }
  
  Future<void> _onSaveProfile(SaveProfileEvent event, Emitter<EditProfileState> emit) async {
    emit(EditProfileSaving());
    
    final result = await updateProfileUseCase(event.updatedAthlete);
    
    result.fold(
      (failure) => emit(EditProfileSaveFailure(failure.message)),
      (updatedAthlete) => emit(EditProfileSaveSuccess(updatedAthlete)),
    );
  }
} 