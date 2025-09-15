class Cause {
  final int id;
  final String documentId;
  final String title;
  final String? description;
  final String? category;
  final bool? hasDetails;
  final CauseImage? image;
  final BlogLink? blogLink;
  final CauseLink? link;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime publishedAt;

  Cause({
    required this.id,
    required this.documentId,
    required this.title,
    this.description,
    this.category,
    this.hasDetails,
    this.image,
    this.blogLink,
    this.link,
    required this.createdAt,
    required this.updatedAt,
    required this.publishedAt,
  });

  factory Cause.fromJson(Map<String, dynamic> json) {
    return Cause(
      id: json['id'],
      documentId: json['documentId'],
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'],
      hasDetails: json['hasDetails'],
      image: json['image'] != null ? CauseImage.fromJson(json['image']) : null,
      blogLink: json['blogLink'] != null ? BlogLink.fromJson(json['blogLink']) : null,
      link: json['link'] != null ? CauseLink.fromJson(json['link']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      publishedAt: DateTime.parse(json['publishedAt']),
    );
  }
}

class CauseImage {
  final String? url;
  final String? name;
  final String? alternativeText;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CauseImage({
    this.url,
    this.name,
    this.alternativeText,
    this.createdAt,
    this.updatedAt,
  });

  factory CauseImage.fromJson(Map<String, dynamic> json) {
    return CauseImage(
      url: json['url'],
      name: json['name'],
      alternativeText: json['alternativeText'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
}

class BlogLink {
  final int id;
  final String? heading;
  final String? subHeading;
  final List<Map<String, dynamic>>? body;
  final CauseImage? cover;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;

  BlogLink({
    required this.id,
    this.heading,
    this.subHeading,
    this.body,
    this.cover,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
  });

  factory BlogLink.fromJson(Map<String, dynamic> json) {
    return BlogLink(
      id: json['id'],
      heading: json['heading'],
      subHeading: json['subHeading'],
      body: json['body'] != null ? List<Map<String, dynamic>>.from(json['body']) : null,
      cover: json['cover'] != null ? CauseImage.fromJson(json['cover']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      publishedAt: json['publishedAt'] != null ? DateTime.tryParse(json['publishedAt']) : null,
    );
  }
}

class CauseLink {
  final int id;
  final String? label;
  final String? url;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;

  CauseLink({
    required this.id,
    this.label,
    this.url,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
  });

  factory CauseLink.fromJson(Map<String, dynamic> json) {
    return CauseLink(
      id: json['id'],
      label: json['label'],
      url: json['url'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      publishedAt: json['publishedAt'] != null ? DateTime.tryParse(json['publishedAt']) : null,
    );
  }
}
