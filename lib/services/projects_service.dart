import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../models/cause.dart';
import '../models/project.dart';
import '../utils/network_error_handler.dart';

class ProjectsService {
  final http.Client _client;

  ProjectsService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _getJson(String url) async {
    try {
      final res = await _client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception(
            'ProjectsService error (${res.statusCode}): ${res.body}');
      }

      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (error) {
      // If it's a network error, throw a user-friendly message
      if (NetworkErrorHandler.isNetworkError(error)) {
        throw Exception(NetworkErrorHandler.getNetworkErrorMessage(error));
      }
      // Re-throw other errors as-is
      rethrow;
    }
  }

  Future<List<Cause>> getCauses() async {
    final url = ApiEndpoints.causes;
    print('[ProjectsService] GET => ' + url);
    final data = await _getJson(url);
    final items = data['data'];
    if (items is! List) return <Cause>[];

    final causes = <Cause>[];
    for (final item in items) {
      if (item is Map<String, dynamic>) {
        // Debug: log the raw item to see what we're getting
        print('[ProjectsService] Raw item keys: ${item.keys.join(", ")}');
        if (item.containsKey('blogLink')) {
          print('[ProjectsService] blogLink keys: ${(item['blogLink'] as Map?)?.keys.join(", ")}');
          if (item['blogLink'] is Map && (item['blogLink'] as Map).containsKey('body')) {
            final body = (item['blogLink'] as Map)['body'];
            print('[ProjectsService] blogLink.body type: ${body.runtimeType}, length: ${body is List ? body.length : 'N/A'}');
            if (body is List && body.isNotEmpty) {
              print('[ProjectsService] First body item: ${body.first}');
            }
          }
        }
        causes.add(Cause.fromJson(item));
      }
    }
    print('[ProjectsService] Parsed causes: ${causes.length}');
    return causes;
  }

  Future<List<Project>> getProjects() async {
    final url = ApiEndpoints.causes;
    print('[ProjectsService] GET Projects => ' + url);
    final data = await _getJson(url);
    final items = data['data'];
    if (items is! List) return <Project>[];
    final projects = <Project>[];
    for (final item in items) {
      if (item is Map<String, dynamic>) {
        projects.add(Project.fromJson(item));
      }
    }
    print('[ProjectsService] Parsed projects: [32m${projects.length}[0m');
    return projects;
  }
}
