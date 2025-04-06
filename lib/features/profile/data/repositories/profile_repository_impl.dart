import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
// import 'package:injectable/injectable.dart';  // Not needed
import '../../../../core/models/athlete.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../../../../core/errors/exceptions.dart';

// @Injectable(as: ProfileRepository)  // Removed since not using code generation
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  ResultFuture<Athlete> getProfile(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final athlete = await remoteDataSource.getProfile(id);
        return Right(athlete);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
  
  @override
  ResultFuture<Athlete> updateProfile(Athlete athlete) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedAthlete = await remoteDataSource.updateProfile(athlete);
        return Right(updatedAthlete);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
  
  @override
  ResultFuture<String> uploadProfileImage(
    String athleteId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final imageUrl = await remoteDataSource.uploadProfileImage(
          athleteId,
          imageBytes,
          fileName,
        );
        return Right(imageUrl);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
