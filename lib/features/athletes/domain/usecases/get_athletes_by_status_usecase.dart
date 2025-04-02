import 'package:athlete_alumni/core/utils/typedef.dart';
import '../../../../core/models/athlete.dart';
import '../repositories/i_athlete_repository.dart';

/// Use case for retrieving athletes filtered by status
class GetAthletesByStatusUseCase {
  final IAthleteRepository repository;
  
  GetAthletesByStatusUseCase(this.repository);
  
  /// Execute the use case
  /// [status] - The status to filter athletes by (former or current)
  ResultFuture<List<Athlete>> call(AthleteStatus status) async {
    return await repository.getAthletesByStatus(status);
  }
} 