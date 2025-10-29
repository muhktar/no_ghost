import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/user_profile.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../discovery/widgets/profile_card.dart';

final suggestedProfilesProvider = StreamProvider<List<UserProfile>>((ref) {
  final userProfileService = ref.watch(userProfileServiceProvider);
  return userProfileService.getSuggestedProfiles();
});

class SuggestionsScreen extends HookConsumerWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profilesAsync = ref.watch(suggestedProfilesProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Suggested For You',
          style: GoogleFonts.lobster(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: profilesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load suggestions',
                  style: GoogleFonts.lobster(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          data: (profiles) => profiles.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No suggestions yet',
                      style: GoogleFonts.lobster(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for curated matches!',
                      style: GoogleFonts.lobster(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return Container(
                    height: 500,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Stack(
                      children: [
                        // Profile Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ProfileCard(
                            profile: profile,
                            onPhotoTap: (photoIndex) {
                              // Handle photo tap
                            },
                          ),
                        ),
                        
                        // Suggestion Badge
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFB8860B),
                                  Color(0xFFDAA520),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Suggested',
                                  style: GoogleFonts.lobster(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Action Buttons
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            children: [
                              // Pass Button
                              Container(
                                width: 60,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _handlePass(ref, index);
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.black87,
                                    size: 22,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              // Connect Button
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFB8860B),
                                        Color(0xFFDAA520),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      _handleConnect(context, profile);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Connect',
                                      style: GoogleFonts.lobster(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: (index * 100).ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0);
                },
              ),
        ),
      ),
    );
  }
  
  void _handlePass(WidgetRef ref, int index) {
    // TODO: Implement pass functionality with Firestore
    // For now, just show feedback to user
    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile passed',
          style: GoogleFonts.lobster(fontSize: 12),
        ),
        backgroundColor: Colors.grey,
      ),
    );
  }
  
  void _handleConnect(BuildContext context, UserProfile profile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Connected with ${profile.name}!',
          style: GoogleFonts.lobster(fontSize: 12),
        ),
        backgroundColor: const Color(0xFFB8860B),
      ),
    );
  }
}