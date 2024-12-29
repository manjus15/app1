// lib/services/image_picker_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../core/utils/logger.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  // Select image from gallery with size validation
  static Future<File?> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        // Check file size (max 5MB)
        final fileSize = await imageFile.length();
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Image size should be less than 5MB');
        }
        return imageFile;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error picking image: $e');
      rethrow;
    }
  }
}