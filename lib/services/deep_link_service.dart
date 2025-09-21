import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  String? _initialLink;
  bool _initialLinkProcessed = false;
  bool _isInitialized = false; // Prevent multiple initialization

  /// Initialize the deep link service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint(
          '🔗 [DeepLink] Deep link service already initialized, skipping...');
      return;
    }

    _isInitialized = true;
    try {
      debugPrint('🔗 [DeepLink] Initializing deep link service...');

      // Get the initial link if the app was opened with a link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _initialLink = initialUri.toString();
        debugPrint('🔗 [DeepLink] Initial link stored: $_initialLink');
        // Don't process it immediately - let main.dart handle it after listeners are set up
      } else {
        debugPrint('🔗 [DeepLink] No initial link found');
      }

      // Listen for incoming links while the app is running (only set up once)
      _appLinks.uriLinkStream.listen(
        (Uri uri) {
          debugPrint(
              '🔗 [DeepLink] Incoming link while running: ${uri.toString()}');
          _handleIncomingLink(uri);
        },
        onError: (err) {
          debugPrint('🔗 [DeepLink] Stream error: $err');
        },
      );

      debugPrint('🔗 [DeepLink] Deep link service initialized successfully');
    } catch (e) {
      debugPrint('🔗 [DeepLink] Initialization error: $e');
    }
  }

  /// Handle incoming deep links
  void _handleIncomingLink(Uri uri) {
    debugPrint('🔗 [DeepLink] Handling link: ${uri.toString()}');

    switch (uri.scheme) {
      case 'loveinaction':
        _handleLoveInActionLink(uri);
        break;
      case 'https':
      case 'http':
        if (uri.host == 'thomasasfaw.com' && uri.path.startsWith('/app/')) {
          debugPrint('🔗 [DeepLink] Handling HTTP app link');
          _handleAppLink(uri);
        } else {
          debugPrint(
              '🔗 [DeepLink] Unhandled HTTP/HTTPS URL: ${uri.host}${uri.path}');
        }
        break;
      default:
        debugPrint('🔗 [DeepLink] Unhandled scheme: ${uri.scheme}');
    }
  }

  /// Handle HTTP/HTTPS app links
  void _handleAppLink(Uri uri) {
    debugPrint('🔗 [DeepLink] App link: ${uri.path}');

    final pathSegments = uri.pathSegments;
    if (pathSegments.length >= 2 && pathSegments[0] == 'app') {
      final action = pathSegments[1];
      final queryParams = uri.queryParameters;

      debugPrint(
          '🔗 [DeepLink] App link action: $action, params: $queryParams');

      switch (action) {
        case 'confirm':
          handleEmailConfirmation(queryParams['token']);
          break;
        case 'reset':
          handlePasswordReset(queryParams['code']);
          break;
        default:
          debugPrint('🔗 [DeepLink] Unhandled app link action: $action');
      }
    } else {
      debugPrint('🔗 [DeepLink] Invalid app link path: ${uri.path}');
    }
  }

  /// Handle Love in Action specific deep links
  void _handleLoveInActionLink(Uri uri) {
    final path = uri.host;
    final queryParams = uri.queryParameters;

    debugPrint('🔗 [DeepLink] Path: $path, Params: $queryParams');

    switch (path) {
      case 'confirm':
        handleEmailConfirmation(queryParams['token']);
        break;
      case 'reset':
        handlePasswordReset(queryParams['code']);
        break;
      default:
        debugPrint('🔗 [DeepLink] Unhandled path: $path');
    }
  }

  /// Handle email confirmation deep links
  void handleEmailConfirmation(String? token) {
    if (token == null || token.isEmpty) {
      debugPrint('🔗 [DeepLink] Email confirmation: No token provided');
      return;
    }

    debugPrint('🔗 [DeepLink] Email confirmation token: $token');

    // Notify listeners that email confirmation is needed
    _emailConfirmationController.add(token);
  }

  /// Handle password reset deep links
  void handlePasswordReset(String? code) {
    if (code == null || code.isEmpty) {
      debugPrint('🔗 [DeepLink] Password reset: No code provided');
      return;
    }

    debugPrint('🔗 [DeepLink] Password reset code: $code');
    debugPrint('🔗 [DeepLink] About to trigger password reset stream...');

    // Notify listeners that password reset is needed
    _passwordResetController.add(code);

    debugPrint('🔗 [DeepLink] Password reset stream triggered');
  }

  // Controllers for notifying other parts of the app
  final StreamController<String> _emailConfirmationController =
      StreamController<String>.broadcast();
  final StreamController<String> _passwordResetController =
      StreamController<String>.broadcast();

  // Getters for streams
  Stream<String> get emailConfirmationStream =>
      _emailConfirmationController.stream;
  Stream<String> get passwordResetStream => _passwordResetController.stream;

  // Note: Removed pending token logic to prevent unwanted navigation on app start
  // Deep links now only trigger through real-time streams when user clicks links

  /// Get the initial link (for processing after listeners are set up)
  String? get initialLink => _initialLinkProcessed ? null : _initialLink;

  /// Clear the initial link after it's been processed
  void clearInitialLink() {
    _initialLink = null;
    _initialLinkProcessed = true;
    debugPrint('🔗 [DeepLink] Initial link cleared and marked as processed');
  }

  /// Dispose resources
  void dispose() {
    _emailConfirmationController.close();
    _passwordResetController.close();
  }
}
