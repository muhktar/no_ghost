import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/models/user_profile.dart';
import '../../profile/providers/user_profile_provider.dart';
import 'views/discovery_carousel_view.dart';
import 'views/discovery_profile_view.dart';
import 'views/discovery_card_view.dart';

// Real Firestore profiles provider
final discoveryProfilesProvider = StreamProvider<List<UserProfile>>((ref) {
  final userProfileService = ref.watch(userProfileServiceProvider);
  return userProfileService.getDiscoveryProfiles();
});

final currentProfileIndexProvider = StateProvider<int>((ref) => 0);
final previousProfilesStackProvider = StateProvider<List<int>>((ref) => []);

enum DiscoveryViewMode {
  carousel,      // Current default view
  profilePreview, // Profile Preview page identical view
  custom         // Placeholder for third view
}

final discoveryViewModeProvider = StateProvider<DiscoveryViewMode>((ref) => DiscoveryViewMode.carousel);

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profilesAsync = ref.watch(discoveryProfilesProvider);
    final currentIndex = ref.watch(currentProfileIndexProvider);
    final viewMode = ref.watch(discoveryViewModeProvider);

    return profilesAsync.when(
      loading: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Finding amazing people for you...',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
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
                'Something went wrong',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please try again later',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (profiles) {
        // Handle empty profiles
        if (profiles.isEmpty || currentIndex >= profiles.length) {
          final previousStack = ref.watch(previousProfilesStackProvider);

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // Back button at top when there are previous profiles
                  if (previousStack.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _handlePreviousProfile(ref),
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Go back to previous profile',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Centered no more profiles message
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_outline,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No more profiles',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for new connections!',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (previousStack.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _handlePreviousProfile(ref),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('View Previous'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final currentProfile = profiles[currentIndex];

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: _buildViewContent(viewMode, currentProfile, ref, context),
          ),
        );
      },
    );
  }

  void _handlePreviousProfile(WidgetRef ref) {
    final previousStack = ref.read(previousProfilesStackProvider);
    if (previousStack.isNotEmpty) {
      final previousIndex = previousStack.last;
      ref.read(previousProfilesStackProvider.notifier).state =
          previousStack.sublist(0, previousStack.length - 1);
      ref.read(currentProfileIndexProvider.notifier).state = previousIndex;
    }
  }


  Widget _buildViewContent(
    DiscoveryViewMode viewMode,
    UserProfile currentProfile,
    WidgetRef ref,
    BuildContext context,
  ) {
    switch (viewMode) {
      case DiscoveryViewMode.carousel:
        return DiscoveryCarouselView(profile: currentProfile);
      case DiscoveryViewMode.profilePreview:
        return DiscoveryProfileView(profile: currentProfile, ref: ref);
      case DiscoveryViewMode.custom:
        return DiscoveryCardView(profile: currentProfile, ref: ref);
    }
  }
}