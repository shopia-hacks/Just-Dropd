import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://api.justdropd.com"; 
  // Flutter web uses localhost, NOT 10.0.2.2

  static Future<String> pingBackend() async {
    final uri = Uri.parse("$baseUrl/health");
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return res.body;
    } else {
      throw Exception("Backend not reachable");
    }
  }

  static Future<List<dynamic>> fetchConcertReviews(String userId) async {
    final uri = Uri.parse("$baseUrl/concert-reviews/user/$userId");
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to fetch reviews");
    }
  }
}
