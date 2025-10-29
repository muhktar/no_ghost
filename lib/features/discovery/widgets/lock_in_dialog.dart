import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/models/user_profile.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class LockInDialog extends HookConsumerWidget {
  final UserProfile profile;

  const LockInDialog({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final animationController = useAnimationController();
    final isAnimationComplete = useState(false);

    useEffect(() {
      // Start the Lock-In animation sequence
      animationController.forward().then((_) {
        isAnimationComplete.value = true;
      });
      return null;
    }, []);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lockInColor.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lock-In Animation
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow Ring
                  AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      return Container(
                        width: 120 * (1 + animationController.value * 0.5),
                        height: 120 * (1 + animationController.value * 0.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.lockInColor.withOpacity(
                              0.3 * (1 - animationController.value)
                            ),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),

                  // Heart Icon with Pulse
                  AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      final scale = 1 + (animationController.value * 0.3);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.lockInColor,
                                AppTheme.lockInColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.lockInColor.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),

                  // Lock Animation
                  AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      final lockProgress = (animationController.value * 2).clamp(0.0, 1.0);
                      return Positioned(
                        top: 15,
                        right: 15,
                        child: Transform.scale(
                          scale: lockProgress,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              lockProgress > 0.5 ? Icons.lock : Icons.lock_open,
                              color: AppTheme.lockInColor,
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 200.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),

            const SizedBox(height: 24),

            // Lock-In Title
            Text(
              'Lock-In with ${profile.name}?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lockInColor,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 12),

            // Lock-In Description
            Text(
              'Show serious interest! They\'ll receive a special notification that you\'re genuinely interested in connecting.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 20),

            // Premium Feature Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.lockInColor.withOpacity(0.1),
                    AppTheme.lockInColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.lockInColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: AppTheme.lockInColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Premium Feature',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lockInColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(delay: 800.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isAnimationComplete.value
                        ? () {
                            Navigator.pop(context);
                            _sendLockIn(context, profile);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lockInColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text('Lock-In'),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate()
              .fadeIn(delay: 1000.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 16),

            // Anti-Ghosting Reminder
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'If they match back, remember the 4-word minimum and 2-hour response window!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(delay: 1200.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }

  void _sendLockIn(BuildContext context, UserProfile profile) {
    // TODO: Implement actual Lock-In logic with Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.lock,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(AppConstants.lockInSentMessage),
            ),
          ],
        ),
        backgroundColor: AppTheme.lockInColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}