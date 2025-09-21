import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/strapi_auth_provider.dart';
import '../constants/app_colors.dart';
import '../utils/app_messaging.dart';
import 'dashboard/dashboard_screen.dart';
import 'auth/login_screen.dart';
import 'settings/settings_screen.dart';
import 'projects/projects_screen.dart';
import 'donations/donations_screen.dart';

class MainAppScreen extends StatefulWidget {
  final int initialIndex;

  const MainAppScreen({super.key, this.initialIndex = 0});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProjectsScreen(),
    const DonationsScreen(),
    const SettingsScreen(),
  ];

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
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final auth = Provider.of<StrapiAuthProvider>(context);
    final isAuthenticated = auth.isAuthenticated;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true, // Show back button when appropriate
        title: Text(
          'Love in Action',
          style: TextStyle(
            fontFamily: 'Specify',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color:
                isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        actions: [
          if (isAuthenticated)
            IconButton(
              icon: Icon(
                Icons.logout,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
              onPressed: () => _handleSignOut(context),
            ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark
              ? AppColors.darkMutedForeground
              : AppColors.lightMutedForeground,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Specify',
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Specify',
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Donations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screen for screens not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
            const SizedBox(height: 24),
            Text(
              '$title Screen',
              style: TextStyle(
                fontFamily: 'Specify',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Coming soon!',
              style: TextStyle(
                fontFamily: 'Specify',
                fontSize: 16,
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
