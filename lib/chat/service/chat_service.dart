import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String _baseUrl = 'http://localhost:8000';

  Future<String> sendMessage(String message, String lang) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message, 'lang': lang}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['reply'];
    }
    throw Exception('Server error');
  }
}
