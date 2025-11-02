# Firebase Setup Guide - No Ghost Dating App

**Last Updated**: October 31, 2025
**Firebase Project**: no-ghost
**Platforms**: Android, iOS, Web, macOS, Windows

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Firebase Project Creation](#firebase-project-creation)
3. [Firebase Authentication Setup](#firebase-authentication-setup)
4. [Cloud Firestore Setup](#cloud-firestore-setup)
5. [Firebase Storage Setup](#firebase-storage-setup)
6. [Platform Configuration](#platform-configuration)
7. [Security Rules](#security-rules)
8. [Free Tier Limits & Billing](#free-tier-limits--billing)
9. [Testing & Verification](#testing--verification)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- **Flutter SDK**: 3.7.0 or higher
- **Dart**: 3.0 or higher
- **Node.js**: 14+ (for Firebase CLI)
- **Firebase CLI**: Install with `npm install -g firebase-tools`
- **FlutterFire CLI**: Install with `dart pub global activate flutterfire_cli`

### Required Accounts
- **Google/Firebase Account**: Free (gmail.com or Google Workspace)
- **Android Developer Account**: Free for development ($25 one-time for publishing)
- **Apple Developer Account**: $99/year (required for iOS deployment)

### Verify Installation
```bash
flutter --version          # Should show 3.7+
dart --version            # Should show 3.0+
firebase --version        # Should show 11.0+
flutterfire --version     # Should show 0.3+
```

---

## Firebase Project Creation

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: **`no-ghost`**
4. Click **"Continue"**
5. **Google Analytics**: Toggle ON (recommended for tracking)
   - Select or create Analytics account
   - Choose analytics location (e.g., United States)
6. Click **"Create project"**
7. Wait for project creation (30-60 seconds)
8. Click **"Continue"** when ready

### Step 2: Upgrade to Blaze Plan (Recommended for Production)

⚠️ **Important**: The Spark (free) plan has limitations that may not be sufficient for a production dating app. Consider upgrading to Blaze plan.

1. In Firebase Console, go to **Settings** (gear icon) → **Usage and billing**
2. Click **"Modify plan"**
3. Select **"Blaze (Pay as you go)"**
4. Add payment method (credit/debit card)
5. Set budget alerts (recommended: $10, $50, $100)

**Why Blaze Plan?**
- Higher Firestore read/write quotas
- More Storage and bandwidth
- Cloud Functions (if needed later)
- Scales automatically with usage

---

## Firebase Authentication Setup

### Step 1: Enable Authentication

1. In Firebase Console, navigate to **Build** → **Authentication**
2. Click **"Get started"**
3. You'll see the **Sign-in method** tab

### Step 2: Enable Email/Password Authentication

1. Click **"Email/Password"** in the Sign-in providers list
2. Toggle **"Enable"** to ON
3. **Email link (passwordless sign-in)**: Leave OFF (not used)
4. Click **"Save"**

### Step 3: Enable Google Sign-In

1. Click **"Google"** in the Sign-in providers list
2. Toggle **"Enable"** to ON
3. **Project public-facing name**: Enter "No Ghost"
4. **Project support email**: Select your email from dropdown
5. Click **"Save"**

### Step 4: Configure OAuth Consent Screen (Required for Google Sign-In)

#### For Android:
1. Go to **Project Settings** (gear icon)
2. Scroll to **"Your apps"** section
3. Click the Android app (or add one if not exists)
4. Copy the **SHA-1 certificate fingerprint**:
   ```bash
   # Debug certificate (for development)
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. Paste SHA-1 in Firebase Console under Android app settings
6. Download updated `google-services.json`

#### For iOS:
1. Go to **Project Settings** → Your iOS app
2. Download `GoogleService-Info.plist`
3. Note the **REVERSED_CLIENT_ID** for URL schemes

### Step 5: Enable Phone Authentication (Optional)

⚠️ **Note**: Currently implemented in code but not in UI

1. Click **"Phone"** in the Sign-in providers list
2. Toggle **"Enable"** to ON
3. **Test phone numbers** (for development):
   - Add test numbers: +1 234 567 8900
   - Verification code: 123456
4. Click **"Save"**

**Phone Auth Requirements**:
- Requires reCAPTCHA for web
- Requires APNs certificates for iOS
- Android: Works out of the box

### Step 6: Enable Apple Sign-In (Optional - Requires Apple Developer Account)

⚠️ **Currently commented out in code** - Requires $99/year Apple Developer membership

1. Click **"Apple"** in the Sign-in providers list
2. Toggle **"Enable"** to ON
3. Enter **Service ID** from Apple Developer Console
4. Enter **Apple Team ID**
5. Upload **Private Key** (.p8 file from Apple)
6. Enter **Key ID**
7. Click **"Save"**

---

## Cloud Firestore Setup

### Step 1: Create Firestore Database

1. Navigate to **Build** → **Firestore Database**
2. Click **"Create database"**
3. **Security rules**: Select **"Start in test mode"** (we'll fix this later)
4. **Firestore location**: Choose closest region
   - `us-central` (Iowa) - Good for US
   - `us-east1` (South Carolina) - Good for East Coast
   - `europe-west1` (Belgium) - Good for Europe
   - ⚠️ **Cannot change location after creation!**
5. Click **"Enable"**

### Step 2: Create Indexes (Required for Queries)

Firestore requires indexes for complex queries. Create these indexes:

1. Go to **Firestore Database** → **Indexes** tab
2. Click **"+ Create index"**

#### Index 1: Age Range Query
- **Collection ID**: `users`
- **Fields indexed**:
  - `isProfileComplete`: Ascending
  - `age`: Ascending
- **Query scope**: Collection
- Click **"Create index"**
- Wait for build (2-5 minutes)

#### Index 2: Gender + Age Query (If implementing gender filters)
- **Collection ID**: `users`
- **Fields indexed**:
  - `isProfileComplete`: Ascending
  - `gender`: Ascending
  - `age`: Ascending
- **Query scope**: Collection
- Click **"Create index"**

### Step 3: Firestore Data Structure

The app uses this structure:

```
users (collection)
└── {userId} (document - Firebase Auth UID)
    ├── email: string
    ├── name: string
    ├── age: number
    ├── gender: string ("Male" | "Female" | "Other")
    ├── photoUrls: array of strings (Firebase Storage URLs)
    ├── prompts: array of objects
    │   ├── id: string
    │   ├── question: string
    │   ├── answer: string
    │   └── type: string ("text" | "voice" | "photo")
    ├── bio: string
    ├── occupation: string
    ├── location: string
    ├── createdAt: timestamp
    ├── lastActive: timestamp
    ├── isVerified: boolean
    ├── isProfileComplete: boolean  ⚠️ Critical for discovery!
    └── preferences: object
        ├── minAge: number (default: 18)
        ├── maxAge: number (default: 35)
        ├── maxDistance: number (default: 50)
        ├── showVerifiedOnly: boolean
        ├── enableNotifications: boolean
        ├── enablePushNotifications: boolean
        └── interestedIn: array of strings
```

### Step 4: Add Sample User (Optional - For Testing)

1. In Firestore Database, click **"+ Start collection"**
2. **Collection ID**: `users`
3. **Document ID**: Use your Firebase Auth UID (get from Authentication tab)
4. Add fields manually or import this JSON:

```json
{
  "email": "test@example.com",
  "name": "Test User",
  "age": 25,
  "gender": "Male",
  "photoUrls": [],
  "prompts": [],
  "bio": "Test bio",
  "occupation": "Software Engineer",
  "location": "New York, NY",
  "createdAt": "2025-10-31T12:00:00Z",
  "lastActive": "2025-10-31T12:00:00Z",
  "isVerified": false,
  "isProfileComplete": false,
  "preferences": {
    "minAge": 18,
    "maxAge": 35,
    "maxDistance": 50,
    "showVerifiedOnly": false,
    "enableNotifications": true,
    "enablePushNotifications": true,
    "interestedIn": ["everyone"]
  }
}
```

---

## Firebase Storage Setup

### Step 1: Enable Cloud Storage

1. Navigate to **Build** → **Storage**
2. Click **"Get started"**
3. **Security rules**: Select **"Start in test mode"** (we'll fix this later)
4. **Cloud Storage location**: Should match your Firestore location
   - ⚠️ **Cannot change location after creation!**
5. Click **"Next"**, then **"Done"**

### Step 2: Understand Storage Structure

The app uploads photos with this structure:

```
gs://no-ghost.firebasestorage.app/
└── users/
    └── {userId}/
        └── photos/
            ├── profile_photo_1_1698772800000.jpg
            ├── profile_photo_2_1698772801000.jpg
            ├── profile_photo_3_1698772802000.jpg
            └── ...
```

**File Naming Convention**:
- Pattern: `profile_photo_{index}_{timestamp}.jpg`
- Index: 1-6 (max 6 photos)
- Timestamp: Milliseconds since epoch (for uniqueness)

### Step 3: Storage Quotas

**Spark Plan (Free)**:
- **Storage**: 5 GB total
- **Downloads**: 1 GB/day
- **Uploads**: 1 GB/day

**Blaze Plan (Pay as you go)**:
- **Storage**: $0.026/GB/month
- **Downloads**: $0.12/GB
- **Uploads**: $0.12/GB
- **Operations**: $0.05 per 10,000 operations (Class A), $0.004 per 10,000 (Class B)

**Estimated Dating App Usage** (1000 active users):
- 1000 users × 4 photos avg × 2 MB/photo = 8 GB storage ≈ **$0.21/month**
- Profile views: 10,000 photos/day × 2 MB = 20 GB/day ≈ **$2.40/day** → **$72/month**
- Total: ~$72/month for 1000 users

💡 **Optimization Tips**:
- Compress images before upload (target 500 KB/photo)
- Use CDN caching (Firebase provides automatic CDN)
- Implement image size limits in app

---

## Platform Configuration

### Android Setup

#### Step 1: Add Android App to Firebase

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll to **"Your apps"** section
3. Click **Android icon** to add Android app
4. **Android package name**: `com.noghost.dating.no_ghost`
   - ⚠️ Must match `applicationId` in `android/app/build.gradle.kts`
5. **App nickname**: No Ghost Android (optional)
6. **Debug signing certificate SHA-1**: Add for Google Sign-In
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
   ```
7. Click **"Register app"**

#### Step 2: Download and Add google-services.json

1. Download `google-services.json` from Firebase Console
2. Place file at: `android/app/google-services.json`
   ```
   no_ghost/
   └── android/
       └── app/
           └── google-services.json  ← Here
   ```
3. ⚠️ **DO NOT commit to git** - already in `.gitignore`

#### Step 3: Verify Android Configuration

Check `android/app/build.gradle.kts`:

```kotlin
// Should have this plugin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // ← Check this line
}

android {
    defaultConfig {
        applicationId = "com.noghost.dating.no_ghost"  // ← Must match Firebase
        // ...
    }
}
```

Check `android/build.gradle.kts`:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")  // ← Check this
    }
}
```

### iOS Setup

⚠️ **Requires macOS and Xcode**

#### Step 1: Add iOS App to Firebase

1. In Firebase Console, go to **Project Settings**
2. Click **iOS icon** to add iOS app
3. **iOS bundle ID**: `com.noghost.dating.noGhost`
   - ⚠️ Must match bundle ID in Xcode
4. **App nickname**: No Ghost iOS (optional)
5. **App Store ID**: Leave blank for development
6. Click **"Register app"**

#### Step 2: Download and Add GoogleService-Info.plist

1. Download `GoogleService-Info.plist` from Firebase Console
2. Open Xcode: `open ios/Runner.xcworkspace`
3. Drag `GoogleService-Info.plist` into `Runner/Runner` folder
4. Check **"Copy items if needed"**
5. ⚠️ **DO NOT commit to git** - already in `.gitignore`

#### Step 3: Configure URL Schemes (for Google Sign-In)

1. In Xcode, select **Runner** project
2. Go to **Info** tab
3. Expand **URL Types**
4. Click **+** to add URL scheme
5. **Identifier**: `com.google.gid`
6. **URL Schemes**: Add `REVERSED_CLIENT_ID` from `GoogleService-Info.plist`
   - Example: `com.googleusercontent.apps.948508900116-xxx`

### Web Setup (Optional)

1. In Firebase Console, click **Web icon** to add web app
2. **App nickname**: No Ghost Web
3. Check **"Also set up Firebase Hosting"** if deploying to Firebase
4. Copy the Firebase config object (already in `firebase_options.dart`)

### Using FlutterFire CLI (Easiest Method)

Instead of manual setup, use FlutterFire CLI:

```bash
# Login to Firebase
firebase login

# Configure Flutter app with Firebase
flutterfire configure --project=no-ghost

# This will:
# 1. Detect all platforms
# 2. Register apps in Firebase
# 3. Download config files
# 4. Generate lib/firebase_options.dart
```

**Current `firebase_options.dart` already exists** with these platforms:
- Android
- iOS
- Web
- macOS
- Windows

---

## Security Rules

### Firestore Security Rules

⚠️ **CRITICAL**: Currently using test mode rules that allow all access. This MUST be changed before production.

#### Step 1: Update Firestore Rules

1. Go to **Firestore Database** → **Rules** tab
2. Replace with production-ready rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    function isValidAge(age) {
      return age is int && age >= 18 && age <= 100;
    }

    function hasRequiredFields(data) {
      return data.keys().hasAll([
        'email', 'name', 'age', 'gender',
        'photoUrls', 'prompts', 'isProfileComplete'
      ]);
    }

    // Users collection rules
    match /users/{userId} {

      // Anyone can read complete profiles (for discovery)
      allow read: if isSignedIn() &&
                     resource.data.isProfileComplete == true;

      // Users can read their own profile (even if incomplete)
      allow get: if isOwner(userId);

      // Users can create their own profile
      allow create: if isOwner(userId) &&
                       hasRequiredFields(request.resource.data) &&
                       isValidAge(request.resource.data.age) &&
                       request.resource.data.email == request.auth.token.email;

      // Users can update their own profile
      allow update: if isOwner(userId) &&
                       // Cannot change userId or email
                       request.resource.data.email == resource.data.email &&
                       // Age must be valid if changed
                       (!request.resource.data.keys().hasAny(['age']) ||
                        isValidAge(request.resource.data.age));

      // Users can delete their own profile
      allow delete: if isOwner(userId);
    }

    // Likes collection (TODO: implement)
    match /likes/{likeId} {
      allow read, write: if false;  // Not implemented yet
    }

    // Matches collection (TODO: implement)
    match /matches/{matchId} {
      allow read, write: if false;  // Not implemented yet
    }

    // Block all other collections
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click **"Publish"**

#### Step 2: Test Security Rules

Use Firebase Emulator Suite or Rules Playground:

1. Go to **Rules** tab → **Rules Playground**
2. Test scenarios:
   - Read other user's profile (should succeed if complete)
   - Update other user's profile (should fail)
   - Create profile with invalid age (should fail)

### Firebase Storage Security Rules

#### Step 1: Update Storage Rules

1. Go to **Storage** → **Rules** tab
2. Replace with production-ready rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isImage() {
      return request.resource.contentType.matches('image/.*');
    }

    function isUnder5MB() {
      return request.resource.size < 5 * 1024 * 1024;  // 5 MB limit
    }

    // User photos
    match /users/{userId}/photos/{photoName} {

      // Anyone can read photos (for profile display)
      allow read: if isSignedIn();

      // Users can upload their own photos
      allow create: if isOwner(userId) &&
                       isImage() &&
                       isUnder5MB();

      // Users can delete their own photos
      allow delete: if isOwner(userId);

      // Prevent updates (delete and re-create instead)
      allow update: if false;
    }

    // Block all other paths
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click **"Publish"**

**Security Rules Explained**:
- ✅ Anyone authenticated can view photos (required for discovery)
- ✅ Users can only upload to their own folder
- ✅ Max file size: 5 MB (prevents abuse)
- ✅ Only image files allowed
- ❌ Cannot upload to other users' folders
- ❌ Cannot upload non-image files

---

## Free Tier Limits & Billing

### Spark Plan (Free Tier)

**Firebase Authentication**:
- ✅ **Unlimited users**
- ✅ **Unlimited sign-ins**
- ✅ Email/password, Google, Apple, Phone auth included

**Cloud Firestore**:
- **Storage**: 1 GB
- **Document reads**: 50,000/day
- **Document writes**: 20,000/day
- **Document deletes**: 20,000/day
- **Network egress**: 10 GB/month

**Cloud Storage**:
- **Storage**: 5 GB
- **Downloads**: 1 GB/day
- **Uploads**: 1 GB/day

**Cloud Functions** (if used):
- **Invocations**: 125,000/month
- **GB-seconds**: 40,000/month
- **CPU-seconds**: 40,000/month

**Firebase Hosting** (if used):
- **Storage**: 10 GB
- **Bandwidth**: 360 MB/day

### Blaze Plan (Pay as you go)

**Firebase Authentication**:
- **Phone auth**: $0.01 per verification (after 10K/month free)
- Other methods: Free

**Cloud Firestore**:
- **Storage**: $0.18/GB/month (first 1 GB free)
- **Document reads**: $0.036 per 100,000 (after 50,000/day free)
- **Document writes**: $0.18 per 100,000 (after 20,000/day free)
- **Document deletes**: $0.02 per 100,000 (after 20,000/day free)
- **Network egress**: $0.12/GB (after 10 GB/month free)

**Cloud Storage**:
- **Storage**: $0.026/GB/month (after 5 GB free)
- **Downloads**: $0.12/GB (after 1 GB/day free)
- **Uploads**: $0.12/GB (after 1 GB/day free)
- **Operations**: $0.05 per 10,000 (Class A), $0.004 per 10,000 (Class B)

### Estimated Costs for Dating App

**Scenario 1: Small Scale (100 daily active users)**

Assumptions:
- 100 users online daily
- Each views 20 profiles/day
- 400 total profiles in database
- 4 photos per profile (2 MB each)

**Firestore**:
- Reads: 100 users × 20 profiles × 1 read = 2,000/day = 60,000/month
- Cost: Free (under 1.5M/month)

**Storage**:
- Storage: 400 users × 4 photos × 2 MB = 3.2 GB
- Cost: Free (under 5 GB)
- Downloads: 100 users × 20 profiles × 4 photos × 2 MB = 16 GB/day
- Cost: (16 GB - 1 GB free) × $0.12 = **$1.80/day** → **$54/month**

**Total: ~$54/month**

**Scenario 2: Medium Scale (1,000 daily active users)**

Assumptions:
- 1,000 users online daily
- Each views 30 profiles/day
- 5,000 total profiles
- 4 photos per profile (500 KB each, compressed)

**Firestore**:
- Reads: 1,000 × 30 = 30,000/day = 900,000/month
- Cost: Free (under 1.5M/month)

**Storage**:
- Storage: 5,000 × 4 × 0.5 MB = 10 GB
- Cost: (10 GB - 5 GB) × $0.026 = **$0.13/month**
- Downloads: 1,000 × 30 × 4 × 0.5 MB = 60 GB/day = 1.8 TB/month
- Cost: (1,800 GB - 30 GB free) × $0.12 = **$212/month**

**Total: ~$212/month**

**Scenario 3: Large Scale (10,000 daily active users)**

Assumptions:
- 10,000 users online daily
- Each views 40 profiles/day
- 50,000 total profiles
- 4 photos per profile (300 KB each, highly compressed)

**Firestore**:
- Reads: 10,000 × 40 = 400,000/day = 12M/month
- Cost: ((12M - 1.5M free) × $0.036) / 100,000 = **$3.78/month**
- Writes: 10,000 × 5 updates = 50,000/day = 1.5M/month
- Cost: Free (under 600K/month free tier)

**Storage**:
- Storage: 50,000 × 4 × 0.3 MB = 60 GB
- Cost: (60 GB - 5 GB) × $0.026 = **$1.43/month**
- Downloads: 10,000 × 40 × 4 × 0.3 MB = 480 GB/day = 14.4 TB/month
- Cost: (14,400 GB - 30 GB free) × $0.12 = **$1,724/month**

**Total: ~$1,729/month**

### Cost Optimization Strategies

1. **Image Compression**:
   - Compress to 300-500 KB per image (use flutter_image_compress)
   - Use WebP format instead of JPG (30-50% smaller)
   - Saves 50-70% on storage costs

2. **CDN Caching**:
   - Firebase Storage has built-in CDN
   - Set long cache headers (365 days for profile photos)
   - Reduces repeated downloads

3. **Lazy Loading**:
   - Only load images when user scrolls to them
   - Use CachedNetworkImage (already implemented)

4. **Pagination**:
   - Limit discovery queries to 20 profiles at a time
   - Load more only when needed

5. **Background Jobs**:
   - Use Cloud Functions to compress images after upload
   - Automatically resize to multiple sizes (thumbnail, medium, full)

### Setting Up Budget Alerts

1. Go to **Project Settings** → **Usage and billing**
2. Click **"Set budgets"**
3. Create alerts at:
   - $10 (early warning)
   - $50 (moderate usage)
   - $100 (high usage)
4. **Email alerts**: Add your email
5. **Budget actions**: No automatic actions (manual review recommended)

---

## Deleting Test Users (Development/Testing)

When testing the app or cleaning up test data, you need to delete users from **THREE** locations:

### Complete User Deletion Checklist

✅ **1. Firebase Authentication** (Login credentials)
✅ **2. Cloud Firestore** (User profile data)
✅ **3. Cloud Storage** (User photos)

### Step 1: Delete from Firebase Authentication

1. Go to [Firebase Console → Authentication → Users](https://console.firebase.google.com/project/no-ghost/authentication/users)
2. Find the test user by email
3. Click the **3-dots menu** (⋮) on the right
4. Select **"Delete account"**
5. Confirm deletion

⚠️ **Why this matters**: Even if you delete from Firestore, the user can still log in if their auth account exists. This causes a "black screen" error when the app expects profile data that doesn't exist.

### Step 2: Delete from Cloud Firestore

1. Go to [Firebase Console → Firestore Database](https://console.firebase.google.com/project/no-ghost/firestore)
2. Navigate to **users** collection
3. Find the user document (document ID = user's UID)
4. Click the document
5. Click the **3-dots menu** (⋮) → **"Delete document"**
6. Confirm deletion

**Bulk Delete** (for multiple test users):
```bash
# Using Firebase CLI (requires installation)
firebase firestore:delete users --all-collections --yes
```

### Step 3: Delete from Cloud Storage

1. Go to [Firebase Console → Storage](https://console.firebase.google.com/project/no-ghost/storage)
2. Navigate to **users/** folder
3. Find the user's folder: **users/{userId}/**
4. Click the **folder icon**
5. Click **"Delete folder"**
6. Confirm deletion

**Delete All User Folders** (complete reset for testing):
1. In Storage console
2. Select the entire **users/** folder
3. Click **"Delete folder"**
4. Confirm deletion
5. The folder will be recreated automatically when new users upload photos

### Common Deletion Scenarios

**Scenario 1: Testing Ghost Mode Feature**
```
Problem: Need to test fresh profile creation with ghost prompts
Solution:
1. Delete from Authentication (logout, then delete)
2. Delete from Firestore (remove profile data)
3. Delete from Storage (remove old photos)
4. Create new account with same or different email
```

**Scenario 2: "User already exists" error**
```
Problem: Deleted from Firestore but user still exists in Authentication
Solution:
1. Go to Authentication → Users
2. Find and delete the user account
3. Now you can create new account with same email
```

**Scenario 3: Black screen after login**
```
Problem: User exists in Authentication but NOT in Firestore
Solution:
1. Sign out from the app
2. Delete user from Authentication
3. Create fresh account
```

**Scenario 4: Old photos showing after profile deletion**
```
Problem: Deleted Firestore data but photos still in Storage
Solution:
1. Go to Storage → users/{userId}/photos/
2. Delete the entire photos folder
3. Or delete the entire user folder
```

### Automation Script (Optional)

For frequent testing, you can use Firebase CLI:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Delete specific user's Firestore data
firebase firestore:delete users/{USER_ID} --project no-ghost

# Delete user's Storage folder (requires Firebase Admin SDK)
# See: https://firebase.google.com/docs/storage/admin/delete-files
```

### Best Practices for Testing

1. **Use test email pattern**: `test+1@example.com`, `test+2@example.com`
   - Gmail ignores `+` suffix, all go to same inbox
   - Easy to identify test accounts

2. **Delete in order**:
   - First: Sign out from app
   - Second: Delete from Authentication
   - Third: Delete from Firestore
   - Fourth: Delete from Storage

3. **Clear app data** (alternative to deletion):
   - Android: Settings → Apps → No Ghost → Clear Data
   - iOS: Delete and reinstall app
   - This logs out user locally but doesn't delete Firebase data

4. **Use different emails** for different test scenarios:
   - `test-basic@example.com` - Test basic info only
   - `test-photos@example.com` - Test photo upload
   - `test-ghost@example.com` - Test ghost mode prompts

---

## Testing & Verification

### Step 1: Test Firebase Connection

```bash
# Run the app
flutter run

# Check console for Firebase initialization
# Should see: "Successfully initialized Firebase"
```

### Step 2: Test Authentication

1. **Email Sign-Up**:
   - Create account with email/password
   - Check Firebase Console → Authentication → Users
   - Verify user appears in list

2. **Google Sign-In**:
   - Tap "Continue with Google"
   - Select Google account
   - Check users list in Firebase Console

3. **Email Verification**:
   - Sign up with new email
   - Check email inbox for verification link
   - Click link, verify account

### Step 3: Test Firestore

1. **Create Profile**:
   - Complete profile setup (name, age, gender)
   - Add 3 photos
   - Answer 3 prompts

2. **Verify in Firestore**:
   - Go to Firestore Database
   - Check `users` collection
   - Find your user document
   - Verify fields: `isProfileComplete` should be `true`

### Step 4: Test Storage

1. **Upload Photos**:
   - Add photos in profile setup
   - Check progress indicators

2. **Verify in Storage**:
   - Go to Storage → Files
   - Navigate to `users/{your-uid}/photos/`
   - Verify images uploaded
   - Click to preview

3. **Test Image Loading**:
   - Go to Discovery screen
   - Images should load from Firebase Storage
   - Check for cached images (faster loading on re-view)

### Step 5: Test Security Rules

1. **Test Read Access**:
   ```bash
   # In app, try to view other profiles
   # Should work only if isProfileComplete == true
   ```

2. **Test Write Access**:
   ```bash
   # Try to modify your profile → Should work
   # Try to modify someone else's profile → Should fail
   ```

3. **Test Storage Access**:
   ```bash
   # Try to upload to your folder → Should work
   # Try to upload to someone else's folder → Should fail
   ```

### Debugging Firebase Issues

Enable Firebase debug logging:

```dart
// In lib/main.dart, add before runApp():
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

// Enable debug logging (development only)
FirebaseFirestore.setLoggingEnabled(true);
```

**Common Issues**:

1. **"Failed to initialize Firebase"**:
   - Check `google-services.json` / `GoogleService-Info.plist` exists
   - Verify package name matches Firebase Console
   - Run `flutter clean && flutter pub get`

2. **"PERMISSION_DENIED" in Firestore**:
   - Check security rules
   - Verify user is authenticated
   - Check required fields in document

3. **"Storage object not found"**:
   - Check file path matches: `users/{userId}/photos/`
   - Verify file uploaded successfully
   - Check Storage security rules

4. **Google Sign-In fails**:
   - Verify SHA-1 certificate added to Firebase
   - Check OAuth consent screen configured
   - Ensure `google-services.json` is latest version

---

## Troubleshooting

### Android Build Issues

**Error**: "google-services.json not found"
```bash
# Solution: Download and place file
cp ~/Downloads/google-services.json android/app/
flutter clean
flutter pub get
```

**Error**: "Duplicate class found" (multidex issue)
```kotlin
// In android/app/build.gradle.kts
android {
    defaultConfig {
        multiDexEnabled = true
    }
}
```

### iOS Build Issues

**Error**: "GoogleService-Info.plist not found"
```bash
# Solution: Re-add to Xcode project
# 1. Delete from Xcode (if exists)
# 2. Download fresh from Firebase
# 3. Drag into Xcode with "Copy items if needed" checked
```

**Error**: "URL schemes not configured"
```bash
# Solution: Add REVERSED_CLIENT_ID to Info.plist
# Check Firebase Setup Guide → iOS Setup → URL Schemes
```

### Firestore Issues

**Error**: "Missing or insufficient permissions"
```javascript
// Solution: Update security rules
// Go to Firestore → Rules
// Ensure user can read/write their own document
```

**Error**: "Index not found"
```bash
# Solution: Create composite index
# Click the error link in console
# It will auto-generate index in Firebase
```

### Storage Issues

**Error**: "File size exceeds maximum allowed size"
```dart
// Solution: Compress images before upload
import 'package:flutter_image_compress/flutter_image_compress.dart';

final compressed = await FlutterImageCompress.compressWithFile(
  file.path,
  quality: 70,  // 0-100
  minWidth: 1080,
  minHeight: 1920,
);
```

---

## Additional Resources

### Firebase Documentation
- [Firebase Console](https://console.firebase.google.com)
- [Firebase Docs](https://firebase.google.com/docs)
- [FlutterFire Docs](https://firebase.flutter.dev)
- [Firestore Data Model](https://firebase.google.com/docs/firestore/data-model)
- [Storage Security](https://firebase.google.com/docs/storage/security)

### Flutter Packages
- [firebase_core](https://pub.dev/packages/firebase_core)
- [firebase_auth](https://pub.dev/packages/firebase_auth)
- [cloud_firestore](https://pub.dev/packages/cloud_firestore)
- [firebase_storage](https://pub.dev/packages/firebase_storage)

### Support
- [FlutterFire GitHub Issues](https://github.com/firebase/flutterfire/issues)
- [Stack Overflow - Firebase](https://stackoverflow.com/questions/tagged/firebase)
- [Firebase Community](https://firebase.google.com/community)

---

## Checklist for Production Launch

- [ ] Enable Blaze plan with payment method
- [ ] Update Firestore security rules to production
- [ ] Update Storage security rules to production
- [ ] Configure budget alerts ($10, $50, $100)
- [ ] Add production SHA-1 certificate for Android
- [ ] Configure OAuth consent screen for production
- [ ] Test all authentication methods
- [ ] Test security rules thoroughly
- [ ] Enable Firebase App Check (bot protection)
- [ ] Set up Firebase Crashlytics
- [ ] Configure Firebase Performance Monitoring
- [ ] Set up Cloud Functions for image processing (if needed)
- [ ] Test billing with real usage
- [ ] Monitor quota usage daily for first week
- [ ] Set up backup strategy for Firestore
- [ ] Document all Firebase configuration for team

---

**Last Updated**: October 31, 2025

For questions or issues with Firebase setup, refer to this guide first. If issues persist, check the [Firebase Status Dashboard](https://status.firebase.google.com) or contact Firebase Support through the Firebase Console.