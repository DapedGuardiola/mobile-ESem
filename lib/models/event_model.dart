import 'event_detail_model.dart';
class Event {
  final int eventId;
  final String eventName;
  final String eventStatus;
  final EventDetailModel? eventDetail;

  Event({
    required this.eventId,
    required this.eventName,
    required this.eventStatus,
    this.eventDetail,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'],
      eventName: json['event_name'] ?? '',
      eventStatus: json['event_status'] ?? '',
      eventDetail: json['event_detail'] != null
          ? EventDetailModel.fromJson(json['event_detail'])
          : null,
    );
  }
}
