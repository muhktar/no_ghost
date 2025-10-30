import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../shared/models/user_profile.dart';
import '../../widgets/profile_card.dart';
import '../../widgets/connect_bottom_sheet.dart';
import '../discovery_screen.dart';

class DiscoveryCarouselView extends ConsumerWidget {
  final UserProfile profile;

  const DiscoveryCarouselView({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(discoveryViewModeProvider);

    return Stack(
      children: [
        // Main Profile Card (full screen - no borders)
        Positioned.fill(
          child: ProfileCard(
            profile: profile,
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

                // View Toggle Button (center)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
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
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${profile.name}, ${profile.age}',
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
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
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

                // Connect Button (shortened)
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () => _showConnectDialog(ref, profile, context),
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

                const SizedBox(width: 12),

                // Ghost Button (right side)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      // TODO: Add ghost functionality
                    },
                    icon: const Icon(
                      Icons.visibility_off,  // Ghost-like (invisible) icon
                      color: Colors.black87,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
}