import 'package:asthmaapp/api/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class AsthmacontroltestApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addAsthamControlTest(String userId, int actScore,
      Map<String, dynamic> location, int month, int year,
      [String? accessToken]) async {
    final addAsthamControlTestUrl =
        ApiConstants.addAsthamControlTestUrl(userId);
    return _apiService.post(addAsthamControlTestUrl, accessToken, {
      'actScore': actScore,
      'location': location,
      'month': month,
      'year': year,
    });
  }

  Future<Map<String, dynamic>> getAllAsthamControlTest(
      String userId, int month, int year,
      [String? accessToken]) async {
    final getAllAsthamControlTestUrl =
        ApiConstants.getAllAsthamControlTestUrl(userId);
    return _apiService.get(getAllAsthamControlTestUrl, accessToken);
  }
}
