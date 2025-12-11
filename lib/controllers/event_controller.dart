import 'dart:convert';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import '../models/participant_model.dart';

class EventController {
  // Mendapatkan semua event aktif
  Future<List<Event>> getActiveEvent() async {
    final response = await ApiService.getRequest("/events");

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final List<dynamic> dynamicList = result["activeEvent"];
      return dynamicList.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load events");
    }
  }

  // Membuat event baru
  Future<Map<String, dynamic>> createEvent({
    required String name,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    required int maxParticipants,
    required String type, // 'paid' or 'unpaid'
    double? price,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan.'};
      }

      final eventData = {
        'name': name,
        'description': description ?? 'Deskripsi event',
        'date': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'time': time ?? '08:00 - 17:00',
        'location': location ?? 'Lokasi belum ditentukan',
        'max_participants': maxParticipants,
        'type': type,
        'price': price,
        'status': 'upcoming',
      };

      final response = await ApiService.postAuth(
        '/events/create',
        eventData,
        token,
      );
      final result = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': result,
        'message': result['message'] ?? 'Event berhasil dibuat',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error creating event: $e'};
    }
  }

  // Mendapatkan detail event
  Future<(Event, List<Participant>)> getEventDetail(int eventId) async {
    final response = await ApiService.getRequest('/eventDetail/$eventId');
    final result = jsonDecode(response.body);
    print(result);
    final event = Event.fromJson(result['event']);
    final participantsJson = result['participants'] as List;
    final participants = participantsJson
        .map((json) => Participant.fromJson(json))
        .toList();
    print('participant =');
    print(participants);
    return (event, participants);
  }

  // Mendapatkan riwayat event
  Future<List<Event>> getRecentEvent() async {
    final response = await ApiService.getRequest("/events");

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);

      final List<dynamic> dynamicList = result["recentEvent"];

      return dynamicList.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load events");
    }
  }

  Future<List<Event>> getComingSoonEvent() async {
    final response = await ApiService.getRequest("/events");

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);

      final List<dynamic> dynamicList = result["comingSoonEvent"];

      return dynamicList.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load events");
    }
  }

  // Mendapatkan semua event (untuk dropdown)
  Future<Map<String, dynamic>> getAllEvents() async {
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

      final response = await ApiService.getAuth('/events', token);
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
}
