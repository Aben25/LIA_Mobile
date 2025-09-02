class Project {
  final int id;
  final String title;
  final String description;
  final String projectType;
  final String goal;
  final String impact;
  final String? profilePictureUrl;
  final int? galleryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.projectType,
    required this.goal,
    required this.impact,
    this.profilePictureUrl,
    this.galleryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      title: json['project_title'] as String,
      description: json['description'] as String,
      projectType: json['project_type'] as String,
      goal: json['goal'] as String,
      impact: json['impact'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      galleryId: json['gallery_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_title': title,
      'description': description,
      'project_type': projectType,
      'goal': goal,
      'impact': impact,
      'profile_picture_url': profilePictureUrl,
      'gallery_id': galleryId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Project copyWith({
    int? id,
    String? title,
    String? description,
    String? projectType,
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
      projectType: projectType ?? this.projectType,
      goal: goal ?? this.goal,
      impact: impact ?? this.impact,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      galleryId: galleryId ?? this.galleryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
