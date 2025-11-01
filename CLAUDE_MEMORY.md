# Claude Memory - No Ghost Dating App

**Last Updated**: October 31, 2025
**Project**: No Ghost - Modern Dating App with Lock-In Feature
**Framework**: Flutter 3.7+ with Firebase Backend

---

## Project Overview

**No Ghost** is a modern dating app inspired by Hinge and Tinder, featuring a unique premium "Lock-In" feature that symbolizes exclusivity and deeper intent. Built with Flutter for cross-platform deployment (iOS, Android, Web), using Firebase as the backend infrastructure.

### Core Value Proposition
- **No Ghosting**: The name reflects the app's commitment to authentic connections
- **Lock-In Feature**: Premium match request system showing serious interest
- **Profile Depth**: Required photos (min 3) and prompts (min 3) ensure quality profiles
- **Multiple Discovery Modes**: Three view styles for browsing profiles

---

## Tech Stack

### Frontend
- **Flutter** 3.7+ (Dart 3.0+)
- **State Management**: Riverpod 2.6+ with flutter_hooks
- **Navigation**: GoRouter 14.5+ with ShellRoute for bottom navigation
- **Animations**: flutter_animate 4.5+, Lottie 3.2+
- **UI Components**: Google Fonts (Lobster, Roboto), Shimmer effects

### Backend & Services
- **Firebase Auth**: Email/password, Google Sign-In, Phone auth (setup)
- **Cloud Firestore**: User profiles and app data
- **Firebase Storage**: Photo uploads (users/{userId}/photos/)
- **Firebase Messaging**: Push notifications (configured)
- **Firebase Analytics**: User behavior tracking (configured)

### Key Packages
- `cached_network_image` 3.4+: Efficient image loading and caching
- `image_picker` 1.1+: Photo selection from gallery/camera
- `google_sign_in` 6.2+: Google authentication
- `geolocator` 13.0+: Location services
- `in_app_purchase` 3.2+: Premium subscriptions

---

## Project Architecture

### Folder Structure
```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── theme/              # AppTheme (black/white design)
│   └── router/             # GoRouter navigation setup
├── features/
│   ├── splash/             # Splash screen with logo animation
│   ├── auth/               # Authentication (welcome, login, signup, profile setup)
│   ├── profile/            # Profile management (photos, prompts, editing)
│   ├── discovery/          # Main matching interface (3 view modes)
│   ├── suggestions/        # Curated matches (skeleton)
│   ├── likes/              # Likes management (UI done, backend TODO)
│   ├── chat/               # Messaging (screens only, no backend)
│   └── subscription/       # Premium features (screen only)
├── shared/
│   ├── models/             # Data models (UserProfile, ProfilePrompt, etc.)
│   ├── widgets/            # Reusable UI components
│   ├── providers/          # Shared Riverpod providers
│   ├── services/           # API and business logic services
│   └── utils/              # Helper functions
└── main.dart               # App entry point with Firebase initialization
```

### State Management Pattern
- **Riverpod Providers**: Centralized state management
- **StreamProviders**: Real-time Firestore data (discovery profiles, user profile)
- **StateProviders**: UI state (view mode, current profile index)
- **NotifierProviders**: Complex state logic (user profile updates)

---

## Features Implemented

### 1. Authentication System ✅
**Location**: `lib/features/auth/`

#### Sign-Up/Login Methods
- **Email/Password**: Full implementation with validation
  - Email verification sent on signup
  - Password reset functionality
  - Error handling with user-friendly messages

- **Google Sign-In**: Fully working
  - Handles sign-out before new sign-in for fresh authentication
  - Creates user profile automatically after first sign-in

- **Phone Authentication**: Setup but not integrated in UI
  - Verification code sending implemented
  - SMS code verification ready
  - TODO: Add phone UI in sign-up flow

- **Apple Sign-In**: Commented out (requires Apple Developer membership)

#### Authentication Flow
1. **Splash Screen** → Logo animation
2. **Welcome Screen** → Sign Up / Log In options
3. **Sign Up/Login** → Email or Google authentication
4. **Profile Setup** → If first time or incomplete profile
5. **Discovery** → If profile complete

#### Post-Login Routing Logic
```dart
// AuthService.getPostLoginRoute() determines routing:
- No profile exists → /profile-setup
- Profile incomplete → /profile-setup
- Profile complete → /discovery
```

#### Files
- `auth_service.dart`: All authentication logic and Firebase Auth integration
- `auth_provider.dart`: Riverpod providers for auth state
- `welcome_screen.dart`, `login_screen.dart`, `sign_up_screen.dart`
- `profile_setup_screen.dart`: Entry point for profile completion

---

### 2. Profile Management ✅
**Location**: `lib/features/profile/`

#### User Profile Model
**File**: `lib/shared/models/user_profile.dart`

```dart
class UserProfile {
  String userId          // Firebase Auth UID
  String email           // User email
  String? name           // Display name
  int? age               // Age (required for matching)
  String? gender         // Male/Female/Other (required for matching)
  List<String> photoUrls // Firebase Storage URLs (min 3, max 6)
  List<ProfilePrompt> prompts  // Text prompts (min 3, max 6)
  String? bio            // Optional bio text
  String? occupation     // Job title
  String? location       // City/location
  DateTime createdAt     // Account creation
  DateTime lastActive    // Last activity timestamp
  bool isVerified        // Verification badge
  bool isProfileComplete // Profile completion status
  UserPreferences preferences // Matching preferences
}
```

#### Profile Completion Logic
```dart
enum ProfileCompletionStatus {
  notStarted,    // No basic info
  photosOnly,    // Has photos but not enough prompts
  promptsOnly,   // Has prompts but not enough photos
  complete       // Has 3+ photos AND 3+ prompts AND basic info
}
```

#### Photo Upload System
**File**: `lib/features/profile/data/photo_upload_service.dart`

- **Source**: Gallery or Camera (ImagePicker)
- **Validation**: 3-6 photos required
- **Storage**: Firebase Storage at `users/{userId}/photos/`
- **Format**: JPG with timestamp-based filenames
- **Display**: First photo is "Main Photo" badge
- **Process**:
  1. User selects photo from gallery/camera
  2. Photo stored locally as XFile
  3. On "Done", uploaded to Firebase Storage
  4. Download URL saved to Firestore user document
  5. Displayed with CachedNetworkImage

#### Prompts System
**File**: `lib/features/profile/presentation/add_prompts_screen.dart`

- **Count**: 3-6 prompts required
- **Available Prompts** (21 total):
  - "My ideal Sunday involves..."
  - "I'm overly competitive about..."
  - "A perfect first date would be..."
  - "I'm secretly really good at..."
  - "My most controversial opinion is..."
  - "I spend too much money on..."
  - "The way to win me over is..."
  - "I'm looking for someone who..."
  - *(+ 13 more)*

- **Types**: Text (voice and photo types defined but not implemented)
- **Storage**: Firestore in user document as array of objects

#### Profile Setup Flow
1. **Basic Info Screen**: Name, age, gender (required)
2. **Add Photos Screen**: Upload 3-6 photos
3. **Add Prompts Screen**: Answer 3-6 prompts
4. **Profile Preview**: Review before going live
5. **Completion**: Redirected to Discovery

#### Profile Editing
- **Profile Screen**: View and edit current profile
- Can navigate back to Add Photos/Prompts screens
- Updates saved to Firestore immediately

---

### 3. Discovery/Matching System ✅
**Location**: `lib/features/discovery/`

#### Three View Modes
**File**: `lib/features/discovery/presentation/discovery_screen.dart`

```dart
enum DiscoveryViewMode {
  carousel,       // Default: Horizontal scrolling photo carousel
  profilePreview, // Full profile page view
  custom          // Card-based vertical scroll
}
```

1. **Carousel View** (Default)
   - Horizontal pin-wheel carousel effect
   - Large photos with visible prev/next
   - Prompts overlaid on photos
   - Action buttons at bottom: X, Connect, Ghost
   - Photo counter pill (dynamic positioning)

2. **Profile Preview View**
   - Identical to ProfilePreviewScreen layout
   - Full profile information
   - All photos in carousel
   - All prompts displayed
   - Occupation, location, bio visible

3. **Card View (Custom)**
   - Vertical scrolling ListView
   - Alternating photos and prompts
   - Action buttons on each card
   - Basic info card after first photo
   - Compact layout with 8px spacing

#### Matching Algorithm
**File**: `lib/features/profile/data/user_profile_service.dart`

```dart
// getDiscoveryProfiles() logic:
1. Query Firestore users collection
2. Filter: isProfileComplete == true
3. Filter: Exclude current user
4. Filter: Opposite gender only
5. Filter: Age range from preferences (default 18-35)
6. Limit: 50 profiles fetched, 20 shown
7. Stream: Real-time updates via Firestore snapshots
```

**Gender Matching**:
- Male users see Female profiles
- Female users see Male profiles
- Other sees Other (currently)

**Age Preferences**:
- Default: 18-35 years
- Configurable per user (stored in UserPreferences)
- TODO: Distance filtering (geolocator ready but not implemented)

#### Action Buttons
- **X Button (Pass)**: Skip profile
  - TODO: Track passes in Firestore

- **Connect Button (Like)**: Express interest
  - Opens ConnectBottomSheet with message options
  - TODO: Save likes to Firestore likes collection

- **Ghost Button**: Placeholder for future feature
  - Currently visibility_off icon
  - TODO: Implement "ghost pick" functionality

#### Navigation Features
- **Previous Profile**: Back button (top-left)
  - Limited history (2 profiles max)
  - Stack-based navigation

- **Skip**: Name/age button (top-right)
  - Quick skip to next profile

- **View Toggle**: Center toggle (3 buttons)
  - Switch between view modes instantly
  - State persists during session

#### Lock-In Feature 🔒❤️
**File**: `lib/features/discovery/widgets/lock_in_dialog.dart`

- **Purpose**: Premium super-like showing serious interest
- **UI**: Heart animation → lock closing effect
- **Status**: UI complete, Firestore integration TODO
- **Cost**: Credits-based system (not implemented)

---

### 4. Navigation Structure ✅
**File**: `lib/core/router/app_router.dart`

#### Routes
```
/splash                  # Splash screen
/welcome                 # Welcome/landing page
/signup                  # Sign up screen
/login                   # Login screen
/profile-setup           # Profile setup entry
/basic-info              # Basic info form
/add-photos              # Photo upload
/add-prompts             # Prompts selection
/profile-preview         # Preview before going live

# Main app with bottom navigation (ShellRoute):
/discovery               # Home - main swiping
/suggestions             # Curated matches
/likes                   # Who liked you
/chat                    # Messages list
  /conversation/:matchId # Individual chat
/profile                 # User profile

/subscription            # Premium features
```

#### Bottom Navigation (5 Tabs)
1. **Discovery** (explore icon): Main matching interface
2. **Suggestions** (auto_awesome icon): Curated matches
3. **Likes** (favorite icon): Likes management
4. **Chat** (chat_bubble icon): Messages
5. **Profile** (person icon): User profile

---

### 5. Firebase Integration ✅

#### Firestore Database Structure
```
users (collection)
├── {userId} (document)
│   ├── email: string
│   ├── name: string
│   ├── age: number
│   ├── gender: string
│   ├── photoUrls: array<string>     # Firebase Storage URLs
│   ├── prompts: array<object>
│   │   ├── id: string
│   │   ├── question: string
│   │   ├── answer: string
│   │   └── type: string
│   ├── bio: string
│   ├── occupation: string
│   ├── location: string
│   ├── createdAt: timestamp
│   ├── lastActive: timestamp
│   ├── isVerified: boolean
│   ├── isProfileComplete: boolean   # Critical for discovery
│   └── preferences: object
│       ├── minAge: number (default 18)
│       ├── maxAge: number (default 35)
│       ├── maxDistance: number (default 50km)
│       ├── showVerifiedOnly: boolean
│       ├── enableNotifications: boolean
│       ├── enablePushNotifications: boolean
│       └── interestedIn: array<string>
```

#### Firebase Storage Structure
```
users/
└── {userId}/
    └── photos/
        ├── profile_photo_1_{timestamp}.jpg
        ├── profile_photo_2_{timestamp}.jpg
        ├── profile_photo_3_{timestamp}.jpg
        └── ...
```

#### Firebase Configuration
**File**: `lib/firebase_options.dart`

- **Project ID**: no-ghost
- **Storage Bucket**: no-ghost.firebasestorage.app
- **Platforms**: Android, iOS, Web, macOS, Windows configured

#### Security Considerations
- TODO: Implement Firestore security rules
- TODO: Implement Storage security rules
- TODO: Add rate limiting for writes
- TODO: Validate data on server side

---

## UI/UX Design

### Theme
**File**: `lib/core/theme/app_theme.dart`

- **Primary**: Black and white minimalist design
- **Accent**: Pink (#EC4899) for Lock-In feature
- **Fonts**:
  - Google Fonts Lobster for headings
  - Roboto for body text
- **Buttons**: Rounded corners (12px radius)
- **Cards**: Light gray (0xFFF8F9FA) with elevation
- **Animations**: Smooth transitions with flutter_animate

### Key Widgets
- **ProfileCard**: Reusable profile display with carousel
- **ConnectBottomSheet**: Message options when liking
- **LockInDialog**: Premium match request UI
- **ActionButtons**: X, Connect, Ghost button row

---

## Development History

### Major Milestones

**October 30, 2025**
- **Comprehensive code cleanup**: Reduced Flutter analyze issues from 280 → 15 (94.6% reduction)
  - Replaced deprecated `withOpacity()` with `withValues(alpha:)`
  - Updated background/onBackground to surface/onSurface
  - Removed 134+ debug print statements
  - Fixed unused imports and variables across 25 files
  - Added context.mounted checks for async operations

**October 29, 2025**
- **Discovery screen refactoring**: Split monolithic 2054-line file into modular components
  - Created discovery_carousel_view.dart
  - Created discovery_profile_view.dart
  - Created discovery_card_view.dart
  - Extracted ConnectBottomSheet as shared component
  - Reduced main file to ~200 lines

**October 28, 2025**
- Enhanced profile card with dynamic positioning to prevent text overlap
- Added occupation and location display
- Implemented text height calculation for proper spacing

**October 27, 2025**
- Added three-button layout (X, Connect, Ghost)
- Implemented ghost button with visibility_off icon
- Added third discovery view with alternating photo-prompt layout

**Early October 2025**
- View toggle functionality with profile preview mode
- Fixed Android build issues and app launch compatibility
- Added No Ghost logo
- Initial app setup with core features

---

## Current Session (October 31, 2025)

### Session 1: Documentation and Asset Recovery
**Issues Discovered**
1. **Missing README files**: Firebase setup guide and Claude Memory file were never committed
2. **Sample images not in repo**: 27 Unsplash images (99MB) were on Android emulator but not in git

**Actions Taken**
1. **Image Recovery**: Used `adb pull` to retrieve 27 sample images from emulator
   - Saved to: `assets/sample_images/`
   - Total size: 99MB
   - Images: jamaal-kareem, joey-nicotra, justin-essah portrait photos

2. **Documentation**: Created CLAUDE_MEMORY.md and FIREBASE_SETUP.md
   - Complete project context for future sessions
   - Step-by-step Firebase configuration guide
   - Free tier limits and billing information

### Session 2: Profile Preview Screen Enhancements
**Objective**: Make Profile Preview screen's first view (carousel) match Discovery screen layout while adding edit functionality

**Changes Made**
1. **Layout Restructuring** (`profile_preview_screen.dart`)
   - Shortened photo carousel height (top: 120, bottom: 200 vs full screen)
   - Added occupation and location display above photos (top: 100)
   - Maintained all existing elements (name/age, view toggles, prompts)

2. **Bottom Section Redesign**
   - **Row 1**: X button | "Profile Preview" label | Ghost button
   - **Row 2**: Edit Photos button (camera icon) | Edit Prompts button (edit icon)
   - Replaced original "Connect" button with profile editing functionality
   - Both edit buttons navigate to respective editing screens

3. **Photo Counter & Prompt Text Grouping**
   - Fixed spacing inconsistency issue where prompt length affected counter positioning
   - Grouped counter badge and prompt text in single Column container
   - Counter always maintains 12px margin from prompt regardless of content length
   - Added text overflow protection (maxLines: 3 for question, 4 for answer)

4. **Navigation Fix**
   - Fixed back arrow button to properly navigate back using `context.pop()`
   - Previously called non-functional `_handlePreviousProfile()` method

**Technical Details**
- Photo carousel positioned at `bottom: 220` (provides space for edit buttons)
- Occupation/location at `top: 100` in white space above photos
- Photo counter and prompts in Column at `bottom: 220` with relative spacing
- Bottom section: 2-row layout with SafeArea padding
- All changes isolated to Profile Preview screen (Discovery screen untouched)

**File Modified**: `lib/features/profile/presentation/profile_preview_screen.dart`

---

## TODO Items & Incomplete Features

### High Priority
- [ ] **Refactor Profile Preview Screen**: Split 1600+ line file into modular views
  - Current: Single monolithic file with all 3 views
  - Target: Separate files like Discovery screen architecture
  - Files to create:
    - `views/profile_preview_carousel_view.dart` (~500 lines)
    - `views/profile_preview_full_view.dart` (~450 lines)
    - `views/profile_preview_card_view.dart` (~400 lines)
  - Main coordinator should be ~150 lines
  - Benefits: Easier maintenance, parallel development, cleaner git diffs
- [ ] **Lock-In Backend**: Implement Firestore logic for premium match requests
- [ ] **Likes System**: Create likes/matches collection and real-time tracking
- [ ] **Match Detection**: When both users like each other, create match
- [ ] **Firestore Security Rules**: Protect user data properly
- [ ] **Storage Security Rules**: Secure photo uploads

### Medium Priority
- [ ] **Chat Backend**: Implement real-time messaging with Firestore
- [ ] **Push Notifications**: Set up Firebase Cloud Messaging for matches/messages
- [ ] **Distance Filtering**: Implement geolocator-based distance matching
- [ ] **Profile Verification**: Add verification system
- [ ] **Block/Report**: User safety features

### Low Priority
- [ ] **Subscription System**: Implement in-app purchases for premium features
- [ ] **Ghost Feature**: Define and implement "ghost pick" functionality
- [ ] **Voice Prompts**: Allow voice recordings for prompts
- [ ] **Photo Prompts**: Allow photos as prompt answers
- [ ] **Advanced Filters**: More matching criteria
- [ ] **Analytics**: Track user behavior and engagement

---

## Known Issues

1. **Apple Sign-In Disabled**: Requires Apple Developer Program membership ($99/year)
2. **Phone Auth UI Missing**: Backend ready but no UI for phone number input
3. **No Error Logging**: Need Crashlytics or similar for production
4. **Large Sample Images**: 99MB in assets/sample_images/ should be gitignored
5. **No CI/CD Pipeline**: Manual testing and deployment only

---

## Testing Status

### Tested ✅
- Email signup/login flow
- Google Sign-In
- Profile setup flow (photos, prompts, basic info)
- Discovery screen (all 3 view modes)
- View mode switching
- Profile navigation (previous/skip)
- Photo upload to Firebase Storage
- Firestore user profile CRUD

### Not Tested ❌
- Phone authentication
- Like/match system (no backend)
- Chat functionality (no backend)
- Lock-In feature (no backend)
- Subscription/payments
- Push notifications
- Production builds (Android/iOS)

---

## Deployment

### Development Environment
- Flutter SDK: 3.7+
- Dart: 3.0+
- Android Studio / VS Code
- Firebase Project: no-ghost

### Platform Status
- **Android**: Debug builds working, release signing TODO
- **iOS**: Not tested (requires Mac + iOS developer account)
- **Web**: Configured but not production-ready
- **Desktop**: macOS/Windows configured, not primary targets

---

## Key Learnings & Decisions

### Why Riverpod?
- Type-safe state management
- Better testing compared to Provider
- Compile-time safety
- Auto-dispose for memory management

### Why GoRouter?
- Declarative routing recommended by Flutter team
- Type-safe navigation
- Deep linking support
- ShellRoute for persistent bottom navigation

### Why Firebase?
- Rapid development with BaaS
- Real-time data sync for dating app use case
- Scalable authentication
- Built-in security rules
- Free tier sufficient for MVP

### Why Three View Modes?
- Different user preferences for browsing
- Carousel: Quick swiping (Tinder-style)
- Profile: Detailed view (Hinge-style)
- Card: Hybrid approach with context

---

## Next Session Checklist

When resuming work on this project:

1. **Read this file first** to understand project context
2. **Check TODO items** above for priorities
3. **Run `flutter pub get`** to ensure dependencies are current
4. **Check Firebase console** for any quota warnings
5. **Review recent commits** with `git log` for latest changes
6. **Test auth flow** to ensure Firebase connection working
7. **Check Flutter analyze** with `flutter analyze` (should be ~15 issues)

---

## Resources

### Documentation
- Flutter Docs: https://docs.flutter.dev
- Firebase Docs: https://firebase.google.com/docs
- Riverpod Docs: https://riverpod.dev
- GoRouter Docs: https://pub.dev/packages/go_router

### Firebase Console
- Project: https://console.firebase.google.com/project/no-ghost
- Auth: https://console.firebase.google.com/project/no-ghost/authentication
- Firestore: https://console.firebase.google.com/project/no-ghost/firestore
- Storage: https://console.firebase.google.com/project/no-ghost/storage

### Package References
- See `pubspec.yaml` for complete package list
- Major versions: riverpod 2.6+, go_router 14.5+, firebase_core 3.9+

---

## Contact & Support

For questions about this codebase or to resume development:
- Review this CLAUDE_MEMORY.md file
- Check FIREBASE_SETUP.md for Firebase configuration
- Review git history for recent changes
- Test the app to understand current functionality

---

**Remember**: This file should be updated after significant development sessions to maintain project continuity. Update the "Current Session" section and "Development History" when major features are added or changed.