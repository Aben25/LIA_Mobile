class ApiEndpoints {
  static const String baseUrl = 'https://admin.loveinaction.co/api';

  // Auth
  static const String login = '$baseUrl/auth/local';
  static const String register = '$baseUrl/auth/local/register';

  // Users
  static const String me = '$baseUrl/users/me';

  // Domain endpoints
  static const String sponsors = '$baseUrl/sponsors';
  static const String children = '$baseUrl/children';
  static const String causes = '$baseUrl/causes';
}
