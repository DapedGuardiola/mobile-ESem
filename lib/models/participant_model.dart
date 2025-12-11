import 'registered_model.dart';

class Participant {
  final int participantId;
  final int eventId;
  final int sessionId;
  final int registeredId;
  final Registered? registered; // relasi

  Participant({
    required this.participantId,
    required this.eventId,
    required this.sessionId,
    required this.registeredId,
    this.registered,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      participantId: json['participant_id'],
      eventId: json['event_id'],
      sessionId: json['session_id'],
      registeredId: json['registered_id'],
      registered: json['registered'] != null
          ? Registered.fromJson(json['registered'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "participant_id": participantId,
      "event_id": eventId,
      "session_id": sessionId,
      "registered_id": registeredId,
      "registered": registered?.toJson(),
    };
  }
}