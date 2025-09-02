import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/supabase_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/easy_loading_config.dart';
import 'login_screen.dart';
import '../main_app_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      EasyLoadingConfig.showLoading();

      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      await supabaseProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        print(
            '🎉 [REGISTER] SignUp completed successfully, showing success message');
        EasyLoadingConfig.dismiss();
        EasyLoadingConfig.showToast(
            'Account created successfully! Please check your email to confirm your account.');

        // Navigate to main app after successful registration
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainAppScreen(),
          ),
        );
      }
    } catch (error) {
      print('❌ [REGISTER] Error occurred:');
      print('❌ [REGISTER] Error type: ${error.runtimeType}');
      print('❌ [REGISTER] Error message: $error');
      print('❌ [REGISTER] Error toString: ${error.toString()}');

      // Check if it's an AuthRetryableFetchException specifically
      if (error.runtimeType
          .toString()
          .contains('AuthRetryableFetchException')) {
        print(
            '🔄 [REGISTER] AuthRetryableFetchException detected - this is a Supabase service issue');
      }

      if (mounted) {
        String errorMessage = error.toString().replaceAll('Exception: ', '');

        // Handle specific Supabase errors
        if (errorMessage.contains('Error sending confirmation email') ||
            errorMessage.contains('error sending confirmation email') ||
            errorMessage.contains('unexpected_failure')) {
          errorMessage =
              'Signup failed due to a temporary service issue. Please try again in a few minutes.';
          print(
              '📧 [REGISTER] Email confirmation service issue detected - signup actually failed');
        } else if (errorMessage.contains('User already registered')) {
          errorMessage =
              'An account with this email already exists. Please sign in or use a different email.';
          print('👤 [REGISTER] User already exists error detected');
        } else if (errorMessage.contains('Invalid email')) {
          errorMessage = 'Please enter a valid email address.';
          print('📧 [REGISTER] Invalid email error detected');
        } else if (errorMessage.contains('Password should be at least')) {
          errorMessage = 'Password must be at least 6 characters long.';
          print('🔒 [REGISTER] Password too short error detected');
        } else if (errorMessage.contains('rate limit')) {
          errorMessage = 'Too many signup attempts. Please try again later.';
          print('⏰ [REGISTER] Rate limit error detected');
        } else if (errorMessage.contains('unexpected failure')) {
          errorMessage =
              'A temporary service issue occurred. Please try again in a few minutes.';
          print('🔧 [REGISTER] Service failure error detected');
        }

        print('❌ [REGISTER] Final error message: $errorMessage');
        EasyLoadingConfig.showError(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
            Icons.arrow_back_ios,
            color:
                isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Welcome Text
                Text(
                  'Join Our Mission',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Create an account to start making a difference',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: isDark
                        ? AppColors.darkMutedForeground
                        : AppColors.lightMutedForeground,
                  ),
                ),

                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Minimum 6 characters',
                    prefixIcon: Icon(
                      Icons.lock_outlined,
                      color: isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter password',
                    prefixIcon: Icon(
                      Icons.lock_outlined,
                      color: isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
