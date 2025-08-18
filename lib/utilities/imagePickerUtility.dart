import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ImagePickerUtility {
  static final ImagePicker _picker = ImagePicker();

  /// Shows a beautiful modal bottom sheet for image source selection
  static Future<XFile?> showImageSourceModal(BuildContext context, {String title = "Select Image Source"}) async {
    final Completer<XFile?> completer = Completer<XFile?>();
    
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              const Divider(height: 1),
              
              // Camera option
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF96222).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFFF96222),
                    size: 24,
                  ),
                ),
                title: const Text(
                  "Camera",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  "Take a new photo",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 100, // We'll compress manually
                  );
                  if (image != null) {
                    // Compress camera image to 70%
                    final compressedImage = await compressImage(image, quality: 70);
                    completer.complete(compressedImage);
                  } else {
                    completer.complete(null);
                  }
                },
              ),
              
              // Gallery option
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF96222).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Color(0xFFF96222),
                    size: 24,
                  ),
                ),
                title: const Text(
                  "Gallery",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  "Choose from gallery",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 100, // No compression for gallery images
                  );
                  completer.complete(image);
                },
              ),
              
              // Cancel button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      completer.complete(null);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Bottom safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
    
    return await completer.future;
  }

  /// Compresses an image to the specified quality
  static Future<XFile?> compressImage(XFile image, {int quality = 70}) async {
    try {
      // Read the image bytes
      final Uint8List bytes = await image.readAsBytes();
      
      // Decode the image
      final img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) return image;
      
      // Calculate new dimensions (maintain aspect ratio)
      int newWidth = originalImage.width;
      int newHeight = originalImage.height;
      
      // If image is too large, resize it
      const int maxDimension = 1024;
      if (originalImage.width > maxDimension || originalImage.height > maxDimension) {
        if (originalImage.width > originalImage.height) {
          newWidth = maxDimension;
          newHeight = (originalImage.height * maxDimension / originalImage.width).round();
        } else {
          newHeight = maxDimension;
          newWidth = (originalImage.width * maxDimension / originalImage.height).round();
        }
      }
      
      // Resize the image
      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
      );
      
      // Encode with compression
      final List<int> compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      
      // Create a temporary file with compressed image
      final String tempPath = '${image.path}_compressed.jpg';
      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(compressedBytes);
      
      return XFile(tempPath);
    } catch (e) {
      print('Error compressing image: $e');
      return image; // Return original if compression fails
    }
  }
}
