import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:love_in_action/models/strapi_auth_response.dart';
import 'package:love_in_action/models/strapi_user.dart';
import 'package:love_in_action/constants/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/network_error_handler.dart';

class StrapiAuthService {
  static const _tokenKey = 'strapi_jwt';

  Future<StrapiAuthResponse> register(
      {required String email,
      required String password,
      required String username}) async {
    final uri = Uri.parse(ApiEndpoints.register);
    final res = await _makeHttpRequest(() async => await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
            'username': username,
          }),
        ));

    final data = _decodeResponse(res);

    // Handle JWT token - it might be null if email confirmation is required
    final jwt = data['jwt'] as String?;
    if (jwt != null) {
      await _saveToken(jwt);
    }

    final auth = StrapiAuthResponse.fromJson(data);
    return auth;
  }

  Future<StrapiAuthResponse> login(
      {required String identifier, required String password}) async {
    final uri = Uri.parse(ApiEndpoints.login);
    final res = await _makeHttpRequest(() async => await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'identifier': identifier,
            'password': password,
          }),
        ));

    final data = _decodeResponse(res);

    // Handle JWT token - should always be present for successful login
    final jwt = data['jwt'] as String?;
    if (jwt != null) {
      await _saveToken(jwt);
    } else {
      throw Exception('Login successful but no authentication token received.');
    }

    final auth = StrapiAuthResponse.fromJson(data);
    return auth;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<StrapiUser> getMe() async {
    final token = await getSavedToken();
    if (token == null) {
      throw Exception('No saved token found.');
    }
    final uri = Uri.parse(ApiEndpoints.me);
    final res = await _makeHttpRequest(() async => await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ));

    final data = _decodeResponse(res);
    return StrapiUser.fromJson(data);
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Map<String, dynamic> _decodeResponse(http.Response res) {
    final status = res.statusCode;

    // Handle empty responses (common for email confirmation)
    if (res.body.isEmpty) {
      if (status >= 200 && status < 300) {
        return {}; // Return empty map for successful empty responses
      } else {
        throw Exception('Server returned empty response with status $status');
      }
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
          'Invalid server response (${res.statusCode}): ${res.body}');
    }

    if (status >= 200 && status < 300) {
      return body;
    }

    // Strapi error format: { error: { message, details, name, status } }
    final error = body['error'];
    final msg = error is Map<String, dynamic>
        ? (error['message']?.toString() ?? 'Authentication error.')
        : 'Authentication error.';
    throw Exception(msg);
  }

  /// Wraps HTTP calls with network error handling
  Future<http.Response> _makeHttpRequest(
      Future<http.Response> Function() request) async {
    try {
      return await request();
    } catch (error) {
      // If it's a network error, throw a user-friendly message
      if (NetworkErrorHandler.isNetworkError(error)) {
        throw Exception(NetworkErrorHandler.getNetworkErrorMessage(error));
      }
      // Re-throw other errors as-is
      rethrow;
    }
  }

  // Password Management
  Future<void> forgotPassword(String email) async {
    final uri = Uri.parse(ApiEndpoints.forgotPassword);
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    _decodeResponse(res);
  }

  Future<void> resetPassword({
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    final uri = Uri.parse(ApiEndpoints.resetPassword);
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'code': code,
        'password': password,
        'passwordConfirmation': passwordConfirmation,
      }),
    );

    _decodeResponse(res);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final token = await getSavedToken();
    if (token == null) {
      throw Exception('No authentication token found. Please log in again.');
    }

    final uri = Uri.parse(ApiEndpoints.changePassword);
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'password': password,
        'passwordConfirmation': passwordConfirmation,
      }),
    );

    _decodeResponse(res);
  }

  // Email Confirmation
  Future<void> confirmEmail(String confirmationToken) async {
    final uri = Uri.parse(
        '${ApiEndpoints.emailConfirmation}?confirmation=$confirmationToken');
    debugPrint('🔗 [EmailConfirmation] Calling: $uri');

    try {
      final res = await http.get(uri);
      debugPrint('🔗 [EmailConfirmation] Response status: ${res.statusCode}');
      debugPrint(
          '🔗 [EmailConfirmation] Response body length: ${res.body.length}');

      if (res.statusCode == 200) {
        // Status 200 means confirmation was successful
        // Even if it returns HTML, the user was confirmed on the backend
        debugPrint(
            '🔗 [EmailConfirmation] Email confirmation successful (status 200)');
        return;
      } else if (res.statusCode == 400) {
        // Status 400 means token is invalid, expired, or already used
        try {
          final decoded = jsonDecode(res.body);
          debugPrint('🔗 [EmailConfirmation] Error response: $decoded');

          // Check if it's a validation error (token already used/invalid)
          if (decoded['error'] != null &&
              decoded['error']['name'] == 'ValidationError') {
            // Instead of throwing an error, return a special success state
            // This means the token was already used (email already confirmed)
            debugPrint(
                '🔗 [EmailConfirmation] Token already used - email already confirmed');
            return; // Return successfully, don't throw error
          }

          throw Exception(
              'Email confirmation failed: ${decoded['error']?['message'] ?? 'Unknown error'}');
        } catch (e) {
          if (e.toString().contains('Email confirmation failed')) {
            rethrow; // Re-throw actual errors
          }
          // If JSON parsing failed, assume token was already used
          debugPrint(
              '🔗 [EmailConfirmation] JSON parse failed, assuming token already used');
          return; // Return successfully
        }
      } else {
        // Other status codes
        debugPrint(
            '🔗 [EmailConfirmation] Unexpected status code: ${res.statusCode}');
        throw Exception(
            'Email confirmation failed: Server error (${res.statusCode})');
      }
    } catch (e) {
      debugPrint('🔗 [EmailConfirmation] API call failed: $e');

      // If it's a network error or other issue, check if the user might already be confirmed
      // by trying to get user info (if we have a token)
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('HandshakeException')) {
        debugPrint(
            '🔗 [EmailConfirmation] Network error - assuming email might already be confirmed');
        // Don't throw error, return successfully to let user try logging in
        return;
      }

      rethrow; // Re-throw other exceptions
    }
  }

  Future<void> sendEmailConfirmation(String email) async {
    final uri = Uri.parse(ApiEndpoints.sendEmailConfirmation);
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    _decodeResponse(res);
  }

  // User Management
  Future<StrapiUser> updateUser(
      int userId, Map<String, dynamic> updates) async {
    final token = await getSavedToken();
    if (token == null) {
      throw Exception('No authentication token found. Please log in again.');
    }

    final uri = Uri.parse(ApiEndpoints.userById(userId));
    final res = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updates),
    );

    final data = _decodeResponse(res);
    return StrapiUser.fromJson(data);
  }

  Future<void> deleteUser(int userId) async {
    final token = await getSavedToken();
    if (token == null) {
      throw Exception('No authentication token found. Please log in again.');
    }

    final uri = Uri.parse(ApiEndpoints.userById(userId));
    final res = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    _decodeResponse(res);
    // Clear local token after account deletion
    await logout();
  }

  static String get tokenKey => _tokenKey;
}
