import 'package:athlete_alumni/core/utils/typedef.dart';
import '../../../../core/models/athlete.dart';
import '../repositories/i_athlete_repository.dart';

/// Use case for retrieving all athletes
class GetAllAthletesUseCase {
  final IAthleteRepository repository;
  
  GetAllAthletesUseCase(this.repository);
  
  /// Execute the use case
  ResultFuture<List<Athlete>> call() async {
    return await repository.getAllAthletes();
  }
} 