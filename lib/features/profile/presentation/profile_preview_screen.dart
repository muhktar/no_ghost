import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/user_profile_provider.dart';
import '../../../shared/models/user_profile.dart';
import '../../discovery/presentation/discovery_screen.dart';

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
        return _buildViewBasedScreen(context, profile, selectedViewMode.value, currentPhotoIndex, selectedViewMode, ref);
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
        return _buildView1Screen(context, profile, currentPhotoIndex, selectedViewMode, ref);
      case DiscoveryViewMode.profilePreview:
        return _buildView2Screen(context, profile, currentPhotoIndex, selectedViewMode, ref);
      case DiscoveryViewMode.custom:
        return _buildView3Screen(context, profile, currentPhotoIndex, selectedViewMode, ref);
    }
  }

  Widget _buildView1Screen(
    BuildContext context,
    UserProfile profile,
    ValueNotifier<int> currentPhotoIndex,
    ValueNotifier<DiscoveryViewMode> selectedViewMode,
    WidgetRef ref,
  ) {
    final pageController = usePageController(viewportFraction: 0.85);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Occupation and Location above photos
          if (profile.occupation != null || profile.location != null)
            Positioned(
              top: 100,  // Above the photos
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

          // Shortened Photo Carousel for Profile Preview (shifted down)
          Positioned(
            top: 120,  // Moved down from 100
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

  Widget _buildView2Screen(
    BuildContext context,
    UserProfile profile,
    ValueNotifier<int> currentPhotoIndex,
    ValueNotifier<DiscoveryViewMode> selectedViewMode,
    WidgetRef ref,
  ) {
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
            child: _buildViewToggle(DiscoveryViewMode.profilePreview, selectedViewMode, ref),
          ),
        ],
      ),
      body: _buildProfilePreview(context, profile, currentPhotoIndex),
    );
  }

  Widget _buildView3Screen(
    BuildContext context,
    UserProfile profile,
    ValueNotifier<int> currentPhotoIndex,
    ValueNotifier<DiscoveryViewMode> selectedViewMode,
    WidgetRef ref,
  ) {
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
            child: _buildViewToggle(DiscoveryViewMode.custom, selectedViewMode, ref),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Custom view content (without top bar and bottom panel)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120), // Leave space for buttons
              child: _buildDiscoveryCardContentOnly(context, profile),
            ),
          ),
          // Bottom action buttons - 2 buttons with icons
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // Edit Photos Button with camera icon
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
                        size: 22,
                      ),
                      label: Text(
                        'Edit Photos',
                        style: GoogleFonts.lobster(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Edit Prompts Button with pencil icon
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
                        size: 22,
                      ),
                      label: Text(
                        'Edit Prompts',
                        style: GoogleFonts.lobster(
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
        ],
      ),
    );
  }

  Widget _buildViewToggle(DiscoveryViewMode currentMode, ValueNotifier<DiscoveryViewMode> selectedViewMode, WidgetRef ref) {
    // Use white background for view 1 (over photos), grey for views 2&3 (over white background)
    final backgroundColor = currentMode == DiscoveryViewMode.carousel
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.grey.withValues(alpha: 0.1);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewButton(Icons.view_carousel, DiscoveryViewMode.carousel, currentMode, selectedViewMode, ref),
          _buildViewButton(Icons.person, DiscoveryViewMode.profilePreview, currentMode, selectedViewMode, ref),
          _buildViewButton(Icons.grid_view, DiscoveryViewMode.custom, currentMode, selectedViewMode, ref),
        ],
      ),
    );
  }

  Widget _buildViewButton(IconData icon, DiscoveryViewMode mode, DiscoveryViewMode currentMode, ValueNotifier<DiscoveryViewMode> selectedViewMode, WidgetRef ref) {
    final isSelected = mode == currentMode;
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

  // Custom method to show only the card content without the top bar
  Widget _buildDiscoveryCardContentOnly(BuildContext context, UserProfile profile) {
    // Create alternating list of photos and prompts (copied from _DiscoveryCardView)
    final List<Widget> contentItems = [];

    final maxItems = profile.photoUrls.length > profile.prompts.length
        ? profile.photoUrls.length
        : profile.prompts.length;

    for (int i = 0; i < maxItems * 2; i++) {
      if (i % 2 == 0) {
        // Even index: add photo if available
        final photoIndex = i ~/ 2;
        if (photoIndex < profile.photoUrls.length) {
          contentItems.add(_buildPhotoCardWithoutActions(profile.photoUrls[photoIndex], photoIndex, context));

          // Add basic info card after the first photo
          if (photoIndex == 0) {
            contentItems.add(_buildBasicInfoCard(context, profile));
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

  Widget _buildPhotoCardWithoutActions(String photoUrl, int photoIndex, BuildContext context) {
    return Container(
      height: 670,
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

  Widget _buildBasicInfoCard(BuildContext context, UserProfile profile) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
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
          Row(
            children: [
              Text(
                profile.name ?? 'Unknown',
                style: GoogleFonts.lobster(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (profile.age != null) ...[
                const SizedBox(width: 8),
                Text(
                  '${profile.age}',
                  style: GoogleFonts.lobster(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ],
          ),
          if (profile.occupation != null || profile.location != null) ...[
            const SizedBox(height: 12),
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
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              profile.bio!,
              style: GoogleFonts.lobster(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromptCard(dynamic prompt, int promptIndex, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
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
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Content Available',
              style: GoogleFonts.lobster(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add photos and prompts to see your profile preview',
              style: GoogleFonts.lobster(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSkip(WidgetRef ref) {
    // TODO: Implement skip functionality
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