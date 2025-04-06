import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/athlete.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/i_athlete_repository.dart';

/// Implementation of athlete repository that uses Supabase
class SupabaseAthleteRepository implements IAthleteRepository {
  final SupabaseClient supabaseClient;
  
  SupabaseAthleteRepository({required this.supabaseClient});
  
  @override
  Future<Either<Failure, List<Athlete>>> getAllAthletes() async {
    try {
      debugPrint('SupabaseAthleteRepository: Getting all athletes');
      
      final response = await supabaseClient
          .from('athletes')
          .select()
          .order('full_name');
      
      debugPrint('SupabaseAthleteRepository: Received ${response.length} athletes');
      
      final athletes = response.map<Athlete>((json) => _mapJsonToAthlete(json)).toList();
      return Right(athletes);
    } catch (e) {
      debugPrint('SupabaseAthleteRepository: Error getting all athletes: $e');
      return Left(ServerFailure(message: 'Failed to load athletes: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, List<Athlete>>> getAthletesByStatus(AthleteStatus status) async {
    try {
      debugPrint('SupabaseAthleteRepository: Getting athletes by status: ${status.name}');
      
      final response = await supabaseClient
          .from('athletes')
          .select()
          .eq('athlete_status', status.name)
          .order('full_name');
      
      debugPrint('SupabaseAthleteRepository: Received ${response.length} athletes with status ${status.name}');
      
      final athletes = response.map<Athlete>((json) => _mapJsonToAthlete(json)).toList();
      return Right(athletes);
    } catch (e) {
      debugPrint('SupabaseAthleteRepository: Error getting athletes by status: $e');
      return Left(ServerFailure(message: 'Failed to load athletes by status: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, List<Athlete>>> searchAthletes(String query) async {
    try {
      if (query.isEmpty) {
        return getAllAthletes();
      }
      
      debugPrint('SupabaseAthleteRepository: Searching athletes with query: $query');
      
      // Convert query to lowercase for case-insensitive search
      final lowerQuery = query.toLowerCase();
      
      // Use Supabase text search or ilike for simpler queries
      final response = await supabaseClient
          .from('athletes')
          .select()
          .or('full_name.ilike.%$lowerQuery%,college.ilike.%$lowerQuery%,sport.ilike.%$lowerQuery%')
          .order('full_name');
      
      debugPrint('SupabaseAthleteRepository: Search found ${response.length} athletes');
      
      final athletes = response.map<Athlete>((json) => _mapJsonToAthlete(json)).toList();
      return Right(athletes);
    } catch (e) {
      debugPrint('SupabaseAthleteRepository: Error searching athletes: $e');
      return Left(ServerFailure(message: 'Failed to search athletes: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, Athlete>> getAthleteById(String id) async {
    try {
      debugPrint('SupabaseAthleteRepository: Getting athlete by ID: $id');
      
      final response = await supabaseClient
          .from('athletes')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) {
        debugPrint('SupabaseAthleteRepository: Athlete not found with ID: $id');
        return Left(NotFoundFailure(message: 'Athlete with ID $id not found'));
      }
      
      debugPrint('SupabaseAthleteRepository: Found athlete with ID: $id');
      
      final athlete = _mapJsonToAthlete(response);
      return Right(athlete);
    } catch (e) {
      debugPrint('SupabaseAthleteRepository: Error getting athlete by ID: $e');
      return Left(ServerFailure(message: 'Failed to get athlete: ${e.toString()}'));
    }
  }
  
  /// Maps the JSON response from Supabase to an Athlete object
  Athlete _mapJsonToAthlete(Map<String, dynamic> json) {
    // Convert from Supabase snake_case to our model's camelCase
    return Athlete(
      id: json['id'] ?? '',
      name: json['full_name'] ?? '',
      email: json['email'] ?? '',
      status: _parseAthleteStatus(json['athlete_status']),
      major: _parseAthleteMajor(json['major']),
      career: _parseAthleteCareer(json['career']),
      university: json['college'],
      sport: json['sport'],
      profileImageUrl: json['profile_image_url'],
      graduationYear: json['graduation_year'] != null 
          ? _parseGraduationYear(json['graduation_year'])
          : null,
      achievements: json['achievements'] != null 
          ? List<String>.from(json['achievements'])
          : null,
    );
  }
  
  /// Parse athlete status from string
  AthleteStatus _parseAthleteStatus(String? statusStr) {
    if (statusStr == null) return AthleteStatus.current;
    
    try {
      return AthleteStatus.values.firstWhere(
        (status) => status.name == statusStr,
        orElse: () => AthleteStatus.current,
      );
    } catch (_) {
      return AthleteStatus.current;
    }
  }
  
  /// Parse athlete major from string
  AthleteMajor _parseAthleteMajor(String? majorStr) {
    if (majorStr == null) return AthleteMajor.other;
    
    try {
      return AthleteMajor.values.firstWhere(
        (major) => major.name == majorStr,
        orElse: () => AthleteMajor.other,
      );
    } catch (_) {
      return AthleteMajor.other;
    }
  }
  
  /// Parse athlete career from string
  AthleteCareer _parseAthleteCareer(String? careerStr) {
    if (careerStr == null) return AthleteCareer.other;
    
    try {
      return AthleteCareer.values.firstWhere(
        (career) => career.name == careerStr,
        orElse: () => AthleteCareer.other,
      );
    } catch (_) {
      return AthleteCareer.other;
    }
  }
  
  /// Parse graduation year from various formats
  DateTime? _parseGraduationYear(dynamic gradYear) {
    if (gradYear == null) return null;
    
    // Handle ISO8601 string format
    if (gradYear is String) {
      try {
        return DateTime.parse(gradYear);
      } catch (_) {
        // If parsing fails, try to extract year from string
        final match = RegExp(r'(\d{4})').firstMatch(gradYear);
        if (match != null) {
          final year = int.tryParse(match.group(1)!);
          if (year != null) {
            return DateTime(year);
          }
        }
        return null;
      }
    } 
    // Handle integer year
    else if (gradYear is int) {
      return DateTime(gradYear);
    }
    
    return null;
  }
} 