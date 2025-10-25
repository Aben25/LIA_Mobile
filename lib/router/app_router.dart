import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../screens/welcome_screen.dart';
import '../screens/main_app_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../providers/strapi_auth_provider.dart';
import '../utils/app_messaging.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;
  static GlobalKey<NavigatorState> get shellNavigatorKey => _shellNavigatorKey;

  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      routes: [
        // Main route
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) {
            return Consumer<StrapiAuthProvider>(
              builder: (context, authProvider, child) {
                // If auth is not initialized yet, show welcome screen
                if (!authProvider.initialized) {
                  return const WelcomeScreen();
                }
                // If user is authenticated, show main app
                if (authProvider.isAuthenticated) {
                  return const MainAppScreen();
                }
                // If user is not authenticated, show welcome screen
                return const WelcomeScreen();
              },
            );
          },
        ),

        // Email confirmation route - redirect to login after confirmation
        GoRoute(
          path: '/confirm',
          name: 'email-confirmation',
          redirect: (context, state) {
            final token = state.uri.queryParameters['token'];
            if (token == null) {
              // If no token, redirect to home
              return '/';
            }
            // Process confirmation and redirect to login
            _processEmailConfirmation(context, token);
            return '/login';
          },
        ),

        // Password reset route
        GoRoute(
          path: '/reset',
          name: 'password-reset',
          builder: (context, state) {
            final code = state.uri.queryParameters['code'];
            if (code == null) {
              // If no code, redirect to home
              return const WelcomeScreen();
            }
            return ResetPasswordScreen(initialCode: code);
          },
        ),

        // Login screen
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Register screen
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Forgot password screen
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Main app screen (after authentication)
        GoRoute(
          path: '/app',
          name: 'main-app',
          builder: (context, state) => const MainAppScreen(),
        ),
      ],
      // Handle redirects based on authentication state
      redirect: (context, state) {
        final authProvider =
            Provider.of<StrapiAuthProvider>(context, listen: false);

        // If auth is not initialized yet, stay on current route
        if (!authProvider.initialized) {
          return null;
        }

        final isAuthenticated = authProvider.isAuthenticated;
        final isOnAuthRoute =
            state.uri.path == '/confirm' || state.uri.path == '/reset';

        // If user is authenticated and trying to access auth routes, redirect to app
        if (isAuthenticated && isOnAuthRoute) {
          return '/app';
        }

        // If user is not authenticated and trying to access app, redirect to home
        if (!isAuthenticated && state.uri.path == '/app') {
          return '/';
        }

        return null; // No redirect needed
      },
    );
  }

  // Process email confirmation in the background
  static void _processEmailConfirmation(BuildContext context, String token) {
    // Process confirmation asynchronously
    Future.microtask(() async {
      try {
        debugPrint('🔗 [Router] Starting email confirmation for token: $token');

        final authProvider =
            Provider.of<StrapiAuthProvider>(context, listen: false);
        await authProvider.confirmEmail(token);

        debugPrint('🔗 [Router] Email confirmation completed successfully');

        // Show success message
        AppMessaging.showSuccess(
            'Email confirmed successfully! You can now log in.');
      } catch (error) {
        debugPrint('🔗 [Router] Email confirmation failed: $error');
        debugPrint('🔗 [Router] Error type: ${error.runtimeType}');

        // Check if it's a token validation error (already used/expired)
        String errorMessage = error.toString().toLowerCase();
        if (errorMessage.contains('invalid') ||
            errorMessage.contains('expired') ||
            errorMessage.contains('validation')) {
          AppMessaging.showInfo(
              'This confirmation link has already been used or has expired.');
        } else if (errorMessage.contains('server error (404)')) {
          // 404 might mean the confirmation worked but endpoint returned 404
          // Check if user can log in to verify confirmation
          AppMessaging.showInfo(
              'Email confirmation completed. You can now try logging in.');
        } else {
          AppMessaging.showError(
              'Failed to confirm email. Please try again or contact support.');
        }
      }
    });
  }
}
