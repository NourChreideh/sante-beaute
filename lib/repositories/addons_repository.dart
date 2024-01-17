import 'package:mlay_dmp_teams/app_config.dart';
import 'package:mlay_dmp_teams/data_model/addons_response.dart';
import 'package:http/http.dart' as http;

class AddonsRepository {
  Future<List<AddonsListResponse>> getAddonsListResponse() async {
    Uri url = Uri.parse('${AppConfig.BASE_URL}/addon-list');

    final response = await http.get(url);
    //print("adons ${response.body}");
    return addonsListResponseFromJson(response.body);
  }
}
