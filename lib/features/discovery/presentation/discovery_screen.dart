import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class DiscoveryScreen extends HookConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profilesAsync = ref.watch(discoveryProfilesProvider);
    final currentIndex = ref.watch(currentProfileIndexProvider);
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
      backgroundColor: Colors.white, // White background for black and white theme
      body: SafeArea(
        child: Stack(
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
                    
                    const Spacer(),
                    
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
        ),
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