import 'package:flutter/foundation.dart';
import 'package:myapp/services/local_storage_service.dart';

class UserService extends ChangeNotifier {
  final LocalStorageService _localStorageService;
  String? _currentUsername;

  UserService({LocalStorageService? localStorageService})
      : _localStorageService = localStorageService ?? LocalStorageService() {
    _loadUsername();
  }

  String? get currentUsername => _currentUsername;

  bool get hasUsername => _currentUsername != null && _currentUsername!.isNotEmpty;

  Future<void> _loadUsername() async {
    _currentUsername = await _localStorageService.getUsername();
    notifyListeners();
  }

  Future<void> saveUsername(String username) async {
    if (username.trim().isEmpty) {
      // Optionally handle or prevent saving empty usernames
      return;
    }
    await _localStorageService.saveUsername(username.trim());
    _currentUsername = username.trim();
    notifyListeners();
  }

  Future<void> clearUsername() async {
    await _localStorageService.saveUsername(''); // Save as empty or handle null in LocalStorageService
    _currentUsername = null;
    notifyListeners();
  }
}