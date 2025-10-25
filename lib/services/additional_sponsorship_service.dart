import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../utils/network_error_handler.dart';
import 'package:flutter/foundation.dart';

class AdditionalSponsorshipService {
  final http.Client _client;

  AdditionalSponsorshipService({http.Client? client})
      : _client = client ?? http.Client();

  /// Submit additional sponsorship request
  Future<Map<String, dynamic>> submitAdditionalSponsorshipRequest({
    required int sponsorId,
    required int numberOfChildren,
    required String sponsorEmail,
    required String jwt,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiEndpoints.baseUrl}/update-sponsorship'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({
          'sponsorId': sponsorId,
          'numberOfChildren': numberOfChildren,
          'sponsorEmail': sponsorEmail,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorData = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{};
        throw Exception(
            errorData['error'] ?? 'HTTP error! status: ${response.statusCode}');
      }

      return response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
    } catch (error) {
      if (NetworkErrorHandler.isNetworkError(error)) {
        throw Exception(NetworkErrorHandler.getNetworkErrorMessage(error));
      }
      rethrow;
    }
  }

  /// Get active sponsorship requests for a sponsor
  Future<List<Map<String, dynamic>>> getActiveSponsorshipRequests({
    required int sponsorId,
    required String jwt,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '${ApiEndpoints.baseUrl}/sponsorships?filters[sponsor]=$sponsorId&filters[sponsorshipStatus][\$in]=submitted,pending&populate=sponsor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
            'Failed to fetch sponsorship requests (${response.statusCode}): ${response.body}');
      }

      final data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      final requests = data['data'] as List<dynamic>? ?? [];
      return requests.cast<Map<String, dynamic>>();
    } catch (error) {
      if (NetworkErrorHandler.isNetworkError(error)) {
        throw Exception(NetworkErrorHandler.getNetworkErrorMessage(error));
      }
      rethrow;
    }
  }

  /// Check if sponsor has active requests
  Future<bool> hasActiveSponsorshipRequests({
    required int sponsorId,
    required String jwt,
  }) async {
    try {
      final requests =
          await getActiveSponsorshipRequests(sponsorId: sponsorId, jwt: jwt);
      return requests.isNotEmpty;
    } catch (error) {
      debugPrint('Error checking active sponsorship requests: $error');
      return false;
    }
  }
}
