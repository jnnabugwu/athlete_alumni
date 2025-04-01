part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class GetProfileEvent extends ProfileEvent {
  final String userId;
  
  const GetProfileEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class UpdateProfileEvent extends ProfileEvent {
  final Athlete athlete;
  
  const UpdateProfileEvent(this.athlete);

  @override
  List<Object> get props => [athlete];
}

class UploadProfileImageEvent extends ProfileEvent {
  final String athleteId;
  final Uint8List imageBytes;
  final String fileName;
  
  const UploadProfileImageEvent({
    required this.athleteId,
    required this.imageBytes,
    required this.fileName,
  });

  @override
  List<Object> get props => [athleteId, imageBytes, fileName];
}
