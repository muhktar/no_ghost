import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/profile/presentation/basic_info_screen.dart';
import '../../features/profile/presentation/add_photos_screen.dart';
import '../../features/profile/presentation/add_prompts_screen.dart';
import '../../features/profile/presentation/profile_preview_screen.dart';
import '../../features/discovery/presentation/discovery_screen.dart';
import '../../features/suggestions/presentation/suggestions_screen.dart';
import '../../features/likes/presentation/likes_screen.dart';
import '../../features/chat/presentation/chat_list_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/subscription/presentation/subscription_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/basic-info',
        name: 'basic-info',
        builder: (context, state) => const BasicInfoScreen(),
      ),
      GoRoute(
        path: '/add-photos',
        name: 'add-photos',
        builder: (context, state) => const AddPhotosScreen(),
      ),
      GoRoute(
        path: '/add-prompts',
        name: 'add-prompts',
        builder: (context, state) => const AddPromptsScreen(),
      ),
      GoRoute(
        path: '/profile-preview',
        name: 'profile-preview',
        builder: (context, state) => const ProfilePreviewScreen(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          // Discovery (Home)
          GoRoute(
            path: '/discovery',
            name: 'discovery',
            builder: (context, state) => const DiscoveryScreen(),
          ),

          // Suggestions
          GoRoute(
            path: '/suggestions',
            name: 'suggestions',
            builder: (context, state) => const SuggestionsScreen(),
          ),

          // Likes
          GoRoute(
            path: '/likes',
            name: 'likes',
            builder: (context, state) => const LikesScreen(),
          ),

          // Chat
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ChatListScreen(),
            routes: [
              GoRoute(
                path: '/conversation/:matchId',
                name: 'conversation',
                builder: (context, state) => ChatScreen(
                  matchId: state.pathParameters['matchId']!,
                ),
              ),
            ],
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Subscription
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
    ],
  );
});

class MainNavigationShell extends StatelessWidget {
  final Widget child;

  const MainNavigationShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, 0, Icons.explore, 'Discovery'),
              _buildNavItem(context, 1, Icons.auto_awesome, 'Suggestions'),
              _buildNavItem(context, 2, Icons.favorite, 'Likes'),
              _buildNavItem(context, 3, Icons.chat_bubble, 'Chat'),
              _buildNavItem(context, 4, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = _getCurrentIndex(context) == index;
    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              size: 22,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    if (location.startsWith('/discovery')) return 0;
    if (location.startsWith('/suggestions')) return 1;
    if (location.startsWith('/likes')) return 2;
    if (location.startsWith('/chat')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/discovery');
        break;
      case 1:
        context.go('/suggestions');
        break;
      case 2:
        context.go('/likes');
        break;
      case 3:
        context.go('/chat');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}