import 'package:mlay_dmp_teams/app_config.dart';
import 'package:mlay_dmp_teams/data_model/check_response_model.dart';
import 'package:mlay_dmp_teams/helpers/response_check.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:mlay_dmp_teams/data_model/coupon_apply_response.dart';
import 'package:mlay_dmp_teams/data_model/coupon_remove_response.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';

class CouponRepository {
  Future<dynamic> getCouponApplyResponse(@required String coupon_code) async {
    var post_body =
        jsonEncode({"user_id": "${user_id.$}", "coupon_code": "$coupon_code"});

    Uri url = Uri.parse("${AppConfig.BASE_URL}/coupon-apply");
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$
        },
        body: post_body);
    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    return couponApplyResponseFromJson(response.body);
  }

  Future<dynamic> getCouponRemoveResponse() async {
    var post_body = jsonEncode({"user_id": "${user_id.$}"});

    Uri url = Uri.parse("${AppConfig.BASE_URL}/coupon-remove");
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$
        },
        body: post_body);
    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    return couponRemoveResponseFromJson(response.body);
  }
}
