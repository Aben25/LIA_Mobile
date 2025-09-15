import 'package:flutter/material.dart';
import 'package:love_in_action/screens/auth/login_screen.dart';
import 'package:love_in_action/screens/profile_screen.dart';
import 'package:love_in_action/screens/auth/change_password_screen.dart';
import 'package:love_in_action/screens/auth/delete_account_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/theme_provider.dart';
import '../../providers/supabase_provider.dart';
import '../../providers/strapi_auth_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/app_messaging.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _emailUpdatesEnabled = true;
  final String _appVersion = "1.0.0";

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Future<void> _handleSignOut(BuildContext context) async {
    try {
      AppMessaging.showLoading('Signing you out...');

      final strapiProvider =
          Provider.of<StrapiAuthProvider>(context, listen: false);
      await strapiProvider.logout();

      AppMessaging.dismiss();
      AppMessaging.showSuccess('Signed out successfully');

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    } catch (error) {
      AppMessaging.dismiss();
      AppMessaging.showError('Failed to sign out');
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final strapiProvider =
          Provider.of<StrapiAuthProvider>(context, listen: false);
      strapiProvider.getUser();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppMessaging.showError('Could not open link');
      }
    } catch (e) {
      AppMessaging.showError('Error opening link');
    }
  }

  void _openPrivacyPolicy() {
    _openUrl('https://loveinaction.co/privacy-policy-2/');
  }

  void _openTerms() {
    _openUrl('https://your-terms-url.com');
  }

  void _openHelpCenter() {
    _openUrl('https://your-help-center-url.com');
  }

  void _handleDeleteAccount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DeleteAccountScreen(),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? description,
    bool? value,
    ValueChanged<bool>? onValueChange,
    Color? iconColor,
    VoidCallback? onPress,
  }) {
    return InkWell(
      onTap: () {
        if (onValueChange != null && value != null) {
          _animationController.forward().then((_) {
            _animationController.reverse();
            onValueChange(!value);
          });
        } else if (onPress != null) {
          onPress();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            // Icon
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: onValueChange != null ? _scaleAnimation.value : 1.0,
                  child: Icon(
                    icon,
                    size: 22,
                    color: iconColor ?? Colors.grey[600],
                  ),
                );
              },
            ),
            const SizedBox(width: 12),

            // Title and Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),

            // Switch or Arrow
            if (onValueChange != null && value != null)
              Switch(
                value: value,
                onChanged: onValueChange,
                activeColor: AppColors.primary,
              )
            else if (onPress != null)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // final supabaseProvider = Provider.of<SupabaseProvider>(context); // Commented out during Strapi transition
    final strapiProvider = Provider.of<StrapiAuthProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = strapiProvider.user;
    print('user: $user');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Profile Section
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ProfileScreen()));
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 24,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                                Text(
                                  '${user?.email}',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.darkMutedForeground
                                        : AppColors.lightMutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Security Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Security',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                        ),
                        _buildSettingItem(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          description: 'Update your account password',
                          onPress: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordScreen(),
                              ),
                            );
                          },
                          iconColor: const Color(0xFF2196F3),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Preferences Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Preferences',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                        ),
                        _buildSettingItem(
                          icon: isDark ? Icons.dark_mode : Icons.light_mode,
                          title: 'Dark Mode',
                          description: 'Toggle between light and dark mode',
                          value: isDark,
                          onValueChange: (value) {
                            themeProvider.toggleTheme();
                          },
                          iconColor: const Color(0xFFFDB813),
                        ),
                        // _buildSettingItem(
                        //   icon: Icons.notifications,
                        //   title: 'Push Notifications',
                        //   description: 'Receive important updates and alerts',
                        //   value: _notificationsEnabled,
                        //   onValueChange: (value) {
                        //     setState(() {
                        //       _notificationsEnabled = value;
                        //     });
                        //   },
                        //   iconColor: _notificationsEnabled
                        //       ? const Color(0xFF4CAF50)
                        //       : null,
                        // ),
                        // _buildSettingItem(
                        //   icon: Icons.mail,
                        //   title: 'Email Updates',
                        //   description: 'Receive news and updates via email',
                        //   value: _emailUpdatesEnabled,
                        //   onValueChange: (value) {
                        //     setState(() {
                        //       _emailUpdatesEnabled = value;
                        //     });
                        //   },
                        //   iconColor: _emailUpdatesEnabled
                        //       ? const Color(0xFF2196F3)
                        //       : null,
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Help & Support Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Help & Support',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                        ),
                        // _buildSettingItem(
                        //   icon: Icons.help_outline,
                        //   title: 'Help Center',
                        //   description: 'Get help with using the app',
                        //   onPress: _openHelpCenter,
                        //   iconColor: const Color(0xFF9C27B0),
                        // ),
                        _buildSettingItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          description: 'Read our privacy policy',
                          onPress: _openPrivacyPolicy,
                          iconColor: const Color(0xFFFF9800),
                        ),
                        // _buildSettingItem(
                        //   icon: Icons.description_outlined,
                        //   title: 'Terms of Service',
                        //   description: 'Read our terms of service',
                        //   onPress: _openTerms,
                        //   iconColor: const Color(0xFF607D8B),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Version $_appVersion',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkMutedForeground
                                    : AppColors.lightMutedForeground,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account Management Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'ACCOUNT MANAGEMENT',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkMutedForeground
                                : AppColors.lightMutedForeground,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? AppColors.darkBackground
                                  : AppColors.lightBackground)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _handleDeleteAccount(context),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 24,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Delete Account',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red[400],
                                        ),
                                      ),
                                      Text(
                                        'Permanently delete your account and all data',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkMutedForeground
                                              : AppColors.lightMutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  size: 24,
                                  color: Colors.red[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        _handleSignOut(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
