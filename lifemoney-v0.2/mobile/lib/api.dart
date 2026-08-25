import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LifeMoneyApi {
  LifeMoneyApi({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl();

  final String baseUrl;

  static String _defaultBaseUrl() {
    const cloudUrl = String.fromEnvironment('API_BASE_URL');
    if (cloudUrl.isNotEmpty) return _stripTrailingSlash(cloudUrl);

    // Development fallback only. Production builds should always pass API_BASE_URL.
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  static String _stripTrailingSlash(String input) =>
      input.endsWith('/') ? input.substring(0, input.length - 1) : input;

  Future<Map<String, dynamic>> health() => _get('/health');

  Future<Map<String, dynamic>> calculateGoal(Map<String, dynamic> payload) =>
      _post('/v1/goals/calculate', payload);

  Future<Map<String, dynamic>> simulateRetirement(Map<String, dynamic> payload) =>
      _post('/v1/retirement/simulate', payload);

  Future<Map<String, dynamic>> checkAffordability(Map<String, dynamic> payload) =>
      _post('/v1/affordability/check', payload);

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await http
        .get(Uri.parse('$baseUrl$path'))
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final Object? decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded is Map<String, dynamic> ? decoded['detail'] : null;
      throw Exception(detail ?? 'Request failed (${response.statusCode})');
    }
    if (decoded is! Map) {
      throw const FormatException('Unexpected API response');
    }
    return Map<String, dynamic>.from(decoded);
  }
}
