import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class AsthmaControlTestApi {
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

  Future<Map<String, dynamic>> getAsthamControlTestHistory(
      String userId, int month, int year,
      [String? accessToken]) async {
    final getAsthamControlTestHistoryUrl =
        ApiConstants.getAsthamControlTestHistoryUrl(userId, month, year);
    return _apiService.get(getAsthamControlTestHistoryUrl, accessToken);
  }
}
