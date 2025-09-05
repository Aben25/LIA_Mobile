class StrapiUser {
  final int id;
  final String email;
  final String? username;
  final bool? confirmed;
  final bool? blocked;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StrapiUser({
    required this.id,
    required this.email,
    this.username,
    this.confirmed,
    this.blocked,
    this.createdAt,
    this.updatedAt,
  });

  factory StrapiUser.fromJson(Map<String, dynamic> json) {
    return StrapiUser(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      username: json['username'] as String?,
      confirmed: json['confirmed'] as bool?,
      blocked: json['blocked'] as bool?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }
}
