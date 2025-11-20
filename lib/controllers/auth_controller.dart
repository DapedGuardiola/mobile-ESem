import 'dart:convert';
import '../services/api_service.dart';

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
}
