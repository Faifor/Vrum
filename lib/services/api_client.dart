import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/document.dart';
import '../models/user_summary.dart';

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
              defaultValue: 'http://89.108.113.52',
            );

  final http.Client _httpClient;
  final String baseUrl;
  String? authToken;

  Duration get _timeout => const Duration(seconds: 15);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _post(
      '/auth/login',
      body: <String, dynamic>{
        'grant_type': 'password',
        'username': email,
        'password': password,
        'scope': '',
      },
      authorized: false,
      formUrlEncoded: true,
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
      authorized: false,
    );
  }

  Future<Map<String, dynamic>> requestPasswordResetCode({
    required String email,
  }) async {
    return _post(
      '/auth/password/forgot',
      body: <String, dynamic>{'email': email},
      authorized: false,
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
      authorized: false,
    );
  }

  Future<UserDocument> getMyDocument() async {
    final payload = await _get('/document');
    return UserDocument.fromJson(_extractMap(payload));
  }

  Future<UserDocument> updateMyDocument(UserDocument doc) async {
    final payload = await _put('/document', body: doc.toJson());
    return UserDocument.fromJson(_extractMap(payload));
  }

  Future<UserDocument> submitDocument() async {
    final payload = await _post('/document/submit', body: const {});
    return UserDocument.fromJson(_extractMap(payload));
  }

  Future<List<UserSummary>> listUsers() async {
    final payload = await _get('/admin/users');
    return _extractList(payload)
        .map((dynamic json) =>
            UserSummary.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<UserDocument> getUserDocument(int userId) async {
    final payload = await _get('/admin/users/$userId/document');
    return UserDocument.fromJson(_extractMap(payload));
  }

  Future<UserDocument> approveUserDocument(int userId) async {
    final payload = await _post('/admin/users/$userId/approve', body: const {});
    return UserDocument.fromJson(_extractMap(payload));
  }

  Future<UserDocument> rejectUserDocument({
    required int userId,
    required String reason,
  }) async {
    final payload = await _post(
      '/admin/users/$userId/reject',
      body: <String, dynamic>{'reason': reason},
    );
    return UserDocument.fromJson(_extractMap(payload));
  }


  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
    bool authorized = true,
    bool formUrlEncoded = false,

  }) {
    return _request(
      path,
      method: 'POST',
      body: body,
      authorized: authorized,
      formUrlEncoded: formUrlEncoded,
    );
  }

  Future<Map<String, dynamic>> _put(
    String path, {
    required Map<String, dynamic> body,
  }) {
    return _request(
      path,
      method: 'PUT',
      body: body,
      authorized: true,
    );
  }

  Future<Map<String, dynamic>> _get(String path) {
    return _request(path, method: 'GET', authorized: true);
  }

  Future<Map<String, dynamic>> _request(
    String path, {
    required String method,
    Map<String, dynamic>? body,
    bool authorized = true,
    bool formUrlEncoded = false,
  }) async {
    final uri = _buildUri(path);
    final headers =
        _buildHeaders(authorized: authorized, formUrlEncoded: formUrlEncoded);

    final encodedBody = body == null
        ? null
        : formUrlEncoded
            ? _encodeFormBody(body)
            : jsonEncode(body);

    late http.Response response;

    switch (method) {
      case 'GET':
        response =
            await _httpClient.get(uri, headers: headers).timeout(_timeout);
        break;
      case 'PUT':
        response = await _httpClient
            .put(uri, headers: headers, body: encodedBody)
            .timeout(_timeout);
        break;
      case 'POST':
        response = await _httpClient
            .post(uri, headers: headers, body: encodedBody)
            .timeout(_timeout);
        break;
      default:
        throw ArgumentError.value(method, 'method', 'Unsupported HTTP method');
    }

    final payload = _decodeJson(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload;
    }

    final message = _extractErrorMessage(payload) ??
        response.reasonPhrase ??
        'Unexpected error (code ${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

    Map<String, String> _buildHeaders({
    required bool authorized,
    required bool formUrlEncoded,
  }) {
    final headers = <String, String>{
      'Content-Type': formUrlEncoded
          ? 'application/x-www-form-urlencoded'
          : 'application/json',
      'Accept': 'application/json',
    };

    if (authorized && authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  String _encodeFormBody(Map<String, dynamic> body) {
    return body.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value?.toString() ?? '')}',
        )
        .join('&');
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

  Map<String, dynamic> _extractMap(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return payload;
  }

  List<dynamic> _extractList(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is List<dynamic>) {
      return data;
    }
    final results = payload['results'];
    if (results is List<dynamic>) {
      return results;
    }
    final valuesList =
        payload.values.whereType<List<dynamic>>().toList(growable: false);
    if (valuesList.isNotEmpty) {
      return valuesList.first;
    }
    return <dynamic>[];
  }

  String? _extractErrorMessage(Map<String, dynamic> payload) {
    final message = payload['message'] ?? payload['error'];
    return message?.toString();
  }

  void dispose() {
    _httpClient.close();
  }
}