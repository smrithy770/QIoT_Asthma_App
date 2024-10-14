import 'dart:convert';

import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';
import 'package:asthmaapp/utils/encryption_util.dart';

class AuthApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> signin(String email, String password,
      String? accessToken, String? deviceToken, String? deviceType) async {
    final response = await _apiService.post(ApiConstants.signin, accessToken, {
      'email': email,
      'password': password,
      'deviceToken': deviceToken,
      'deviceType': deviceType,
    });
    // Assuming the encrypted data is in 'encryptedResponse' key
    if (response.containsKey('encryptedResponse')) {
      String encryptedData = response['encryptedResponse'];
      // Decrypt the data
      String decryptedData = EncryptionUtil.decryptAES(encryptedData);

      // Parse the decrypted JSON string into a Map
      return jsonDecode(decryptedData);
    }

    // Return the response directly if there's no encryption
    return response;
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
    final response =
        await _apiService.post(ApiConstants.signupUrl, accessToken, {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'dateTimeZone': dateTimeZone,
      'deviceToken': deviceToken,
      'deviceType': deviceType,
    });
    // Assuming the encrypted data is in 'encryptedResponse' key
    if (response.containsKey('encryptedResponse')) {
      String encryptedData = response['encryptedResponse'];
      // Decrypt the data
      String decryptedData = EncryptionUtil.decryptAES(encryptedData);

      // Parse the decrypted JSON string into a Map
      return jsonDecode(decryptedData);
    }

    // Return the response directly if there's no encryption
    return response;
  }

  Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    final dataToSend = {
      'email': email,
    };
    final jsonString = jsonEncode(dataToSend); // Convert map to JSON
    logger.d('jsonString: $jsonString');
    final encryptedData =
        EncryptionUtil.encryptAES(jsonString); // Encrypt the JSON string

    // Send the encrypted data in the request
    final response =
        await _apiService.post(ApiConstants.resendVerificationEmailUrl, null, {
      'data': encryptedData,
    });
    // Assuming the encrypted data is in 'encryptedResponse' key
    if (response.containsKey('encryptedResponse')) {
      String encryptedData = response['encryptedResponse'];
      // Decrypt the data
      String decryptedData = EncryptionUtil.decryptAES(encryptedData);

      // Parse the decrypted JSON string into a Map
      return jsonDecode(decryptedData);
    }

    // Return the response directly if there's no encryption
    return response;
  }

  Future<Map<String, dynamic>> checkVerification(String email) async {
    final dataToSend = {
      'email': email,
    };
    final jsonString = jsonEncode(dataToSend); // Convert map to JSON
    logger.d('jsonString: $jsonString');
    final encryptedData =
        EncryptionUtil.encryptAES(jsonString); // Encrypt the JSON string

    // Send the encrypted data in the request
    final response =
        await _apiService.post(ApiConstants.checkVerificationUrl, null, {
      'data': encryptedData,
    });
    // Assuming the encrypted data is in 'encryptedResponse' key
    if (response.containsKey('encryptedResponse')) {
      String encryptedData = response['encryptedResponse'];
      // Decrypt the data
      String decryptedData = EncryptionUtil.decryptAES(encryptedData);

      // Parse the decrypted JSON string into a Map
      return jsonDecode(decryptedData);
    }

    // Return the response directly if there's no encryption
    return response;
  }

  Future<Map<String, dynamic>> signout(String userId) async {
    final signoutUrl = ApiConstants.getSignoutUrl(userId);
    return _apiService.delete(signoutUrl, null);
  }
}
