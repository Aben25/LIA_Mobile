import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/strapi_auth_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/easy_loading_config.dart';
import '../../services/google_sheets_service.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  List<DonationRecord> _userDonations = [];
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    if (!mounted) return;

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // Commented out during Strapi transition
      // final supabaseProvider =
      //     Provider.of<SupabaseProvider>(context, listen: false);

      print('🔍 [DONATIONS] Loading donations...');

      // Fetch real donations from Google Sheets
      final allDonations = await GoogleSheetsService.fetchDonations();

      // Filter donations for the current user
      final strapiProvider =
          Provider.of<StrapiAuthProvider>(context, listen: false);
      final userEmail = strapiProvider.user?.email;
      if (userEmail != null) {
        final userEmailLower = userEmail.toLowerCase().trim();
        final username = userEmailLower.split('@')[0];

        // Super flexible filtering that tries multiple approaches (same as Expo app)
        final filtered = allDonations.where((donation) {
          // Check email field
          if (donation.email != null) {
            final emailLower = donation.email!.toLowerCase().trim();
            if (emailLower.contains(userEmailLower) ||
                userEmailLower.contains(emailLower)) {
              return true;
            }
          }

          // Check donor name for username match
          if (username.isNotEmpty &&
              donation.donor.toLowerCase().contains(username)) {
            return true;
          }

          return false;
        }).toList();

        setState(() {
          _userDonations = filtered;
          _totalAmount =
              filtered.fold(0.0, (sum, donation) => sum + donation.amount);
          _loading = false;
        });
      } else {
        setState(() {
          _userDonations = [];
          _totalAmount = 0.0;
          _loading = false;
        });
      }

      print(
          '🔍 [DONATIONS] Loaded ${_userDonations.length} donations from Google Sheets');
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _loading = false;
        });
        EasyLoadingConfig.showError('Failed to load donations');
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _refreshing = true;
    });

    await _loadDonations();

    if (mounted) {
      setState(() {
        _refreshing = false;
      });
    }
  }

  Widget _buildDonationItem(DonationRecord donation) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final status = donation.status.toLowerCase();
    Color statusColor;
    if (status.contains('succeed') || status.contains('completed')) {
      statusColor = Colors.green;
    } else if (status.contains('process') || status.contains('pending')) {
      statusColor = Colors.purple;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount and Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${donation.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    donation.status,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: isDark
                  ? AppColors.darkMutedForeground.withOpacity(0.1)
                  : AppColors.lightMutedForeground.withOpacity(0.1),
            ),
            const SizedBox(height: 16),

            // Donation Details
            Column(
              children: [
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      donation.date,
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
                const SizedBox(height: 8),

                // Project
                if (donation.project.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.label_outlined,
                        size: 16,
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        donation.project,
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
                if (donation.project.isNotEmpty) const SizedBox(height: 8),

                // Payment Method
                if (donation.paymentMethod != null &&
                    donation.paymentMethod!.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.credit_card_outlined,
                        size: 16,
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        donation.paymentMethod!,
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
                if (donation.paymentMethod != null &&
                    donation.paymentMethod!.isNotEmpty)
                  const SizedBox(height: 8),

                // Notes
                if (donation.notes != null && donation.notes!.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          donation.notes!,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkMutedForeground
                                : AppColors.lightMutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (_error != null) {
      return Center(
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
              onPressed: _loadDonations,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
          const SizedBox(height: 24),
          Text(
            'No donations found for your account',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your generous contributions will appear here once you make a donation',
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
                      'My Donations',
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

            // Summary Card
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkMutedForeground
                        : AppColors.lightMutedForeground,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Donations',
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
                            '\$${_totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_userDonations.length} ${_userDonations.length == 1 ? 'donation' : 'donations'}',
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
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.favorite,
                        size: 32,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            // Content
            if (_loading && !_refreshing)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading donations...'),
                    ],
                  ),
                ),
              )
            else if (_userDonations.isNotEmpty)
              // Donations List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildDonationItem(_userDonations[index]),
                    childCount: _userDonations.length,
                  ),
                ),
              )
            else
              // Empty State
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
