import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String email;
  final String? name;
  final int? age;
  final String? gender;
  final List<String> photoUrls;
  final List<ProfilePrompt> prompts;
  final String? bio;
  final String? occupation;
  final String? location;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isVerified;
  final bool isProfileComplete;
  final UserPreferences preferences;
  final int distance; // in kilometers (for display/matching)
  
  UserProfile({
    required this.userId,
    required this.email,
    this.name,
    this.age,
    this.gender,
    this.photoUrls = const [],
    this.prompts = const [],
    this.bio,
    this.occupation,
    this.location,
    DateTime? createdAt,
    DateTime? lastActive,
    this.isVerified = false,
    this.isProfileComplete = false,
    UserPreferences? preferences,
    this.distance = 0,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastActive = lastActive ?? DateTime.now(),
       preferences = preferences ?? UserPreferences();


  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      userId: doc.id,
      email: data['email'] as String,
      name: data['name'] as String?,
      age: data['age'] as int?,
      gender: data['gender'] as String?,
      photoUrls: List<String>.from(data['photoUrls'] as List? ?? []),
      prompts: (data['prompts'] as List? ?? [])
          .map((promptJson) => ProfilePrompt.fromJson(promptJson))
          .toList(),
      bio: data['bio'] as String?,
      occupation: data['occupation'] as String?,
      location: data['location'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: data['isVerified'] as bool? ?? false,
      isProfileComplete: data['isProfileComplete'] as bool? ?? false,
      preferences: data['preferences'] != null
          ? UserPreferences.fromJson(data['preferences'] as Map<String, dynamic>)
          : UserPreferences(),
      distance: data['distance'] as int? ?? 0,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      photoUrls: List<String>.from(json['photoUrls'] as List? ?? []),
      prompts: (json['prompts'] as List? ?? [])
          .map((promptJson) => ProfilePrompt.fromJson(promptJson))
          .toList(),
      bio: json['bio'] as String?,
      occupation: json['occupation'] as String?,
      location: json['location'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'] as String)
          : DateTime.now(),
      isVerified: json['isVerified'] as bool? ?? false,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : UserPreferences(),
      distance: json['distance'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'photoUrls': photoUrls,
      'prompts': prompts.map((prompt) => prompt.toJson()).toList(),
      'bio': bio,
      'occupation': occupation,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'isVerified': isVerified,
      'isProfileComplete': isProfileComplete,
      'preferences': preferences.toJson(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'photoUrls': photoUrls,
      'prompts': prompts.map((prompt) => prompt.toJson()).toList(),
      'bio': bio,
      'occupation': occupation,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'isVerified': isVerified,
      'isProfileComplete': isProfileComplete,
      'preferences': preferences.toJson(),
      'distance': distance,
    };
  }

  UserProfile copyWith({
    String? userId,
    String? email,
    String? name,
    int? age,
    String? gender,
    List<String>? photoUrls,
    List<ProfilePrompt>? prompts,
    String? bio,
    String? occupation,
    String? location,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isVerified,
    bool? isProfileComplete,
    UserPreferences? preferences,
    int? distance,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      photoUrls: photoUrls ?? this.photoUrls,
      prompts: prompts ?? this.prompts,
      bio: bio ?? this.bio,
      occupation: occupation ?? this.occupation,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isVerified: isVerified ?? this.isVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      preferences: preferences ?? this.preferences,
      distance: distance ?? this.distance,
    );
  }

  // Helper methods for profile completion logic
  bool get hasMinimumPhotos => photoUrls.length >= 3;
  bool get hasMinimumPrompts => prompts.length >= 3;
  bool get hasBasicInfo => name != null && age != null && gender != null;
  
  ProfileCompletionStatus get completionStatus {
    if (!hasBasicInfo) return ProfileCompletionStatus.notStarted;
    if (hasMinimumPhotos && !hasMinimumPrompts) return ProfileCompletionStatus.photosOnly;
    if (!hasMinimumPhotos && hasMinimumPrompts) return ProfileCompletionStatus.promptsOnly;
    if (hasMinimumPhotos && hasMinimumPrompts) return ProfileCompletionStatus.complete;
    return ProfileCompletionStatus.notStarted;
  }
}

enum ProfileCompletionStatus {
  notStarted,
  photosOnly,
  promptsOnly,
  complete
}

class UserPreferences {
  final int minAge;
  final int maxAge;
  final int maxDistance;
  final bool showVerifiedOnly;
  final bool enableNotifications;
  final bool enablePushNotifications;
  final List<String> interestedIn;
  
  UserPreferences({
    this.minAge = 18,
    this.maxAge = 35,
    this.maxDistance = 50,
    this.showVerifiedOnly = false,
    this.enableNotifications = true,
    this.enablePushNotifications = true,
    this.interestedIn = const ['everyone'],
  });
  
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      minAge: json['minAge'] as int? ?? 18,
      maxAge: json['maxAge'] as int? ?? 35,
      maxDistance: json['maxDistance'] as int? ?? 50,
      showVerifiedOnly: json['showVerifiedOnly'] as bool? ?? false,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      enablePushNotifications: json['enablePushNotifications'] as bool? ?? true,
      interestedIn: List<String>.from(json['interestedIn'] as List? ?? ['everyone']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'minAge': minAge,
      'maxAge': maxAge,
      'maxDistance': maxDistance,
      'showVerifiedOnly': showVerifiedOnly,
      'enableNotifications': enableNotifications,
      'enablePushNotifications': enablePushNotifications,
      'interestedIn': interestedIn,
    };
  }
  
  UserPreferences copyWith({
    int? minAge,
    int? maxAge,
    int? maxDistance,
    bool? showVerifiedOnly,
    bool? enableNotifications,
    bool? enablePushNotifications,
    List<String>? interestedIn,
  }) {
    return UserPreferences(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      maxDistance: maxDistance ?? this.maxDistance,
      showVerifiedOnly: showVerifiedOnly ?? this.showVerifiedOnly,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      interestedIn: interestedIn ?? this.interestedIn,
    );
  }
}

class ProfilePrompt {
  final String id;
  final String question;
  final String answer;
  final PromptType type;

  ProfilePrompt({
    this.id = '',
    required this.question,
    required this.answer,
    required this.type,
  });

  factory ProfilePrompt.fromJson(Map<String, dynamic> json) {
    return ProfilePrompt(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      type: PromptType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => PromptType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'type': type.name,
    };
  }
}

enum PromptType {
  text,
  voice,
  photo,
}

