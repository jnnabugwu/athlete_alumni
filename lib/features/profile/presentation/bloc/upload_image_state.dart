part of 'upload_image_bloc.dart';

abstract class UploadImageState extends Equatable {
  const UploadImageState();
  
  @override
  List<Object?> get props => [];
}

class UploadImageInitial extends UploadImageState {}

class UploadImageLoading extends UploadImageState {}

class UploadImageSuccess extends UploadImageState {
  final String imageUrl;
  
  const UploadImageSuccess({required this.imageUrl});
  
  @override
  List<Object?> get props => [imageUrl];
}

class UploadImageFailure extends UploadImageState {
  final String message;
  
  const UploadImageFailure({required this.message});
  
  @override
  List<Object?> get props => [message];
} 