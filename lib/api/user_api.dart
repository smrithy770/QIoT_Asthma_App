import 'package:asthmaapp/api/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class UserApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> getUserById(String id,
      [String? accessToken]) async {
    final signoutUrl = ApiConstants.getUserByIdUrl(id);
    return _apiService.get(signoutUrl, accessToken);
  }

  Future<Map<String, dynamic>> getAllAsthmaMessages(
      [String? accessToken]) async {
    return _apiService.get(ApiConstants.getAllAsthmaMessages, accessToken);
  }
}
