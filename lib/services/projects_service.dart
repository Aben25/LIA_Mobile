import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../models/cause.dart';
import '../models/project.dart';

class ProjectsService {
  final http.Client _client;

  ProjectsService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _getJson(String url) async {
    final res = await _client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('ProjectsService error (${res.statusCode}): ${res.body}');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
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
