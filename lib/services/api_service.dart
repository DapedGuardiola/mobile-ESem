import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  static Future<http.Response> getRequest(String endpoint) {
    return http.get(Uri.parse("$baseUrl$endpoint"));
  }


  static Future<http.Response> postRequest(String endpoint, Map data) {
  return http.post(
    Uri.parse("$baseUrl$endpoint"),
    headers: {
      "Content-Type": "application/json", // pakai JSON
    },
    body: jsonEncode(data), // encode Map ke JSON string
  );
}

  static Future<http.Response> postAuth(String endpoint, Map data, String token) {
    return http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
      },
      body: data,
    );
  }
  static Future<http.Response> getAuth(String endpoint, String token) {
    return http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }
}
