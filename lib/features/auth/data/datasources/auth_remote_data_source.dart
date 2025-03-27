import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:athlete_alumni/core/models/athlete.dart';
import 'package:athlete_alumni/core/errors/exceptions.dart';


abstract class AuthRemoteDataSource {
  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String college,
    required AthleteStatus athleteStatus,
  });

  Future<void> signOut();
  
  Future<bool> isSignedIn();
  
  Future<Athlete?> getCurrentAthlete();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Failed to sign in');
      }
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw const AuthException('An unexpected error occurred');
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String college,
    required AthleteStatus athleteStatus,
  }) async {
    try {
      // First, create the auth user
      final authResponse = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw const AuthException('Failed to create account');
      }

      // Then, create the athlete profile in the athletes table
      await supabaseClient.from('athletes').insert({
        'id': authResponse.user!.id,
        'email': email,
        'full_name': fullName,
        'username': username,
        'college': college,
        'athlete_status': athleteStatus.name,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw const AuthException('An unexpected error occurred');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw const AuthException('Failed to sign out');
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return supabaseClient.auth.currentUser != null;
  }

  @override
  Future<Athlete?> getCurrentAthlete() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      final response = await supabaseClient
          .from('athletes')
          .select()
          .eq('id', user.id)
          .single();

      return Athlete.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
