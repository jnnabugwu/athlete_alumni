import '../../../../core/models/athlete.dart';
import '../../../../core/utils/typedef.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  
  GetProfileUseCase(this.repository);
  
  ResultFuture<Athlete> call(String userId) {
    return repository.getProfile(userId);
  }
} 