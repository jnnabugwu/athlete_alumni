import 'package:athlete_alumni/core/utils/typedef.dart';
import '../../../../core/models/athlete.dart';

/// Interface defining methods to access athlete data
abstract class IAthleteRepository {
  /// Get all athletes
  ResultFuture<List<Athlete>> getAllAthletes();
  
  /// Get athletes filtered by status (former or current)
  ResultFuture<List<Athlete>> getAthletesByStatus(AthleteStatus status);
  
  /// Search athletes by query string (matches against name, sport, university, etc.)
  ResultFuture<List<Athlete>> searchAthletes(String query);
  
  /// Get a specific athlete by ID
  ResultFuture<Athlete> getAthleteById(String id);
} 