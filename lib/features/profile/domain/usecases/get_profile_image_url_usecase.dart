import '../../../../core/utils/typedef.dart';
import '../repositories/profile_repository.dart';

class GetProfileImageUrlUseCase {
  final ProfileRepository repository;
  
  GetProfileImageUrlUseCase(this.repository);
  
  ResultFuture<String?> call(String athleteId) {
    return repository.getProfileImageUrl(athleteId);
  }
} 