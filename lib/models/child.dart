import 'dart:convert';

class Child {
  final int id;
  final String? documentId;
  final String? liaId;
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? location;
  final String? about;
  final String? aspiration;
  final List<dynamic>? imagesRaw; // raw images payload (structure varies)

  Child({
    required this.id,
    this.documentId,
    this.liaId,
    this.fullName,
    this.dateOfBirth,
    this.location,
    this.about,
    this.aspiration,
    this.imagesRaw,
  });

  // Helper to get first image URL from various Strapi response shapes
  String? get firstImageUrl {
    if (imagesRaw == null || imagesRaw!.isEmpty) return null;

    // imagesRaw can be list of maps with url or nested data/attributes
    final first = imagesRaw!.first;
    try {
      if (first is Map<String, dynamic>) {
        // Direct url
        if (first['url'] is String) return first['url'] as String;

        // Strapi v4 default: { data: { attributes: { url } } }
        final data = first['data'];
        if (data is Map<String, dynamic>) {
          final attrs = data['attributes'];
          if (attrs is Map<String, dynamic> && attrs['url'] is String) {
            return attrs['url'] as String;
          }
        }

        // Some setups may store formats: { formats: { thumbnail: { url } } }
        if (first['formats'] is Map<String, dynamic>) {
          final formats = first['formats'] as Map<String, dynamic>;
          final thumb = formats['thumbnail'];
          if (thumb is Map<String, dynamic> && thumb['url'] is String) {
            return thumb['url'] as String;
          }
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Parse Child supporting both flat and attributes-nested shapes
  factory Child.fromJson(Map<String, dynamic> json) {
    // If this is a Strapi v4 default (with attributes)
    if (json.containsKey('attributes')) {
      final attrs = json['attributes'] as Map<String, dynamic>;
      return Child(
        id: (json['id'] as num).toInt(),
        documentId: attrs['documentId'] as String?,
        liaId: attrs['liaId'] as String?,
        fullName: attrs['fullName'] as String?,
        dateOfBirth: _parseDate(attrs['dateOfBirth']),
        location: attrs['location'] as String?,
        about: attrs['about'] as String?,
        aspiration: attrs['aspiration'] as String?,
        imagesRaw: _extractImages(attrs['images']),
      );
    }

    // Flat shape
    return Child(
      id: (json['id'] as num).toInt(),
      documentId: json['documentId'] as String?,
      liaId: json['liaId'] as String?,
      fullName: json['fullName'] as String?,
      dateOfBirth: _parseDate(json['dateOfBirth']),
      location: json['location'] as String?,
      about: json['about'] as String?,
      aspiration: json['aspiration'] as String?,
      imagesRaw: _extractImages(json['images']),
    );
  }

  static List<dynamic>? _extractImages(dynamic images) {
    if (images == null) return null;
    if (images is List) return images;
    // Strapi v4 may return { data: [ ... ] }
    if (images is Map<String, dynamic> && images['data'] is List) {
      return images['data'] as List<dynamic>;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'liaId': liaId,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'location': location,
      'about': about,
      'aspiration': aspiration,
      'images': imagesRaw,
    };
  }
}
