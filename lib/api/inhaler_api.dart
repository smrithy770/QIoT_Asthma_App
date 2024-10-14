import 'dart:convert';

import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';
import 'package:asthmaapp/utils/encryption_util.dart';

class InhalerApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addInhaler(
      String userId,
      String inhalerDeviceId,
      int dataIndex,
      int inhalerValue,
      Map<String, dynamic> location,
      int month,
      int year,
      DateTime? createdAt,
      [String? accessToken]) async {
        logger.d('User ID: $userId and Created At: $createdAt');
    final addInhalerUrl = ApiConstants.addInhalerUrl(userId);

    // Prepare the data to be encrypted
    final dataToSend = {
      'inhalerDeviceId': inhalerDeviceId,
      'dataIndex': dataIndex,
      'inhalerValue': inhalerValue,
      'location': location,
      'month': month,
      'year': year,
      'createdAt': createdAt?.toIso8601String(),
    };

    // Convert the data to a JSON string and encrypt it
    final jsonString = jsonEncode(dataToSend); // Convert map to JSON
    final encryptedData =
        EncryptionUtil.encryptAES(jsonString); // Encrypt the JSON string

    // Send the encrypted data in the request
    final response = await _apiService.post(addInhalerUrl, accessToken, {
      'data': encryptedData, // Sending the encrypted data under the 'data' key
    });
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

  Future<Map<String, dynamic>> getInhalerHistory(
      String userId, int month, int year,
      [String? accessToken]) async {
    final getInhalerHistoryUrl =
        ApiConstants.getInhalerHistoryUrl(userId, month, year);
    final response = await _apiService.get(getInhalerHistoryUrl, accessToken);

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
