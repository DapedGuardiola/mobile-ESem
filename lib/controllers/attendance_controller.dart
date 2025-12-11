import 'dart:convert';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceController {
  // Scan QR dan simpan absensi
  Future<Map<String, dynamic>> scanQR(String qrData, int eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login ulang.',
        };
      }

      final result = await ApiService.postAttendance(qrData, eventId, token);
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error scanning QR: $e',
      };
    }
  }

  // Mendapatkan riwayat absensi user
  Future<Map<String, dynamic>> getAttendanceHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan.',
          'data': [],
        };
      }

      final response = await ApiService.getAuth('/attendance/history', token);
      final result = jsonDecode(response.body);
      
      return {
        'success': response.statusCode == 200,
        'data': result['data'] ?? [],
        'message': result['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'data': [],
      };
    }
  }

  // Mendapatkan daftar peserta event
  Future<Map<String, dynamic>> getEventParticipants(int eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan.',
          'data': [],
        };
      }

      final response = await ApiService.getAuth('/events/$eventId/participants', token);
      final result = jsonDecode(response.body);
      
      return {
        'success': response.statusCode == 200,
        'data': result['data'] ?? [],
        'message': result['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'data': [],
      };
    }
  }

  // Export data absensi
  Future<Map<String, dynamic>> exportAttendance(int eventId, String format) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan.',
        };
      }

      final response = await ApiService.getAuth(
        '/events/$eventId/export?format=$format',
        token,
      );
      final result = jsonDecode(response.body);
      
      return {
        'success': response.statusCode == 200,
        'data': result['data'],
        'message': result['message'] ?? 'Export berhasil',
        'file_url': result['file_url'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}