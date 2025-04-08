import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/athlete.dart';
import '../../../../core/di/injection.dart';
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
    on<MockProfileLoadedEvent>(_onMockProfileLoaded);
    on<InitializeNewProfileEvent>(_onInitializeNewProfile);
  }
  
  Future<void> _onGetProfile(GetProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    try {
      debugPrint('ProfileBloc: Getting profile for user ID: ${event.userId}');
      final result = await getProfileUseCase(event.userId);
      
      result.fold(
        (failure) {
          final errorMsg = 'Failed to get profile: ${failure.toString()}';
          debugPrint('ProfileBloc: $errorMsg');
          
          // If we have a temp ID, try to create a new profile
          if (event.userId.startsWith('user-') || event.userId == 'unknown-user-id') {
            debugPrint('ProfileBloc: Temporary ID detected, creating new profile');
            
            // Get auth data from Supabase
            final supabaseClient = sl<SupabaseClient>();
            final currentUser = supabaseClient.auth.currentUser;
            
            if (currentUser != null && currentUser.email != null) {
              debugPrint('ProfileBloc: Creating profile with email: ${currentUser.email}');
              
              // Create a basic profile for the new user
              final newAthlete = Athlete(
                id: currentUser.id,
                email: currentUser.email ?? '', // Handle null email (shouldn't happen)
                name: currentUser.userMetadata?['full_name'] ?? '',
                status: AthleteStatus.current,
                major: AthleteMajor.other,
                career: AthleteCareer.other,
              );
              
              emit(ProfileLoaded(newAthlete));
              return;
            }
          }
          
          emit(ProfileError(errorMsg));
        },
        (athlete) {
          debugPrint('ProfileBloc: Successfully loaded profile: ${athlete.email}');
          emit(ProfileLoaded(athlete));
        },
      );
    } catch (e) {
      debugPrint('ProfileBloc: Unexpected error in _onGetProfile: $e');
      emit(ProfileError('An unexpected error occurred: $e'));
    }
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
  
  // Handle mock profile loaded event for development
  void _onMockProfileLoaded(MockProfileLoadedEvent event, Emitter<ProfileState> emit) {
    emit(ProfileLoaded(event.athlete));
  }
  
  // Handle initializing a new profile for first-time users
  Future<void> _onInitializeNewProfile(InitializeNewProfileEvent event, Emitter<ProfileState> emit) async {
    debugPrint('ProfileBloc: Initializing new profile with data: ${event.email}, ${event.fullName}, ${event.college}, ${event.username}');
    
    emit(ProfileLoading());
    
    try {
      // First, check if we already have a profile in the database for this user
      if (event.authUserId != 'user-unknown' && event.authUserId != 'new-user' && !event.authUserId.startsWith('user-')) {
        // Use the dependency injector to get the SupabaseClient
        final supabaseClient = sl<SupabaseClient>();
        
        try {
          final response = await supabaseClient
              .from('athletes')
              .select()
              .eq('id', event.authUserId)
              .maybeSingle();
              
          if (response != null) {
            debugPrint('ProfileBloc: Found existing athlete profile in database');
            final athlete = Athlete.fromJson(response);
            emit(ProfileLoaded(athlete));
            return;
          }
        } catch (e) {
          debugPrint('ProfileBloc: Error checking for existing profile: $e');
          // Continue with profile creation even if lookup fails
        }
      }
      
      // If we get here, we need to create a new profile
      // Create an athlete object with data from registration if available
      final Map<String, dynamic> athleteData = {
        'id': event.authUserId, // Use the auth user ID
        'name': event.fullName ?? '', // Use name from registration if available
        'email': event.email ?? '', // Use provided email if available
        'university': event.college, // Use college from registration
        'status': event.athleteStatus?.name ?? AthleteStatus.current.name, // Use status from registration or default
        'major': AthleteMajor.other.name, // Default value
        'career': AthleteCareer.other.name, // Default value
      };
      
      // Add the username to the metadata for Supabase
      athleteData['username'] = event.username;
      
      final newAthlete = Athlete.fromJson(athleteData);
      
      debugPrint('ProfileBloc: Created new athlete profile: $newAthlete');
      
      // Emit a loaded state with the profile
      emit(ProfileLoaded(newAthlete));
    } catch (e) {
      debugPrint('ProfileBloc: Error initializing new profile: $e');
      emit(ProfileError('Failed to initialize profile: ${e.toString()}'));
    }
  }
}
