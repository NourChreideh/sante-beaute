import 'dart:convert';

allBooking allBookingResponseFromJson(String str) =>
    allBooking.fromJson(json.decode(str));

String allBookingResponseToJson(allBooking data) => json.encode(data.toJson());

class allBooking {
  allBooking({
    this.reminders,
    this.success,
    this.status,
  });

  List<Reminders> reminders;
  bool success;
  int status;

  factory allBooking.fromJson(Map<String, dynamic> json) => allBooking(
        reminders: List<Reminders>.from(
            json["reminders"].map((x) => Reminders.fromJson(x))),
        success: json["success"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(reminders.map((x) => x.toJson())),
        "success": success,
        "status": status,
      };
}

class Reminders {
  int id;
  int userId;
  String location;
  String sessionTime;
  String status;
  String dateCreated;
  String dateUpdated;

  Reminders(
      {this.id,
      this.userId,
      this.location,
      this.sessionTime,
      this.status,
      this.dateCreated,
      this.dateUpdated});

  Reminders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    location = json['location'];
    sessionTime = json['session_time'];
    status = json['status'];
    dateCreated = json['date_created'];
    dateUpdated = json['date_updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['location'] = this.location;
    data['session_time'] = this.sessionTime;
    data['status'] = this.status;
    data['date_created'] = this.dateCreated;
    data['date_updated'] = this.dateUpdated;
    return data;
  }
}
