import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';

class WelcomeScreen extends HookConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pageController = usePageController();
    final currentPage = useState(0);
    
    // Auto-rotate every 5 seconds
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (pageController.hasClients) {
          final nextPage = (currentPage.value + 1) % 4; // 4 pages total
          pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
      
      return () => timer.cancel();
    }, []);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Logo and Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        AppConstants.logoPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.8, 0.8), duration: 800.ms),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    AppConstants.appName,
                    style: GoogleFonts.lobster(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ).animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    AppConstants.appSlogan,
                    style: GoogleFonts.lobster(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                    .fadeIn(delay: 500.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                ],
              ),
            ),
            
            // Feature Carousel with Auto-rotation
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (page) {
                  currentPage.value = page;
                },
                children: [
                  _buildFeaturePage(
                    context,
                    icon: Icons.schedule,
                    title: 'No More Ghosting',
                    description: 'Every message gets a 2-hour response window. No response? Auto-unmatch. Keep conversations active and meaningful.',
                    color: theme.colorScheme.primary,
                  ),
                  _buildFeaturePage(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: 'Quality Conversations',
                    description: 'Every message must be at least 4 words. Say goodbye to "hey" and "ok" - promote thoughtful communication.',
                    color: Colors.green,
                  ),
                  _buildFeaturePage(
                    context,
                    icon: Icons.lock_outlined,
                    title: 'Lock-In Feature',
                    description: 'Show serious interest with our premium Lock-In. Let them know you\'re genuinely interested in connecting.',
                    color: const Color(0xFFFF6B6B),
                  ),
                  _buildFeaturePage(
                    context,
                    icon: Icons.access_time,
                    title: 'Premium Flexibility',
                    description: 'Busy schedule? Upgrade to 4, 6, or 8-hour response windows while maintaining accountability.',
                    color: Colors.amber,
                  ),
                ],
              ),
            ),
            
            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: currentPage.value == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: currentPage.value == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ).animate()
                    .scale(
                      duration: 300.ms,
                      curve: Curves.easeInOut,
                    );
                }),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/signup'),
                      child: const Text('Get Started'),
                    ),
                  ).animate()
                    .fadeIn(delay: 700.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push('/login'),
                      child: const Text('I Already Have an Account'),
                    ),
                  ).animate()
                    .fadeIn(delay: 800.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: GoogleFonts.lobster(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                    .fadeIn(delay: 900.ms, duration: 600.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePage(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              size: 50,
              color: color,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            title,
            style: GoogleFonts.lobster(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            description,
            style: GoogleFonts.lobster(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}