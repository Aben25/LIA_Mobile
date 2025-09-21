import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../constants/app_colors.dart';

class AppMessaging {
  // Private constructor to prevent instantiation
  AppMessaging._();

  /// Configure EasyLoading for the current theme
  static void configureForTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 12.0
      ..progressColor = AppColors.primary
      ..backgroundColor = isDark ? AppColors.darkCard : AppColors.lightCard
      ..indicatorColor = AppColors.primary
      ..textColor =
          isDark ? AppColors.darkForeground : AppColors.lightForeground
      ..maskColor =
          isDark ? Colors.black.withOpacity(0.7) : Colors.black.withOpacity(0.3)
      ..userInteractions = false
      ..dismissOnTap = false
      ..animationDuration = const Duration(milliseconds: 200)
      ..toastPosition = EasyLoadingToastPosition.bottom
      ..fontSize = 16.0
      ..contentPadding =
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
  }

  /// Show loading spinner with optional message
  static void showLoading([String? message]) {
    EasyLoading.show(
      status: message,
      maskType: EasyLoadingMaskType.custom,
    );
  }

  /// Show success message
  static void showSuccess(String message, {Duration? duration}) {
    EasyLoading.showSuccess(
      message,
      duration: duration ?? const Duration(seconds: 2),
      maskType: EasyLoadingMaskType.custom,
    );
  }

  /// Show error message
  static void showError(String message, {Duration? duration}) {
    EasyLoading.showError(
      message,
      duration: duration ?? const Duration(seconds: 3),
      maskType: EasyLoadingMaskType.custom,
    );
  }

  /// Show info message
  static void showInfo(String message, {Duration? duration}) {
    EasyLoading.showInfo(
      message,
      duration: duration ?? const Duration(seconds: 2),
      maskType: EasyLoadingMaskType.custom,
    );
  }

  /// Show warning message
  static void showWarning(String message, {Duration? duration}) {
    EasyLoading.show(
      status: message,
      maskType: EasyLoadingMaskType.custom,
      indicator: const Icon(
        Icons.warning_rounded,
        color: AppColors.warning,
        size: 45,
      ),
    );
    // Auto dismiss after duration
    Future.delayed(duration ?? const Duration(seconds: 2), () {
      EasyLoading.dismiss();
    });
  }

  /// Show toast notification (non-blocking)
  static void showToast(
    String message, {
    Duration? duration,
    ToastType type = ToastType.info,
  }) {
    EasyLoading.showToast(
      message,
      duration: duration ?? const Duration(seconds: 2),
      toastPosition: EasyLoadingToastPosition.bottom,
    );
  }

  /// Dismiss any current loading/message
  static void dismiss() {
    EasyLoading.dismiss();
  }

  /// Get appropriate color for toast type
  static Color _getToastColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.info;
    }
  }

  /// Show custom loading with progress
  static void showProgress(double progress, [String? message]) {
    EasyLoading.showProgress(
      progress,
      status: message,
      maskType: EasyLoadingMaskType.custom,
    );
  }
}

enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Enhanced error message widget for form validation
class AppErrorMessage extends StatelessWidget {
  final String? message;
  final bool isVisible;
  final EdgeInsetsGeometry? padding;

  const AppErrorMessage({
    super.key,
    this.message,
    this.isVisible = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: padding ?? const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                fontFamily: 'Specify',
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Enhanced success message widget
class AppSuccessMessage extends StatelessWidget {
  final String? message;
  final bool isVisible;
  final EdgeInsetsGeometry? padding;

  const AppSuccessMessage({
    super.key,
    this.message,
    this.isVisible = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: padding ?? const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                fontFamily: 'Specify',
                fontSize: 12,
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Enhanced info message widget
class AppInfoMessage extends StatelessWidget {
  final String? message;
  final bool isVisible;
  final EdgeInsetsGeometry? padding;

  const AppInfoMessage({
    super.key,
    this.message,
    this.isVisible = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: padding ?? const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.info,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                fontFamily: 'Specify',
                fontSize: 12,
                color: AppColors.info,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
