import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/supabase_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/easy_loading_config.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordValid = true;
  bool _isConfirmValid = true;
  bool _isSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validatePassword(String password) {
    return password.length >= 6; // Minimum 6 characters
  }

  Future<void> _handleResetPassword() async {
    // Reset validations
    setState(() {
      _isPasswordValid = true;
      _isConfirmValid = true;
    });

    // Validate fields
    bool isValid = true;

    if (!_passwordController.text.isNotEmpty ||
        !_validatePassword(_passwordController.text)) {
      setState(() {
        _isPasswordValid = false;
      });
      isValid = false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _isConfirmValid = false;
      });
      isValid = false;
    }

    if (!isValid) {
      return;
    }

    try {
      EasyLoadingConfig.showLoading();

      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);

      await supabaseProvider.updatePassword(_passwordController.text);

      EasyLoadingConfig.dismiss();
      EasyLoadingConfig.showToast('Password updated successfully!');

      setState(() {
        _isSuccess = true;
      });

      // Success is handled in the UI
    } catch (error) {
      EasyLoadingConfig.dismiss();
      print('Error updating password: $error');
      EasyLoadingConfig.showError(
        'Failed to update password. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ),
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),

                const SizedBox(height: 20),

                if (!_isSuccess) ...[
                  // Title
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Enter your new password below.',
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

                  // New Password Field
                  Text(
                    'New Password',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Minimum 6 characters',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _isPasswordValid
                              ? (isDark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground)
                              : Colors.red,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkMutedForeground
                              : AppColors.lightMutedForeground,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                    onChanged: (value) {
                      if (_isPasswordValid == false) {
                        setState(() {
                          _isPasswordValid = true;
                        });
                      }
                      if (_confirmPasswordController.text.isNotEmpty) {
                        setState(() {
                          _isConfirmValid =
                              value == _confirmPasswordController.text;
                        });
                      }
                    },
                  ),

                  if (!_isPasswordValid) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Password must be at least 6 characters',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Confirm Password Field
                  Text(
                    'Confirm New Password',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Re-enter password',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _isConfirmValid
                              ? (isDark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground)
                              : Colors.red,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkMutedForeground
                              : AppColors.lightMutedForeground,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                    onChanged: (value) {
                      if (_isConfirmValid == false) {
                        setState(() {
                          _isConfirmValid = true;
                        });
                      }
                      setState(() {
                        _isConfirmValid = _passwordController.text == value;
                      });
                    },
                  ),

                  if (!_isConfirmValid) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Passwords do not match',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Update Password',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Success State
                  const SizedBox(height: 60),

                  Icon(
                    Icons.check_circle,
                    size: 60,
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Password Updated',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Your password has been updated successfully. You can now sign in with your new password.',
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

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Go to Sign In',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
