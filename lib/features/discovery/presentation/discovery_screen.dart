import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../shared/models/user_profile.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../widgets/profile_card.dart';
import '../widgets/action_buttons.dart';
import '../widgets/lock_in_dialog.dart';

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

class DiscoveryScreen extends HookConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profilesAsync = ref.watch(discoveryProfilesProvider);
    final currentIndex = ref.watch(currentProfileIndexProvider);
    final viewMode = ref.watch(discoveryViewModeProvider);
    final pageController = usePageController();
    
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
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                              color: Colors.white.withOpacity(0.9),
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
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
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

  void _handleSkip(WidgetRef ref) {
    _moveToNextProfile(ref);
  }

  void _showConnectDialog(WidgetRef ref, UserProfile profile, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConnectBottomSheet(profile: profile),
    );
  }

  void _handleLockIn(WidgetRef ref, UserProfile profile, BuildContext context) {
    // Show Lock-In dialog
    showDialog(
      context: context,
      builder: (context) => LockInDialog(profile: profile),
    );
  }

  void _moveToNextProfile(WidgetRef ref) {
    final currentIndex = ref.read(currentProfileIndexProvider);
    final profilesAsync = ref.read(discoveryProfilesProvider);

    // Add current index to previous stack
    final previousStack = ref.read(previousProfilesStackProvider);
    ref.read(previousProfilesStackProvider.notifier).state =
        [...previousStack, currentIndex];

    // Move to next profile
    profilesAsync.whenData((profiles) {
      if (currentIndex < profiles.length - 1) {
        ref.read(currentProfileIndexProvider.notifier).state = currentIndex + 1;
      } else {
        // No more profiles - reset index to show empty state
        ref.read(currentProfileIndexProvider.notifier).state = profiles.length;
      }
    });
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildViewContent(
    DiscoveryViewMode viewMode,
    UserProfile currentProfile,
    WidgetRef ref,
    BuildContext context,
  ) {
    switch (viewMode) {
      case DiscoveryViewMode.carousel:
        return _buildCarouselView(currentProfile, ref, context);
      case DiscoveryViewMode.profilePreview:
        return _buildProfilePreviewView(currentProfile, ref, context);
      case DiscoveryViewMode.custom:
        return _buildCustomView(currentProfile, ref, context);
    }
  }

  Widget _buildCarouselView(UserProfile currentProfile, WidgetRef ref, BuildContext context) {
    final viewMode = ref.watch(discoveryViewModeProvider);
    return Stack(
      children: [
        // Main Profile Card (full screen - no borders)
        Positioned.fill(
          child: ProfileCard(
            profile: currentProfile,
            onPhotoTap: (index) {
              // Handle photo tap for carousel navigation
            },
          ).animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.95, 0.95), duration: 400.ms),
        ),

        // Top Bar (overlaid on card)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button (rectangular with rounded edges)
                Container(
                  width: 44,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
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

                // View Toggle Button (center)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildViewToggleButton(
                        icon: Icons.view_carousel,
                        isSelected: viewMode == DiscoveryViewMode.carousel,
                        onTap: () => ref.read(discoveryViewModeProvider.notifier).state = DiscoveryViewMode.carousel,
                      ),
                      _buildViewToggleButton(
                        icon: Icons.person,
                        isSelected: viewMode == DiscoveryViewMode.profilePreview,
                        onTap: () => ref.read(discoveryViewModeProvider.notifier).state = DiscoveryViewMode.profilePreview,
                      ),
                      _buildViewToggleButton(
                        icon: Icons.grid_view,
                        isSelected: viewMode == DiscoveryViewMode.custom,
                        onTap: () => ref.read(discoveryViewModeProvider.notifier).state = DiscoveryViewMode.custom,
                      ),
                    ],
                  ),
                ),

                // Name and age button (rectangular with rounded edges) - moved to right
                GestureDetector(
                  onTap: () => _handleSkip(ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${currentProfile.name}, ${currentProfile.age}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Action Buttons (matching reference design)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                // Skip/X Button (rectangular with rounded edges)
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
                    onPressed: () => _handleSkip(ref),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black87,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),

                const SizedBox(width: 12),

                // Connect Button (rectangular with rounded edges)
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      onPressed: () => _showConnectDialog(ref, currentProfile, context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Connect',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePreviewView(UserProfile currentProfile, WidgetRef ref, BuildContext context) {
    final viewMode = ref.watch(discoveryViewModeProvider);
    return Column(
      children: [
        // Top Bar with view toggle (not overlaid)
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Button
              Container(
                width: 44,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
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

              // View Toggle Button (center)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewToggleButton(
                      icon: Icons.view_carousel,
                      isSelected: viewMode == DiscoveryViewMode.carousel,
                      onTap: () => ref.read(discoveryViewModeProvider.notifier).state = DiscoveryViewMode.carousel,
                    ),
                    _buildViewToggleButton(
                      icon: Icons.person,
                      isSelected: viewMode == DiscoveryViewMode.profilePreview,
                      onTap: () => ref.read(discoveryViewModeProvider.notifier).state = DiscoveryViewMode.profilePreview,
                    ),
                    _buildViewToggleButton(
                      icon: Icons.grid_view,
                      isSelected: viewMode == DiscoveryViewMode.custom,
                      onTap: () => ref.read(discoveryViewModeProvider.notifier).state = DiscoveryViewMode.custom,
                    ),
                  ],
                ),
              ),

              // Connect Button
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () => _showConnectDialog(ref, currentProfile, context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'Connect',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile content below the top bar
        Expanded(
          child: _DiscoveryProfilePreview(profile: currentProfile, ref: ref),
        ),
      ],
    );
  }

  Widget _buildCustomView(UserProfile currentProfile, WidgetRef ref, BuildContext context) {
    final viewMode = ref.watch(discoveryViewModeProvider);
    return Column(
      children: [
        // Top Bar with view toggle (not overlaid)
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Button
              Container(
                width: 44,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
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

              // View Toggle Button (center)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewToggleButton(
                      icon: Icons.view_carousel,
                      isSelected: viewMode == DiscoveryViewMode.carousel,
                      onTap: () => ref.read(discoveryViewModeProvider.notifier).state = DiscoveryViewMode.carousel,
                    ),
                    _buildViewToggleButton(
                      icon: Icons.person,
                      isSelected: viewMode == DiscoveryViewMode.profilePreview,
                      onTap: () => ref.read(discoveryViewModeProvider.notifier).state = DiscoveryViewMode.profilePreview,
                    ),
                    _buildViewToggleButton(
                      icon: Icons.grid_view,
                      isSelected: viewMode == DiscoveryViewMode.custom,
                      onTap: () => ref.read(discoveryViewModeProvider.notifier).state = DiscoveryViewMode.custom,
                    ),
                  ],
                ),
              ),

              // Connect Button
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () => _showConnectDialog(ref, currentProfile, context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'Connect',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile content below the top bar
        Expanded(
          child: _DiscoveryCardView(profile: currentProfile, ref: ref),
        ),
      ],
    );
  }
}

class _DiscoveryProfilePreview extends HookWidget {
  final UserProfile profile;
  final WidgetRef ref;

  const _DiscoveryProfilePreview({
    required this.profile,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final currentPhotoIndex = useState(0);
    final hasPhotos = profile.photoUrls.isNotEmpty;
    final hasPrompts = profile.prompts.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Photo carousel section
          Container(
            height: 500,
            child: hasPhotos
                ? Stack(
                    children: [
                      CarouselSlider.builder(
                        itemCount: profile.photoUrls.length,
                        itemBuilder: (context, index, realIndex) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              profile.photoUrls[index],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: 500,
                          viewportFraction: 0.85,
                          enableInfiniteScroll: profile.photoUrls.length > 1,
                          autoPlay: false,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            currentPhotoIndex.value = index;
                          },
                        ),
                      ),

                      // Photo indicators
                      if (profile.photoUrls.length > 1)
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: profile.photoUrls.asMap().entries.map((entry) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currentPhotoIndex.value == entry.key
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      // Photo count indicator
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${currentPhotoIndex.value + 1}/${profile.photoUrls.length}',
                            style: GoogleFonts.lobster(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    height: 500,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Photos Added',
                          style: GoogleFonts.lobster(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 24),

          // Profile info section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and basic info
                Row(
                  children: [
                    Text(
                      profile.name ?? 'No Name',
                      style: GoogleFonts.lobster(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (profile.age != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${profile.age}',
                        style: GoogleFonts.lobster(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                // Location and occupation
                if (profile.location != null || profile.occupation != null)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (profile.occupation != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.work_outline,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    profile.occupation!,
                                    style: GoogleFonts.lobster(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            if (profile.location != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    profile.location!,
                                    style: GoogleFonts.lobster(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Next profile button (X symbol)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              final currentIndex = ref.read(currentProfileIndexProvider);
                              final profilesAsync = ref.read(discoveryProfilesProvider);

                              // Add current index to previous stack
                              final previousStack = ref.read(previousProfilesStackProvider);
                              ref.read(previousProfilesStackProvider.notifier).state =
                                  [...previousStack, currentIndex];

                              // Move to next profile
                              profilesAsync.whenData((profiles) {
                                if (currentIndex < profiles.length - 1) {
                                  ref.read(currentProfileIndexProvider.notifier).state = currentIndex + 1;
                                } else {
                                  // No more profiles - reset index to show empty state
                                  ref.read(currentProfileIndexProvider.notifier).state = profiles.length;
                                }
                              });
                            },
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 16),

                // Bio section
                if (profile.bio != null && profile.bio!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200]!,
                      ),
                    ),
                    child: Text(
                      profile.bio!,
                      style: GoogleFonts.lobster(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ).animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 24),

                // Prompts section
                if (hasPrompts) ...[
                  Text(
                    'About Me',
                    style: GoogleFonts.lobster(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ).animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  ...profile.prompts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final prompt = entry.value;
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prompt.question,
                            style: GoogleFonts.lobster(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prompt.answer,
                            style: GoogleFonts.lobster(
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.9),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(delay: (800 + index * 100).ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0);
                  }).toList(),
                ] else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        style: BorderStyle.solid,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Prompts Added',
                          style: GoogleFonts.lobster(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 80), // Extra space for action buttons
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConnectBottomSheet extends StatefulWidget {
  final UserProfile profile;
  
  const ConnectBottomSheet({super.key, required this.profile});

  @override
  State<ConnectBottomSheet> createState() => _ConnectBottomSheetState();
}

class _ConnectBottomSheetState extends State<ConnectBottomSheet> {
  final TextEditingController _messageController = TextEditingController();
  bool _showLockInOption = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Connect with ${widget.profile.name}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Send a message to start the conversation',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Message input
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your message here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Lock-In Option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFB8860B), // Golden beige
                    Color(0xFFDAA520), // Light golden beige
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_open,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lock-In Super Like',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Stand out and get noticed first!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _showLockInOption,
                    onChanged: (value) {
                      setState(() {
                        _showLockInOption = value;
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_messageController.text.trim().split(' ').length < 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Message must be at least 4 words long'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _showLockInOption 
                                ? 'Lock-In sent to ${widget.profile.name}!' 
                                : 'Message sent to ${widget.profile.name}!'
                          ),
                          backgroundColor: _showLockInOption 
                              ? const Color(0xFFB8860B) // Golden beige
                              : theme.colorScheme.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showLockInOption 
                          ? const Color(0xFFB8860B) // Golden beige
                          : theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _showLockInOption ? 'Send Lock-In' : 'Send Message',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryCardView extends HookWidget {
  final UserProfile profile;
  final WidgetRef ref;

  const _DiscoveryCardView({
    required this.profile,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    // Create alternating list of photos and prompts
    final List<Widget> contentItems = [];

    final maxItems = profile.photoUrls.length > profile.prompts.length
        ? profile.photoUrls.length
        : profile.prompts.length;

    for (int i = 0; i < maxItems * 2; i++) {
      if (i % 2 == 0) {
        // Even index: add photo if available
        final photoIndex = i ~/ 2;
        if (photoIndex < profile.photoUrls.length) {
          contentItems.add(_buildPhotoCard(profile.photoUrls[photoIndex], photoIndex, context));
        }
      } else {
        // Odd index: add prompt if available
        final promptIndex = i ~/ 2;
        if (promptIndex < profile.prompts.length) {
          contentItems.add(_buildPromptCard(profile.prompts[promptIndex], promptIndex, context));
        }
      }
    }

    // If no content, show placeholder
    if (contentItems.isEmpty) {
      contentItems.add(_buildEmptyCard(context));
    }

    return ListView.separated(
      scrollDirection: Axis.vertical,
      itemCount: contentItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: contentItems[index],
        );
      },
    );
  }

  Widget _buildPhotoCard(String photoUrl, int photoIndex, BuildContext context) {
    return Container(
      height: 700,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Photo
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  // X (Skip) button
                  GestureDetector(
                    onTap: () => _handleSkipProfile(context),
                    child: Container(
                      width: 60,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Connect button (wider with heart and message icons)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleConnectFromPhoto(photoIndex, context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite_outline,
                              size: 20,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.message_outlined,
                              size: 20,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Connect',
                              style: GoogleFonts.lobster(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Photo indicator
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Photo ${photoIndex + 1}',
                  style: GoogleFonts.lobster(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptCard(dynamic prompt, int promptIndex, BuildContext context) {
    return IntrinsicHeight(
      child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Prompt question
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question',
                  style: GoogleFonts.lobster(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  prompt.question,
                  style: GoogleFonts.lobster(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Answer
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Answer',
                style: GoogleFonts.lobster(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                prompt.answer,
                style: GoogleFonts.lobster(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              // X (Skip) button
              GestureDetector(
                onTap: () => _handleSkipProfile(context),
                child: Container(
                  width: 60,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Connect button (wider with heart and message icons)
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleConnectFromPrompt(promptIndex, prompt, context),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_outline,
                          size: 20,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.message_outlined,
                          size: 20,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Connect',
                          style: GoogleFonts.lobster(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Content Available',
            style: GoogleFonts.lobster(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This profile has no photos or prompts to display.',
            style: GoogleFonts.lobster(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.black87,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.lobster(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSkipProfile(BuildContext context) {
    // Move to next profile logic (same as X button in other views)
    final currentIndex = ref.read(currentProfileIndexProvider);
    final profilesAsync = ref.read(discoveryProfilesProvider);

    // Add current index to previous stack
    final previousStack = ref.read(previousProfilesStackProvider);
    ref.read(previousProfilesStackProvider.notifier).state =
        [...previousStack, currentIndex];

    // Move to next profile
    profilesAsync.whenData((profiles) {
      if (currentIndex < profiles.length - 1) {
        ref.read(currentProfileIndexProvider.notifier).state = currentIndex + 1;
      } else {
        // No more profiles - reset index to show empty state
        ref.read(currentProfileIndexProvider.notifier).state = profiles.length;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Moved to next profile'),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleConnectFromPhoto(int photoIndex, BuildContext context) {
    // Same functionality as the top-right connect button - show connect dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConnectBottomSheet(profile: profile),
    );
  }

  void _handleConnectFromPrompt(int promptIndex, dynamic prompt, BuildContext context) {
    // Same functionality as the top-right connect button - show connect dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConnectBottomSheet(profile: profile),
    );
  }
}