class Project {
  final int id;
  final String documentId;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final bool? hasDetails;

  Project({
    required this.id,
    required this.documentId,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.hasDetails,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      documentId: json['documentId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt'] as String) : null,
      hasDetails: json['hasDetails'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'hasDetails': hasDetails,
    };
  }

  Project copyWith({
    int? id,
    String? documentId,
    String? title,
    String? description,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    bool? hasDetails,
  }) {
    return Project(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      hasDetails: hasDetails ?? this.hasDetails,
    );
  }
}
