import 'package:mlay_dmp_teams/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:mlay_dmp_teams/data_model/brand_response.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';

class BrandRepository {
  Future<BrandResponse> getFilterPageBrands() async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/filter/brands");
    final response = await http.get(url, headers: {
      "App-Language": app_language.$,
    });
    return brandResponseFromJson(response.body);
  }

  Future<BrandResponse> getBrands({name = "", page = 1}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/brands" + "?page=${page}&name=${name}");
    final response = await http.get(url, headers: {
      "App-Language": app_language.$,
    });
    return brandResponseFromJson(response.body);
  }
}
