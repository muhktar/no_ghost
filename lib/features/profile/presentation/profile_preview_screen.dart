import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_profile_provider.dart';
import '../../../shared/models/user_profile.dart';
import '../../discovery/presentation/discovery_screen.dart';
import 'views/profile_preview_carousel_view.dart';
import 'views/profile_preview_full_view.dart';
import 'views/profile_preview_card_view.dart';

/// Main coordinator for Profile Preview Screen
/// Routes to the appropriate view based on selected view mode
class ProfilePreviewScreen extends HookConsumerWidget {
  const ProfilePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPhotoIndex = useState(0);
    final selectedViewMode = useState(DiscoveryViewMode.profilePreview);

    // Get current user profile
    final profileAsync = ref.watch(currentUserProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Profile Preview',
                style: GoogleFonts.lobster(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              centerTitle: true,
            ),
            body: const Center(child: Text('No profile found')),
          );
        }
        return _buildViewBasedScreen(
          context,
          profile,
          selectedViewMode.value,
          currentPhotoIndex,
          selectedViewMode,
          ref,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Profile Preview',
            style: GoogleFonts.lobster(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Profile Preview',
            style: GoogleFonts.lobster(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(child: Text('Error loading profile: $error')),
      ),
    );
  }

  Widget _buildViewBasedScreen(
    BuildContext context,
    UserProfile profile,
    DiscoveryViewMode viewMode,
    ValueNotifier<int> currentPhotoIndex,
    ValueNotifier<DiscoveryViewMode> selectedViewMode,
    WidgetRef ref,
  ) {
    switch (viewMode) {
      case DiscoveryViewMode.carousel:
        return ProfilePreviewCarouselView(
          profile: profile,
          currentPhotoIndex: currentPhotoIndex,
          selectedViewMode: selectedViewMode,
        );
      case DiscoveryViewMode.profilePreview:
        return ProfilePreviewFullView(
          profile: profile,
          currentPhotoIndex: currentPhotoIndex,
          selectedViewMode: selectedViewMode,
        );
      case DiscoveryViewMode.custom:
        return ProfilePreviewCardView(
          profile: profile,
          selectedViewMode: selectedViewMode,
        );
    }
  }
}
