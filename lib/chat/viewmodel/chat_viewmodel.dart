import 'package:flutter/material.dart';
class ChatViewModel extends ChangeNotifier {
  final List<Map<String, String>> _messages = [];
  List<Map<String, String>> get messages => _messages;
}
