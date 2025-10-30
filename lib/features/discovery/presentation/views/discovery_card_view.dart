import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/models/user_profile.dart';
import '../../widgets/connect_bottom_sheet.dart';
import '../discovery_screen.dart';

class DiscoveryCardView extends HookWidget {
  final UserProfile profile;
  final WidgetRef ref;

  const DiscoveryCardView({
    super.key,
    required this.profile,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.grey.withValues(alpha: 0.1),
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
                  color: Colors.grey.withValues(alpha: 0.1),
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

              // Visibility Off Button
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () {
                    // No functionality for now as requested
                  },
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.visibility_off,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile content below the top bar
        Expanded(
          child: _DiscoveryCardView(profile: profile, ref: ref),
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

          // Add basic info card after the first photo
          if (photoIndex == 0) {
            contentItems.add(_buildBasicInfoCard(context));
          }
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
            color: Colors.black.withValues(alpha: 0.1),
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
            SizedBox(
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
                      Colors.black.withValues(alpha: 0.7),
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
                            color: Colors.black.withValues(alpha: 0.1),
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
                              color: Colors.black.withValues(alpha: 0.1),
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
                  color: Colors.black.withValues(alpha: 0.6),
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
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
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
                          color: Colors.black.withValues(alpha: 0.1),
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
                            color: Colors.black.withValues(alpha: 0.1),
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

  Widget _buildBasicInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and age
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
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Location and occupation
          if (profile.location != null || profile.occupation != null) ...[
            if (profile.occupation != null)
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      profile.occupation!,
                      style: GoogleFonts.lobster(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            if (profile.location != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      profile.location!,
                      style: GoogleFonts.lobster(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],

          // Bio section
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
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
                  color: Colors.black.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleSkipProfile(BuildContext context) {
    // Move to next profile logic (same as X button in other views)
    final currentIndex = ref.read(currentProfileIndexProvider);

    // Add current index to previous stack
    final previousStack = ref.read(previousProfilesStackProvider);
    ref.read(previousProfilesStackProvider.notifier).state =
        [...previousStack, currentIndex];

    // Move to next profile
    ref.read(currentProfileIndexProvider.notifier).state = currentIndex + 1;

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