import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = "https://api.jsonbin.io/v3/b/66184918ad19ca34f858908f"; // Sample Public API for testing

  Future<String> fetchQuote() async {
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/quotes/random'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['quote'] ?? "Stay focused and keep moving!";
      } else {
        return "Stay focused and keep moving!";
      }
    } catch (e) {
      return "Keep pushing forward!";
    }
  }
}
