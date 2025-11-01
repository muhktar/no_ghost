import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../discovery/presentation/discovery_screen.dart';

class ProfilePreviewCardView extends StatelessWidget {
  final UserProfile profile;
  final ValueNotifier<DiscoveryViewMode> selectedViewMode;

  const ProfilePreviewCardView({
    super.key,
    required this.profile,
    required this.selectedViewMode,
  });

  @override
  Widget build(BuildContext context) {
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
    final isSelected = mode == DiscoveryViewMode.custom;
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

  // Custom method to show only the card content without the top bar
  Widget _buildDiscoveryCardContentOnly(BuildContext context, UserProfile profile) {
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
}
