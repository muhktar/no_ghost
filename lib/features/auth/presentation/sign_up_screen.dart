import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({super.key});

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
      next.whenData((user) async {
        if (user != null) {
          try {
            // Add small delay to prevent Navigator concurrent access
            await Future.delayed(const Duration(milliseconds: 100));

            // Use the smart routing logic from AuthService
            final authService = ref.read(authServiceProvider);
            final route = await authService.getPostLoginRoute();

            // Use WidgetsBinding to ensure navigation happens on next frame
            if (context.mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go(route);
                }
              });
            } else {
            }
          } catch (e) {
            if (context.mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go('/profile-setup'); // Default fallback
                }
              });
            }
          }
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
          'Sign Up',
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
                'Join the Anti-Ghosting Revolution',
                style: GoogleFonts.lobster(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 8),
              
              Text(
                'Choose your preferred sign-up method to start making meaningful connections.',
                style: GoogleFonts.lobster(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ).animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 40),
              
              // Sign up options
              _buildSignUpButton(
                context,
                icon: Icons.phone,
                iconColor: Colors.green, // Green for phone/SMS
                title: 'Continue with Phone Number',
                subtitle: 'Verify with SMS',
                isLoading: isLoading,
                onTap: () async {
                  // TODO: Implement phone number input dialog
                  _showPhoneNumberDialog(context, ref);
                },
              ).animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
              
              const SizedBox(height: 16),
              
              _buildSignUpButton(
                context,
                icon: Icons.email,
                iconColor: Colors.red, // Red for email
                title: 'Continue with Email',
                subtitle: 'Traditional email signup',
                isLoading: isLoading,
                onTap: () async {
                  _showEmailSignUpDialog(context, ref);
                },
              ).animate()
                .fadeIn(delay: 500.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
              
              const SizedBox(height: 16),
              
              _buildSignUpButton(
                context,
                icon: Icons.g_mobiledata,
                iconColor: const Color(0xFF4285F4), // Google blue
                title: 'Continue with Google',
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
              
              _buildSignUpButton(
                context,
                icon: Icons.apple,
                iconColor: Colors.black, // Black for Apple
                title: 'Continue with Apple',
                subtitle: 'Coming soon - Apple membership required',
                isLoading: false, // Always disabled for now
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
              
              // Anti-ghosting reminder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Remember: All messages require 4+ words and 2-hour response window!',
                        style: GoogleFonts.lobster(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
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

  Widget _buildSignUpButton(
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
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
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
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.lobster(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                        theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : Icon(
                    Icons.arrow_forward_ios,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 16,
                  ),
          ],
        ),
      ),
    );
  }

  // Email Sign Up Dialog
  void _showEmailSignUpDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final authNotifier = ref.read(authNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Up with Email',
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
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
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
              if (passwordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              
              if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              try {
                await authNotifier.signUpWithEmail(
                  emailController.text,
                  passwordController.text,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                // Error handling is done in the provider listener
              }
            },
            child: Text(
              'Sign Up',
              style: GoogleFonts.lobster(),
            ),
          ),
        ],
      ),
    );
  }

  // Phone Number Dialog
  void _showPhoneNumberDialog(BuildContext context, WidgetRef ref) {
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
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _showVerificationCodeDialog(context, ref);
                }
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

  // Verification Code Dialog
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
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
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
}