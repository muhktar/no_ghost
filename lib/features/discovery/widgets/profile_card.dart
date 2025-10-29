import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/models/user_profile.dart';
import 'dart:math' as math;

class ProfileCard extends HookConsumerWidget {
  final UserProfile profile;
  final Function(int)? onPhotoTap;
  final Function(bool)? onScrollDirectionChange;

  const ProfileCard({
    super.key,
    required this.profile,
    this.onPhotoTap,
    this.onScrollDirectionChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pageController = usePageController(viewportFraction: 0.85);
    final currentPhotoIndex = useState(0);
    final rotationAnimation = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final scrollDirection = useState<String>('');
    
    // Create content for each photo (prompts, captions, or voice memos)
    final photoContent = _buildPhotoContent(profile);

    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [
              // Pin Wheel Carousel Effect with visible prev/next - moved up slightly
              Positioned(
                top: 75, // Move up a bit more for better positioning
                bottom: 120, // Leave space for gradient and buttons
                left: 0,
                right: 0,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      final delta = notification.scrollDelta ?? 0;
                      if (delta > 0) {
                        // Scrolling right (clockwise)
                        scrollDirection.value = 'clockwise';
                        rotationAnimation.forward();
                        onScrollDirectionChange?.call(true);
                      } else if (delta < 0) {
                        // Scrolling left (counter-clockwise)
                        scrollDirection.value = 'counter-clockwise';
                        rotationAnimation.reverse();
                        onScrollDirectionChange?.call(false);
                      }
                    }
                    return true;
                  },
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (index) {
                      currentPhotoIndex.value = index;
                      onPhotoTap?.call(index);
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
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), // Increased spacing so cards don't touch
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                      GestureDetector(
                                      onTap: () {
                                        // Navigate to next photo
                                        if (index < profile.photoUrls.length - 1) {
                                          pageController.nextPage(
                                            duration: const Duration(milliseconds: 400),
                                            curve: Curves.easeInOut,
                                          );
                                        } else {
                                          pageController.animateToPage(
                                            0,
                                            duration: const Duration(milliseconds: 400),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: profile.photoUrls[index],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: theme.colorScheme.surface,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: theme.colorScheme.surface,
                                          child: Icon(
                                            Icons.person,
                                            size: 64,
                                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),




              // Dynamic Text Content that changes with photos  
              Positioned(
                bottom: 200, // Moved down further for full gradient coverage
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Photo Counter Button (like reference photo) - moved to left above prompt
                      if (profile.photoUrls.length > 1)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
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
                      
                      // Dynamic content based on current photo
                      if (photoContent.isNotEmpty && currentPhotoIndex.value < photoContent.length)
                        _buildTextContent(photoContent[currentPhotoIndex.value]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
  }

  // Build content for each photo (prompts, captions, or voice memos)
  List<Map<String, dynamic>> _buildPhotoContent(UserProfile profile) {
    List<Map<String, dynamic>> content = [];
    
    for (int i = 0; i < profile.photoUrls.length; i++) {
      if (i < profile.prompts.length) {
        // Photo has associated prompt
        final prompt = profile.prompts[i];
        if (prompt.type == PromptType.voice) {
          content.add({
            'type': 'voice',
            'question': prompt.question,
            'answer': 'Voice Message', // Could be actual voice memo
          });
        } else {
          content.add({
            'type': 'prompt',
            'question': prompt.question,
            'answer': prompt.answer,
          });
        }
      } else {
        // Photo only has caption (use occupation or fallback)
        content.add({
          'type': 'caption',
          'text': profile.occupation ?? 'Photo ${i + 1}',
        });
      }
    }
    
    return content;
  }

  // Build text widget based on content type
  Widget _buildTextContent(Map<String, dynamic> content) {
    switch (content['type']) {
      case 'prompt':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bold prompt question
            Text(
              content['question'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            // Normal response text
            Text(
              content['answer'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.3, end: 0);
      
      case 'voice':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bold prompt question
            Text(
              content['question'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            // Voice memo indicator
            Row(
              children: [
                Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  content['answer'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.3, end: 0);
      
      case 'caption':
      default:
        return Text(
          content['text'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.3, end: 0);
    }
  }
}