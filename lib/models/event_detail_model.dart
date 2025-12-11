class EventDetailModel {
  final int eventDetailId;
  final int eventId;
  final String eventDescription;
  final String eventAddress;
  final String eventSpeaker;
  final String registerOpenDate;
  final String registerClosedDate;
  final int registerStatus;
  final int totalParticipant;
  final String date;
  final int eventHandler;
  final int cost;
  final int totalIncome;
  final int paidStatus;
  final String dateString;
  final String timeString;
  final int registeredCount;
  final String imageUrl;


  EventDetailModel({
    required this.eventDetailId,
    required this.eventId,
    required this.eventDescription,
    required this.eventAddress,
    required this.eventSpeaker,
    required this.registerOpenDate,
    required this.registerClosedDate,
    required this.registerStatus,
    required this.totalParticipant,
    required this.date,
    required this.eventHandler,
    required this.cost,
    required this.totalIncome,
    required this.paidStatus,
    required this.dateString,
    required this.timeString,
    required this.registeredCount,
    required this.imageUrl,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    return EventDetailModel(
      eventDetailId: json['event_detail_id'],
      eventId: json['event_id'],
      eventDescription: json['event_description'] ?? '',
      eventAddress: json['event_address'] ?? '',
      eventSpeaker: json['event_speaker'] ?? '',
      registerOpenDate: json['register_open_date'] ?? '',
      registerClosedDate: json['register_closed_date'] ?? '',
      registerStatus: json['register_status'] ?? 0,
      totalParticipant: json['total_participant'] ?? 0,
      date: json['date'] ?? '',
      eventHandler: json['event_handler'] ?? 0,
      cost: json['cost'] ?? 0,
      totalIncome: json['total_income'] ?? 0,
      paidStatus: json['paid_status'] ?? 0,
      dateString: json['date_string'] ?? '',
      timeString: json['time_string'] ?? '',
      registeredCount: json['registered_count'] ?? 0,
      imageUrl : json['image_url'],
    );
  }
}