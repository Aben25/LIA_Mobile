import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:love_in_action/models/strapi_auth_response.dart';
import 'package:love_in_action/models/strapi_user.dart';
import 'package:love_in_action/constants/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StrapiAuthService {
  static const _tokenKey = 'strapi_jwt';

  Future<StrapiAuthResponse> register({required String email, required String password, required String username}) async {
    final uri = Uri.parse(ApiEndpoints.register);
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'username': username,
      }),
    );

    final data = _decodeResponse(res);
    await _saveToken(data['jwt'] as String);
    final auth = StrapiAuthResponse.fromJson(data);
    return auth;
  }
  Future<StrapiAuthResponse> login({required String identifier, required String password}) async {
    final uri = Uri.parse(ApiEndpoints.login);
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    );

    final data = _decodeResponse(res);
    await _saveToken(data['jwt'] as String);
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
    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

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
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Invalid server response (${res.statusCode}).');
    }

    if (status >= 200 && status < 300) {
      return body;
    }

    // Strapi error format: { error: { message, details, name, status } }
    final error = body['error'];
    final msg = error is Map<String, dynamic> ? (error['message']?.toString() ?? 'Authentication error.') : 'Authentication error.';
    throw Exception(msg);
  }

  // Optionally fetch current user using token, if needed for validation later

  static String get tokenKey => _tokenKey;
}
