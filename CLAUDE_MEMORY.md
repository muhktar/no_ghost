# Claude Memory - No Ghost Dating App

**Last Updated**: November 2, 2025
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

## Current Session (November 2, 2025)

### Session 7: Ghost Mode UI Enhancements & Polish
**Objective**: Restore ghost mode functionality and enhance visual effects across all discovery views

**Context**: Ghost mode implementation was previously reverted. User recovered the feature via IDE local history.

**Changes Made**:

1. **Top Bar Layout Fix** (Discovery Views 2 & 3)
   - **Problem**: Ghost mode button was grouped with view toggle in the middle
   - **Solution**: Restructured Row to position buttons correctly:
     - Left: Back arrow
     - Center: View toggle (carousel/profile/grid icons)
     - Right: Ghost mode button
   - Files modified:
     - `lib/features/discovery/presentation/views/discovery_profile_view.dart`
     - `lib/features/discovery/presentation/views/discovery_card_view.dart`
   - Maintained existing ghost mode functionality and animations

2. **Pulse Animation Effects** (Ghost Mode Active State)
   - **Added to View 2** (Profile Preview):
     - Shimmer animation with light blue color (2000ms duration, alpha: 0.3)
     - Scale pulse effect (1500ms duration, 1.0 → 1.02)
     - Both animations repeat infinitely while ghost mode is active
   - **Added to View 3** (Card View):
     - Same shimmer and scale animations as View 2
     - Applied to all photo cards in vertical scroll
   - **Technical Implementation**:
     ```dart
     ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), ...)
       .animate(onPlay: (controller) => controller.repeat(reverse: true))
       .shimmer(duration: 2000.ms, color: Colors.lightBlue.withValues(alpha: 0.3))
       .scale(begin: Offset(1.0, 1.0), end: Offset(1.02, 1.02), duration: 1500.ms)
     ```
   - Creates a breathing/pulsing effect on blurred photos
   - Visual feedback that ghost mode is active

3. **Git Version Control Management**
   - **Analysis of untracked files**:
     - `devtools_options.yaml`: IDE-generated config → should NOT be versioned
     - `lib/core/constants/ghost_prompts.dart`: App constants → SHOULD be versioned
     - `lib/features/profile/presentation/add_ghost_prompts_screen.dart`: App code → SHOULD be versioned
   - **Actions taken**:
     - Added `devtools_options.yaml` to `.gitignore`
     - Staged ghost prompts constants file
     - Staged add ghost prompts screen file
     - Staged `.gitignore` changes
   - **Reasoning**: DevTools config is local/regenerated, ghost mode files are essential app code

**Files Modified** (5 files):
- `.gitignore` (added devtools_options.yaml)
- `lib/features/discovery/presentation/views/discovery_profile_view.dart` (layout fix + pulse effects)
- `lib/features/discovery/presentation/views/discovery_card_view.dart` (layout fix + pulse effects)

**Files Staged for Commit** (3 files):
- `lib/core/constants/ghost_prompts.dart` (21 ghost mode prompt questions)
- `lib/features/profile/presentation/add_ghost_prompts_screen.dart` (599 lines - full ghost prompts UI)
- `.gitignore` (updated)

**Visual Enhancements**:
- ✅ Consistent top bar layout across all 3 discovery views
- ✅ Ghost mode button properly positioned on far right
- ✅ Pulsing shimmer effect on blurred photos (views 2 & 3)
- ✅ Light blue glow indicates ghost mode active state
- ✅ Smooth breathing animation creates polished UX

**Testing Status**:
- ✅ Top bar layout: Buttons correctly positioned
- ✅ Ghost mode toggle: Working with scale animation
- ✅ Image blur: Functioning with pulse effects
- ✅ Shimmer animation: Visible and repeating
- ✅ Scale pulse: Subtle breathing effect working

**Next Steps**:
- Test ghost mode with real user profiles
- Verify ghost prompts display correctly when active
- Consider adding pulse effect to View 1 (carousel) for consistency

---

## Previous Sessions (October 31, 2025)

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

### Session 3: Profile Preview Modular Refactoring
**Objective**: Improve code maintainability by splitting monolithic Profile Preview screen into modular view components

**Changes Made**
1. **Architectural Refactoring**
   - Split 1,600+ line file into 4 focused files
   - Main coordinator reduced to 125 lines (92% reduction)
   - Created dedicated view files matching Discovery screen architecture

2. **New File Structure**
   ```
   lib/features/profile/presentation/
   ├── profile_preview_screen.dart (125 lines - coordinator)
   └── views/
       ├── profile_preview_carousel_view.dart (548 lines)
       ├── profile_preview_full_view.dart (525 lines)
       └── profile_preview_card_view.dart (508 lines)
   ```

3. **Benefits Achieved**
   - **Maintainability**: Each view is self-contained and focused
   - **Parallel Development**: Multiple developers can work on different views
   - **Cleaner Git Diffs**: Changes isolated to specific view files
   - **Consistent Architecture**: Matches Discovery screen pattern

**Files Modified**:
- `lib/features/profile/presentation/profile_preview_screen.dart` (refactored)
- Created: `lib/features/profile/presentation/views/profile_preview_carousel_view.dart`
- Created: `lib/features/profile/presentation/views/profile_preview_full_view.dart`
- Created: `lib/features/profile/presentation/views/profile_preview_card_view.dart`

### Session 4: Fix Async Context Warnings
**Objective**: Resolve all 15 "use_build_context_synchronously" warnings for production readiness

**Problem Identified**
- 15 async context warnings across 3 profile screens
- Using `BuildContext` after `await` operations without checking if widget is still mounted
- Can cause crashes if widget is disposed during async operation

**Solution Applied**
- Added `context.mounted` checks after all async operations
- Prevents using context on unmounted widgets
- Following Flutter 3.7+ best practices

**Files Fixed**
1. **add_photos_screen.dart** (6 warnings fixed)
   - Lines 70, 74, 76: After photo upload save
   - Lines 349, 353, 355: After continue button photo upload

2. **add_prompts_screen.dart** (6 warnings fixed)
   - Lines 95, 99, 101: After prompt save
   - Lines 338, 342, 344: After profile setup complete

3. **basic_info_screen.dart** (3 warnings fixed)
   - Lines 80, 82, 85: After basic info save operation

**Pattern Applied**
```dart
await someAsyncOperation();
if (!context.mounted) return;  // Check before using context
context.pop();
if (!context.mounted) return;  // Check before each context usage
ScaffoldMessenger.of(context).showSnackBar(...);
```

**Result**: `flutter analyze` - No issues found! ✅

**Files Modified**:
- `lib/features/profile/presentation/add_photos_screen.dart`
- `lib/features/profile/presentation/add_prompts_screen.dart`
- `lib/features/profile/presentation/basic_info_screen.dart`

### Session 5: Dynamic Photo Counter Positioning
**Objective**: Implement dynamic positioning for photo counter badge in Profile Preview carousel view to prevent overlap with long prompt text

**Problem Identified**
- Photo counter badge had fixed positioning at `bottom: 280`
- Long prompt text could overlap with counter badge
- Discovery screen already had dynamic positioning that Profile Preview lacked
- Fixed positioning wasn't resilient to varying prompt text lengths

**Solution Applied**
- Implemented `calculateTextHeight()` function to estimate prompt text height
- Added dynamic `pillBottomPosition` calculation based on text content
- Split photo counter and prompts into separate Positioned widgets
- Counter now moves up automatically when prompts are long

**Technical Details**
```dart
double calculateTextHeight(int photoIndex) {
  if (photoIndex >= profile.prompts.length) return 0;
  final prompt = profile.prompts[photoIndex];
  final text = '${prompt.question}\n${prompt.answer}';
  final lines = (text.length / 25).ceil();  // Character count per line
  const questionFontSize = 28.0;
  const lineHeight = 1.1;
  return lines * (questionFontSize * lineHeight) + 30;  // Add padding
}

final estimatedTextHeight = calculateTextHeight(currentPhotoIndex.value);
final pillBottomPosition = estimatedTextHeight > 80
    ? (280.0 + estimatedTextHeight - 85)
    : 280.0;
```

**Changes Made**
- Photo counter badge: `bottom: pillBottomPosition` (dynamic)
- Prompts text: `bottom: 220, left: 40` (fixed)
- Removed Column grouping (no longer needed with dynamic positioning)
- Counter adjusts position based on estimated prompt height
- Matches Discovery screen behavior for consistency

**Benefits**
- ✅ No overlap regardless of prompt length
- ✅ Consistent UX between Discovery and Profile Preview
- ✅ Professional, polished appearance
- ✅ Resilient to user-edited prompts with varying lengths

**File Modified**:
- `lib/features/profile/presentation/views/profile_preview_carousel_view.dart`

### Session 6: Ghost Mode Feature Implementation (Phase 1 & 2)
**Objective**: Implement Ghost Mode feature where users can browse profiles anonymously with blurred photos and ghost-specific prompts

**User Requirements**:
- Users must create 3-6 "ghost mode prompts" (separate from regular prompts)
- Ghost mode toggle in discovery screen
- When active: blur photos, hide name/occupation, show ghost prompts, keep location visible
- Pulse animation on activation
- Profile reshuffle when toggled

**Phase 1: Data Model & Backend (Completed)**

1. **UserProfile Model Updates**:
   - Added `ghostPrompts` field (List<ProfilePrompt>)
   - Added `hasMinimumGhostPrompts` helper (≥3 prompts required)
   - Updated `ProfileCompletionStatus` enum with `ghostPromptsNeeded` state
   - Updated all serialization methods (fromFirestore, toFirestore, fromJson, toJson, copyWith)
   - Profile now requires: basic info + 3+ photos + 3+ regular prompts + 3+ ghost prompts

2. **Ghost Prompts Constants**:
   - Created `lib/core/constants/ghost_prompts.dart`
   - 21 unique prompts focused on personality/values without revealing identity
   - Examples: "My philosophy on life is...", "I value most in a relationship...", "My biggest fear is..."

3. **Backend Services**:
   - Added `updateUserGhostPrompts()` method in user_profile_service.dart
   - Created `userGhostPromptsProvider` in user_profile_provider.dart
   - Firestore integration for saving/loading ghostPrompts array

**Phase 2: Profile Setup Flow (Completed)**

1. **AddGhostPromptsScreen**:
   - Created `lib/features/profile/presentation/add_ghost_prompts_screen.dart`
   - Full-featured screen for adding/editing/deleting ghost prompts
   - Min 3, max 6 ghost prompts
   - Uses ghost-specific prompt questions
   - Validation and error handling
   - Integration with user profile service

2. **Profile Setup Screen Updates**:
   - Added 4th section: "Ghost Mode Prompts" with visibility_off icon
   - Shows ghost prompt count (X/6)
   - Displays check icon when 3+ prompts added
   - Button navigates to `/add-ghost-prompts`
   - Fixed "Start Discovering" button - now disabled until ALL requirements met:
     ```dart
     hasAllRequirements = hasMinimumPhotos && hasMinimumPrompts &&
                          hasMinimumGhostPrompts && hasBasicInfo
     ```

3. **Router Configuration**:
   - Added `/add-ghost-prompts` route → AddGhostPromptsScreen
   - Import added to app_router.dart

**Phase 3: Ghost Mode State & Toggle (Completed)**

1. **State Management**:
   - Created `lib/features/discovery/providers/discovery_providers.dart`
   - `isGhostModeActiveProvider` - StateProvider<bool> for ghost mode state
   - Tracks whether ghost mode is currently active in discovery

2. **Discovery Carousel View**:
   - Watches `isGhostModeActiveProvider` state
   - Ghost button toggles state on press
   - Button changes icon: `visibility_off` → `visibility` when active
   - Button changes color: black → purple when active
   - Scale animation on button toggle (1.0 → 1.2 scale)

**Bug Fixes**:

1. **auth_service.dart**: Added missing `ghostPromptsNeeded` case to switch statement
2. **profile_setup_screen.dart**:
   - Fixed "Start Discovering" button - was always enabled
   - Now properly validates all requirements before enabling
   - Button text changes: "Start Discovering" vs "Complete All Sections to Continue"
3. **Removed temporary logout button** after user testing cleanup

**Files Created** (4 files):
- `lib/core/constants/ghost_prompts.dart`
- `lib/features/profile/presentation/add_ghost_prompts_screen.dart`
- `lib/features/discovery/providers/discovery_providers.dart`

**Files Modified** (8 files):
- `lib/shared/models/user_profile.dart`
- `lib/features/profile/data/user_profile_service.dart`
- `lib/features/profile/providers/user_profile_provider.dart`
- `lib/features/auth/presentation/profile_setup_screen.dart`
- `lib/core/router/app_router.dart`
- `lib/features/auth/data/auth_service.dart`
- `lib/features/discovery/presentation/views/discovery_carousel_view.dart`

**Documentation Updates**:
- Updated `FIREBASE_SETUP.md` with comprehensive "Deleting Test Users" section
- Explains 3-location deletion: Authentication, Firestore, Storage
- Common scenarios: "User already exists", "Black screen", "Old photos"
- Best practices for testing with test emails

**Testing Status**:
- ✅ Flutter analyze: No issues found
- ✅ Data model: ghostPrompts field added
- ✅ Profile setup: Ghost prompts section functional
- ✅ Ghost mode toggle: Button working with animation
- ⏳ ProfileCard blur effects: Not yet implemented
- ⏳ Ghost prompts display: Not yet implemented
- ⏳ Full ghost mode UX: Pending ProfileCard updates

**Remaining Work** (Phase 4):
- Update ProfileCard widget to accept `isGhostMode` parameter
- Implement blur effects for photos (ImageFiltered with ImageFilter.blur)
- Hide/blur name and occupation when ghost mode active
- Show ghostPrompts instead of regular prompts
- Add pulse animation on ghost mode activation
- Update other discovery views (profile view, card view)
- Testing complete flow

**Key Technical Decisions**:
- Ghost prompts are completely separate from regular prompts (not a subset)
- Ghost mode state is session-based (doesn't persist - resets on app restart)
- Profile completion logic is additive (adds requirement, doesn't replace)
- All users must have ghost prompts before profile is considered complete

---

## TODO Items & Incomplete Features

### High Priority
- [x] **Refactor Profile Preview Screen**: ✅ COMPLETED (Session 3)
- [x] **Fix Async Context Warnings**: ✅ COMPLETED (Session 4)
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