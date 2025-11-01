import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../discovery/presentation/discovery_screen.dart';

class ProfilePreviewCarouselView extends HookConsumerWidget {
  final UserProfile profile;
  final ValueNotifier<int> currentPhotoIndex;
  final ValueNotifier<DiscoveryViewMode> selectedViewMode;

  const ProfilePreviewCarouselView({
    super.key,
    required this.profile,
    required this.currentPhotoIndex,
    required this.selectedViewMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController(viewportFraction: 0.85);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Occupation and Location above photos
          if (profile.occupation != null || profile.location != null)
            Positioned(
              top: 100,
              left: 55,
              right: 30,
              child: Row(
                children: [
                  // Occupation on the left
                  if (profile.occupation != null) ...[
                    const Icon(
                      Icons.work_outline,
                      size: 18,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        profile.occupation!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (profile.location != null) const SizedBox(width: 50),
                  ],
                  // Location on the right
                  if (profile.location != null) ...[
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        profile.location!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Shortened Photo Carousel for Profile Preview
          Positioned(
            top: 120,
            bottom: 200,
            left: 0,
            right: 0,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                currentPhotoIndex.value = index;
              },
              itemCount: profile.photoUrls.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: pageController,
                  builder: (context, child) {
                    double value = 0.0;
                    if (pageController.position.haveDimensions) {
                      value = index.toDouble() - (pageController.page ?? 0);
                      value = (value * 0.038).clamp(-1, 1);
                    }
                    return Transform.rotate(
                      angle: value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            profile.photoUrls[index],
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
                      ),
                    );
                  },
                );
              },
            ).animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95), duration: 400.ms),
          ),

          // Dynamic Prompt Text and Photo Counter (grouped together)
          Positioned(
            bottom: 220,
            left: 24,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Photo counter badge
                if (profile.photoUrls.length > 1)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12, left: 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${currentPhotoIndex.value + 1} of ${profile.photoUrls.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                // Prompt text below the photo counter
                if (currentPhotoIndex.value < profile.prompts.length)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bold prompt question
                        Text(
                          profile.prompts[currentPhotoIndex.value].question,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Normal response text
                        Text(
                          profile.prompts[currentPhotoIndex.value].answer,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ).animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.3, end: 0),
                  ),
              ],
            ),
          ),

          // Top Bar (overlaid on card)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    Container(
                      width: 44,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => context.pop(),
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
                            isSelected: selectedViewMode.value == DiscoveryViewMode.carousel,
                            onTap: () => selectedViewMode.value = DiscoveryViewMode.carousel,
                          ),
                          _buildViewToggleButton(
                            icon: Icons.person,
                            isSelected: selectedViewMode.value == DiscoveryViewMode.profilePreview,
                            onTap: () => selectedViewMode.value = DiscoveryViewMode.profilePreview,
                          ),
                          _buildViewToggleButton(
                            icon: Icons.grid_view,
                            isSelected: selectedViewMode.value == DiscoveryViewMode.custom,
                            onTap: () => selectedViewMode.value = DiscoveryViewMode.custom,
                          ),
                        ],
                      ),
                    ),

                    // Name and age button
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement skip functionality
                      },
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
          ),

          // Bottom Section with X button, Ghost button, Profile Preview title and Edit buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row: X button, Profile Preview title, Ghost button
                    Row(
                      children: [
                        // Skip/X Button
                        Container(
                          width: 50,
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
                            onPressed: () {
                              // TODO: Implement skip functionality
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

                        // Profile Preview Title (expanded)
                        Expanded(
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
                            child: const Center(
                              child: Text(
                                'Profile Preview',
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

                        // Ghost Button
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
                              Icons.visibility_off,
                              color: Colors.black87,
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Bottom row: Edit Photos and Edit Prompts buttons
                    Row(
                      children: [
                        // Edit Photos Button
                        Expanded(
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
                            child: TextButton.icon(
                              onPressed: () {
                                context.pop();
                                context.push('/add-photos');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              icon: const Icon(
                                Icons.photo_camera,
                                color: Colors.black87,
                                size: 20,
                              ),
                              label: const Text(
                                'Edit Photos',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Edit Prompts Button
                        Expanded(
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
                            child: TextButton.icon(
                              onPressed: () {
                                context.pop();
                                context.push('/add-prompts');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.black87,
                                size: 20,
                              ),
                              label: const Text(
                                'Edit Prompts',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
}
