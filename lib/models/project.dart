class Project {
  final int id;
  final String title;
  final String description;
  final String goal;
  final String impact;
  final String category;
  final String? profilePictureUrl;
  final int? galleryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    required this.impact,
    this.profilePictureUrl,
    this.galleryId,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for JSON deserialization
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      goal: json['goal'] as String,
      impact: json['impact'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      galleryId: json['gallery_id'] as int?,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goal': goal,
      'impact': impact,
      'profile_picture_url': profilePictureUrl,
      'gallery_id': galleryId,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with method
  Project copyWith({
    int? id,
    String? title,
    String? description,
    String? goal,
    String? impact,
    String? profilePictureUrl,
    int? galleryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      goal: goal ?? this.goal,
      impact: impact ?? this.impact,
      category: category,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      galleryId: galleryId ?? this.galleryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
