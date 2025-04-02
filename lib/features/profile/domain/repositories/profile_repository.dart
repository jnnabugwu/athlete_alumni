import 'dart:typed_data';

import 'package:athlete_alumni/core/errors/failures.dart';
import 'package:athlete_alumni/core/models/athlete.dart';
import 'package:dartz/dartz.dart';

/// Repository interface for profile-related operations
abstract class ProfileRepository {
  /// Gets the profile of an athlete
  /// 
  /// Returns either a [Failure] if something went wrong or an [Athlete] if successful
  Future<Either<Failure, Athlete>> getProfile(String id);

  /// Updates the profile of an athlete
  /// 
  /// Returns either a [Failure] if something went wrong or the updated [Athlete] if successful
  Future<Either<Failure, Athlete>> updateProfile(Athlete athlete);

  /// Uploads a profile image for an athlete
  /// 
  /// Returns either a [Failure] if something went wrong or the URL of the uploaded image as [String] if successful
  Future<Either<Failure, String>> uploadProfileImage(
    String athleteId,
    Uint8List imageBytes,
    String fileName,
  );
}
