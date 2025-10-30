import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_service.dart';

// Provider for the AuthService singleton
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider that streams the authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Provider for the current user (null if not signed in)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((user) => user).value;
});

// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Provider for loading state during authentication operations
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for authentication error messages
final authErrorProvider = StateProvider<String?>((ref) => null);

// Authentication notifier for handling auth operations
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(const AsyncValue.loading()) {
    // Listen to auth state changes
    _authService.authStateChanges.listen(
      (user) => state = AsyncValue.data(user),
      onError: (error) => state = AsyncValue.error(error, StackTrace.current),
    );
  }

  // Sign up with email and password (enhanced with profile creation)
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      _ref.read(authErrorProvider.notifier).state = null;
      
      await _authService.signUpWithEmailAndCreateProfile(email, password);
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Sign in with email and password (ensures profile exists)
  Future<void> signInWithEmail(String email, String password) async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      _ref.read(authErrorProvider.notifier).state = null;
      
      final result = await _authService.signInWithEmail(email, password);
      
      // Ensure profile exists for existing users
      if (result?.user != null) {
        await _authService.createInitialProfile(result!.user!);
      }
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Sign in with Google (enhanced with profile creation)
  Future<void> signInWithGoogle() async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      _ref.read(authErrorProvider.notifier).state = null;
      
      await _authService.signInWithGoogleAndCreateProfile();
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Apple Sign In - COMMENTED OUT (Apple Developer membership required)
  /*
  Future<void> signInWithApple() async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      _ref.read(authErrorProvider.notifier).state = null;
      
      await _authService.signInWithApple();
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  */

  // Phone authentication - send verification code
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      _ref.read(authErrorProvider.notifier).state = null;
      
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _ref.read(authErrorProvider.notifier).state = e.message ?? 'Phone verification failed';
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verification ID for later use
          _ref.read(phoneVerificationIdProvider.notifier).state = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
      );
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Verify phone SMS code
  Future<void> verifyPhoneCode(String smsCode) async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      _ref.read(authErrorProvider.notifier).state = null;
      
      final verificationId = _ref.read(phoneVerificationIdProvider);
      if (verificationId == null) {
        throw 'No verification ID found. Please request a new code.';
      }
      
      await _authService.signInWithPhoneCode(verificationId, smsCode);
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      _ref.read(authErrorProvider.notifier).state = null;
      
      await _authService.resetPassword(email);
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      _ref.read(authErrorProvider.notifier).state = null;
      
      await _authService.signOut();
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      _ref.read(authErrorProvider.notifier).state = null;
      
      await _authService.deleteAccount();
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Clear error message
  void clearError() {
    _ref.read(authErrorProvider.notifier).state = null;
  }
}

// Provider for phone verification ID (used during phone auth)
final phoneVerificationIdProvider = StateProvider<String?>((ref) => null);

// Main auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});

// Convenient providers for common auth operations
final signUpWithEmailProvider = Provider<Future<void> Function(String, String)>((ref) {
  return ref.read(authNotifierProvider.notifier).signUpWithEmail;
});

final signInWithEmailProvider = Provider<Future<void> Function(String, String)>((ref) {
  return ref.read(authNotifierProvider.notifier).signInWithEmail;
});

final signInWithGoogleProvider = Provider<Future<void> Function()>((ref) {
  return ref.read(authNotifierProvider.notifier).signInWithGoogle;
});

final signOutProvider = Provider<Future<void> Function()>((ref) {
  return ref.read(authNotifierProvider.notifier).signOut;
});