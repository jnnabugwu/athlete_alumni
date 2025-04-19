import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  
  // Pick image from gallery
  Future<ImageResult?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile == null) return null;
      
      return _processPickedImage(pickedFile);
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }
  
  // Take image from camera
  Future<ImageResult?> takeImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile == null) return null;
      
      return _processPickedImage(pickedFile);
    } catch (e) {
      debugPrint('Error taking image with camera: $e');
      return null;
    }
  }
  
  // Process the picked image into a format we can use
  Future<ImageResult> _processPickedImage(XFile pickedFile) async {
    // Get the file name
    final String fileName = pickedFile.name.isNotEmpty 
        ? pickedFile.name 
        : 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    Uint8List imageBytes;
    // For web, we already have bytes from XFile
    if (kIsWeb) {
      imageBytes = await pickedFile.readAsBytes();
    } else {
      // For mobile, read the file
      final File imageFile = File(pickedFile.path);
      imageBytes = await imageFile.readAsBytes();
    }
    
    return ImageResult(
      fileName: fileName,
      imageBytes: imageBytes,
      filePath: pickedFile.path,
    );
  }
  
  // Show a dialog to choose between gallery and camera
  Future<ImageResult?> showImageSourceDialog(BuildContext context) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
    
    if (source == null) return null;
    
    return source == ImageSource.gallery
        ? await pickImageFromGallery()
        : await takeImageFromCamera();
  }
}

// Class to hold the result of image picking
class ImageResult {
  final String fileName;
  final Uint8List imageBytes;
  final String filePath;
  
  ImageResult({
    required this.fileName,
    required this.imageBytes,
    required this.filePath,
  });
} 