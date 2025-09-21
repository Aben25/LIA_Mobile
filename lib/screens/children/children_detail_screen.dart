import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/supabase_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/easy_loading_config.dart';
import '../../utils/network_error_handler.dart';
import 'full_gallery_screen.dart';

class ChildrenDetailScreen extends StatefulWidget {
  final String childId;

  const ChildrenDetailScreen({
    super.key,
    required this.childId,
  });

  @override
  State<ChildrenDetailScreen> createState() => _ChildrenDetailScreenState();
}

class _ChildrenDetailScreenState extends State<ChildrenDetailScreen> {
  Map<String, dynamic>? _sponsee;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSponseeDetails();
  }

  Future<void> _fetchSponseeDetails() async {
    if (!mounted) return;

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // Commented out during Strapi transition
      // final supabaseProvider =
      //     Provider.of<SupabaseProvider>(context, listen: false);
      // final supabase = supabaseProvider.supabase;

      print('🔍 [CHILDREN] Fetching sponsee details for ID: ${widget.childId}');

      // TODO: Implement with Strapi API
      // Simulate loading delay
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              'Children details feature is temporarily unavailable during migration to Strapi';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = NetworkErrorHandler.getErrorMessage(error);
          _loading = false;
        });
        EasyLoadingConfig.showError(NetworkErrorHandler.getErrorMessage(error));
      }
    }
  }

  int _calculateAge(String? dateOfBirth) {
    if (dateOfBirth == null) return 0;
    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String? content,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? AppColors.darkBackground : AppColors.lightBackground),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkMutedForeground
              : AppColors.lightMutedForeground,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: iconColor ?? AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Specify',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
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

  Widget _buildQuickInfoCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkBackground : AppColors.lightBackground)
              .withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Specify',
                fontSize: 12,
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Specify',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallerySection() {
    if (_sponsee == null || _sponsee!['gallery'] == null)
      return const SizedBox.shrink();

    final gallery = _sponsee!['gallery'];
    final galleryMedia =
        List<Map<String, dynamic>>.from(gallery['gallery_media'] ?? []);

    if (galleryMedia.isEmpty) return const SizedBox.shrink();

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkMutedForeground
              : AppColors.lightMutedForeground,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Photo Gallery',
                    style: TextStyle(
                      fontFamily: 'Specify',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                ),
                const Spacer(),
                if (galleryMedia.length > 4)
                  InkWell(
                    onTap: () {
                      _openFullGallery(galleryMedia);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              fontFamily: 'Specify',
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (gallery['description'] != null) ...[
              const SizedBox(height: 16),
              Text(
                gallery['description'],
                style: TextStyle(
                  fontFamily: 'Specify',
                  fontSize: 16,
                  color: isDark
                      ? AppColors.darkMutedForeground
                      : AppColors.lightMutedForeground,
                ),
              ),
            ],
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 0.7,
              ),
              itemCount: galleryMedia.length > 4 ? 4 : galleryMedia.length,
              itemBuilder: (context, index) {
                final media = galleryMedia[index];
                final filename = media['media']?['filename'];

                if (filename == null) {
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image,
                      size: 32,
                      color: isDark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                    ),
                  );
                }

                final imageUrl =
                    'https://ntckmekstkqxqgigqzgn.supabase.co/storage/v1/object/public/Media/$filename';

                return InkWell(
                  onTap: () {
                    _openFullGallery(galleryMedia, initialIndex: index);
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkMutedForeground
                                    : AppColors.lightMutedForeground,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.image,
                                size: 32,
                                color: isDark
                                    ? AppColors.darkBackground
                                    : AppColors.lightBackground,
                              ),
                            );
                          },
                        ),
                      ),
                      // Caption overlay if exists
                      if (media['caption'] != null &&
                          media['caption'].toString().isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              media['caption'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openFullGallery(List<Map<String, dynamic>> galleryMedia,
      {int initialIndex = 0}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullGalleryScreen(
          galleryMedia: galleryMedia,
          childName: _sponsee?['full_name'] ?? 'Child',
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading child details...'),
            ],
          ),
        ),
      );
    }

    if (_error != null || _sponsee == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                'Could not find the child\'s information',
                style: TextStyle(
                  fontFamily: 'Specify',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _fetchSponseeDetails,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final sponsee = _sponsee!;
    final fullName = sponsee['full_name'] ?? 'Unknown';
    final imageUrl = sponsee['media']?['filename'] != null
        ? 'https://ntckmekstkqxqgigqzgn.supabase.co/storage/v1/object/public/Media/${sponsee['media']['filename']}'
        : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Child Details',
          style: TextStyle(
            fontFamily: 'Specify',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color:
                isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Header with profile image
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Profile image
                Container(
                  height: 250,
                  width: double.infinity,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: isDark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground,
                              child: Icon(
                                Icons.person,
                                size: 80,
                                color: isDark
                                    ? AppColors.darkBackground
                                    : AppColors.lightBackground,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: isDark
                              ? AppColors.darkMutedForeground
                              : AppColors.lightMutedForeground,
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground,
                          ),
                        ),
                ),

                // Quick info cards overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _buildQuickInfoCard(
                          label: 'Gender',
                          value: (sponsee['gender'] ?? 'Unknown')
                              .toString()
                              .toUpperCase(),
                          icon: Icons.person_outline,
                        ),
                        _buildQuickInfoCard(
                          label: 'Age',
                          value: _calculateAge(sponsee['date_of_birth'])
                              .toString(),
                          icon: Icons.cake_outlined,
                        ),
                        _buildQuickInfoCard(
                          label: 'Joined',
                          value:
                              _formatDate(sponsee['joined_sponsorship_date']),
                          icon: Icons.calendar_today_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and location
                  Text(
                    fullName,
                    style: TextStyle(
                      fontFamily: 'Specify',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (sponsee['location'] != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: isDark
                              ? AppColors.darkMutedForeground
                              : AppColors.lightMutedForeground,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sponsee['location'],
                            style: TextStyle(
                              fontFamily: 'Specify',
                              fontSize: 16,
                              color: isDark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // About section
                  if (sponsee['about'] != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'About ${fullName.split(' ').first}',
                                  style: TextStyle(
                                    fontFamily: 'Specify',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            sponsee['about'],
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

                  // Info sections
                  _buildInfoCard(
                    title: 'Location',
                    icon: Icons.location_on_outlined,
                    content: sponsee['location'],
                  ),
                  _buildInfoCard(
                    title: 'Education',
                    icon: Icons.school_outlined,
                    content: sponsee['education'],
                  ),
                  _buildInfoCard(
                    title: 'Aspiration',
                    icon: Icons.star_outline,
                    content: sponsee['aspiration'],
                  ),
                  _buildInfoCard(
                    title: 'Hobbies',
                    icon: Icons.sports_basketball_outlined,
                    content: sponsee['hobby'],
                  ),
                  _buildInfoCard(
                    title: 'Family',
                    icon: Icons.people_outline,
                    content: sponsee['family'],
                  ),

                  // How sponsorship helps
                  if (sponsee['how_sponsorship_will_help'] != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.favorite_outline,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'How Your Sponsorship Helps',
                                  style: TextStyle(
                                    fontFamily: 'Specify',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            sponsee['how_sponsorship_will_help'],
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

                  // Gallery section
                  _buildGallerySection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark
            ? AppColors.darkMutedForeground
            : AppColors.lightMutedForeground,
        currentIndex: 0, // Dashboard is selected
        onTap: (index) {
          // Navigate to different tabs by popping back to main app
          Navigator.of(context).pop(); // Go back to children screen
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Donations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
