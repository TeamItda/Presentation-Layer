import 'package:flutter/material.dart';
class AuthViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
}
