import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _httpClient = httpClient ?? http.Client(),
        baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://localhost:3000',
            );

  final http.Client _httpClient;
  final String baseUrl;

  Duration get _timeout => const Duration(seconds: 15);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _post(
      '/auth/login',
      body: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    return _post(
      '/auth/register',
      body: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> requestPasswordResetCode({
    required String email,
  }) async {
    return _post(
      '/auth/password/forgot',
      body: <String, dynamic>{'email': email},
    );
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return _post(
      '/auth/password/reset',
      body: <String, dynamic>{
        'email': email,
        'code': code,
        'new_password': newPassword,
      },
    );
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final uri = _buildUri(path);
    final response = await _httpClient
        .post(
          uri,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    final payload = _decodeJson(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload;
    }

    final message = _extractErrorMessage(payload) ??
        response.reasonPhrase ??
        'Unexpected error (code ${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Uri _buildUri(String path) {
    if (path.startsWith('http')) {
      return Uri.parse(path);
    }
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Map<String, dynamic> _decodeJson(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{'data': decoded};
  }

  String? _extractErrorMessage(Map<String, dynamic> payload) {
    final message = payload['message'] ?? payload['error'];
    return message?.toString();
  }

  void dispose() {
    _httpClient.close();
  }
}