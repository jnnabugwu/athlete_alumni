
import 'package:dartz/dartz.dart';
import '../../../../core/models/athlete.dart';
import '../../../../core/errors/failures.dart';
import '../../../../utils/data_service.dart';
import '../../domain/repositories/i_athlete_repository.dart';

/// Implementation of athlete repository that uses local storage
class LocalAthleteRepository implements IAthleteRepository {
  @override
  Future<Either<Failure, List<Athlete>>> getAllAthletes() async {
    try {
      final athletes = await AthleteDataService.getAllAthletes();
      return Right(athletes);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load athletes: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, List<Athlete>>> getAthletesByStatus(AthleteStatus status) async {
    try {
      final athletes = await AthleteDataService.getAthletesByStatus(status);
      return Right(athletes);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load athletes by status: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, List<Athlete>>> searchAthletes(String query) async {
    try {
      // Get all athletes first
      final allAthletes = await AthleteDataService.getAllAthletes();
      
      // If query is empty, return all athletes
      if (query.isEmpty) {
        return Right(allAthletes);
      }
      
      // Convert query to lowercase for case-insensitive search
      final lowerQuery = query.toLowerCase();
      
      // Filter athletes based on query
      final filteredAthletes = allAthletes.where((athlete) {
        return athlete.name.toLowerCase().contains(lowerQuery) ||
               (athlete.sport?.toLowerCase().contains(lowerQuery) ?? false) ||
               (athlete.university?.toLowerCase().contains(lowerQuery) ?? false) ||
               athlete.major.displayName.toLowerCase().contains(lowerQuery) ||
               athlete.career.displayName.toLowerCase().contains(lowerQuery);
      }).toList();
      
      return Right(filteredAthletes);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to search athletes: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, Athlete>> getAthleteById(String id) async {
    try {
      final athlete = await AthleteDataService.getAthleteById(id);
      
      if (athlete == null) {
        return Left(NotFoundFailure(message: 'Athlete with ID $id not found'));
      }
      
      return Right(athlete);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get athlete: ${e.toString()}'));
    }
  }
} 