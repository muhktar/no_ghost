import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../profile/providers/user_profile_provider.dart';

class ProfileSetupScreen extends HookConsumerWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Get real user profile data
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final photoCount = ref.watch(userPhotoUrlsProvider).length;
    final promptCount = ref.watch(userPromptsProvider).length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Setup Your Profile',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          userProfileAsync.when(
            data: (profile) => profile?.hasBasicInfo == true
              ? TextButton(
                  onPressed: () => context.go('/discovery'),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.lobster(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Your No Ghost Profile',
              style: GoogleFonts.lobster(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Upload at least ${AppConstants.minimumPhotoCount} photos and answer ${AppConstants.minimumPromptCount} prompts to get started.',
              style: GoogleFonts.lobster(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            
            const SizedBox(height: 32),

            // Basic Info Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Basic Info',
                        style: GoogleFonts.lobster(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      userProfileAsync.when(
                        data: (profile) => profile?.hasBasicInfo == true
                          ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                          : Icon(Icons.circle_outlined, color: Colors.grey, size: 20),
                        loading: () => SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => Icon(Icons.error, color: Colors.red, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your name, age, and other details',
                    style: GoogleFonts.lobster(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await context.push('/basic-info');
                      // Info will update automatically via provider
                    },
                    child: Text(
                      'Add Basic Info',
                      style: GoogleFonts.lobster(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Photo Upload Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.photo_camera,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Add Photos ($photoCount/6)',
                        style: GoogleFonts.lobster(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Show your authentic self with quality photos',
                    style: GoogleFonts.lobster(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  userProfileAsync.when(
                    data: (profile) => ElevatedButton(
                      onPressed: profile?.hasBasicInfo == true
                          ? () async {
                              await context.push('/add-photos');
                              // Photo count will update automatically via provider
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: profile?.hasBasicInfo == true
                            ? null
                            : Colors.grey[300],
                      ),
                      child: Text(
                        profile?.hasBasicInfo == true
                            ? 'Add Photos'
                            : 'Complete Basic Info First',
                        style: GoogleFonts.lobster(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    loading: () => ElevatedButton(
                      onPressed: null,
                      child: Text(
                        'Loading...',
                        style: GoogleFonts.lobster(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    error: (_, __) => ElevatedButton(
                      onPressed: null,
                      child: Text(
                        'Error',
                        style: GoogleFonts.lobster(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Prompts Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.quiz,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Answer Prompts ($promptCount/6)',
                        style: GoogleFonts.lobster(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your personality and interests',
                    style: GoogleFonts.lobster(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  userProfileAsync.when(
                    data: (profile) => ElevatedButton(
                      onPressed: profile?.hasBasicInfo == true
                          ? () async {
                              await context.push('/add-prompts');
                              // Prompt count will update automatically via provider
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: profile?.hasBasicInfo == true
                            ? null
                            : Colors.grey[300],
                      ),
                      child: Text(
                        profile?.hasBasicInfo == true
                            ? 'Answer Prompts'
                            : 'Complete Basic Info First',
                        style: GoogleFonts.lobster(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    loading: () => ElevatedButton(
                      onPressed: null,
                      child: Text(
                        'Loading...',
                        style: GoogleFonts.lobster(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    error: (_, __) => ElevatedButton(
                      onPressed: null,
                      child: Text(
                        'Error',
                        style: GoogleFonts.lobster(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Preview Profile Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/profile-preview'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Preview My Profile',
                      style: GoogleFonts.lobster(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/discovery'),
                child: Text(
                  'Start Discovering',
                  style: GoogleFonts.lobster(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}