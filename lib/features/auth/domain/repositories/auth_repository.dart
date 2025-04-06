import 'package:athlete_alumni/core/models/athlete.dart';

abstract class AuthRepository {
  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    String? username,
    String? college,
    AthleteStatus? athleteStatus,
  });

  Future<void> signOut();
  
  Future<bool> isSignedIn();
  
  Future<Athlete?> getCurrentAthlete();
  
  Future<void> sendPasswordResetEmail(String email);
  
  Future<void> resetPassword(String password, String token);
}
