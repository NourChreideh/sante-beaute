// To parse this JSON data, do
//
//     final addressAddResponse = addressAddResponseFromJson(jsonString);

import 'dart:convert';

SendBook SendBookResponseFromJson(String str) =>
    SendBook.fromJson(json.decode(str));

String SendBookResponseToJson(SendBook data) => json.encode(data.toJson());

class SendBook {
  SendBook({
    this.result,
    this.message,
  });

  bool result;
  String message;

  factory SendBook.fromJson(Map<String, dynamic> json) => SendBook(
        result: json["result"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "message": message,
      };
}
