import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class UserApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> pushNotifications([String? accessToken]) async {
    final getAllNotesUrl = ApiConstants.getPushNotificationUrl();
    return _apiService.post(getAllNotesUrl, accessToken, {});
  }

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

  Future<Map<String, dynamic>> updateUserDataById(
      String userId, String morningTime, String eveningTime,
      [String? accessToken]) async {
    final updateUserDataByIdUrl = ApiConstants.updateUserDataByIdUrl(userId);
    return _apiService.put(
      updateUserDataByIdUrl,
      {
        'startTime': morningTime,
        'endTime': eveningTime,
      },
      accessToken,
    );
  }
}
