import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../constants/app_colors.dart';

class EasyLoadingConfig {
  static void configure() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = AppColors.primary
      ..backgroundColor = Colors.white
      ..indicatorColor = AppColors.primary
      ..textColor = AppColors.primary
      ..maskColor = Colors.black.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false
      ..animationDuration = const Duration(milliseconds: 200)
      ..toastPosition = EasyLoadingToastPosition.bottom
      ..fontSize = 16.0
      ..contentPadding =
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
  }

  static void configureForDarkMode() {
    EasyLoading.instance
      ..backgroundColor = AppColors.darkBackground
      ..textColor = AppColors.darkForeground
      ..indicatorColor = AppColors.primary
      ..maskColor = Colors.black.withOpacity(0.7);
  }

  static void configureForLightMode() {
    EasyLoading.instance
      ..backgroundColor = AppColors.lightBackground
      ..textColor = AppColors.lightForeground
      ..indicatorColor = AppColors.primary
      ..maskColor = Colors.black.withOpacity(0.3);
  }

  // Loading only - no text, just spinner
  static void showLoading() {
    EasyLoading.show(
      status: null, // No text
      maskType: EasyLoadingMaskType.custom,
    );
  }

  // Error messages only (for critical errors)
  static void showError(String message, {Duration? duration}) {
    EasyLoading.showError(
      message,
      duration: duration ?? const Duration(seconds: 3),
      maskType: EasyLoadingMaskType.custom,
    );
  }

  // Dismiss loading
  static void dismiss() {
    EasyLoading.dismiss();
  }

  // Toast for non-critical information
  static void showToast(String message, {Duration? duration}) {
    EasyLoading.showToast(
      message,
      duration: duration ?? const Duration(seconds: 2),
      toastPosition: EasyLoadingToastPosition.bottom,
    );
  }
}
