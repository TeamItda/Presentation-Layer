import 'package:flutter/material.dart';
import '../service/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  // 채팅 메시지 목록
  final List<Map<String, String>> _messages = [
    {
      'role': 'ai',
      'text':
          '🤖 \n안녕하세요, 여기요 챗봇이에요!\n원하시는 종로구 생활정보를 알려드릴게요.\n의료시설, 공공기관, 교육시설, 맛집 등에 대해 질문해보세요! 😊',
    },
  ];
  List<Map<String, String>> get messages => _messages;

  // 서버 통신 서비스
  final ChatService _chatService = ChatService();

  // 응답 대기 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 현재 선택된 응답 언어
  String _selectedLang = 'ko';
  String get selectedLang => _selectedLang;

  // 응답 언어 변경
  void changeLang(String lang) {
    _selectedLang = lang;
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // 사용자 메시지 추가
    _messages.add({'role': 'user', 'text': message});
    notifyListeners();

    // AI 응답 대기 시작
    _isLoading = true;
    notifyListeners();

    try {
      final reply = await _chatService.sendMessage(message, _selectedLang);

      // AI 응답 추가
      _messages.add({'role': 'ai', 'text': reply});
    } catch (e) {
      // 서버 연결 실패 시 안내 메시지 표시
      _messages.add({
        'role': 'ai',
        'text': '현재 답변을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
