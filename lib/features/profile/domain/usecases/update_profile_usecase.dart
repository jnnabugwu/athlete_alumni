import '../../../../core/models/athlete.dart';
import '../../../../core/utils/typedef.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  
  UpdateProfileUseCase(this.repository);
  
  ResultFuture<Athlete> call(Athlete athlete) {
    return repository.updateProfile(athlete);
  }
} 