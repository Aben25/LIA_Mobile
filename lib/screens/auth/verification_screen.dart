import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/easy_loading_config.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<FirebaseAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your email'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Check your inbox',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a verification link to ${auth.user?.email ?? 'your email'}.'
              ' Please verify your email, then tap "I verified" below.',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        EasyLoadingConfig.showLoading();
                        await auth.sendEmailVerification();
                        EasyLoadingConfig.dismiss();
                        EasyLoadingConfig.showToast('Verification email sent');
                      } catch (e) {
                        EasyLoadingConfig.showError(e.toString().replaceAll('Exception: ', ''));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Resend Email',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        EasyLoadingConfig.showLoading();
                        await auth.reloadUser();
                        EasyLoadingConfig.dismiss();
                        if (auth.isEmailVerified) {
                          Navigator.of(context).maybePop();
                        } else {
                          EasyLoadingConfig.showToast('Not verified yet.');
                        }
                      } catch (e) {
                        EasyLoadingConfig.showError(e.toString().replaceAll('Exception: ', ''));
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'I Verified',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () async {
                  await auth.signOut();
                },
                child: const Text(
                  'Sign out',
                  style: TextStyle(fontFamily: 'Poppins', color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
