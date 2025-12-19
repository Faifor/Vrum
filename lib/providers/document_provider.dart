import 'package:flutter/material.dart';

import '../models/document.dart';
import '../services/api_client.dart';

class DocumentProvider extends ChangeNotifier {
  DocumentProvider({required ApiClient client}) : _client = client {
    fetch();
  }

  final ApiClient _client;

  UserDocument _document = UserDocument.empty();
  bool _loading = false;
  String? _error;

  UserDocument get document => _document;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch() async {
    _setLoading();
    try {
      _document = await _client.getMyDocument();
      _clearError();
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> update(UserDocument doc) async {
    _setLoading();
    try {
      _document = await _client.updateMyDocument(doc);
      _clearError();
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> submit() async {
    _setLoading();
    try {
      _document = await _client.submitDocument();
      _clearError();
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
