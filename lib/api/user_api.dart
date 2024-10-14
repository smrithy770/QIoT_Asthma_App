import 'dart:convert';

import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';
import 'package:asthmaapp/utils/encryption_util.dart';

class UserApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> getHomepageData(String userId,
      [String? accessToken]) async {
    final homepageDataUrl = ApiConstants.getHomepageDataUrl(userId);

    // Make the API call to fetch the homepage data
    final response = await _apiService.get(homepageDataUrl, accessToken);
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

  Future<Map<String, dynamic>> getUserById(String userId,
      [String? accessToken]) async {
    final userByIdtUrl = ApiConstants.getUserByIdUrl(userId);
    final response = await _apiService.get(userByIdtUrl, accessToken);
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

  Future<Map<String, dynamic>> updateUserDataById(
      String userId, Map<String, String> data,
      [String? accessToken]) async {
    final updateUserDataByIdUrl = ApiConstants.updateUserDataByIdUrl(userId);
    logger.d('Data: $data');
    final jsonString = jsonEncode(data); // Convert map to JSON
    logger.d('jsonString: $jsonString');
    final encryptedData =
        EncryptionUtil.encryptAES(jsonString); // Encrypt the JSON string

    // Send the encrypted data in the request
    final response = await _apiService.put(
      updateUserDataByIdUrl,
      accessToken,
      {
        'data':
            encryptedData, // Sending the encrypted data under the 'data' key
      },
    );
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
}
