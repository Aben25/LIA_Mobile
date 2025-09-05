import 'package:flutter/foundation.dart';

class Cause {
  final int? id;
  final String? documentId;
  final String title;
  final String? description;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;
  final bool? hasDetails;

  Cause({
    required this.id,
    required this.documentId,
    required this.title,
    this.description,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.hasDetails,
  });

  factory Cause.fromJson(Map<String, dynamic> json) {
    // Supports Strapi v4 default shape and flat shape
    if (json.containsKey('attributes')) {
      final attrs = json['attributes'] as Map<String, dynamic>;
      return Cause(
        id: (json['id'] as num?)?.toInt(),
        documentId: attrs['documentId'] as String?,
        title: (attrs['title'] ?? '') as String,
        description: attrs['description'] as String?,
        category: attrs['category'] as String?,
        createdAt: _parseDate(attrs['createdAt']),
        updatedAt: _parseDate(attrs['updatedAt']),
        publishedAt: _parseDate(attrs['publishedAt']),
        hasDetails: attrs['hasDetails'] as bool?,
      );
    }

    return Cause(
      id: (json['id'] as num?)?.toInt(),
      documentId: json['documentId'] as String?,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      publishedAt: _parseDate(json['publishedAt']),
      hasDetails: json['hasDetails'] as bool?,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v as String);
    } catch (_) {
      return null;
    }
  }
}
