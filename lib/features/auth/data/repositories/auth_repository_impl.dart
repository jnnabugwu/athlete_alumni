import 'package:athlete_alumni/core/models/athlete.dart';
import 'package:athlete_alumni/features/auth/domain/repositories/auth_repository.dart';
import 'package:athlete_alumni/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(Object object, {required this.remoteDataSource});

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
    required String fullName,
    required String username,
    required String college,
    required AthleteStatus athleteStatus,
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
}
