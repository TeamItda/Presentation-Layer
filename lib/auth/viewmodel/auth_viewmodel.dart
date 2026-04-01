import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedLanguage = 'ko';

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedLanguage => _selectedLanguage;

  void selectLanguage(String lang) {
    _selectedLanguage = lang;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // TODO: Firebase 연동 시 채울 메서드들
  Future<void> signInWithEmail(String email, String password) async {}
  Future<void> signInWithGoogle() async {}
  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
    required String language,
  }) async {}
  Future<void> signOut() async {}
}