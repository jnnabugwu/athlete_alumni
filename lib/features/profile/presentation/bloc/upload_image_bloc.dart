import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../domain/usecases/upload_profile_image_usecase.dart';

part 'upload_image_event.dart';
part 'upload_image_state.dart';

class UploadImageBloc extends Bloc<UploadImageEvent, UploadImageState> {
  final UploadProfileImageUseCase uploadProfileImageUseCase;
  
  UploadImageBloc({
    required this.uploadProfileImageUseCase,
  }) : super(UploadImageInitial()) {
    on<UploadProfileImageEvent>(_onUploadProfileImage);
    on<ResetUploadStateEvent>(_onResetUploadState);
  }
  
  Future<void> _onUploadProfileImage(
    UploadProfileImageEvent event,
    Emitter<UploadImageState> emit,
  ) async {
    emit(UploadImageLoading());
    
    try {
      final params = UploadImageParams(
        athleteId: event.athleteId,
        imageBytes: event.imageBytes,
        fileName: event.fileName,
      );
      
      final result = await uploadProfileImageUseCase(params);
      
      result.fold(
        (failure) => emit(UploadImageFailure(message: failure.message)),
        (imageUrl) => emit(UploadImageSuccess(imageUrl: imageUrl)),
      );
    } catch (e) {
      emit(UploadImageFailure(message: e.toString()));
    }
  }
  
  void _onResetUploadState(
    ResetUploadStateEvent event,
    Emitter<UploadImageState> emit,
  ) {
    emit(UploadImageInitial());
  }
} 