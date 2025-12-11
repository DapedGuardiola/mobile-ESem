import 'registered_model.dart';

class Participant {
  final int registeredId;
  final Registered registered;
  final List<int> sessions; // daftar session yang diikuti peserta

  Participant({
    required this.registeredId,
    required this.registered,
    required this.sessions,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    // sessions dikirim sebagai string "1,2,3" dari API
    final sessionString = json['sessions'] as String;
    final sessionList = sessionString
        .split(',')
        .map((s) => int.tryParse(s))
        .where((s) => s != null)
        .map((s) => s!)
        .toList();

    return Participant(
      registeredId: json['registered_id'],
      registered: Registered.fromJson(json['registered']),
      sessions: sessionList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registered_id': registeredId,
      'registered': registered.toJson(),
      'sessions': sessions.join(','), // untuk kirim balik ke API
    };
  }
}
