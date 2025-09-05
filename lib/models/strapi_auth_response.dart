import 'strapi_user.dart';

class StrapiAuthResponse {
  final String? jwt;
  final StrapiUser user;

  StrapiAuthResponse({required this.jwt, required this.user});

  factory StrapiAuthResponse.fromJson(Map<String, dynamic> json) {
    return StrapiAuthResponse(
      jwt: json['jwt'] as String?,
      user: StrapiUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
