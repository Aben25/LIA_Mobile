import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../utils/network_error_handler.dart';

class TeamMembershipService {
  final http.Client _client;

  TeamMembershipService({http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _postJson(
    String url, {
    required Map<String, dynamic> data,
    Map<String, String>? headers,
  }) async {
    try {
      print('[TeamMembershipService] POST => $url');
      print('[TeamMembershipService] Data: $data');

      final requestHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      final res = await _client.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: jsonEncode(data),
      );

      print('[TeamMembershipService] <-- ${res.statusCode} for $url');
      if (res.body.isNotEmpty) {
        final preview =
            res.body.length > 300 ? res.body.substring(0, 300) + '…' : res.body;
        print('[TeamMembershipService] Body preview: $preview');
      }

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Request failed (${res.statusCode}): ${res.body}');
      }

      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (error) {
      if (NetworkErrorHandler.isNetworkError(error)) {
        throw Exception(NetworkErrorHandler.getNetworkErrorMessage(error));
      }
      rethrow;
    }
  }

  /// Submit a team membership request
  Future<Map<String, dynamic>> submitTeamMembershipRequest({
    required String name,
    required String email,
    required String phoneNumber,
    required String howYouCanHelp,
  }) async {
    print(
        '[TeamMembershipService] Submitting team membership request for: $name');

    final data = {
      'data': {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'howYouCanHelp': howYouCanHelp,
        'submittedAt': DateTime.now().toIso8601String(),
      }
    };

    try {
      final response = await _postJson(
        'https://best-desire-8443ae2768.strapiapp.com/api/team-membership-requests',
        data: data,
      );

      print(
          '[TeamMembershipService] Team membership request submitted successfully');
      return response;
    } catch (error) {
      print(
          '[TeamMembershipService] Failed to submit team membership request: $error');
      rethrow;
    }
  }
}
