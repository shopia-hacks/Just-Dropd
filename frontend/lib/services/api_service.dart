import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:3000"; 
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
}
