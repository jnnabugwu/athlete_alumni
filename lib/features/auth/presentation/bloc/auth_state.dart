part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
  emailVerificationSent,
  passwordResetEmailSent,
  passwordResetSuccess,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final Athlete? athlete;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.athlete,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Athlete? athlete,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      athlete: athlete ?? this.athlete,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, athlete, errorMessage];
}