import 'package:flutter/material.dart';

import '../models/document.dart';
import '../models/user_summary.dart';
import '../services/api_client.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({required ApiClient client}) : _apiClient = client;

  final ApiClient _apiClient;
  List<UserSummary> _users = const [];
  UserDocument? _selectedDocument;
  int? _selectedUserId;
  bool _loading = false;
  String? _error;

  List<UserSummary> get users => _users;
  UserDocument? get selectedDocument => _selectedDocument;
  int? get selectedUserId => _selectedUserId;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> refreshUsers() async {
    _setLoading();
    try {
      _users = await _apiClient.listUsers();
      _clearError();
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> fetchDocument(int userId) async {
    _setLoading();
    try {
      _selectedDocument = await _apiClient.getUserDocument(userId);
      _selectedUserId = userId;
      _clearError();
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> approve(int userId) async {
    _setLoading();
    try {
      _selectedDocument = await _apiClient.approveUserDocument(userId);
      _selectedUserId = userId;
      await refreshUsers();
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> reject(int userId, String reason) async {
    _setLoading();
    try {
      _selectedDocument = await _apiClient.rejectUserDocument(
        userId: userId,
        reason: reason,
      );
      _selectedUserId = userId;
      await refreshUsers();
    } catch (e) {
      _setError(e);
    }
  }

  void _setLoading() {
    _loading = true;
    _error = null;
    notifyListeners();
  }

  void _setError(Object error) {
    _loading = false;
    _error = error.toString();
    notifyListeners();
  }

  void _clearError() {
    _loading = false;
    _error = null;
    notifyListeners();
  }
}
