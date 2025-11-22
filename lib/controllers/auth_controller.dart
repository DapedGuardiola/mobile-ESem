import 'dart:convert';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  Future<Map> login(String email, String password) async {
    final response = await ApiService.postRequest("/login", {
      "email": email,
      "password": password,
    });
    return jsonDecode(response.body);
  }

  Future<Map> register(Map<String, dynamic> data) async {
    final response = await ApiService.postRequest("/register", data);
    return jsonDecode(response.body);
  }
  
  Future<Map> getUser(String token) async {
    final response = await ApiService.getAuth("/user", token);
    return jsonDecode(response.body);
  }

  // ---------------- GET ME ----------------
  Future<Map> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      return {
        "success": false,
        "message": "Token tidak ditemukan, user belum login"
      };
    }

    final response = await ApiService.getAuth("/me", token);
    return jsonDecode(response.body);
  }
}
