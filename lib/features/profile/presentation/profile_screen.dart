import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.lobster(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your Profile',
                        style: GoogleFonts.lobster(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your photos and prompts',
                        style: GoogleFonts.lobster(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context.push('/add-photos');
                              },
                              child: Text(
                                'Edit Photos',
                                style: GoogleFonts.lobster(fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context.push('/add-prompts');
                              },
                              child: Text(
                                'Edit Prompts',
                                style: GoogleFonts.lobster(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Preview Profile Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push('/profile-preview');
                          },
                          icon: Icon(
                            Icons.visibility_outlined,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          label: Text(
                            'Preview My Profile',
                            style: GoogleFonts.lobster(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: theme.colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 24),
                
                // Settings List
                Text(
                  'Account Settings',
                  style: GoogleFonts.lobster(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms),
                
                const SizedBox(height: 16),
                
                _buildSettingsItem(
                  context,
                  Icons.notifications,
                  'Notifications',
                  'Manage your notification preferences',
                  () {},
                ).animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideX(begin: -0.3, end: 0),
                
                _buildSettingsItem(
                  context,
                  Icons.security,
                  'Privacy & Safety',
                  'Control your privacy settings',
                  () {},
                ).animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideX(begin: -0.3, end: 0),
                
                _buildSettingsItem(
                  context,
                  Icons.workspace_premium,
                  'Subscription',
                  'Manage your premium subscription',
                  () {
                    context.push('/subscription');
                  },
                ).animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideX(begin: -0.3, end: 0),
                
                _buildSettingsItem(
                  context,
                  Icons.help,
                  'Help & Support',
                  'Get help and contact support',
                  () {},
                ).animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideX(begin: -0.3, end: 0),
                
                _buildSettingsItem(
                  context,
                  Icons.info,
                  'About',
                  'App version and legal information',
                  () {},
                ).animate()
                  .fadeIn(delay: 700.ms, duration: 600.ms)
                  .slideX(begin: -0.3, end: 0),
                
                const SizedBox(height: 32),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      _showLogoutDialog(context, ref);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: GoogleFonts.lobster(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: GoogleFonts.lobster(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lobster(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.lobster(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.lobster(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final authNotifier = ref.read(authNotifierProvider.notifier);
              try {
                await authNotifier.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Signed out successfully!',
                      style: GoogleFonts.lobster(fontSize: 12),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                context.go('/welcome');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Sign out failed: $e',
                      style: GoogleFonts.lobster(fontSize: 12),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Sign Out',
              style: GoogleFonts.lobster(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}