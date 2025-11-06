import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/strapi_auth_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/easy_loading_config.dart';
import '../children/children_detail_screen.dart';
import '../team/team_membership_form_screen.dart';
import '../../services/dashboard_service.dart';
import '../../services/sponsorship_service.dart';
import '../../models/child.dart';
import '../../constants/api_endpoints.dart';
import '../../components/webview_donation.dart';
import '../../components/additional_sponsorship_modal.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _service = DashboardService();
  final SponsorshipService _sponsorshipService = SponsorshipService();
  List<Child> _children = [];
  bool _loading = true;
  String? _error;
  bool _showAdditionalSponsorshipModal = false;
  bool _showTeamMembershipForm = false;
  UserSponsorshipStatus _sponsorshipStatus = UserSponsorshipStatus.newUser;
  int? _sponsorId;
  String? _sponsorEmail;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    if (!mounted) return;

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final auth = Provider.of<StrapiAuthProvider>(context, listen: false);
      final jwt = auth.jwt;
      if (jwt == null || jwt.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Get user email from auth provider first
      final authProvider =
          Provider.of<StrapiAuthProvider>(context, listen: false);
      final userEmail = authProvider.user?.email;

      if (userEmail == null || userEmail.isEmpty) {
        throw Exception('User email not found');
      }

      // Fetch children, sponsorship status, and sponsor ID in parallel
      final results = await Future.wait([
        _service.getChildrenForUser(jwt: jwt),
        _sponsorshipService.getUserSponsorshipStatus(jwt: jwt),
        _service.getSponsorIdFromSponsors(jwt: jwt, email: userEmail),
      ]);

      final children = results[0] as List<Child>;
      final sponsorshipStatus = results[1] as UserSponsorshipStatus;
      final sponsorId = results[2] as int?;

      debugPrint('🔍 [Dashboard] User email: $userEmail');
      debugPrint('🔍 [Dashboard] Sponsor ID: $sponsorId');
      debugPrint('🔍 [Dashboard] Children count: ${children.length}');

      // Debug: Log all children being loaded in dashboard
      for (final child in children) {
        debugPrint(
            '🔍 [Dashboard] Loading child: id=${child.id}, liaId=${child.liaId}, documentId=${child.documentId}, name=${child.fullName}');
      }

      setState(() {
        _children = children;
        _sponsorshipStatus = sponsorshipStatus;
        _sponsorId = sponsorId;
        _sponsorEmail = userEmail;
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
    await _fetchChildren();
  }

  void _openSponsorshipWebView() {
    debugPrint('🎯 [Dashboard] Sponsorship button pressed!');
    debugPrint('🎯 [Dashboard] User sponsorship status: $_sponsorshipStatus');

    // Check if user should be able to sponsor
    if (!_sponsorshipService.shouldShowSponsorshipButton(_sponsorshipStatus)) {
      EasyLoadingConfig.showError(
          'You have a pending sponsorship request. Please wait for it to be processed.');
      return;
    }

    debugPrint(
        '🎯 [Dashboard] Opening sponsorship WebView for status: $_sponsorshipStatus');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewDonation(
          url: _sponsorshipService.getZeffyFormUrl(_sponsorshipStatus),
          title: _sponsorshipService.getButtonText(_sponsorshipStatus),
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _openTeamMembershipForm() {
    debugPrint('🎯 [Dashboard] Join Team button pressed!');
    setState(() {
      _showTeamMembershipForm = true;
    });
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
              fontFamily: 'Specify',
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
              fontFamily: 'Specify',
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

  Widget _buildChildCard(Child child) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return InkWell(
      onTap: () {
        // Use documentId first (most stable), then liaId, then database id
        final childId = child.documentId ?? child.liaId ?? child.id.toString();
        debugPrint(
            '🔍 [Dashboard] Navigating to child detail for ID: $childId');
        debugPrint('🔍 [Dashboard] Child name: ${child.fullName}');
        debugPrint('🔍 [Dashboard] Child liaId: ${child.liaId}');
        debugPrint('🔍 [Dashboard] Child documentId: ${child.documentId}');
        debugPrint('🔍 [Dashboard] Child database id: ${child.id}');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChildrenDetailScreen(
              childId: childId,
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
                child: Builder(
                  builder: (context) {
                    final url = child.firstImageUrl;
                    if (url == null || url.isEmpty) {
                      return Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      );
                    }
                    // If URL is relative, prefix with Strapi base (without /api)
                    final absoluteUrl = url.startsWith('http')
                        ? url
                        : ApiEndpoints.baseUrl.replaceFirst('/api', '') + url;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network(
                        absoluteUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.primary,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 20),

              // Sponsee Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.fullName ?? 'Unknown Name',
                      style: TextStyle(
                        fontFamily: 'Specify',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_calculateAge(child.dateOfBirth?.toIso8601String())} years old • ${child.location ?? 'Unknown Location'}',
                      style: TextStyle(
                        fontFamily: 'Specify',
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      child.about ??
                          child.aspiration ??
                          'No description available',
                      style: TextStyle(
                        fontFamily: 'Specify',
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
  //               fontFamily: 'Specify',
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
  //               fontFamily: 'Specify',
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
  //                 fontFamily: 'Specify',
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Empty state message
          Padding(
            padding: const EdgeInsets.all(24.0),
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
                    fontFamily: 'Specify',
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
                    fontFamily: 'Specify',
                    fontSize: 16,
                    color: isDark
                        ? AppColors.darkMutedForeground
                        : AppColors.lightMutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _sponsorshipService
                          .shouldShowSponsorshipButton(_sponsorshipStatus)
                      ? () {
                          debugPrint(
                              '🎯 [Dashboard] Sponsorship button onPressed triggered');
                          _openSponsorshipWebView();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    _sponsorshipService.getButtonText(_sponsorshipStatus),
                    style: const TextStyle(
                      fontFamily: 'Specify',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // One-Time Donation Card
          _buildOneTimeDonationSection(),
          // Join Team Card
          _buildJoinTeamSection(),
        ],
      ),
    );
  }

  Widget _buildAdditionalSponsorshipSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sponsor Another Child',
                        style: TextStyle(
                          fontFamily: 'Specify',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'There are more children who could benefit from your support.',
                        style: TextStyle(
                          fontFamily: 'Specify',
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint(
                      '🔍 [Dashboard] Additional sponsorship button pressed');
                  debugPrint('🔍 [Dashboard] Sponsor ID: $_sponsorId');
                  debugPrint('🔍 [Dashboard] Sponsor Email: $_sponsorEmail');

                  if (_sponsorId == null || _sponsorId == 0) {
                    debugPrint('🔍 [Dashboard] Error: Sponsor ID is null or 0');
                    EasyLoadingConfig.showError(
                        'Unable to submit request: Sponsor information not found');
                    return;
                  }

                  setState(() {
                    _showAdditionalSponsorshipModal = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sponsor Another Child',
                      style: TextStyle(
                        fontFamily: 'Specify',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOneTimeDonationSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      padding: const EdgeInsets.all(24.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volunteer_activism,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Make a One-Time Donation',
                  style: TextStyle(
                    fontFamily: 'Specify',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Every donation counts. Your one-time gift helps fund immediate needs like food assistance, educational supplies, and community development projects that improve lives.',
            style: TextStyle(
              fontFamily: 'Specify',
              fontSize: 14,
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Donate Now',
                    style: TextStyle(
                      fontFamily: 'Specify',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDonationPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewDonation(
          url:
              'https://www.zeffy.com/donation-form/make-a-one-time-donation-for-your-sponsee',
          title: 'Make a Donation',
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildJoinTeamSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      padding: const EdgeInsets.all(24.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group_add,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Join Our Team',
                  style: TextStyle(
                    fontFamily: 'Specify',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'We\'d love to have you join our mission! Help us make a difference in children\'s lives.',
            style: TextStyle(
              fontFamily: 'Specify',
              fontSize: 14,
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _openTeamMembershipForm,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: Text(
                'Join the Team',
                style: TextStyle(
                  fontFamily: 'Specify',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
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
              _error ?? 'An unexpected error occurred',
              style: TextStyle(
                fontFamily: 'Specify',
                fontSize: 16,
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchChildren,
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
                  fontFamily: 'Specify',
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
    return Stack(
      children: [
        RefreshIndicator(
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
              else if (_children.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < _children.length) {
                        return _buildChildCard(_children[index]);
                      } else if (index == _children.length) {
                        // Add "Sponsor Another Child" button after all children
                        return _buildAdditionalSponsorshipSection();
                      } else if (index == _children.length + 1) {
                        // Add "One-Time Donation" section
                        return _buildOneTimeDonationSection();
                      } else {
                        // Add "Join Team" section after donation section
                        return _buildJoinTeamSection();
                      }
                    },
                    childCount: _children.length +
                        3, // +1 for sponsorship, +1 for donation, +1 for join team
                  ),
                ),
            ],
          ),
        ),
        // Additional Sponsorship Modal
        AdditionalSponsorshipModal(
          isOpen: _showAdditionalSponsorshipModal,
          onClose: () {
            setState(() {
              _showAdditionalSponsorshipModal = false;
            });
          },
          sponsorId: _sponsorId ?? 0,
          sponsorEmail: _sponsorEmail ?? '',
          onSuccess: () {
            // Refresh the data after successful submission
            _fetchChildren();
          },
        ),

        // Team Membership Form Modal
        if (_showTeamMembershipForm)
          TeamMembershipFormScreen(
            onSuccess: () {
              setState(() {
                _showTeamMembershipForm = false;
              });
            },
            onClose: () {
              setState(() {
                _showTeamMembershipForm = false;
              });
            },
          ),
      ],
    );
  }
}
