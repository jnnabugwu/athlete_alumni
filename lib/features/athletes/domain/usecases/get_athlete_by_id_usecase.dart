import 'package:athlete_alumni/core/utils/typedef.dart';
import '../../../../core/models/athlete.dart';
import '../repositories/i_athlete_repository.dart';

/// Use case for retrieving a specific athlete by ID
class GetAthleteByIdUseCase {
  final IAthleteRepository repository;
  
  GetAthleteByIdUseCase(this.repository);
  
  /// Execute the use case
  /// [id] - The ID of the athlete to retrieve
  ResultFuture<Athlete> call(String id) async {
    return await repository.getAthleteById(id);
  }
} 