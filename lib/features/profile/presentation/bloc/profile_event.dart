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

/// Event to directly load a mock profile for development purposes
class MockProfileLoadedEvent extends ProfileEvent {
  final Athlete athlete;
  
  const MockProfileLoadedEvent(this.athlete);

  @override
  List<Object> get props => [athlete];
}

/// Event to initialize a new profile for first-time users
class InitializeNewProfileEvent extends ProfileEvent {
  final String authUserId;
  final String? email;
  final String? fullName;
  final String? username;
  final String? college;
  final AthleteStatus? athleteStatus;
  
  const InitializeNewProfileEvent({
    required this.authUserId,
    this.email,
    this.fullName,
    this.username,
    this.college,
    this.athleteStatus,
  });

  @override
  List<Object> get props => [
    authUserId,
    if (email != null) email!,
    if (fullName != null) fullName!,
    if (username != null) username!,
    if (college != null) college!,
    if (athleteStatus != null) athleteStatus!,
  ];
}

/// Event to get the profile image URL for an athlete
class GetProfileImageUrlEvent extends ProfileEvent {
  final String athleteId;
  
  const GetProfileImageUrlEvent(this.athleteId);

  @override
  List<Object> get props => [athleteId];
}
