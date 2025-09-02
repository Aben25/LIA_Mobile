import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/supabase_provider.dart';
import '../constants/app_colors.dart';
import '../models/project.dart';
import '../utils/easy_loading_config.dart';
import 'auth/login_screen.dart';
import 'projects/project_detail_screen.dart';

class GuestProjectsScreen extends StatefulWidget {
  const GuestProjectsScreen({super.key});

  @override
  State<GuestProjectsScreen> createState() => _GuestProjectsScreenState();
}

class _GuestProjectsScreenState extends State<GuestProjectsScreen> {
  List<Map<String, dynamic>> _projects = [];
  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    if (!mounted) return;

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      print('🔍 [GUEST] Loading projects...');

      // Fetch projects from Supabase (public access)
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      final projects = await supabaseProvider.fetchProjects();

      if (mounted) {
        setState(() {
          _projects = projects;
          _loading = false;
        });
      }

      print('🔍 [GUEST] Loaded ${_projects.length} projects');
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

    await _loadProjects();

    if (mounted) {
      setState(() {
        _refreshing = false;
      });
    }
  }

  void _navigateToProjectDetails(String projectId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(
          projectId: projectId,
        ),
      ),
    );
  }

  void _navigateToSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final projectTitle = project['project_title'] ?? 'Untitled Project';
    final goal = project['goal'];
    final impact = project['impact'];
    final projectType = project['project_type'] ?? 'Project';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
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
        onTap: () => _navigateToProjectDetails(project['id'].toString()),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Type Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  projectType,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Project Title
              Text(
                projectTitle,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Goal
              if (goal != null && goal.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goal:',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),

              // Impact
              if (impact != null && impact.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Impact:',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      impact,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Sign in prompt
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sign in to donate and support this project',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          Icon(
            Icons.search_off,
            size: 80,
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
          const SizedBox(height: 24),
          Text(
            'No projects available',
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
            'Check back later for new projects',
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
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
          'Browse Projects',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color:
                isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _navigateToSignIn,
            child: Text(
              'Sign In',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _loading && !_refreshing
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading projects...'),
                  ],
                ),
              )
            : _error != null
                ? Center(
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
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error ?? 'An unexpected error occurred',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark
                                ? AppColors.darkMutedForeground
                                : AppColors.lightMutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _loadProjects,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      // Header message
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'Sign in to donate and support these amazing projects',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: isDark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      // Projects list
                      if (_projects.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _buildProjectCard(_projects[index]),
                              childCount: _projects.length,
                            ),
                          ),
                        )
                      else
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(),
                        ),
                    ],
                  ),
      ),
    );
  }
}
