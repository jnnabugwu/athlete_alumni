import 'package:athlete_alumni/core/models/athlete.dart';

abstract class AuthRepository {
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
