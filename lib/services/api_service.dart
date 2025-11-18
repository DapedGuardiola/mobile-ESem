import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  Future<String> ping() async {
    final response = await http.get(Uri.parse("$baseUrl/ping"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'];
    } else {
      throw Exception("Gagal terhubung ke API");
    }
  }
}
