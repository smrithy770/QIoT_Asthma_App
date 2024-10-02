import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class InhalerApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addInhaler(String userId, int inhalerValue,
      Map<String, dynamic> location, int month, int year,
      [String? accessToken]) async {
    final addInhalerUrl = ApiConstants.addInhalerUrl(userId);
    return _apiService.post(addInhalerUrl, accessToken, {
      'inhalerValue': inhalerValue,
      'location': location,
      'month': month,
      'year': year,
    });
  }

  Future<Map<String, dynamic>> getInhalerHistory(
      String userId, int month, int year,
      [String? accessToken]) async {
    final getInhalerHistoryUrl =
        ApiConstants.getInhalerHistoryUrl(userId, month, year);
    return _apiService.get(getInhalerHistoryUrl, accessToken);
  }
}
