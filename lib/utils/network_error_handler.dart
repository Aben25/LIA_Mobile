import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkErrorHandler {
  /// Checks if the error is a network connectivity issue
  static bool isNetworkError(dynamic error) {
    if (error is SocketException) return true;
    if (error is HttpException) return true;
    if (error is HandshakeException) return true;
    if (error is TimeoutException) return true;
    if (error is http.ClientException) return true;

    // Check for common network error messages
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('handshakeexception') ||
        errorString.contains('timeoutexception') ||
        errorString.contains('clientexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('no internet connection') ||
        errorString.contains('connection timed out');
  }

  /// Gets a user-friendly error message for network issues
  static String getNetworkErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network settings and try again.';
    }
    if (error is HttpException) {
      return 'Network error. Please check your internet connection and try again.';
    }
    if (error is HandshakeException) {
      return 'Secure connection failed. Please check your internet connection and try again.';
    }
    if (error is TimeoutException) {
      return 'Request timed out. Please check your internet connection and try again.';
    }
    if (error is http.ClientException) {
      return 'Unable to connect to the server. Please check your internet connection and try again.';
    }

    // Check for common network error messages in string
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socketexception') ||
        errorString.contains('connection refused')) {
      return 'No internet connection. Please check your network settings and try again.';
    }
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your internet connection and try again.';
    }
    if (errorString.contains('handshakeexception')) {
      return 'Secure connection failed. Please check your internet connection and try again.';
    }

    return 'Network error. Please check your internet connection and try again.';
  }

  /// Gets a user-friendly error message for any error type
  static String getErrorMessage(dynamic error) {
    if (isNetworkError(error)) {
      return getNetworkErrorMessage(error);
    }

    // Handle other types of errors
    String errorMessage = error.toString();

    // Remove common exception prefixes
    errorMessage = errorMessage.replaceAll('Exception: ', '');
    errorMessage = errorMessage.replaceAll('FormatException: ', '');
    errorMessage = errorMessage.replaceAll('StateError: ', '');

    // If it's a generic error message, provide a more helpful one
    if (errorMessage.toLowerCase().contains('something went wrong') ||
        errorMessage.toLowerCase().contains('unexpected error')) {
      return 'An unexpected error occurred. Please try again.';
    }

    return errorMessage;
  }

  /// Checks if the error indicates the user should retry
  static bool shouldRetry(dynamic error) {
    if (isNetworkError(error)) return true;

    final errorString = error.toString().toLowerCase();
    return !errorString.contains('invalid credentials') &&
        !errorString.contains('user not found') &&
        !errorString.contains('email already exists') &&
        !errorString.contains('account disabled');
  }
}
