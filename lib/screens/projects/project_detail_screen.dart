import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/supabase_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/easy_loading_config.dart';
import '../../components/webview_donation.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Map<String, dynamic>? _project;
  bool _loading = true;
  String? _error;
  bool _showDonationWebView = false;

  @override
  void initState() {
    super.initState();
    _fetchProjectDetails();
  }

  Future<void> _fetchProjectDetails() async {
    if (!mounted) return;

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      final supabase = supabaseProvider.supabase;

      print(
          '🔍 [PROJECT] Fetching project details for ID: ${widget.projectId}');

      final response = await supabase.from('projects').select('''
            *,
            media:project_profile_picture_id (
              filename,
              url
            )
          ''').eq('id', widget.projectId).single();

      if (mounted) {
        setState(() {
          _project = response;
          _loading = false;
        });
      }

      // Fetch gallery media if gallery_id exists
      if (_project != null && _project!['gallery_id'] != null) {
        try {
          final galleryResponse =
              await supabase.from('gallery_media').select('''
                id,
                image_id,
                caption,
                media_type,
                media:image_id (
                  filename,
                  url
                )
              ''').eq('_parent_id', _project!['gallery_id']);

          if (mounted && galleryResponse != null) {
            setState(() {
              _project!['gallery_media'] = galleryResponse;
            });
          }
        } catch (galleryError) {
          print('🔍 [PROJECT] Error fetching gallery: $galleryError');
        }
      }

      print('🔍 [PROJECT] Fetched project data: ${_project?['project_title']}');
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _loading = false;
        });
        EasyLoadingConfig.showError('Failed to load project details');
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
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
                      fontFamily: 'Poppins',
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
                fontFamily: 'Poppins',
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

  Widget _buildGallerySection() {
    if (_project == null || _project!['gallery_media'] == null)
      return const SizedBox.shrink();

    final galleryMedia =
        List<Map<String, dynamic>>.from(_project!['gallery_media'] ?? []);

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
                    'Project Gallery',
                    style: TextStyle(
                      fontFamily: 'Poppins',
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
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: galleryMedia.length,
                itemBuilder: (context, index) {
                  final media = galleryMedia[index];
                  final filename = media['media']?['filename'];

                  if (filename == null) {
                    return Container(
                      width: 256,
                      margin: const EdgeInsets.only(right: 16),
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

                  return Container(
                    width: 256,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            height: 120,
                            width: 256,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                width: 256,
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
                        if (media['caption'] != null &&
                            media['caption'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            media['caption'].toString(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDonationPage() {
    setState(() {
      _showDonationWebView = true;
    });
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
              Text('Loading project details...'),
            ],
          ),
        ),
      );
    }

    if (_error != null || _project == null) {
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
                'Could not find the project\'s information',
                style: TextStyle(
                  fontFamily: 'Poppins',
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
                onPressed: _fetchProjectDetails,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final project = _project!;
    final projectTitle = project['project_title'] ?? 'Unknown Project';
    final imageUrl = project['media']?['filename'] != null
        ? 'https://ntckmekstkqxqgigqzgn.supabase.co/storage/v1/object/public/Media/${project['media']['filename']}'
        : null;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Project Details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              // Header with project image
              SliverToBoxAdapter(
                child: Container(
                  height: 288,
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
                                Icons.construction_outlined,
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
                            Icons.construction_outlined,
                            size: 80,
                            color: isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground,
                          ),
                        ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project type badge
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          project['project_type'] ?? 'Project',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      // Project title
                      Text(
                        projectTitle,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Last updated
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 16,
                            color: isDark
                                ? AppColors.darkMutedForeground
                                : AppColors.lightMutedForeground,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Last updated: ${_formatDate(project['updated_at'])}',
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
                      const SizedBox(height: 24),

                      // Goal section
                      if (project['goal'] != null)
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
                                      Icons.flag_outlined,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Project Goal',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
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
                                project['goal'],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: isDark
                                      ? AppColors.darkMutedForeground
                                      : AppColors.lightMutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Impact section
                      if (project['impact'] != null)
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
                                      Icons.trending_up_outlined,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Expected Impact',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
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
                                project['impact'],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
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

                      // Support button
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 24, bottom: 32),
                        child: ElevatedButton(
                          onPressed: _openDonationPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Support This Project',
                            style: TextStyle(
                              fontFamily: 'Poppins',
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
            currentIndex: 1, // Projects is selected
            onTap: (index) {
              // Navigate to different tabs by popping back to main app
              Navigator.of(context).pop(); // Go back to projects screen
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
        ),
        // WebView Donation Modal
        if (_showDonationWebView)
          WebViewDonation(
            url:
                'https://www.zeffy.com/donation-form/make-a-one-time-donation-for-your-sponsee',
            onClose: () {
              setState(() {
                _showDonationWebView = false;
              });
            },
          ),
      ],
    );
  }
}
