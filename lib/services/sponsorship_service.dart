import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../utils/network_error_handler.dart';

enum UserSponsorshipStatus {
  newUser, // No sponsor profile, no children
  hasProfile, // Has sponsor profile but no children
  hasChildren, // Has sponsored children
  hasOpenRequests, // Has pending sponsorship requests
}

class SponsorshipService {
  final http.Client _client;

  SponsorshipService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _getJson(String url,
      {required String jwt}) async {
    try {
      final res = await _client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception(
            'SponsorshipService error (${res.statusCode}): ${res.body}');
      }

      return res.body.isNotEmpty
          ? (res.headers['content-type']?.contains('application/json') == true
              ? jsonDecode(res.body) as Map<String, dynamic>
              : {'data': res.body})
          : <String, dynamic>{};
    } catch (error) {
      // If it's a network error, throw a user-friendly message
      if (NetworkErrorHandler.isNetworkError(error)) {
        throw Exception(NetworkErrorHandler.getNetworkErrorMessage(error));
      }
      // Re-throw other errors as-is
      rethrow;
    }
  }

  /// Get user's sponsorship status to determine which Zeffy form to show
  Future<UserSponsorshipStatus> getUserSponsorshipStatus(
      {required String jwt}) async {
    try {
      // Get current user email
      final me = await _getJson('https://admin.loveinaction.co/api/users/me',
          jwt: jwt);
      final String email = _extractEmail(me);

      // Check if user has sponsor profile
      final sponsorsUrl =
          '${ApiEndpoints.sponsors}?filters[email][\$eq]=$email&populate=children';
      final sponsorsRes = await _getJson(sponsorsUrl, jwt: jwt);

      final sponsorsList = _extractDataList(sponsorsRes);

      if (sponsorsList.isEmpty) {
        // No sponsor profile - new user
        return UserSponsorshipStatus.newUser;
      }

      final sponsor = sponsorsList.first as Map<String, dynamic>;
      final children = _extractChildrenFromSponsor(sponsor);

      if (children.isNotEmpty) {
        // Has sponsored children
        return UserSponsorshipStatus.hasChildren;
      }

      // Has sponsor profile but no children - check for open requests
      final requestsUrl =
          '${ApiEndpoints.sponsors}?filters[email][\$eq]=$email&filters[sponsorshipStatus][\$eq]=pending';
      try {
        final requestsRes = await _getJson(requestsUrl, jwt: jwt);
        final requestsList = _extractDataList(requestsRes);

        if (requestsList.isNotEmpty) {
          return UserSponsorshipStatus.hasOpenRequests;
        }
      } catch (e) {
        // If requests check fails, assume no open requests
      }

      return UserSponsorshipStatus.hasProfile;
    } catch (error) {
      // Default to new user on error
      return UserSponsorshipStatus.newUser;
    }
  }

  /// Get the appropriate Zeffy form URL based on user status
  String getZeffyFormUrl(UserSponsorshipStatus status) {
    // All users who can sponsor use the same ticketing form (matches website behavior)
    if (status == UserSponsorshipStatus.hasOpenRequests) {
      return ''; // Users with pending requests should not see sponsorship form
    }

    // Use the same form as the website for all sponsorship requests
    return 'https://www.zeffy.com/embed/ticketing/child-sponsorship';
  }

  /// Get appropriate button text based on user status
  String getButtonText(UserSponsorshipStatus status) {
    switch (status) {
      case UserSponsorshipStatus.newUser:
        return 'Start Sponsoring';
      case UserSponsorshipStatus.hasProfile:
        return 'Complete Sponsorship';
      case UserSponsorshipStatus.hasChildren:
        return 'Sponsor Another Child';
      case UserSponsorshipStatus.hasOpenRequests:
        return 'Request Pending';
    }
  }

  /// Check if sponsorship button should be shown
  bool shouldShowSponsorshipButton(UserSponsorshipStatus status) {
    return status != UserSponsorshipStatus.hasOpenRequests;
  }

  String _extractEmail(Map<String, dynamic> userData) {
    if (userData.containsKey('email')) {
      return userData['email'] as String;
    } else if (userData.containsKey('user') &&
        userData['user'] is Map<String, dynamic>) {
      return (userData['user'] as Map<String, dynamic>)['email'] as String;
    } else if (userData.containsKey('data')) {
      final data = userData['data'];
      if (data is Map<String, dynamic> && data.containsKey('attributes')) {
        return (data['attributes'] as Map<String, dynamic>)['email'] as String;
      }
    }
    throw Exception('Could not resolve user email from /users/me response');
  }

  List<dynamic> _extractDataList(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) {
      return data;
    } else if (data is Map<String, dynamic> && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    return [];
  }

  List<dynamic> _extractChildrenFromSponsor(Map<String, dynamic> sponsor) {
    dynamic childrenNode;
    if (sponsor.containsKey('attributes')) {
      final attrs = sponsor['attributes'] as Map<String, dynamic>;
      childrenNode = attrs['children'];
    } else {
      childrenNode = sponsor['children'];
    }

    if (childrenNode is Map<String, dynamic> && childrenNode['data'] is List) {
      return childrenNode['data'] as List<dynamic>;
    } else if (childrenNode is List) {
      return childrenNode;
    }
    return [];
  }
}
