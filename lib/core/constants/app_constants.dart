class AppConstants {
  // Anti-Ghosting Policy Constants
  static const Duration standardResponseWindow = Duration(hours: 2);
  static const Duration premiumResponseWindow4Hours = Duration(hours: 4);
  static const Duration premiumResponseWindow6Hours = Duration(hours: 6);
  static const Duration premiumResponseWindow8Hours = Duration(hours: 8);
  
  static const int minimumMessageWordCount = 4;
  static const int maximumProfileViews = 2; // Previous button limit
  
  // Premium Tiers
  static const String premiumTier4Hours = 'premium_4h';
  static const String premiumTier6Hours = 'premium_6h';
  static const String premiumTier8Hours = 'premium_8h';
  
  // Message Types
  static const String messageTypeText = 'text';
  static const String messageTypeVoice = 'voice';
  static const String messageTypeGif = 'gif';
  static const String messageTypeMeme = 'meme';
  
  // Profile Setup Requirements
  static const int minimumPhotoCount = 3;
  static const int minimumPromptCount = 3;
  
  // Lock-In Feature
  static const String lockInMessageType = 'lock_in';
  static const Duration lockInAnimationDuration = Duration(milliseconds: 2000);
  
  // App Strings
  static const String appName = 'No Ghost';
  static const String appSlogan = 'Where authentic connections happen';
  static const String antiGhostingDescription = 
      'Find authentic connections without the games. No ghosting, just real relationships.';
  
  // Validation Messages
  static const String messageWordCountError = 
      'Messages must contain at least 4 words to encourage meaningful conversation.';
  static const String responseTimeWarning = 
      'Response time is running out! Reply within {time} to keep this match active.';
  static const String conversationExpiredMessage = 
      'This conversation has expired due to no response within the time limit.';
  static const String matchCreatedMessage = 
      'It\'s a match! Start a meaningful conversation with at least 4 words.';
  
  // Response Window Descriptions
  static const Map<String, String> responseWindowDescriptions = {
    'standard': '2 hours - Perfect for active users',
    premiumTier4Hours: '4 hours - Great for professionals',
    premiumTier6Hours: '6 hours - Comfortable schedule',
    premiumTier8Hours: '8 hours - Maximum flexibility',
  };
  
  // Lock-In Messages
  static const String lockInReceivedMessage = 
      'You\'ve been Locked-In! This person is seriously interested in connecting with you.';
  static const String lockInSentMessage = 
      'Lock-In sent! They\'ll know you\'re genuinely interested.';
  
  // Assets
  static const String logoPath = 'assets/images/No_Ghosts _logo.png';
  static const String splashAnimationPath = 'assets/animations/no_ghost_chase_lottie_v2.json';
  static const String referenceImagePath = 'assets/images/no_ghost_reference.jpg';
}

enum SubscriptionTier {
  standard,
  premium4Hours,
  premium6Hours,
  premium8Hours,
}

extension SubscriptionTierExtension on SubscriptionTier {
  Duration get responseWindow {
    switch (this) {
      case SubscriptionTier.standard:
        return AppConstants.standardResponseWindow;
      case SubscriptionTier.premium4Hours:
        return AppConstants.premiumResponseWindow4Hours;
      case SubscriptionTier.premium6Hours:
        return AppConstants.premiumResponseWindow6Hours;
      case SubscriptionTier.premium8Hours:
        return AppConstants.premiumResponseWindow8Hours;
    }
  }
  
  String get description {
    switch (this) {
      case SubscriptionTier.standard:
        return AppConstants.responseWindowDescriptions['standard']!;
      case SubscriptionTier.premium4Hours:
        return AppConstants.responseWindowDescriptions[AppConstants.premiumTier4Hours]!;
      case SubscriptionTier.premium6Hours:
        return AppConstants.responseWindowDescriptions[AppConstants.premiumTier6Hours]!;
      case SubscriptionTier.premium8Hours:
        return AppConstants.responseWindowDescriptions[AppConstants.premiumTier8Hours]!;
    }
  }
  
  String get displayName {
    switch (this) {
      case SubscriptionTier.standard:
        return '2 Hours (Free)';
      case SubscriptionTier.premium4Hours:
        return '4 Hours (Premium)';
      case SubscriptionTier.premium6Hours:
        return '6 Hours (Premium)';
      case SubscriptionTier.premium8Hours:
        return '8 Hours (Premium)';
    }
  }
}