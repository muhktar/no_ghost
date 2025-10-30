import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Test Firebase Storage connectivity
  Future<bool> testStorageConnection() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      
      // Try to list files in the user's directory (this will work even if empty)
      final ref = _storage.ref().child('users/${user.uid}/');
      await ref.listAll();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Upload a single photo and return the download URL
  Future<String?> uploadPhoto(XFile photo, {String? customFileName}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }


      // Create a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = customFileName ?? 'profile_photo_$timestamp.jpg';
      final filePath = 'users/${user.uid}/photos/$fileName';


      // Create reference to Firebase Storage
      final ref = _storage.ref().child(filePath);

      // Upload the file
      final file = File(photo.path);
      
      // Check if file exists
      if (!await file.exists()) {
        return null;
      }

      final uploadTask = ref.putFile(file);

      // Wait for upload to complete and get download URL
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // Upload multiple photos and return list of URLs
  Future<List<String>> uploadPhotos(List<XFile> photos) async {
    final urls = <String>[];

    for (int i = 0; i < photos.length; i++) {
      final photo = photos[i];
      final customFileName = 'profile_photo_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await uploadPhoto(photo, customFileName: customFileName);
      
      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }

  // Delete a photo from Firebase Storage
  Future<bool> deletePhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete multiple photos
  Future<void> deletePhotos(List<String> photoUrls) async {
    for (final url in photoUrls) {
      await deletePhoto(url);
    }
  }

  // Update profile photos: upload new ones and delete removed ones
  Future<List<String>> updateProfilePhotos({
    required List<dynamic> currentPhotos, // Mix of URLs (String) and new photos (XFile)
    required List<String> existingUrls,
  }) async {
    final finalUrls = <String>[];
    final photosToDelete = <String>[];
    final newPhotosToUpload = <XFile>[];

    // Process current photos to separate existing URLs from new XFiles
    for (final photo in currentPhotos) {
      if (photo is String) {
        // Existing URL - keep it
        finalUrls.add(photo);
      } else if (photo is XFile) {
        // New photo - queue for upload
        newPhotosToUpload.add(photo);
      }
    }

    // Find photos to delete (existing URLs not in final list)
    for (final existingUrl in existingUrls) {
      if (!finalUrls.contains(existingUrl)) {
        photosToDelete.add(existingUrl);
      }
    }

    // Delete removed photos
    if (photosToDelete.isNotEmpty) {
      await deletePhotos(photosToDelete);
    }

    // Upload new photos
    if (newPhotosToUpload.isNotEmpty) {
      final newUrls = await uploadPhotos(newPhotosToUpload);
      finalUrls.addAll(newUrls);
    }

    return finalUrls;
  }
}

// Provider for PhotoUploadService
final photoUploadServiceProvider = Provider<PhotoUploadService>((ref) {
  return PhotoUploadService();
});