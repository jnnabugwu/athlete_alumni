part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoadPersistedState extends AuthEvent {
  const LoadPersistedState();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignedOut extends AuthEvent {
  const AuthSignedOut();
}

class AuthSessionUpdated extends AuthEvent {
  final Athlete? athlete;

  const AuthSessionUpdated({this.athlete});

  @override
  List<Object?> get props => [athlete];
}

class AuthErrorOccurred extends AuthEvent {
  final String message;

  const AuthErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? fullName;
  final String? username;
  final String? college;
  final AthleteStatus? athleteStatus;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.fullName,
    this.username,
    this.college,
    this.athleteStatus,
  });

  @override
  List<Object?> get props => [email, password, fullName, username, college, athleteStatus];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}

class AuthNewPasswordSubmitted extends AuthEvent {
  final String password;
  final String token;

  const AuthNewPasswordSubmitted({
    required this.password,
    required this.token,
  });

  @override
  List<Object?> get props => [password, token];
}

class UpdateAthleteProfile extends AuthEvent {
  final Athlete athlete;

  const UpdateAthleteProfile(this.athlete);

  @override
  List<Object?> get props => [athlete];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
  
  @override
  List<Object?> get props => [];
}