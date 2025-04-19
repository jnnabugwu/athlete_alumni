part of 'upload_image_bloc.dart';

abstract class UploadImageEvent extends Equatable {
  const UploadImageEvent();

  @override
  List<Object> get props => [];
}

class UploadProfileImageEvent extends UploadImageEvent {
  final String athleteId;
  final Uint8List imageBytes;
  final String fileName;
  
  const UploadProfileImageEvent({
    required this.athleteId,
    required this.imageBytes,
    required this.fileName,
  });
  
  @override
  List<Object> get props => [athleteId, imageBytes, fileName];
}

class ResetUploadStateEvent extends UploadImageEvent {} 