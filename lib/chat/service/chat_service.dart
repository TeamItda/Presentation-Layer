import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String _baseUrl = 'https://chatbot-backend-hxsc.onrender.com';

  Future<String> sendMessage(
    String message,
    String lang, {
    List<Map<String, String>> history = const [],
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message, 'lang': lang, 'history': history}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['reply'];
    }

    throw Exception('Server error: ${response.statusCode}');
  }
}
