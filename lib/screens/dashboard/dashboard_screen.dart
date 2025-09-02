import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/supabase_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/easy_loading_config.dart';
import '../children/children_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _sponsees = [];
  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSponsoredChildren();
  }

  Future<void> _fetchSponsoredChildren() async {
    if (!mounted) return;

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      final user = supabaseProvider.user;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      print(
          '🔍 [DASHBOARD] Fetching sponsored children for user: ${user.email}');

      // Step 1: Get sponsor ID from user email
      final sponsorResult = await supabaseProvider.supabase
          .from("sponsors")
          .select("id")
          .eq("email", user.email ?? '')
          .maybeSingle(); // Use maybeSingle() instead of single() to handle no results

      if (sponsorResult == null) {
        // User exists but no sponsor record found - this is normal for new users
        print('🔍 [DASHBOARD] No sponsor record found for user: ${user.email}');
        print(
            '🔍 [DASHBOARD] This is normal for new users - sponsor record needs to be created');

        setState(() {
          _sponsees = [];
          _loading = false;
        });
        return;
      }

      print(
          '🔍 [DASHBOARD] Found sponsor record with ID: ${sponsorResult['id']}');

      final sponsorId = sponsorResult['id'] as int;

      // Step 2: Get sponsee relationships
      final relResult = await supabaseProvider.supabase
          .from("sponsors_rels")
          .select("sponsees_id")
          .eq("parent_id", sponsorId);

      if (relResult == null) {
        setState(() {
          _sponsees = [];
          _loading = false;
        });
        return;
      }

      final sponseeIds = relResult
          .map((rel) => rel['sponsees_id'] as int?)
          .where((id) => id != null)
          .cast<int>()
          .toList();

      if (sponseeIds.isEmpty) {
        print(
            '🔍 [DASHBOARD] No sponsee relationships found for sponsor ID: $sponsorId');
        setState(() {
          _sponsees = [];
          _loading = false;
        });
        return;
      }

      print('🔍 [DASHBOARD] Found ${sponseeIds.length} sponsee relationships');

      // Step 3: Get sponsee details with profile pictures
      final sponseesResult =
          await supabaseProvider.supabase.from("sponsees").select('''
            *,
            media:profile_picture_id (
              filename,
              url
            )
          ''').inFilter("id", sponseeIds);

      if (sponseesResult == null) {
        throw Exception('Error fetching sponsees');
      }

      setState(() {
        _sponsees = sponseesResult ?? [];
        _loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _loading = false;
        });
        EasyLoadingConfig.showError('Failed to load sponsored children');
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _refreshing = true;
    });

    await _fetchSponsoredChildren();

    if (mounted) {
      setState(() {
        _refreshing = false;
      });
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

  Widget _buildHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here are the children you\'re helping to support',
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
    );
  }

  Widget _buildSponseeCard(Map<String, dynamic> sponsee) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChildrenDetailScreen(
              childId: sponsee['id'].toString(),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Profile Picture
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: sponsee['media'] != null &&
                        sponsee['media']['filename'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.network(
                          'https://ntckmekstkqxqgigqzgn.supabase.co/storage/v1/object/public/Media/${sponsee['media']['filename']}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.primary,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
              ),

              const SizedBox(width: 20),

              // Sponsee Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sponsee['full_name'] ?? 'Unknown Name',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_calculateAge(sponsee['date_of_birth'])} years old • ${sponsee['location'] ?? 'Unknown Location'}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sponsee['about'] ??
                          sponsee['aspiration'] ??
                          'No description available',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildEmptyState() {
  //   final themeProvider = Provider.of<ThemeProvider>(context);
  //   final isDark = themeProvider.isDarkMode;

  //   return Container(
  //     padding: const EdgeInsets.all(24.0),
  //     child: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.favorite_border,
  //             size: 80,
  //             color: isDark
  //                 ? AppColors.darkMutedForeground
  //                 : AppColors.lightMutedForeground,
  //           ),
  //           const SizedBox(height: 24),
  //           Text(
  //             'No Sponsored Children Yet',
  //             style: TextStyle(
  //               fontFamily: 'Poppins',
  //               fontSize: 24,
  //               fontWeight: FontWeight.bold,
  //               color: isDark
  //                   ? AppColors.darkForeground
  //                   : AppColors.lightForeground,
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             'You haven\'t been assigned any sponsored children yet. This usually happens for new users or when your account is still being set up.',
  //             style: TextStyle(
  //               fontFamily: 'Poppins',
  //               fontSize: 16,
  //               color: isDark
  //                   ? AppColors.darkMutedForeground
  //                   : AppColors.lightMutedForeground,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //           const SizedBox(height: 32),
  //           ElevatedButton(
  //             onPressed: () {
  //               EasyLoadingConfig.showInfo('Sponsorship feature coming soon!');
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: AppColors.primary,
  //               foregroundColor: Colors.white,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  //             ),
  //             child: const Text(
  //               'Start Sponsoring',
  //               style: TextStyle(
  //                 fontFamily: 'Poppins',
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border,
                size: 80,
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
              ),
              const SizedBox(height: 24),
              Text(
                'No Sponsored Children Yet',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'You haven\'t been assigned any sponsored children yet. This usually happens for new users or when your account is still being set up.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: isDark
                      ? AppColors.darkMutedForeground
                      : AppColors.lightMutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  EasyLoadingConfig.showToast(
                      'Sponsorship feature coming soon!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Start Sponsoring',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(24.0),
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
                fontSize: 16,
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchSponsoredChildren,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // Content
          if (_loading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildErrorState(),
            )
          else if (_sponsees.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildSponseeCard(_sponsees[index]),
                childCount: _sponsees.length,
              ),
            ),
        ],
      ),
    );
  }
}
