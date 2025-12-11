import 'registered_model.dart';

class Participant {
  final int registeredId;
  final Registered registered;
  final List<int> sessions;

  Participant({
    required this.registeredId,
    required this.registered,
    required this.sessions,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    final sessionString = (json['sessions'] ?? '') as String;

    final sessionList = sessionString.isEmpty
        ? <int>[]
        : sessionString
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
      'sessions': sessions.join(','),
    };
  }
}
