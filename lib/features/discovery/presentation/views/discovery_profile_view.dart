import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/models/user_profile.dart';
import '../../widgets/connect_bottom_sheet.dart';
import '../discovery_screen.dart';

class DiscoveryProfileView extends HookWidget {
  final UserProfile profile;
  final WidgetRef ref;

  const DiscoveryProfileView({
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
          child: _DiscoveryProfilePreview(profile: profile, ref: ref),
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
                                      : Colors.white.withValues(alpha: 0.4),
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
                            color: Colors.black.withValues(alpha: 0.7),
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
                          color: Colors.black.withValues(alpha: 0.7),
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
                        color: Colors.black.withValues(alpha: 0.8),
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
                            color: Colors.black.withValues(alpha: 0.05),
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
                              color: Colors.black.withValues(alpha: 0.9),
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

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Bottom action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
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
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
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
                    onTap: () => _handleConnectFromProfilePreview(context),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
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
  }

  void _handleConnectFromProfilePreview(BuildContext context) {
    // Same functionality as the top-right connect button - show connect dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConnectBottomSheet(profile: profile),
    );
  }
}