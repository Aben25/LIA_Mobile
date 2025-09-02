import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/supabase_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/easy_loading_config.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Map<String, dynamic>> _projects = [];
  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    if (!mounted) return;

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);

      print('🔍 [PROJECTS] Fetching projects...');

      final projectsResult =
          await supabaseProvider.supabase.from("projects").select('''
            *,
            media:project_profile_picture_id (
              filename,
              url
            )
          ''');

      if (projectsResult == null) {
        throw Exception('Error fetching projects');
      }

      // Log the first project to debug image issues
      if (projectsResult.isNotEmpty) {
        print('🔍 [PROJECTS] First project data: ${projectsResult.first}');
      }

      print('🔍 [PROJECTS] Found ${projectsResult.length} projects');

      setState(() {
        _projects = projectsResult;
        _loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _loading = false;
        });
        EasyLoadingConfig.showError('Failed to load projects');
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _refreshing = true;
    });

    await _fetchProjects();

    if (mounted) {
      setState(() {
        _refreshing = false;
      });
    }
  }

  void _navigateToProjectDetails(int projectId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(
          projectId: projectId.toString(),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final imageUrl = project['media']?['filename'] != null
        ? 'https://ntckmekstkqxqgigqzgn.supabase.co/storage/v1/object/public/Media/${project['media']['filename']}'
        : null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24.0),
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToProjectDetails(project['id']),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image
            if (imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl,
                  height: 192,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 192,
                      width: double.infinity,
                      color: isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground,
                      child: Icon(
                        Icons.construction_outlined,
                        size: 48,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 192,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkMutedForeground
                      : AppColors.lightMutedForeground,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Icon(
                  Icons.construction_outlined,
                  size: 48,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),

            // Project Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Type Badge
                  Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      project['project_type'] ?? 'Unknown Type',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  // Project Title
                  Text(
                    project['project_title'] ?? 'Untitled Project',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Project Goal
                  Text(
                    project['goal'] ?? 'No description available',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Impact Section
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? AppColors.darkMutedForeground
                              : AppColors.lightMutedForeground,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Impact:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project['impact'] ??
                              'No impact information available',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: isDark
                                ? AppColors.darkMutedForeground
                                : AppColors.lightMutedForeground,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
              borderRadius: BorderRadius.circular(48),
            ),
            child: Icon(
              Icons.construction_outlined,
              size: 48,
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Projects Found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'There are no active projects at the moment. Please check back later.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projects',
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

            // Description
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Explore our ongoing projects that are making a difference.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    color: isDark
                        ? AppColors.darkMutedForeground
                        : AppColors.lightMutedForeground,
                  ),
                ),
              ),
            ),

            // Content
            if (_loading && !_refreshing)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
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
                        'Something went wrong',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error ?? 'An unexpected error occurred',
                        style: TextStyle(fontFamily: 'Poppins'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _fetchProjects,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_projects.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildProjectCard(_projects[index]),
                    childCount: _projects.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
