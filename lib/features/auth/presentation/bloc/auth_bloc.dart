import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:athlete_alumni/core/utils/web_storage.dart';
import 'package:athlete_alumni/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:athlete_alumni/core/models/athlete.dart';
import 'dart:math' as math;
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
      final savedState = await WebStorage.getAuthState();
      final savedAthlete = await WebStorage.getAthleteData();

      if (savedState != null) {
        final stateMap = json.decode(savedState) as Map<String, dynamic>;
        final status = AuthStatus.values.firstWhere(
          (e) => e.toString() == stateMap['status'],
        );

        Athlete? athlete;
        if (savedAthlete != null) {
          athlete = Athlete.fromJson(json.decode(savedAthlete));
        }

        emit(AuthState(
          status: status,
          athlete: athlete,
          errorMessage: stateMap['errorMessage'],
        ));
      }
    } catch (e) {
      add(AuthErrorOccurred('Failed to load persisted state: ${e.toString()}'));
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
      await WebStorage.saveAuthState(json.encode(stateMap));

      if (state.athlete != null) {
        print("AuthBloc: Preparing to save athlete data: ${state.athlete}");
        try {
          final athleteJson = json.encode(state.athlete!.toJson());
          print("AuthBloc: Athlete JSON encoded: ${athleteJson.substring(0, math.min(100, athleteJson.length))}...");
          await WebStorage.saveAthleteData(athleteJson);
          print("AuthBloc: Athlete data saved successfully");
        } catch (jsonError) {
          print("AuthBloc: Error encoding athlete to JSON: $jsonError");
          throw jsonError;
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
      final isSignedIn = await _authRepository.isSignedIn();
      
      if (isSignedIn) {
        final athlete = await _authRepository.getCurrentAthlete();
        final newState = state.copyWith(
          status: AuthStatus.authenticated,
          athlete: athlete,
        );
        emit(newState);
        await _persistState(newState);
      } else {
        final newState = state.copyWith(status: AuthStatus.unauthenticated);
        emit(newState);
        await _persistState(newState);
      }
    } catch (e) {
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
      await WebStorage.clearAuthData();
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
      emit(state.copyWith(status: AuthStatus.loading));
      
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        username: event.username,
        college: event.college,
        athleteStatus: event.athleteStatus,
      );

      // After successful registration, emit email verification state
      emit(state.copyWith(
        status: AuthStatus.emailVerificationSent,
        errorMessage: null,
      ));

      // After a delay, set state to unauthenticated for login
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      ));
    } catch (e) {
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

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    WebStorage.dispose(); // Clean up the stream controller
    return super.close();
  }
}
