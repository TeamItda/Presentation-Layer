import 'package:flutter/material.dart';
import '../service/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  // 채팅 메시지 목록
  static const Map<String, String> _greetings = {
    'ko':
        '🤖 \n안녕하세요, 여기요 챗봇이에요!\n원하시는 종로구 생활정보를 알려드릴게요.\n의료시설, 공공기관, 교육시설, 맛집 등에 대해 질문해보세요! 😊',
    'en':
        '🤖 \nHello! I\'m the Yeogiyo chatbot!\nI can help you with living information in Jongno-gu.\nFeel free to ask about medical facilities, public offices, schools, restaurants, and more! 😊',
    'ja':
        '🤖 \nこんにちは！여기요チャットボットです！\n鍾路区の生活情報をお伝えします。\n医療施設、公共機関、教育施設、グルメなどについて質問してください！ 😊',
    'zh': '🤖 \n您好！我是여기요聊天机器人！\n为您提供钟路区的生活信息。\n请随时询问医疗设施、公共机构、教育设施、美食等问题！ 😊',
  };

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

  String? _detectMapCategory(String message) {
    final text = message.toLowerCase();

    if (text.contains('약국') || text.contains('pharmacy')) {
      return 'pharmacy';
    }

    if (text.contains('병원') ||
        text.contains('의료') ||
        text.contains('진료') ||
        text.contains('응급') ||
        text.contains('의원') ||
        text.contains('치과') ||
        text.contains('한의원') ||
        text.contains('hospital') ||
        text.contains('clinic') ||
        text.contains('medical')) {
      return 'medical';
    }

    if (text.contains('맛집') ||
        text.contains('식당') ||
        text.contains('밥') ||
        text.contains('혼밥') ||
        text.contains('음식') ||
        text.contains('먹거리') ||
        text.contains('광장시장') ||
        text.contains('카페') ||
        text.contains('restaurant') ||
        text.contains('food') ||
        text.contains('cafe')) {
      return 'food';
    }

    if (text.contains('주민센터') ||
        text.contains('구청') ||
        text.contains('공공기관') ||
        text.contains('민원') ||
        text.contains('전입신고') ||
        text.contains('주민등록') ||
        text.contains('public office') ||
        text.contains('district office')) {
      return 'government';
    }

    return null;
  }

  // 응답 언어 변경
  void changeLang(String lang) {
    _selectedLang = lang;
    // 첫 번째 메시지(인사말) 언어에 맞게 변경
    if (_messages.isNotEmpty && _messages[0]['role'] == 'ai') {
      _messages[0] = {
        'role': 'ai',
        'text': _greetings[lang] ?? _greetings['ko']!,
      };
    }
    notifyListeners();
  }

  // 서버 연결 실패 메시지
  static const Map<String, String> _errorMessages = {
    'ko': '현재 답변을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
    'en': 'Unable to get a response. Please try again later.',
    'ja': '現在、回答を取得できません。しばらくしてから再試行してください。',
    'zh': '目前无法获取回答，请稍后再试。',
  };

  Future<void> sendMessage(String message, {String lang = 'ko'}) async {
    if (message.trim().isEmpty) return;

    // 사용자 메시지 추가
    _messages.add({'role': 'user', 'text': message});
    notifyListeners();

    final relatedCategory = _detectMapCategory(message);

    // AI 응답 대기 시작
    _isLoading = true;
    notifyListeners();

    try {
      final history = _messages
          .where((msg) => msg['text'] != null && msg['text']!.trim().isNotEmpty)
          .skip(1) // 초기 환영 메시지 제외
          .toList();

      if (history.isNotEmpty) {
        history.removeLast(); // 방금 보낸 사용자 메시지 제외
      }

      final formattedHistory = history.map((msg) {
        return {
          'role': msg['role'] == 'user' ? 'user' : 'assistant',
          'text': msg['text'] ?? '',
        };
      }).toList();

      final reply = await _chatService.sendMessage(
        message,
        _selectedLang,
        history: formattedHistory,
      );

      // AI 응답 추가
      _messages.add({
        'role': 'ai',
        'text': reply,
        if (relatedCategory != null) 'category': relatedCategory,
      });
    } catch (e) {
      // 서버 연결 실패 시 안내 메시지 표시
      _messages.add({
        'role': 'ai',
        'text': _errorMessages[_selectedLang] ?? _errorMessages['ko']!,
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
