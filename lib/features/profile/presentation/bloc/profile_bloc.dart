import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/athlete.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UploadProfileImageUseCase uploadProfileImageUseCase;
  
  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.uploadProfileImageUseCase,
  }) : super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
  }
  
  Future<void> _onGetProfile(GetProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    final result = await getProfileUseCase(event.userId);
    
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (athlete) => emit(ProfileLoaded(athlete)),
    );
  }
  
  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    final result = await updateProfileUseCase(event.athlete);
    
    result.fold(
      (failure) => emit(ProfileUpdateFailure(failure.message)),
      (updatedAthlete) => emit(ProfileUpdateSuccess(updatedAthlete)),
    );
  }
  
  Future<void> _onUploadProfileImage(UploadProfileImageEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    final params = UploadImageParams(
      athleteId: event.athleteId,
      imageBytes: event.imageBytes,
      fileName: event.fileName,
    );
    
    final result = await uploadProfileImageUseCase(params);
    
    result.fold(
      (failure) => emit(ProfileImageUploadFailure(failure.message)),
      (imageUrl) => emit(ProfileImageUploadSuccess(imageUrl)),
    );
  }
}
