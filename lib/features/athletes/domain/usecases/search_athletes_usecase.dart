import 'package:athlete_alumni/core/utils/typedef.dart';
import '../../../../core/models/athlete.dart';
import '../repositories/i_athlete_repository.dart';

/// Use case for searching athletes by query
class SearchAthletesUseCase {
  final IAthleteRepository repository;
  
  SearchAthletesUseCase(this.repository);
  
  /// Execute the use case
  /// [query] - The search query to filter athletes by
  ResultFuture<List<Athlete>> call(String query) async {
    return await repository.searchAthletes(query);
  }
} 