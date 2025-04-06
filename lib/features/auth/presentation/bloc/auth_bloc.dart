import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:athlete_alumni/core/utils/web_storage.dart';
import 'package:athlete_alumni/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:athlete_alumni/core/models/athlete.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<LoadPersistedState>(_onLoadPersistedState);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignedOut>(_onAuthSignedOut);
    on<AuthSessionUpdated>(_onAuthSessionUpdated);
    on<AuthErrorOccurred>(_onAuthErrorOccurred);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<UpdateAthleteProfile>(_onUpdateAthleteProfile);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthNewPasswordSubmitted>(_onAuthNewPasswordSubmitted);

    // Initialize auth state listener
    _authSubscription = WebStorage.onAuthStateChange.listen((_) {
      add(const AuthCheckRequested());
    });

    // Load persisted state on initialization
    add(const LoadPersistedState());
  }

  Future<void> _onLoadPersistedState(
    LoadPersistedState event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint("AuthBloc: Loading persisted state");
      final isSignedIn = await _authRepository.isSignedIn();
      
      if (isSignedIn) {
        debugPrint("AuthBloc: User is signed in, getting athlete data");
        final athlete = await _authRepository.getCurrentAthlete();
        emit(AuthState(
          status: AuthStatus.authenticated,
          athlete: athlete,
        ));
        debugPrint("AuthBloc: Emitted authenticated state with athlete");
      } else {
        debugPrint("AuthBloc: User is not signed in");
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      debugPrint("AuthBloc: Error loading persisted state: $e");
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _persistState(AuthState state) async {
    print("AuthBloc: Persisting state: ${state.status}");
    try {
      final stateMap = {
        'status': state.status.toString(),
        'errorMessage': state.errorMessage,
      };
      print("AuthBloc: Saving auth state map: $stateMap");
      
      // Comment out WebStorage persistence to prevent freezing
      // await WebStorage.saveAuthState(json.encode(stateMap));

      if (state.athlete != null) {
        print("AuthBloc: Preparing to save athlete data: ${state.athlete}");
        try {
          final athleteJson = json.encode(state.athlete!.toJson());
          print("AuthBloc: Athlete JSON encoded: ${athleteJson.substring(0, math.min(100, athleteJson.length))}...");
          
          // Comment out WebStorage persistence to prevent freezing
          // await WebStorage.saveAthleteData(athleteJson);
          
          print("AuthBloc: Athlete data saved successfully");
        } catch (jsonError) {
          print("AuthBloc: Error encoding athlete to JSON: $jsonError");
          rethrow;
        }
      } else {
        print("AuthBloc: No athlete data to save");
      }
    } catch (e) {
      print("AuthBloc: Error in _persistState: $e");
      add(AuthErrorOccurred('Failed to persist state: ${e.toString()}'));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint("AuthBloc: Checking auth status");
      final isSignedIn = await _authRepository.isSignedIn();
      
      if (isSignedIn) {
        debugPrint("AuthBloc: User is signed in, getting athlete data");
        final athlete = await _authRepository.getCurrentAthlete();
        
        // Allow authentication even if athlete data is null
        emit(AuthState(
          status: AuthStatus.authenticated,
          athlete: athlete,
        ));
        
        if (athlete != null) {
          debugPrint("AuthBloc: Authenticated with athlete data, ID: ${athlete.id}");
        } else {
          debugPrint("AuthBloc: Authenticated but athlete data is null (this is ok for new users)");
        }
      } else {
        debugPrint("AuthBloc: User is not signed in");
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      debugPrint("AuthBloc: Error checking auth status: $e");
      add(AuthErrorOccurred(e.toString()));
    }
  }

  Future<void> _onAuthSignedOut(
    AuthSignedOut event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      await _authRepository.signOut();
      
      // Comment out WebStorage persistence to prevent freezing
      // await WebStorage.clearAuthData();
      
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      add(AuthErrorOccurred(e.toString()));
    }
  }

  void _onAuthSessionUpdated(
    AuthSessionUpdated event,
    Emitter<AuthState> emit,
  ) async {
    print("AuthBloc: Handling AuthSessionUpdated event");
    try {
      print("AuthBloc: Creating new state with athlete: ${event.athlete}");
      final newState = state.copyWith(
        status: AuthStatus.authenticated,
        athlete: event.athlete,
      );
      print("AuthBloc: Emitting new state with status: ${newState.status}");
      emit(newState);
      print("AuthBloc: New state emitted, about to persist state");
      await _persistState(newState);
      print("AuthBloc: State persisted successfully");
    } catch (e) {
      print("AuthBloc: Error in _onAuthSessionUpdated: $e");
      add(AuthErrorOccurred("Failed to update session: ${e.toString()}"));
    }
  }

  void _onAuthErrorOccurred(
    AuthErrorOccurred event,
    Emitter<AuthState> emit,
  ) async {
    final newState = state.copyWith(
      status: AuthStatus.error,
      errorMessage: event.message,
    );
    emit(newState);
    await _persistState(newState);
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('⭐ AuthBloc: Processing signup request for ${event.email}');
      emit(state.copyWith(status: AuthStatus.loading));
      
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        username: event.username,
        college: event.college,
        athleteStatus: event.athleteStatus,
      );
      
      debugPrint('⭐ AuthBloc: Sign up operation completed, checking for successful authentication');
      
      // Check if user is authenticated after signup (might be due to email verification requirement)
      final isAuthenticated = await _authRepository.isSignedIn();
      debugPrint('⭐ AuthBloc: Is user authenticated? $isAuthenticated');
      
      if (isAuthenticated) {
        debugPrint('⭐ AuthBloc: User is authenticated, fetching athlete data');
        // User is authenticated, get their data
        final athlete = await _authRepository.getCurrentAthlete();
        debugPrint('⭐ AuthBloc: Athlete data retrieved: ${athlete != null}');
        
        final authenticatedState = state.copyWith(
          status: AuthStatus.authenticated,
          athlete: athlete,
          errorMessage: null,
        );
        
        emit(authenticatedState);
        await _persistState(authenticatedState);
        debugPrint('⭐ AuthBloc: Authenticated state emitted');
      } else {
        debugPrint('⭐ AuthBloc: User not authenticated immediately, sending verification state');
        // After successful registration, emit email verification state
        final verificationState = state.copyWith(
          status: AuthStatus.emailVerificationSent,
          errorMessage: null,
        );
        
        emit(verificationState);
        await _persistState(verificationState);
        debugPrint('⭐ AuthBloc: Email verification state emitted');
      }
    } catch (e) {
      debugPrint('⭐ AuthBloc: Error during sign up: $e');
      add(AuthErrorOccurred(e.toString()));
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      // After successful login, check auth state to get the athlete data
      add(const AuthCheckRequested());
    } catch (e) {
      add(AuthErrorOccurred(e.toString()));
    }
  }

  Future<void> _onUpdateAthleteProfile(
    UpdateAthleteProfile event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('AuthBloc: Updating athlete profile in auth state: ${event.athlete.id}');
      
      // Emit new state with updated athlete
      final newState = state.copyWith(
        athlete: event.athlete,
      );
      
      emit(newState);
      await _persistState(newState);
      
      debugPrint('AuthBloc: Athlete profile updated in auth state');
    } catch (e) {
      debugPrint('AuthBloc: Error updating athlete profile: $e');
      add(AuthErrorOccurred('Failed to update athlete profile: ${e.toString()}'));
    }
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('🔑 AuthBloc: Processing password reset request for ${event.email}');
      emit(state.copyWith(status: AuthStatus.loading));
      
      await _authRepository.sendPasswordResetEmail(event.email);
      
      debugPrint('✅ AuthBloc: Password reset email sent to ${event.email}');
      
      emit(state.copyWith(
        status: AuthStatus.passwordResetEmailSent,
        errorMessage: null,
      ));
    } catch (e) {
      debugPrint('❌ AuthBloc: Error sending password reset email: $e');
      add(AuthErrorOccurred(e.toString()));
    }
  }

  Future<void> _onAuthNewPasswordSubmitted(
    AuthNewPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('🔑 AuthBloc: Processing new password submission');
      emit(state.copyWith(status: AuthStatus.loading));
      
      await _authRepository.resetPassword(event.password, event.token);
      
      debugPrint('✅ AuthBloc: Password reset successfully');
      
      emit(state.copyWith(
        status: AuthStatus.passwordResetSuccess,
        errorMessage: null,
      ));
      
      // After successfully resetting password, transition to unauthenticated
      // so user can login with new password
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      ));
    } catch (e) {
      debugPrint('❌ AuthBloc: Error resetting password: $e');
      add(AuthErrorOccurred(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    WebStorage.dispose(); // Clean up the stream controller
    return super.close();
  }
}
