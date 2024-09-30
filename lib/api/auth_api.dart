import 'package:asthmaapp/api/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class AuthApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> signin(String email, String password,
      String? accessToken, String? deviceToken, String? deviceType) async {
    return _apiService.post(ApiConstants.signin, accessToken, {
      'email': email,
      'password': password,
      'deviceToken': deviceToken,
      'deviceType': deviceType,
    });
  }

  Future<Map<String, dynamic>> refreshToken(String accessToken,
      String refreshToken, String? deviceToken, String? deviceType) async {
    return _apiService.post(ApiConstants.refreshtoken, accessToken, {
      'refreshToken': refreshToken,
      'deviceToken': deviceToken,
      'deviceType': deviceType,
    });
  }

  Future<Map<String, dynamic>> signup(
      String firstName,
      String lastName,
      String email,
      String password,
      String dateTimeZone,
      String? accessToken,
      String deviceToken,
      String deviceType) async {
    return _apiService.post(ApiConstants.signup, accessToken, {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'dateTimeZone': dateTimeZone,
      'deviceToken': deviceToken,
      'deviceType': deviceType,
    });
  }

  Future<Map<String, dynamic>> signout(String userId) async {
    final signoutUrl = ApiConstants.getSignoutUrl(userId);
    return _apiService.delete(signoutUrl, null);
  }
}
