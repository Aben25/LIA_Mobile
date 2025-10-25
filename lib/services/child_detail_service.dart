import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../utils/network_error_handler.dart';

class ChildDetailService {
  final http.Client _client;

  ChildDetailService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _getJson(
    String url, {
    required String jwt,
  }) async {
    try {
      print('[ChildDetailService] GET => $url');
      final res = await _client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      print('[ChildDetailService] <-- ${res.statusCode} for $url');
      if (res.body.isNotEmpty) {
        final preview =
            res.body.length > 300 ? res.body.substring(0, 300) + '…' : res.body;
        print('[ChildDetailService] Body preview: $preview');
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

  /// Fetch detailed information for a specific child by ID
  /// Uses the same approach as the website for consistency
  Future<Map<String, dynamic>> getChildDetail({
    required String childId,
    required String jwt,
  }) async {
    print('[ChildDetailService] Fetching child detail for ID: $childId');

    // Try multiple approaches like the website does
    final attempts = [
      {
        'name': 'Direct child by ID with full populate',
        'url':
            '${ApiEndpoints.children}/$childId?populate[images]=true&populate[sponsor]=true',
      },
      {
        'name': 'Child by ID with basic populate',
        'url': '${ApiEndpoints.children}/$childId?populate=images',
      },
      {
        'name': 'Child by ID with no populate',
        'url': '${ApiEndpoints.children}/$childId',
      },
    ];

    for (final attempt in attempts) {
      try {
        print('[ChildDetailService] Trying: ${attempt['name']}');
        final response = await _getJson(attempt['url']!, jwt: jwt);

        if (response.containsKey('data')) {
          final data = response['data'];
          if (data != null) {
            print('[ChildDetailService] Success with: ${attempt['name']}');
            return data is Map<String, dynamic> ? data : {};
          }
        }
      } catch (e) {
        print('[ChildDetailService] Failed: ${attempt['name']} => $e');
        continue;
      }
    }

    throw Exception('Failed to fetch child details after trying all methods');
  }

  /// Alternative method: fetch child by filtering all children (like website fallback)
  Future<Map<String, dynamic>> getChildDetailByFilter({
    required String childId,
    required String jwt,
  }) async {
    print('[ChildDetailService] Fetching child by filter for ID: $childId');

    try {
      // Get all children with full populate and filter locally
      final url =
          '${ApiEndpoints.children}?populate[images]=true&populate[sponsor]=true&pagination[pageSize]=100';
      final response = await _getJson(url, jwt: jwt);

      print('[ChildDetailService] Response: $response');

      final data = response['data'];
      if (data is List) {
        for (final child in data) {
          if (child is Map<String, dynamic>) {
            // Check multiple ID fields: id, liaId, documentId
            final id = child['id']?.toString();
            final liaId = child['liaId']?.toString();
            final documentId = child['documentId']?.toString();

            print(
                '[ChildDetailService] Checking child: id=$id, liaId=$liaId, documentId=$documentId, looking for: $childId');

            if (id == childId || liaId == childId || documentId == childId) {
              print(
                  '[ChildDetailService] Found child by filter: $childId (matched: id=$id, liaId=$liaId, documentId=$documentId)');
              return child;
            }
          }
        }
      }

      throw Exception('Child not found');
    } catch (error) {
      print('[ChildDetailService] Filter method failed: $error');
      rethrow;
    }
  }
}
