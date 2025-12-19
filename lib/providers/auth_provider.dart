import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required ApiClient client}) : _client = client;

  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';

  final ApiClient _client;

  String? _accessToken;
  String? _email;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _accessToken != null;
  String? get email => _email;

  Future<void> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);
    _email = prefs.getString(_emailKey);
    _client.authToken = _accessToken;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    await _runTrackedAction(() async {
      final response = await _client.login(email: email, password: password);
      await _persistAuthData(email: email, response: response);
    });
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _runTrackedAction(() async {
      final response =
          await _client.register(email: email, password: password);
      await _persistAuthData(email: email, response: response);
    });
  }

  Future<void> requestPasswordResetCode({required String email}) async {
    await _runTrackedAction(
      () => _client.requestPasswordResetCode(email: email),
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _runTrackedAction(
      () => _client.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      ),
    );
  }

  Future<void> logout() async {
    _accessToken = null;
    _email = null;
    _client.authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    notifyListeners();
  }

  Future<void> _persistAuthData({
    required String email,
    required Map<String, dynamic> response,
  }) async {
    _email = email;
    _accessToken = _extractToken(response);
    _client.authToken = _accessToken;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    if (_accessToken != null) {
      await prefs.setString(_tokenKey, _accessToken!);
    }
    notifyListeners();
  }

  Future<void> _runTrackedAction(
    Future<void> Function() action, {
    bool trackLoading = true,
  }) async {
    if (trackLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await action();
    } finally {
      if (trackLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  String? _extractToken(Map<String, dynamic> response) {
    if (response['token'] is String) {
      return response['token'] as String;
    }
    if (response['access_token'] is String) {
      return response['access_token'] as String;
    }

    final nested = response['data'];
    if (nested is Map<String, dynamic> && nested['token'] is String) {
      return nested['token'] as String;
    }

    return null;
  }
}