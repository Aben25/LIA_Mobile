import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'providers/theme_provider.dart';
// Commented out during transition to Strapi
// import 'providers/supabase_provider.dart';
// import 'providers/firebase_auth_provider.dart';
import 'providers/strapi_auth_provider.dart';
// import 'config/supabase_config.dart';
import 'utils/app_messaging.dart';
import 'services/deep_link_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_app_screen.dart';
import 'screens/auth/email_confirmation_screen.dart';
import 'screens/auth/reset_password_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// Global navigator key for deep link navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (commented out during transition to Strapi)
  // await SupabaseConfig.initialize();

  // Initialize Deep Link Service
  await DeepLinkService().initialize();

  // Set up deep link listeners once at app level
  _setupGlobalDeepLinkListeners();

  // Configure EasyLoading will be done in the widget
  // Initialize Firebase (commented out during transition to Strapi)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const LoveInActionApp());
}

bool _globalListenersSetup = false; // Prevent multiple setup

void _setupGlobalDeepLinkListeners() {
  if (_globalListenersSetup) {
    debugPrint('🔗 [Global] Deep link listeners already set up, skipping...');
    return;
  }

  _globalListenersSetup = true;
  final deepLinkService = DeepLinkService();

  debugPrint('🔗 [Global] Setting up deep link listeners once at app level...');

  // Listen for email confirmation deep links
  deepLinkService.emailConfirmationStream.listen((token) {
    debugPrint('🔗 [Global] Received email confirmation token: $token');
    _handleGlobalEmailConfirmation(token);
  });

  // Listen for password reset deep links
  deepLinkService.passwordResetStream.listen((code) {
    debugPrint('🔗 [Global] Received password reset code: $code');
    _handleGlobalPasswordReset(code);
  });

  debugPrint('🔗 [Global] Deep link listeners set up successfully');

  // Process initial deep link after listeners are set up
  WidgetsBinding.instance.addPostFrameCallback((_) {
    debugPrint(
        '🔗 [Global] Checking for initial deep link after listeners are ready...');

    // Get the initial link from the service
    final initialLink = deepLinkService.initialLink;
    if (initialLink != null) {
      debugPrint('🔗 [Global] Found initial link: $initialLink');

      try {
        final uri = Uri.parse(initialLink);
        if (uri.host == 'thomasasfaw.com' && uri.path.startsWith('/app/')) {
          final pathSegments = uri.pathSegments;
          if (pathSegments.length >= 2 && pathSegments[0] == 'app') {
            final action = pathSegments[1];
            final queryParams = uri.queryParameters;

            debugPrint(
                '🔗 [Global] Processing initial $action with params: $queryParams');

            switch (action) {
              case 'confirm':
                final token = queryParams['token'];
                if (token != null) {
                  debugPrint(
                      '🔗 [Global] Triggering email confirmation stream');
                  deepLinkService.handleEmailConfirmation(token);
                  deepLinkService.clearInitialLink(); // Clear after processing
                }
                break;
              case 'reset':
                final code = queryParams['code'];
                if (code != null) {
                  debugPrint('🔗 [Global] Triggering password reset stream');
                  deepLinkService.handlePasswordReset(code);
                  deepLinkService.clearInitialLink(); // Clear after processing
                }
                break;
            }
          }
        }
      } catch (e) {
        debugPrint('🔗 [Global] Error processing initial link: $e');
      }
    } else {
      debugPrint('🔗 [Global] No initial link found');
    }
  });
}

void _handleGlobalEmailConfirmation(String token) {
  debugPrint('🔗 [Global] Handling email confirmation with token: $token');
  _waitForNavigatorAndNavigate(token, _navigateToEmailConfirmation);
}

void _handleGlobalPasswordReset(String code) {
  debugPrint('🔗 [Global] Handling password reset with code: $code');
  _waitForNavigatorAndNavigate(code, _navigateToPasswordReset);
}

void _waitForNavigatorAndNavigate(
    String token, Function(String) navigateFunction) {
  // Use a simpler approach - wait for the next frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Try multiple times with increasing delays
    Future.delayed(const Duration(milliseconds: 500), () {
      final navigator = navigatorKey.currentState;
      if (navigator != null && navigator.mounted) {
        debugPrint('🔗 [Global] Navigator ready, navigating...');
        navigateFunction(token);
      } else {
        debugPrint('🔗 [Global] Navigator still not ready, will retry...');
        // Retry after a longer delay
        Future.delayed(const Duration(milliseconds: 1000), () {
          final retryNavigator = navigatorKey.currentState;
          if (retryNavigator != null && retryNavigator.mounted) {
            debugPrint('🔗 [Global] Navigator ready on retry, navigating...');
            navigateFunction(token);
          } else {
            debugPrint(
                '🔗 [Global] Navigator still not ready, skipping navigation');
          }
        });
      }
    });
  });
}

void _navigateToEmailConfirmation(String token) {
  debugPrint('🔗 [Global] Navigating to EmailConfirmationScreen');
  navigatorKey.currentState?.pushReplacement(
    MaterialPageRoute(
      builder: (context) => EmailConfirmationScreen(token: token),
    ),
  );
}

void _navigateToPasswordReset(String code) {
  debugPrint('🔗 [Global] Navigating to ResetPasswordScreen');
  navigatorKey.currentState?.pushReplacement(
    MaterialPageRoute(
      builder: (context) => ResetPasswordScreen(initialCode: code),
    ),
  );
}

class LoveInActionApp extends StatelessWidget {
  const LoveInActionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Commented out during transition to Strapi
        // ChangeNotifierProvider(create: (_) => SupabaseProvider()),
        // ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
        ChangeNotifierProvider(create: (_) {
          final provider = StrapiAuthProvider();
          // Initialize auth once when provider is created
          provider.initializeAuth();
          return provider;
        }),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Configure messaging for current theme
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppMessaging.configureForTheme(context);
          });

          return DeepLinkHandler(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Love in Action',
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.themeMode,
              theme: themeProvider.getThemeData(Brightness.light),
              darkTheme: themeProvider.getThemeData(Brightness.dark),
              home: Consumer<StrapiAuthProvider>(
                builder: (context, strapiAuthProvider, child) {
                  // Use Strapi for authentication gating
                  if (!strapiAuthProvider.initialized) {
                    return const WelcomeScreen();
                  }
                  if (!strapiAuthProvider.isAuthenticated) {
                    return const WelcomeScreen();
                  }
                  return const MainAppScreen();
                },
              ),
              builder: EasyLoading.init(),
            ),
          );
        },
      ),
    );
  }
}

class DeepLinkHandler extends StatelessWidget {
  final Widget child;

  const DeepLinkHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Deep link handling is now done globally in main()
    return child;
  }
}
