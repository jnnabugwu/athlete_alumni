part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Athlete athlete;
  final String? imageUrl;
  
  const ProfileLoaded(this.athlete, {this.imageUrl});
  
  @override
  List<Object> get props => [athlete, imageUrl ?? ''];

  // Create a copy of ProfileLoaded with new imageUrl
  ProfileLoaded copyWith({
    Athlete? athlete,
    String? imageUrl,
  }) {
    return ProfileLoaded(
      athlete ?? this.athlete,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;
  
  const ProfileError(this.message);
  
  @override
  List<Object> get props => [message];
}

class ProfileUpdateSuccess extends ProfileState {
  final Athlete athlete;
  
  const ProfileUpdateSuccess(this.athlete);
  
  @override
  List<Object> get props => [athlete];
}

class ProfileUpdateFailure extends ProfileState {
  final String message;
  
  const ProfileUpdateFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ProfileImageUploadSuccess extends ProfileState {
  final String imageUrl;
  
  const ProfileImageUploadSuccess(this.imageUrl);
  
  @override
  List<Object> get props => [imageUrl];
}

class ProfileImageUploadFailure extends ProfileState {
  final String message;
  
  const ProfileImageUploadFailure(this.message);
  
  @override
  List<Object> get props => [message];
}
