part of 'edit_profile_bloc.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();
  
  @override
  List<Object> get props => [];
}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoaded extends EditProfileState {
  final Athlete athlete;
  final bool isDirty;
  
  const EditProfileLoaded({
    required this.athlete,
    this.isDirty = false,
  });
  
  EditProfileLoaded copyWith({
    Athlete? athlete,
    bool? isDirty,
  }) {
    return EditProfileLoaded(
      athlete: athlete ?? this.athlete,
      isDirty: isDirty ?? this.isDirty,
    );
  }
  
  @override
  List<Object> get props => [athlete, isDirty];
}

class EditProfileSaving extends EditProfileState {}

class EditProfileSaveSuccess extends EditProfileState {
  final Athlete athlete;
  
  const EditProfileSaveSuccess(this.athlete);
  
  @override
  List<Object> get props => [athlete];
}

class EditProfileSaveFailure extends EditProfileState {
  final String message;
  
  const EditProfileSaveFailure(this.message);
  
  @override
  List<Object> get props => [message];
} 