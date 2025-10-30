import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/models/user_profile.dart';

class UserProfileService {
  static const String _collection = 'users';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    try {
      final doc = await _firestore.collection(_collection).doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create new user profile (called after first authentication)
  Future<bool> createUserProfile(User user) async {
    try {
      final profile = UserProfile(
        userId: user.uid,
        email: user.email ?? '',
        name: user.displayName,
        isProfileComplete: false,
      );

      await _firestore.collection(_collection).doc(user.uid).set(profile.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      // Update the isProfileComplete flag based on completion status
      final updatedProfile = profile.copyWith(
        isProfileComplete: profile.completionStatus == ProfileCompletionStatus.complete,
        lastActive: DateTime.now(),
      );

      await _firestore.collection(_collection).doc(profile.userId).update(updatedProfile.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update just the photos
  Future<bool> updateUserPhotos(String userId, List<String> photoUrls) async {
    try {
      for (int i = 0; i < photoUrls.length; i++) {
      }

      // Get current profile to check completion status
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile == null) {
        return false;
      }

      // Create updated profile with new photos
      final updatedProfile = currentProfile.copyWith(
        photoUrls: photoUrls,
        lastActive: DateTime.now(),
      );

      // Check if profile is now complete and update accordingly
      final isComplete = updatedProfile.completionStatus == ProfileCompletionStatus.complete;

      await _firestore.collection(_collection).doc(userId).update({
        'photoUrls': photoUrls,
        'lastActive': Timestamp.fromDate(DateTime.now()),
        'isProfileComplete': isComplete,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update just the prompts
  Future<bool> updateUserPrompts(String userId, List<ProfilePrompt> prompts) async {
    try {
      // Get current profile to check completion status
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile == null) {
        return false;
      }

      // Create updated profile with new prompts
      final updatedProfile = currentProfile.copyWith(
        prompts: prompts,
        lastActive: DateTime.now(),
      );

      // Check if profile is now complete and update accordingly
      final isComplete = updatedProfile.completionStatus == ProfileCompletionStatus.complete;

      await _firestore.collection(_collection).doc(userId).update({
        'prompts': prompts.map((prompt) => prompt.toJson()).toList(),
        'lastActive': Timestamp.fromDate(DateTime.now()),
        'isProfileComplete': isComplete,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update basic profile info (name, age, bio, etc.)
  Future<bool> updateBasicInfo({
    required String userId,
    String? name,
    int? age,
    String? gender,
    String? bio,
    String? occupation,
    String? location,
  }) async {
    try {
      // Get current profile to check completion status
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile == null) {
        return false;
      }

      // Create updated profile with new basic info
      final updatedProfile = currentProfile.copyWith(
        name: name ?? currentProfile.name,
        age: age ?? currentProfile.age,
        gender: gender ?? currentProfile.gender,
        bio: bio ?? currentProfile.bio,
        occupation: occupation ?? currentProfile.occupation,
        location: location ?? currentProfile.location,
        lastActive: DateTime.now(),
      );

      // Check if profile is now complete and update accordingly
      final isComplete = updatedProfile.completionStatus == ProfileCompletionStatus.complete;

      final updateData = <String, dynamic>{
        'lastActive': Timestamp.fromDate(DateTime.now()),
        'isProfileComplete': isComplete,
      };

      if (name != null) updateData['name'] = name;
      if (age != null) updateData['age'] = age;
      if (gender != null) updateData['gender'] = gender;
      if (bio != null) updateData['bio'] = bio;
      if (occupation != null) updateData['occupation'] = occupation;
      if (location != null) updateData['location'] = location;

      await _firestore.collection(_collection).doc(userId).update(updateData);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update user preferences
  Future<bool> updateUserPreferences(String userId, UserPreferences preferences) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'preferences': preferences.toJson(),
        'lastActive': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get potential matches (basic algorithm)
  Future<List<UserProfile>> getPotentialMatches(String userId, {int limit = 10}) async {
    try {
      // Get current user's preferences and profile
      final currentUser = await getCurrentUserProfile();
      if (currentUser == null || currentUser.gender == null) return [];

      final preferences = currentUser.preferences;
      final currentUserGender = currentUser.gender!;
      final targetGender = _getOppositeGender(currentUserGender);

      // Basic query: exclude self, only complete profiles, age range
      Query query = _firestore.collection(_collection)
          .where('isProfileComplete', isEqualTo: true)
          .where('age', isGreaterThanOrEqualTo: preferences.minAge)
          .where('age', isLessThanOrEqualTo: preferences.maxAge)
          .limit(limit * 2); // Get more to account for gender filtering

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .where((doc) => doc.id != userId) // Exclude self
          .map((doc) => UserProfile.fromFirestore(doc))
          .where((profile) => profile.gender == targetGender) // Filter by opposite gender
          .take(limit) // Limit final results
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Stream discovery profiles for swiping
  Stream<List<UserProfile>> getDiscoveryProfiles() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore.collection(_collection)
        .where('isProfileComplete', isEqualTo: true)
        .limit(50) // Increase limit to account for filtering
        .snapshots()
        .asyncMap((snapshot) async {
      try {
        // Get current user's profile to determine their gender
        final currentUserProfile = await getCurrentUserProfile();
        if (currentUserProfile?.gender == null) {
          return <UserProfile>[];
        }

        final currentUserGender = currentUserProfile!.gender!;
        final targetGender = _getOppositeGender(currentUserGender);


        final profiles = snapshot.docs
            .where((doc) => doc.id != user.uid) // Exclude self
            .map((doc) => UserProfile.fromFirestore(doc))
            .where((profile) {
              // Filter by opposite gender
              final profileGender = profile.gender;
              final isCorrectGender = profileGender == targetGender;

              if (!isCorrectGender) {
              }

              return isCorrectGender;
            })
            .take(20) // Limit final results
            .toList();

        return profiles;
      } catch (e) {
        return <UserProfile>[];
      }
    });
  }

  // Stream suggested profiles (curated matches)
  Stream<List<UserProfile>> getSuggestedProfiles() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    // For now, return similar logic to discovery but with different criteria
    // In production, this would use ML/recommendation algorithms
    return _firestore.collection(_collection)
        .where('isProfileComplete', isEqualTo: true)
        .where('isVerified', isEqualTo: true) // Only verified users for suggestions
        .limit(20) // Increase limit to account for gender filtering
        .snapshots()
        .asyncMap((snapshot) async {
      try {
        // Get current user's profile to determine their gender
        final currentUserProfile = await getCurrentUserProfile();
        if (currentUserProfile?.gender == null) {
          return <UserProfile>[];
        }

        final currentUserGender = currentUserProfile!.gender!;
        final targetGender = _getOppositeGender(currentUserGender);

        return snapshot.docs
            .where((doc) => doc.id != user.uid) // Exclude self
            .map((doc) => UserProfile.fromFirestore(doc))
            .where((profile) => profile.gender == targetGender) // Filter by opposite gender
            .take(10) // Limit final results
            .toList();
      } catch (e) {
        return <UserProfile>[];
      }
    });
  }

  // Stream who liked me profiles
  Stream<List<UserProfile>> getWhoLikedMe() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    // For now, return empty since we need to implement likes/matches collection
    // In production, this would query a likes/matches collection
    return Stream.value([]);
  }

  // Stream current user profile changes
  Stream<UserProfile?> watchCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore.collection(_collection).doc(user.uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    });
  }

  // Delete user profile
  Future<bool> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if user profile exists
  Future<bool> userProfileExists(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Helper method to get opposite gender for matching
  String _getOppositeGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Female';
      case 'female':
        return 'Male';
      case 'other':
        return 'Other'; // For now, Other sees Other
      default:
        return 'Other';
    }
  }
}