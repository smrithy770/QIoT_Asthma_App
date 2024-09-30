import 'dart:async';
import 'dart:io';
import 'package:asthmaapp/api/auth_api.dart';
import 'package:asthmaapp/main.dart';
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

  // Initialize method with boolean return
  void initialize(
      Realm realm, UserModel userModel, String deviceToken, String deviceType) {
    if (realm == null ||
        userModel == null ||
        deviceToken.isEmpty ||
        deviceType.isEmpty) {
      logger.d('Initialization failed: Insufficient data');
    }
    this.realm = realm;
    this.userModel = userModel;
    this.deviceToken = deviceToken;
    this.deviceType = deviceType;
    _startTokenRefreshTimer();
  }

  void _startTokenRefreshTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      logger.d('Token refresh timer triggered at ${DateTime.now()}');
      await refreshToken();
    });
  }

  Future<bool> refreshToken() async {
    if (userModel == null || deviceToken == null || deviceType == null) {
      logger.d('Token refresh skipped: insufficient data.');
      return false;
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
        return true; // Return true if token refresh is successful
      } else {
        logger.d('Token refresh failed: ${jsonResponse['message']}');
        return false;
      }
    } on SocketException catch (e) {
      logger.d('NetworkException: $e');
      return false;
    } on Exception catch (e) {
      logger.d('Failed to fetch data: $e');
      return false;
    }
  }

  void _updateTokens(String newAccessToken, String newRefreshToken) {
    realm?.write(() {
      userModel!.accessToken = newAccessToken;
      userModel!.refreshToken = newRefreshToken;
    });
  }

  // Dispose method with boolean return
  bool dispose() {
    if (timer == null) {
      logger.d('Dispose failed: Timer is not active.');
      return false; // Return false if there's no active timer to cancel
    }
    timer?.cancel();
    timer = null;
    logger.d('Timer disposed successfully.');
    return true; // Return true if the timer is successfully disposed
  }
}
