part of 'edit_profile_bloc.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object> get props => [];
}

class InitializeEditProfileEvent extends EditProfileEvent {
  final Athlete athlete;
  
  const InitializeEditProfileEvent(this.athlete);

  @override
  List<Object> get props => [athlete];
}

class ChangeAthleteStatusEvent extends EditProfileEvent {
  final AthleteStatus status;
  
  const ChangeAthleteStatusEvent(this.status);

  @override
  List<Object> get props => [status];
}

class UpdateFieldEvent extends EditProfileEvent {
  final String field;
  final dynamic value;

  const UpdateFieldEvent(this.field, this.value);

  @override
  List<Object> get props => [field, value ?? ''];
}

class SaveProfileEvent extends EditProfileEvent {
  final Athlete updatedAthlete;
  
  const SaveProfileEvent(this.updatedAthlete);

  @override
  List<Object> get props => [updatedAthlete];
} 