import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://esem.my.id/api";

  static Future<http.Response> getRequest(String endpoint) {
    return http.get(Uri.parse("$baseUrl$endpoint"));
  }

  static Future<http.Response> postRequest(String endpoint, Map data) {
    final url = "$baseUrl$endpoint";
    return http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> postAuth(
    String endpoint,
    Map data,
    String token,
  ) {
    return http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json", // TAMBAHKAN INI
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data), // ENCODE KE JSON
    );
  }

  static Future<http.Response> getAuth(String endpoint, String token) {
    return http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  // ============ FUNGSI BARU UNTUK ABSENSI ============

  static Future<Map<String, dynamic>> postAttendance(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse("$baseUrl/$endpoint");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      print("📡 POST → $url");
      print("📨 BODY → ${jsonEncode(data)}");
      print("📥 STATUS CODE → ${response.statusCode}");
      print("📥 RESPONSE → ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("❌ ERROR → $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  // Untuk mendapatkan list event aktif
  static Future<Map<String, dynamic>> getActiveEvents(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/events/active"),
        headers: {"Authorization": "Bearer $token"},
      );

      final result = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'data': result['data'] ?? [],
        'message': result['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e', 'data': []};
    }
  }

  // Untuk membuat event baru
  static Future<Map<String, dynamic>> createEvent(
    Map<String, dynamic> eventData,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/events/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(eventData),
      );

      final result = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': result,
        'message': result['message'] ?? 'Event berhasil dibuat',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
