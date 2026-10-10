import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final configuredBase = dotenv.env['API_BASE_URL']?.trim();
    final rawBase = configuredBase == null || configuredBase.isEmpty
        ? (isAndroid ? 'http://10.0.2.2:5000' : 'http://localhost:5000')
        : configuredBase;
    final parsedBase = Uri.parse(rawBase);
    final platformBase = !isAndroid && parsedBase.host == '10.0.2.2'
        ? parsedBase.replace(host: 'localhost').toString()
        : rawBase;
    final cleaned = platformBase.replaceAll(RegExp(r'/+$'), '');
    return cleaned.endsWith('/api') ? cleaned : '$cleaned/api';
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return http.post(uri, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> get(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return http.get(uri, headers: headers);
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return http.put(uri, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return http.delete(uri, headers: headers);
  }
}
