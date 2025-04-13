import '../../../../core/models/athlete.dart';
import '../../../../core/utils/typedef.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  
  UpdateProfileUseCase(this.repository);
  
  ResultFuture<Athlete> call(Athlete athlete) {
    // Convert the athlete to JSON for Supabase
    final Map<String, dynamic> athleteJson = athlete.toJson();
    print('🔍🔍🔍 ATHLETE TO JSON: $athleteJson 🔍🔍🔍');
    // Let the data sources handle the conversion consistently
    
    // Then update the database with the athleteJson
    return repository.updateProfile(athlete);
  }
} 