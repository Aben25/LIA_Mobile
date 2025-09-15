class ApiEndpoints {
  static const String baseUrl = 'https://admin.loveinaction.co/api';

  // Auth
  static const String login = '$baseUrl/auth/local';
  static const String register = '$baseUrl/auth/local/register';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String changePassword = '$baseUrl/auth/change-password';
  static const String emailConfirmation = '$baseUrl/auth/email-confirmation';
  static const String sendEmailConfirmation =
      '$baseUrl/auth/send-email-confirmation';

  // Users
  static const String me = '$baseUrl/users/me';
  static String userById(int id) => '$baseUrl/users/$id';

  // Domain endpoints
  static const String sponsors = '$baseUrl/sponsors';
  static const String children = '$baseUrl/children';
  static const String causes = '$baseUrl/causes?populate=*';
}
