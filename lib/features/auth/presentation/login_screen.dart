import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isLoading = ref.watch(authLoadingProvider);

    // Show error snackbar when there's an auth error
    ref.listen(authErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        // Clear error after showing
        Future.delayed(const Duration(seconds: 3), () {
          authNotifier.clearError();
        });
      }
    });

    // Navigate based on profile completion status when user is authenticated
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // Use the smart routing logic from AuthService
          final authService = ref.read(authServiceProvider);
          authService.getPostLoginRoute().then((route) {
            if (context.mounted) {
              context.go(route);
            }
          });
        }
      });
    });
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Log In',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back!',
                style: GoogleFonts.lobster(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 8),
              
              Text(
                'Log in to continue your anti-ghosting journey and connect with meaningful people.',
                style: GoogleFonts.lobster(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ).animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 40),
              
              // Login options
              _buildLoginButton(
                context,
                icon: Icons.phone,
                iconColor: Colors.green,
                title: 'Log in with Phone Number',
                subtitle: 'Use your registered phone',
                isLoading: isLoading,
                onTap: () async {
                  _showPhoneLoginDialog(context, ref);
                },
              ).animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
              
              const SizedBox(height: 16),
              
              _buildLoginButton(
                context,
                icon: Icons.email,
                iconColor: Colors.red,
                title: 'Log in with Email',
                subtitle: 'Use your registered email',
                isLoading: isLoading,
                onTap: () async {
                  _showEmailLoginDialog(context, ref);
                },
              ).animate()
                .fadeIn(delay: 500.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
              
              const SizedBox(height: 16),
              
              _buildLoginButton(
                context,
                icon: Icons.g_mobiledata,
                iconColor: const Color(0xFF4285F4),
                title: 'Log in with Google',
                subtitle: 'Quick and secure',
                isLoading: isLoading,
                onTap: () async {
                  try {
                    await authNotifier.signInWithGoogle();
                  } catch (e) {
                    // Error handling is done in the provider listener
                  }
                },
              ).animate()
                .fadeIn(delay: 600.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
              
              const SizedBox(height: 16),
              
              _buildLoginButton(
                context,
                icon: Icons.apple,
                iconColor: Colors.black,
                title: 'Log in with Apple',
                subtitle: 'Coming soon - Apple membership required',
                isLoading: false, // Always disabled
                onTap: () async {
                  // Apple Sign-In temporarily disabled (requires Apple Developer membership)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Apple Sign-In coming soon! Apple Developer membership required.',
                        style: GoogleFonts.lobster(fontSize: 12),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                },
              ).animate()
                .fadeIn(delay: 700.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
              
              const Spacer(),
              
              // New user prompt
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'New to No Ghost? ',
                        style: GoogleFonts.lobster(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/signup'),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.lobster(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(delay: 800.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Future<void> Function() onTap,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lobster(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.lobster(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                  )
                : Icon(
                    Icons.arrow_forward_ios,
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                    size: 16,
                  ),
          ],
        ),
      ),
    );
  }

  // Email Login Dialog
  void _showEmailLoginDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final authNotifier = ref.read(authNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Log In with Email',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showForgotPasswordDialog(context, ref);
                },
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.lobster(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.lobster(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              try {
                await authNotifier.signInWithEmail(
                  emailController.text,
                  passwordController.text,
                );
                Navigator.of(context).pop();
              } catch (e) {
                // Error handling is done in the provider listener
              }
            },
            child: Text(
              'Log In',
              style: GoogleFonts.lobster(),
            ),
          ),
        ],
      ),
    );
  }

  // Phone Login Dialog (same as sign up)
  void _showPhoneLoginDialog(BuildContext context, WidgetRef ref) {
    final phoneController = TextEditingController();
    final authNotifier = ref.read(authNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Enter Phone Number',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: '+1234567890',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.lobster(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a phone number')),
                );
                return;
              }

              try {
                await authNotifier.verifyPhoneNumber(phoneController.text);
                Navigator.of(context).pop();
                _showVerificationCodeDialog(context, ref);
              } catch (e) {
                // Error handling is done in the provider listener
              }
            },
            child: Text(
              'Send Code',
              style: GoogleFonts.lobster(),
            ),
          ),
        ],
      ),
    );
  }

  // Verification Code Dialog (same as sign up)
  void _showVerificationCodeDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();
    final authNotifier = ref.read(authNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Enter Verification Code',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'Verification Code',
            hintText: '123456',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.lobster(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (codeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter the verification code')),
                );
                return;
              }

              try {
                await authNotifier.verifyPhoneCode(codeController.text);
                Navigator.of(context).pop();
              } catch (e) {
                // Error handling is done in the provider listener
              }
            },
            child: Text(
              'Verify',
              style: GoogleFonts.lobster(),
            ),
          ),
        ],
      ),
    );
  }

  // Forgot Password Dialog
  void _showForgotPasswordDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final authNotifier = ref.read(authNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email address',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.lobster(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your email')),
                );
                return;
              }

              try {
                await authNotifier.resetPassword(emailController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Password reset email sent! Check your inbox.',
                      style: GoogleFonts.lobster(fontSize: 12),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                // Error handling is done in the provider listener
              }
            },
            child: Text(
              'Send Reset Email',
              style: GoogleFonts.lobster(),
            ),
          ),
        ],
      ),
    );
  }
}