import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Commented out - Apple Developer membership required
import '../../profile/data/user_profile_service.dart';
import '../../../shared/models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Add debug configuration
    scopes: ['email', 'profile'],
  );
  final UserProfileService _profileService = UserProfileService();

  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state stream - listens for login/logout changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Sign Up
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send email verification
      await credential.user?.sendEmailVerification();
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Email/Password Sign In
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      
      // Check if already signed in
      final currentGoogleUser = _googleSignIn.currentUser;
      
      // Sign out first to ensure fresh sign-in
      if (currentGoogleUser != null) {
        await _googleSignIn.signOut();
      }
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      
      // If user cancels the sign-in
      if (googleUser == null) {
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;


      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final result = await _auth.signInWithCredential(credential);
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw 'Failed to sign in with Google. Please try again.';
    }
  }

  // Apple Sign In - COMMENTED OUT (Apple Developer membership required)
  /*
  Future<UserCredential?> signInWithApple() async {
    try {
      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuth credential from the Apple credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple OAuth credential
      return await _auth.signInWithCredential(oauthCredential);
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw 'Failed to sign in with Apple. Please try again.';
    }
  }
  */

  // Phone Authentication (Step 1: Send verification code)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60), // Timeout after 60 seconds
      );
    } catch (e) {
      throw 'Failed to verify phone number. Please try again.';
    }
  }

  // Phone Authentication (Step 2: Verify SMS code)
  Future<UserCredential?> signInWithPhoneCode(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw 'Invalid verification code. Please try again.';
    }
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      await _googleSignIn.signOut();
      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Profile Management Methods
  
  // Get user profile (returns null if doesn't exist)
  Future<UserProfile?> getUserProfile() async {
    return await _profileService.getCurrentUserProfile();
  }

  // Check if user has completed profile setup
  Future<bool> isProfileComplete() async {
    final profile = await getUserProfile();
    return profile?.isProfileComplete ?? false;
  }

  // Get profile completion status
  Future<ProfileCompletionStatus> getProfileCompletionStatus() async {
    final profile = await getUserProfile();
    return profile?.completionStatus ?? ProfileCompletionStatus.notStarted;
  }

  // Create initial profile for new user (called after successful authentication)
  Future<bool> createInitialProfile(User user) async {
    try {
      // Check if profile already exists
      final existingProfile = await _profileService.getCurrentUserProfile();
      if (existingProfile != null) {
        return true; // Profile already exists
      }

      // Create new profile
      return await _profileService.createUserProfile(user);
    } catch (e) {
      return false;
    }
  }

  // Enhanced sign up with profile creation
  Future<UserCredential?> signUpWithEmailAndCreateProfile(String email, String password) async {
    try {
      final credential = await signUpWithEmail(email, password);
      if (credential?.user != null) {
        await createInitialProfile(credential!.user!);
      }
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Enhanced Google sign in with profile creation
  Future<UserCredential?> signInWithGoogleAndCreateProfile() async {
    try {
      final credential = await signInWithGoogle();
      if (credential?.user != null) {
        await createInitialProfile(credential!.user!);
      }
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to determine where user should be routed after login
  Future<String> getPostLoginRoute() async {
    final user = currentUser;
    if (user == null) {
      return '/welcome';
    }

    try {
      // Add a small delay to ensure Firestore operations have completed
      await Future.delayed(const Duration(milliseconds: 500));

      final profile = await getUserProfile();

      if (profile == null) {
        // No profile exists, create one and go to setup
        await createInitialProfile(user);
        return '/profile-setup';
      }

      // Profile exists, check completion status

      final status = profile.completionStatus;
      final route = switch (status) {
        ProfileCompletionStatus.complete => '/discovery', // Complete profile -> main app
        ProfileCompletionStatus.notStarted ||
        ProfileCompletionStatus.photosOnly ||
        ProfileCompletionStatus.promptsOnly => '/profile-setup', // Incomplete profile -> setup
      };

      return route;
    } catch (e) {
      return '/profile-setup'; // Default to setup on error
    }
  }

  // Delete User Account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw 'Failed to delete account. Please try again.';
    }
  }

  // Helper method to convert Firebase auth errors to user-friendly messages
  String _getAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'user-not-found':
        return 'No user found with that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}