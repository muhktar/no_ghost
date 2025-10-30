import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/models/user_profile.dart';
import '../data/user_profile_service.dart';
import '../data/photo_upload_service.dart';

// Service provider
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

// Current user profile provider (stream-based for real-time updates)
final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final service = ref.watch(userProfileServiceProvider);
  return service.watchCurrentUserProfile();
});

// Profile completion status provider
final profileCompletionStatusProvider = Provider<ProfileCompletionStatus>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  
  return profileAsync.when(
    data: (profile) => profile?.completionStatus ?? ProfileCompletionStatus.notStarted,
    loading: () => ProfileCompletionStatus.notStarted,
    error: (_, __) => ProfileCompletionStatus.notStarted,
  );
});

// Profile completion state notifier for managing profile updates
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final UserProfileService _service;
  final Ref _ref;

  UserProfileNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    try {
      state = const AsyncValue.loading();
      final profile = await _service.getCurrentUserProfile();
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Create profile for new user
  Future<bool> createProfile(User user) async {
    try {
      final success = await _service.createUserProfile(user);
      if (success) {
        await _loadCurrentProfile();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Update photos
  Future<bool> updatePhotos(List<String> photoUrls) async {
    final currentProfile = state.value;
    if (currentProfile == null) return false;

    try {
      final success = await _service.updateUserPhotos(currentProfile.userId, photoUrls);
      if (success) {
        await _loadCurrentProfile();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Update photos with Firebase Storage upload (for mixed XFiles and URLs)
  Future<bool> updatePhotosWithUpload(List<dynamic> photos) async {
    final currentProfile = state.value;
    if (currentProfile == null) {
      return false;
    }

    try {
      for (int i = 0; i < photos.length; i++) {
        final photo = photos[i];
        if (photo is String) {
        } else if (photo != null) {
        } else {
        }
      }
      
      final photoUploadService = PhotoUploadService();
      
      // Test storage connection first
      final storageConnected = await photoUploadService.testStorageConnection();
      if (!storageConnected) {
        return false;
      }
      
      // Get existing photo URLs for comparison
      final existingUrls = currentProfile.photoUrls;
      
      // Use the PhotoUploadService to handle uploads and deletions
      final finalUrls = await photoUploadService.updateProfilePhotos(
        currentPhotos: photos,
        existingUrls: existingUrls,
      );


      // Update profile with final URLs
      final success = await _service.updateUserPhotos(currentProfile.userId, finalUrls);
      if (success) {
        await _loadCurrentProfile();
        
        // Force refresh all providers that depend on profile data
        _ref.invalidate(currentUserProfileProvider);
        _ref.invalidate(userPhotoUrlsProvider);
        _ref.invalidate(userPromptsProvider);
        _ref.invalidate(profileCompletionStatusProvider);
        
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Update prompts
  Future<bool> updatePrompts(List<ProfilePrompt> prompts) async {
    final currentProfile = state.value;
    if (currentProfile == null) return false;

    try {
      final success = await _service.updateUserPrompts(currentProfile.userId, prompts);
      if (success) {
        await _loadCurrentProfile();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Update basic info
  Future<bool> updateBasicInfo({
    String? name,
    int? age,
    String? bio,
    String? occupation,
    String? location,
  }) async {
    final currentProfile = state.value;
    if (currentProfile == null) return false;

    try {
      final success = await _service.updateBasicInfo(
        userId: currentProfile.userId,
        name: name,
        age: age,
        bio: bio,
        occupation: occupation,
        location: location,
      );
      if (success) {
        await _loadCurrentProfile();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Update preferences
  Future<bool> updatePreferences(UserPreferences preferences) async {
    final currentProfile = state.value;
    if (currentProfile == null) return false;

    try {
      final success = await _service.updateUserPreferences(currentProfile.userId, preferences);
      if (success) {
        await _loadCurrentProfile();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Refresh profile data
  Future<void> refresh() async {
    await _loadCurrentProfile();
  }
}

// Profile notifier provider
final userProfileNotifierProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final service = ref.watch(userProfileServiceProvider);
  return UserProfileNotifier(service, ref);
});

// Potential matches provider
final potentialMatchesProvider = FutureProvider<List<UserProfile>>((ref) async {
  final service = ref.watch(userProfileServiceProvider);
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) return [];
  
  return await service.getPotentialMatches(user.uid);
});

// Helper providers for quick access to profile data
final userPhotoUrlsProvider = Provider<List<String>>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.photoUrls ?? [],
    loading: () => [],
    error: (_, __) => [],
  );
});

final userPromptsProvider = Provider<List<ProfilePrompt>>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.prompts ?? [],
    loading: () => [],
    error: (_, __) => [],
  );
});

final isProfileCompleteProvider = Provider<bool>((ref) {
  final status = ref.watch(profileCompletionStatusProvider);
  return status == ProfileCompletionStatus.complete;
});