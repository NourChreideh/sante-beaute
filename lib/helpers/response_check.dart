import 'dart:convert';

import 'package:mlay_dmp_teams/helpers/auth_helper.dart';
import 'package:mlay_dmp_teams/screens/main.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';

class ResponseCheck {
  static bool apply(response) {
    // print("ResponseCheck ${response}");
    try {
      var responseData = jsonDecode(response);

      if (responseData is Map &&
          responseData.containsKey("result") &&
          !responseData['result']) {
        if (responseData.containsKey("result_key") &&
            responseData['result_key'] == "banned") {
          AuthHelper().clearUserData();
          Navigator.pushAndRemoveUntil(
              OneContext().context,
              MaterialPageRoute(builder: (context) => Main()),
              (route) => false);
        }
        return false;
      }
    } on Exception catch (e) {
      // TODO
    }
    return true;
  }
}
