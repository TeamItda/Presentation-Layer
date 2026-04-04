import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  // render 이용해서 배포한 Fast API 백엔드 서버 주소
  // 교수님 중간점검 때 시연 할 수 있도록 하는 임시 주소
  static const String _baseUrl = 'https://chatbot-backend-hxsc.onrender.com';

  Future<String> sendMessage(String message, String lang) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message, 'lang': lang, 'history': []}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['reply'];
    }

    throw Exception('Server error: ${response.statusCode}');
  }
}
