// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:convert';

import 'package:mlay_dmp_teams/app_config.dart';
import 'package:mlay_dmp_teams/data_model/check_response_model.dart';
import 'package:mlay_dmp_teams/data_model/purchased_ditital_product_response.dart';
import 'package:mlay_dmp_teams/helpers/response_check.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:mlay_dmp_teams/data_model/order_mini_response.dart';
import 'package:mlay_dmp_teams/data_model/order_detail_response.dart';
import 'package:mlay_dmp_teams/data_model/order_item_response.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';

import '../data_model/all_booking_response.dart';
import '../data_model/send_book_response.dart';

class OrderRepository {
  Future<dynamic> getOrderList(
      {page = 1, payment_status = "", delivery_status = ""}) async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/purchase-history" +
        "?page=${page}&payment_status=${payment_status}&delivery_status=${delivery_status}");
    print("url:" + url.toString());
    print("token:" + access_token.$);
    final response = await http.get(url, headers: {
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$,
    });

    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    return orderMiniResponseFromJson(response.body);
  }

  Future<dynamic> reminders() async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/reminders/${user_id.$}");
    print("url:" + url.toString());
    print("token:" + access_token.$);
    final response = await http.get(url, headers: {
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$,
    });

    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    return allBookingResponseFromJson(response.body);
  }

  Future<SendBook> sendBook({@required int id = 0, String status = ""}) async {
    var post_body = jsonEncode({
      "status": "$status",
    });

    Uri url = Uri.parse("${AppConfig.BASE_URL}/reminders/${user_id.$}/${id}");
    final response = await http.put(url,
        headers: {
          "App-Language": app_language.$,
        },
        body: post_body);
    print(post_body);

    print(response.body);

    return SendBookResponseFromJson(response.body);
  }

  Future<dynamic> getOrderDetails({@required int id = 0}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/purchase-history-details/" + id.toString());

    final response = await http.get(url, headers: {
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$,
    });
    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    return orderDetailResponseFromJson(response.body);
  }

  Future<dynamic> getOrderItems({@required int id = 0}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/purchase-history-items/" + id.toString());
    final response = await http.get(url, headers: {
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$,
    });
    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    return orderItemlResponseFromJson(response.body);
  }

  Future<dynamic> getPurchasedDigitalProducts({
    page = 1,
  }) async {
    Uri url =
        Uri.parse("${AppConfig.BASE_URL}/digital/purchased-list?page=$page");
    print(url.toString());

    final response = await http.get(url, headers: {
      "App-Language": app_language.$,
      "Authorization": "Bearer ${access_token.$}",
    });

    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);
    return purchasedDigitalProductResponseFromJson(response.body);
  }
}
