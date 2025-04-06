import 'package:athlete_alumni/core/models/athlete.dart';
import 'package:athlete_alumni/features/auth/domain/repositories/auth_repository.dart';
import 'package:athlete_alumni/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await remoteDataSource.signIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    String? username,
    String? college,
    AthleteStatus? athleteStatus,
  }) async {
    await remoteDataSource.signUp(
      email: email,
      password: password,
      fullName: fullName,
      username: username,
      college: college,
      athleteStatus: athleteStatus,
    );
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<bool> isSignedIn() async {
    return await remoteDataSource.isSignedIn();
  }

  @override
  Future<Athlete?> getCurrentAthlete() async {
    return await remoteDataSource.getCurrentAthlete();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> resetPassword(String password, String token) async {
    await remoteDataSource.resetPassword(password, token);
  }
}
