import 'package:mlay_dmp_teams/app_config.dart';
import 'package:mlay_dmp_teams/data_model/carriers_response.dart';
import 'package:mlay_dmp_teams/data_model/check_response_model.dart';
import 'package:mlay_dmp_teams/data_model/delivery_info_response.dart';
import 'package:mlay_dmp_teams/helpers/response_check.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';
import 'package:http/http.dart' as http;

class ShippingRepository {
  Future<dynamic> getDeliveryInfo() async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/delivery-info");
    print(url.toString());
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$,
      },
    );
    // print(response.body);

    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    return deliveryInfoResponseFromJson(response.body);
  }
}
