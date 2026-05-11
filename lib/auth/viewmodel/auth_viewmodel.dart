import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedLanguage = 'ko';

  // 유저 정보
  String _nickname = '';
  String _email = '';

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedLanguage => _selectedLanguage;
  String get nickname => _nickname;
  String get email => _email;

  // Firestore에서 유저 정보 로드
  Future<void> loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        _nickname = doc.data()?['nickname'] ?? '';
        _email = doc.data()?['email'] ?? user.email ?? '';
        _selectedLanguage = doc.data()?['language'] ?? 'ko';
        notifyListeners();
      }
    } catch (e) {
      print('유저 정보 로드 에러: $e');
    }
  }

  void selectLanguage(String lang) {
    _selectedLanguage = lang;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 이메일 로그인
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email, password);
      _isLoggedIn = true;
      await loadUserInfo(); // 로그인 후 유저 정보 로드
      return true;
    } catch (e) {
      _errorMessage = _authService.getErrorMessage(
        e.toString().contains(']')
            ? e.toString().split('] ')[1].split(' ')[0]
            : 'unknown',
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 구글 로그인
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      _isLoggedIn = true;
      await loadUserInfo(); // 로그인 후 유저 정보 로드
      return true;
    } catch (e) {
      _errorMessage = '구글 로그인에 실패했어요. 다시 시도해주세요.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 회원가입
  Future<bool> signUp({
    required String email,
    required String password,
    required String nickname,
    required String language,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        nickname: nickname,
        language: language,
      );
      _isLoggedIn = true;
      await loadUserInfo(); // 가입 후 유저 정보 로드
      return true;
    } catch (e) {
      print('회원가입 에러: $e');
      _errorMessage = _authService.getErrorMessage(
        e.toString().contains(']')
            ? e.toString().split('] ')[1].split(' ')[0]
            : 'unknown',
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _authService.signOut();
    _isLoggedIn = false;
    _nickname = '';
    _email = '';
    notifyListeners();
  }
}