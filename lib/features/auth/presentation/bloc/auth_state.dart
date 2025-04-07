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
  final bool isNewUser;

  const AuthState({
    this.status = AuthStatus.initial,
    this.athlete,
    this.errorMessage,
    this.isNewUser = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    Athlete? athlete,
    String? errorMessage,
    bool? isNewUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      athlete: athlete ?? this.athlete,
      errorMessage: errorMessage ?? this.errorMessage,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  @override
  List<Object?> get props => [status, athlete, errorMessage, isNewUser];
}