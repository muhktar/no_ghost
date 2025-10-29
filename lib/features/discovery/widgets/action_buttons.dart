import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class ActionButtons extends HookConsumerWidget {
  final VoidCallback onSkip;
  final VoidCallback onConnect;
  final VoidCallback onLockIn;

  const ActionButtons({
    super.key,
    required this.onSkip,
    required this.onConnect,
    required this.onLockIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lockInAnimationController = useAnimationController();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Skip Button (X)
        _ActionButton(
          icon: Icons.close,
          backgroundColor: Colors.grey.shade100,
          iconColor: Colors.grey.shade600,
          size: 56,
          onTap: onSkip,
        ).animate()
          .fadeIn(delay: 200.ms)
          .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),

        // Connect Button (Heart)
        _ActionButton(
          icon: Icons.favorite,
          backgroundColor: theme.colorScheme.primary,
          iconColor: Colors.white,
          size: 64,
          onTap: onConnect,
        ).animate()
          .fadeIn(delay: 400.ms)
          .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),

        // Lock-In Button (Lock + Heart)
        GestureDetector(
          onTap: () {
            lockInAnimationController.forward().then((_) {
              lockInAnimationController.reverse();
              onLockIn();
            });
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.lockInColor,
                  Color(0xFFFF8A8A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lockInColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: lockInAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + (lockInAnimationController.value * 0.2),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Lock Icon
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Icon(
                          lockInAnimationController.value > 0.5 
                              ? Icons.lock
                              : Icons.lock_open,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      // Heart Icon
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      // Lock-In Text
                      if (lockInAnimationController.value < 0.3)
                        Positioned(
                          child: Text(
                            'Lock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ).animate()
          .fadeIn(delay: 600.ms)
          .scale(begin: const Offset(0.8, 0.8), duration: 400.ms)
          .shimmer(delay: 2000.ms, duration: 1500.ms),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.4,
        ),
      ),
    );
  }
}