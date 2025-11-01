import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../discovery/presentation/discovery_screen.dart';

class ProfilePreviewFullView extends HookConsumerWidget {
  final UserProfile profile;
  final ValueNotifier<int> currentPhotoIndex;
  final ValueNotifier<DiscoveryViewMode> selectedViewMode;

  const ProfilePreviewFullView({
    super.key,
    required this.profile,
    required this.currentPhotoIndex,
    required this.selectedViewMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildViewToggle(selectedViewMode),
          ),
        ],
      ),
      body: _buildProfilePreview(context, profile, currentPhotoIndex),
    );
  }

  Widget _buildViewToggle(ValueNotifier<DiscoveryViewMode> selectedViewMode) {
    final backgroundColor = Colors.grey.withValues(alpha: 0.1);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewButton(Icons.view_carousel, DiscoveryViewMode.carousel, selectedViewMode),
          _buildViewButton(Icons.person, DiscoveryViewMode.profilePreview, selectedViewMode),
          _buildViewButton(Icons.grid_view, DiscoveryViewMode.custom, selectedViewMode),
        ],
      ),
    );
  }

  Widget _buildViewButton(IconData icon, DiscoveryViewMode mode, ValueNotifier<DiscoveryViewMode> selectedViewMode) {
    final isSelected = mode == DiscoveryViewMode.profilePreview;
    return GestureDetector(
      onTap: () {
        selectedViewMode.value = mode;
      },
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

  Widget _buildProfilePreview(
    BuildContext context,
    UserProfile profile,
    ValueNotifier<int> currentPhotoIndex,
  ) {
    final theme = Theme.of(context);
    final hasPhotos = profile.photoUrls.isNotEmpty;
    final hasPrompts = profile.prompts.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Photo carousel section
          SizedBox(
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
                        const SizedBox(height: 8),
                        Text(
                          'Add photos to see how your profile looks',
                          style: GoogleFonts.lobster(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
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
                  Column(
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
                  }),
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
                        const SizedBox(height: 4),
                        Text(
                          'Add prompts to showcase your personality',
                          style: GoogleFonts.lobster(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.pop();
                          context.push('/add-photos');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: theme.colorScheme.primary),
                        ),
                        child: Text(
                          'Edit Photos',
                          style: GoogleFonts.lobster(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.pop();
                          context.push('/add-prompts');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: theme.colorScheme.primary),
                        ),
                        child: Text(
                          'Edit Prompts',
                          style: GoogleFonts.lobster(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate()
                  .fadeIn(delay: 1000.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
