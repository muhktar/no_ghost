import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      // Check authentication status and navigate accordingly
      Future.delayed(const Duration(milliseconds: 3000), () async {
        final authService = ref.read(authServiceProvider);
        final user = authService.currentUser;

        if (user != null) {
          // User is already logged in, determine where to route them
          final route = await authService.getPostLoginRoute();
          if (context.mounted) {
            context.go(route);
          }
        } else {
          // No user logged in, go to welcome
          if (context.mounted) {
            context.go('/welcome');
          }
        }
      });

      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.white, // White background for black and white theme
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // No Ghost Logo with Grey Shadow and Slam Down Effect
              Container(
                width: 160, // Bigger logo
                height: 160, // Bigger logo
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80), // Circular (half of 160)
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withValues(alpha: 0.2),
                  //     blurRadius: 15,
                  //     offset: const Offset(0, 5),
                  //   ),
                  // ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(80), // Circular (half of 160)
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/images/No_Ghosts _logo.png',
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ).animate()
                // Arch trajectory - combine vertical drop with horizontal curve
                .slideY(
                  begin: -10.0, // Start higher above screen
                  end: 0.0,
                  duration: 1200.ms, // Much slower fall
                  curve: Curves.easeIn, // Accelerate like gravity
                )
                .slideX(
                  begin: 2.0, // Start from right corner of screen
                  end: 0.0, // End centered (creates arch effect)
                  duration: 1200.ms,
                  curve: Curves.easeOut, // Slow horizontal curve
                )
                .scale(
                  begin: const Offset(0.6, 0.6), // Start much smaller
                  end: const Offset(1.4, 1.4), // Bigger overshoot on impact
                  duration: 1200.ms,
                  curve: Curves.easeIn,
                )
                .then() // Impact compression
                .scale(
                  begin: const Offset(1.4, 1.4),
                  end: const Offset(0.9, 0.9), // More dramatic compression
                  duration: 150.ms,
                  curve: Curves.easeOut,
                )
                .then() // Elastic settle
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),

              const SizedBox(height: 40),

              // App Name
              Text(
                'No Ghost',
                style: GoogleFonts.lobster(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              // Tagline with fade-in effect
              Text(
                AppConstants.appSlogan,
                style: GoogleFonts.lobster(
                  fontSize: 16,
                  color: Colors.black.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ).animate()
                .fadeIn(
                  delay: 1750.ms, // Start fade after logo settles (1200+150+400=1750ms)
                  duration: 800.ms,
                  curve: Curves.easeOut,
                ),

              const SizedBox(height: 20),

              // Loading indicator
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ).animate()
            .shake(
              delay: 1200.ms, // Shake when logo lands (after fall duration)
              duration: 300.ms,
              hz: 20, // Frequency of shake
              offset: const Offset(3, 2), // Shake intensity
            ),
        ),
      ),
    );
  }
}