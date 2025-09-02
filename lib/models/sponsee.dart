class Sponsee {
  final int id;
  final String name;
  final String? description;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sponsee({
    required this.id,
    required this.name,
    this.description,
    this.dateOfBirth,
    this.gender,
    this.profilePictureUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sponsee.fromJson(Map<String, dynamic> json) {
    return Sponsee(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'profile_picture_url': profilePictureUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Sponsee copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? dateOfBirth,
    String? gender,
    String? profilePictureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sponsee(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
