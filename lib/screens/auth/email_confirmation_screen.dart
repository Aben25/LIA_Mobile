import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../providers/strapi_auth_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/app_messaging.dart';

class EmailConfirmationScreen extends StatefulWidget {
  final String? token;

  const EmailConfirmationScreen({super.key, this.token});

  @override
  State<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  bool _isConfirming = false;
  bool _isSuccess = false;
  bool _isError = false;
  String? _errorMessage;
  bool _hasConfirmed = false; // Prevent multiple confirmation attempts

  @override
  void initState() {
    super.initState();
    // If token is provided, automatically start confirmation
    if (widget.token != null && widget.token!.isNotEmpty && !_hasConfirmed) {
      _confirmEmail(widget.token!);
    }
  }

  Future<void> _confirmEmail(String token) async {
    if (_hasConfirmed) return; // Prevent multiple calls

    _hasConfirmed = true; // Mark as confirmed to prevent multiple calls

    setState(() {
      _isConfirming = true;
      _isError = false;
      _errorMessage = null;
    });

    try {
      AppMessaging.showLoading('Confirming your email...');

      final authProvider =
          Provider.of<StrapiAuthProvider>(context, listen: false);
      await authProvider.confirmEmail(token);

      AppMessaging.dismiss();
      AppMessaging.showSuccess('Email confirmed successfully!');

      if (mounted) {
        setState(() {
          _isConfirming = false;
          _isSuccess = true;
        });
      }

      // Wait a moment then navigate to home screen
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.go('/');
        }
      });
    } catch (error) {
      AppMessaging.dismiss();

      // Debug: Print the exact error to understand what's happening
      debugPrint('🔗 [EmailConfirmation] Caught error: $error');
      debugPrint('🔗 [EmailConfirmation] Error type: ${error.runtimeType}');

      // Check if it's a token validation error (already used/expired)
      String errorMessage = error.toString().toLowerCase();
      debugPrint('🔗 [EmailConfirmation] Error message: $errorMessage');
      if (errorMessage.contains('invalid') ||
          errorMessage.contains('expired')) {
        AppMessaging.showInfo(
            'This confirmation link has already been used or has expired.');

        if (mounted) {
          setState(() {
            _isConfirming = false;
            _isSuccess =
                true; // Show success state even for already used tokens
          });
        }

        // Navigate to home screen
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/');
          }
        });
      } else {
        // For any other error, show the error but still navigate to login
        // because if the user can log in, the email is already confirmed
        AppMessaging.showError('Failed to confirm email. Please try again.');

        if (mounted) {
          setState(() {
            _isConfirming = false;
            _isError = true;
            _errorMessage = error.toString();
          });
        }

        // Still navigate to home screen after a delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            context.go('/');
          }
        });
      }
    }
  }

  Future<void> _resendConfirmation() async {
    try {
      AppMessaging.showLoading('Sending confirmation email...');

      final authProvider =
          Provider.of<StrapiAuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user?.email != null) {
        await authProvider.sendEmailConfirmation(user!.email);
        AppMessaging.dismiss();
        AppMessaging.showSuccess(
            'Confirmation email sent! Please check your inbox.');
      } else {
        throw Exception('No email address found');
      }
    } catch (error) {
      AppMessaging.dismiss();
      AppMessaging.showError(
          'Failed to send confirmation email. Please try again.');
    }
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
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Email Confirmation',
          style: TextStyle(
            fontFamily: 'Specify',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color:
                isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              if (_isSuccess) ...[
                // Success State
                Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                Text(
                  'Email Confirmed!',
                  style: TextStyle(
                    fontFamily: 'Specify',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your email has been successfully confirmed. You can now use all features of the app.',
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
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontFamily: 'Specify',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else if (_isError) ...[
                // Error State
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  'Confirmation Failed',
                  style: TextStyle(
                    fontFamily: 'Specify',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ??
                      'Failed to confirm your email. Please try again.',
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go('/'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkMutedForeground
                                : AppColors.lightMutedForeground,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _resendConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Resend Email'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Loading or Manual Confirmation State
                Icon(
                  Icons.email_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  _isConfirming ? 'Confirming Email...' : 'Email Confirmation',
                  style: TextStyle(
                    fontFamily: 'Specify',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _isConfirming
                      ? 'Please wait while we confirm your email address...'
                      : 'We\'ve sent a confirmation email to your inbox. Please check your email and click the confirmation link.',
                  style: TextStyle(
                    fontFamily: 'Specify',
                    fontSize: 16,
                    color: isDark
                        ? AppColors.darkMutedForeground
                        : AppColors.lightMutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (_isConfirming) ...[
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ] else ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _resendConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Resend Confirmation Email',
                        style: TextStyle(
                          fontFamily: 'Specify',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => context.go('/'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkMutedForeground
                              : AppColors.lightMutedForeground,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontFamily: 'Specify',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
