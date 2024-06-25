import 'dart:async';
import 'dart:io';
import 'package:asthmaapp/api/auth_api.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:realm/realm.dart';

class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  Timer? timer;
  UserModel? userModel;
  Realm? realm;
  String? deviceToken;
  String? deviceType;

  factory TokenRefreshService() {
    return _instance;
  }

  TokenRefreshService._internal();

  void initialize(
      Realm realm, UserModel userModel, String deviceToken, String deviceType) {
    this.realm = realm;
    this.userModel = userModel;
    this.deviceToken = deviceToken;
    this.deviceType = deviceType;
    _startTokenRefreshTimer();
  }

  void _startTokenRefreshTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      print('Token refresh timer triggered at ${DateTime.now()}');
      await refreshToken();
    });
  }

  Future<void> refreshToken() async {
    if (userModel == null || deviceToken == null || deviceType == null) {
      print('Token refresh skipped: insufficient data.');
      return;
    }
    try {
      final response = await AuthApi().refreshToken(userModel!.accessToken,
          userModel!.refreshToken, deviceToken, deviceType);
      final jsonResponse = response;
      final status = jsonResponse['status'];
      if (status == 200) {
        final newAccessToken = jsonResponse['accessToken'];
        final newRefreshToken = jsonResponse['refreshToken'];
        _updateTokens(newAccessToken, newRefreshToken);
      }
    } on SocketException catch (e) {
      print('NetworkException: $e');
    } on Exception catch (e) {
      print('Failed to fetch data: $e');
    }
  }

  void _updateTokens(String newAccessToken, String newRefreshToken) {
    realm?.write(() {
      userModel!.accessToken = newAccessToken;
      userModel!.refreshToken = newRefreshToken;
    });
  }

  void dispose() {
    timer?.cancel();
    timer = null;
  }
}
