import "package:flutter/material.dart";
class ProfileViewModel extends ChangeNotifier {
  String _lang = "ko";
  String get lang => _lang;
  void changeLang(String l) { _lang = l; notifyListeners(); }
}
