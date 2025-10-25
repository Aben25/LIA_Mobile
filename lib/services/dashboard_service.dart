import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../models/child.dart';
import '../utils/network_error_handler.dart';

class DashboardService {
  final http.Client _client;

  DashboardService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _getJson(
    String url, {
    required String jwt,
  }) async {
    try {
      // Debug: outgoing request
      print('[DashboardService] GET => $url');
      final res = await _client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      // Debug: response status and small preview of body
      print('[DashboardService] <-- ${res.statusCode} for $url');
      if (res.body.isNotEmpty) {
        final preview =
            res.body.length > 300 ? res.body.substring(0, 300) + '…' : res.body;
        print('[DashboardService] Body preview: ' + preview);
      }

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Request failed (${res.statusCode}): ${res.body}');
      }

      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (error) {
      // If it's a network error, throw a user-friendly message
      if (NetworkErrorHandler.isNetworkError(error)) {
        throw Exception(NetworkErrorHandler.getNetworkErrorMessage(error));
      }
      // Re-throw other errors as-is
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMe({required String jwt}) async {
    print('[DashboardService] Fetching /users/me');
    final me = await _getJson(ApiEndpoints.me, jwt: jwt);
    print('[DashboardService] /users/me => ' + jsonEncode(me));
    return me;
  }

  /// Get sponsor information for the authenticated user
  Future<Map<String, dynamic>?> getSponsorInfo({required String jwt}) async {
    try {
      final response = await _getJson(
        'https://admin.loveinaction.co/api/users/me?populate[sponsor]=true',
        jwt: jwt,
      );

      debugPrint('🔍 [DashboardService] Full user/me response: $response');

      // Handle both flat and attributes structure
      Map<String, dynamic> userData = response;
      if (response.containsKey('attributes')) {
        userData = response['attributes'] as Map<String, dynamic>;
      }

      final sponsorData = userData['sponsor'];
      debugPrint('🔍 [DashboardService] Sponsor data: $sponsorData');

      if (sponsorData != null) {
        // Handle both flat and attributes structure for sponsor
        if (sponsorData is Map<String, dynamic>) {
          if (sponsorData.containsKey('data')) {
            return sponsorData['data'] as Map<String, dynamic>?;
          }
          return sponsorData;
        }
      }

      debugPrint('🔍 [DashboardService] No sponsor data found');
      return null;
    } catch (error) {
      debugPrint('Error fetching sponsor info: $error');
      return null;
    }
  }

  /// Get sponsor ID from sponsors endpoint
  Future<int?> getSponsorIdFromSponsors(
      {required String jwt, required String email}) async {
    try {
      final sponsorsRes = await _getJson(
        '${ApiEndpoints.sponsors}?filters[email][\$eq]=$email',
        jwt: jwt,
      );

      final sponsors = sponsorsRes['data'] as List<dynamic>?;
      if (sponsors != null && sponsors.isNotEmpty) {
        final sponsor = sponsors.first as Map<String, dynamic>;
        final sponsorId = sponsor['id'];
        debugPrint(
            '🔍 [DashboardService] Found sponsor ID from sponsors endpoint: $sponsorId');
        return sponsorId is int
            ? sponsorId
            : int.tryParse(sponsorId.toString());
      }
      return null;
    } catch (error) {
      debugPrint('Error fetching sponsor ID from sponsors: $error');
      return null;
    }
  }

  Future<List<Child>> getChildrenForUser({required String jwt}) async {
    print('[DashboardService] getChildrenForUser() start');
    // 1) Get current user to resolve email (reliable filter across your data)
    final me = await getMe(jwt: jwt);

    // Support both flat and attributes formats for /users/me
    final String email;
    if (me.containsKey('email')) {
      email = me['email'] as String;
    } else if (me.containsKey('user') && me['user'] is Map<String, dynamic>) {
      email = (me['user'] as Map<String, dynamic>)['email'] as String;
    } else if (me.containsKey('data')) {
      final data = me['data'];
      if (data is Map<String, dynamic> && data.containsKey('attributes')) {
        email = (data['attributes'] as Map<String, dynamic>)['email'] as String;
      } else {
        throw Exception('Could not resolve user email from /users/me response');
      }
    } else {
      throw Exception('Could not resolve user email from /users/me response');
    }

    print('[DashboardService] Resolved email: $email');

    // 2) Query sponsors by email and populate children images specifically
    final urlsToTry = <String>[
      // Most specific: populate children images only (avoid populating children.sponsor)
      '${ApiEndpoints.sponsors}?filters[email][\$eq]=$email&populate[children][populate]=images',
      // Simpler: populate children (no nested populate)
      '${ApiEndpoints.sponsors}?filters[email][\$eq]=$email&populate=children',
      // Very simple: no populate (will likely require fallback children query)
      '${ApiEndpoints.sponsors}?filters[email][\$eq]=$email',
    ];

    Map<String, dynamic>? sponsorsRes;
    for (final url in urlsToTry) {
      try {
        print('[DashboardService] Trying sponsors URL: $url');
        sponsorsRes = await _getJson(url, jwt: jwt);
        print('[DashboardService] Sponsors response keys: ' +
            sponsorsRes.keys.join(','));
        print('[DashboardService] Full sponsors response: $sponsorsRes');
        break;
      } catch (e) {
        print('[DashboardService] Sponsors URL failed: $url => $e');
        continue;
      }
    }

    if (sponsorsRes == null) {
      print(
          '[DashboardService] All sponsors URLs failed. Falling back to /children by sponsor.email');
      return await _fallbackChildrenBySponsorEmail(jwt: jwt, email: email);
    }

    // Expect either { data: [...] } (Strapi default)
    final data = sponsorsRes['data'];
    List<dynamic> sponsorsList;
    if (data is List) {
      sponsorsList = data;
    } else if (data is Map<String, dynamic> && data['data'] is List) {
      sponsorsList = data['data'] as List<dynamic>;
    } else {
      sponsorsList = [];
    }

    print('[DashboardService] Sponsors count: ${sponsorsList.length}');
    if (sponsorsList.isEmpty) {
      // No sponsor; try children directly
      return await _fallbackChildrenBySponsorEmail(jwt: jwt, email: email);
    }

    // Use the first sponsor match (usually unique by email)
    final sponsor = sponsorsList.first as Map<String, dynamic>;

    // Children could be under attributes.children (Strapi default) or flat
    dynamic childrenNode;
    if (sponsor.containsKey('attributes')) {
      final attrs = sponsor['attributes'] as Map<String, dynamic>;
      childrenNode = attrs['children'];
    } else {
      childrenNode = sponsor['children'];
    }

    // childrenNode may be { data: [...] } or a direct list
    List<dynamic> childrenItems = [];
    if (childrenNode is Map<String, dynamic> && childrenNode['data'] is List) {
      childrenItems = childrenNode['data'] as List<dynamic>;
    } else if (childrenNode is List) {
      childrenItems = childrenNode;
    }

    print(
        '[DashboardService] Children items raw count: ${childrenItems.length}');
    if (childrenItems.isEmpty) {
      // Sponsor exists but children not populated; fallback direct query
      return await _fallbackChildrenBySponsorEmail(jwt: jwt, email: email);
    }

    final children = <Child>[];
    for (final item in childrenItems) {
      if (item is Map<String, dynamic>) {
        // If Strapi default, the actual child is under attributes with id at top
        if (item.containsKey('attributes')) {
          final id = (item['id'] as num?)?.toInt();
          final attrs = item['attributes'] as Map<String, dynamic>;
          final merged = {
            'id': id,
            ...attrs,
          };
          children.add(Child.fromJson(merged));
          print(
              '[DashboardService] Parsed child (attributes) id=$id name=${merged['fullName']}');
        } else {
          children.add(Child.fromJson(item));
          print(
              '[DashboardService] Parsed child (flat) id=${item['id']} name=${item['fullName']}');
        }
      }
    }

    print(
        '[DashboardService] getChildrenForUser() done. Parsed children: ${children.length}');
    return children;
  }

  Future<List<Child>> _fallbackChildrenBySponsorEmail({
    required String jwt,
    required String email,
  }) async {
    try {
      final url =
          '${ApiEndpoints.children}?filters[sponsor][email][\$eq]=$email&populate=images';
      print('[DashboardService] Fallback children URL: $url');
      final res = await _getJson(url, jwt: jwt);
      print('[DashboardService] Fallback children response: $res');
      final data = res['data'];
      final items = (data is List) ? data : <dynamic>[];
      print('[DashboardService] Fallback children count: ${items.length}');

      final children = <Child>[];
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          if (item.containsKey('attributes')) {
            final id = (item['id'] as num?)?.toInt();
            final attrs = item['attributes'] as Map<String, dynamic>;
            final merged = {'id': id, ...attrs};
            children.add(Child.fromJson(merged));
          } else {
            children.add(Child.fromJson(item));
          }
        }
      }
      print('[DashboardService] Fallback children parsed: ${children.length}');
      return children;
    } catch (e) {
      print('[DashboardService] Fallback children query failed: $e');
      return <Child>[];
    }
  }
}
