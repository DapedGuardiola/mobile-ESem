class Registered {
  final int registeredId;
  final int eventId;
  final String name;
  final String email;
  final String phone;
  final int paymentStatus;

  Registered({
    required this.registeredId,
    required this.eventId,
    required this.name,
    required this.email,
    required this.phone,
    required this.paymentStatus,
  });

  factory Registered.fromJson(Map<String, dynamic> json) {
    return Registered(
      registeredId: json['registered_id'],
      eventId: json['event_id'],
      name: json['registered_name'],
      email: json['registered_email'],
      phone: json['registered_phone'],
      paymentStatus: json['payment_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "registered_id": registeredId,
      "event_id": eventId,
      "registered_name": name,
      "registered_email": email,
      "registered_phone": phone,
      "payment_status": paymentStatus,
    };
  }
}