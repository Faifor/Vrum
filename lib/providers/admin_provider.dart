import 'package:flutter/material.dart';

import '../models/admin_contract.dart';
import '../models/admin_user_details.dart';
import '../models/document.dart';
import '../models/user_summary.dart';
import '../services/api_client.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({required ApiClient client}) : _apiClient = client;

  final ApiClient _apiClient;
  List<UserSummary> _users = const [];
  AdminUserStatusFilter _statusFilter = AdminUserStatusFilter.all;
  AdminUserDetails? _selectedUser;
  UserDocument? _selectedDocument;
  AdminContract? _selectedContract;
  int? _selectedUserId;
  bool _loading = false;
  String? _error;

  List<UserSummary> get users => _users;
  AdminUserStatusFilter get statusFilter => _statusFilter;
  AdminUserDetails? get selectedUser => _selectedUser;
  UserDocument? get selectedDocument => _selectedDocument;
  AdminContract? get selectedContract => _selectedContract;
  int? get selectedUserId => _selectedUserId;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> refreshUsers() async {
    _setLoading();
    try {
      _users = await _apiClient.listUsers(status: _statusFilter.queryValue);
      _clearError();
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> setStatusFilter(AdminUserStatusFilter filter) async {
    if (_statusFilter == filter) {
      return;
    }
    _statusFilter = filter;
    await refreshUsers();
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

  Future<void> fetchUserDetails(int userId) async {
    _setLoading();
    try {
      _selectedUser = await _apiClient.getAdminUser(userId);
      _selectedDocument = null;
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

  Future<AdminContract> createContract({
    required int userId,
    required AdminContractDraft draft,
  }) async {
    _setLoading();
    try {
      _selectedContract = await _apiClient.createAdminContract(userId, draft);
      _selectedUserId = userId;
      _clearError();
      return _selectedContract!;
    } catch (e) {
      _setError(e);
      rethrow;
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

enum AdminUserStatusFilter { pending, rejected, approved, draft, all }

extension AdminUserStatusFilterX on AdminUserStatusFilter {
  String get queryValue {
    switch (this) {
      case AdminUserStatusFilter.pending:
        return 'pending';
      case AdminUserStatusFilter.rejected:
        return 'rejected';
      case AdminUserStatusFilter.approved:
        return 'approved';
      case AdminUserStatusFilter.draft:
        return 'draft';
      case AdminUserStatusFilter.all:
        return 'all';
    }
  }
}
