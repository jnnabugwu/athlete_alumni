import 'dart:io';
import 'dart:typed_data';
import '../../../../core/utils/typedef.dart';
import '../repositories/profile_repository.dart';

class UploadProfileImageUseCase {
  final ProfileRepository repository;
  
  UploadProfileImageUseCase(this.repository);
  
  ResultFuture<String> call(UploadImageParams params) {
    return repository.uploadProfileImage(
      params.athleteId,
      params.imageBytes,
      params.fileName,
    );
  }
}

class UploadImageParams {
  final String athleteId;
  final Uint8List imageBytes;
  final String fileName;
  
  UploadImageParams({
    required this.athleteId,
    required this.imageBytes,
    required this.fileName,
  });
} 