import 'package:asthmaapp/api/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class UserApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> getHomepageData(String userId,
      [String? accessToken]) async {
    final homepageDataUrl = ApiConstants.getHomepageDataUrl(userId);
    return _apiService.get(homepageDataUrl, accessToken);
  }

  Future<Map<String, dynamic>> getUserById(String userId,
      [String? accessToken]) async {
    final userByIdtUrl = ApiConstants.getUserByIdUrl(userId);
    return _apiService.get(userByIdtUrl, accessToken);
  }
}
